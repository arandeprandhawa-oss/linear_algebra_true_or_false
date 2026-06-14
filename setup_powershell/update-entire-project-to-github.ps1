#requires -Version 5.1
<#
Beginner-friendly full-project GitHub updater.

Repository:
https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false

This tool:
- Finds the local GitHub repository automatically.
- Lets the user choose the repository folder if automatic detection fails.
- Downloads portable Git and GitHub CLI when needed.
- Uses the normal GitHub browser login.
- Shows every changed, deleted, renamed, and new file before uploading.
- Pulls the newest main branch safely.
- Runs git add -A, so every non-ignored repository change is included.
- Creates one commit and pushes it to main.
- Never force-pushes.

Important:
Files excluded by .gitignore are not uploaded.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepositoryOwner = 'arandeprandhawa-oss'
$RepositoryName = 'linear_algebra_true_or_false'
$RepositoryWebUrl = "https://github.com/$RepositoryOwner/$RepositoryName"
$RepositoryGitUrl = "$RepositoryWebUrl.git"
$ToolRootName = 'LAQuizTools'

function Initialize-Ui {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName Microsoft.VisualBasic
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function Write-Step {
    param([string]$Message)

    Write-Host ''
    Write-Host '====================================================================' -ForegroundColor DarkGray
    Write-Host $Message -ForegroundColor Cyan
    Write-Host '====================================================================' -ForegroundColor DarkGray
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Yellow
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor DarkYellow
}

function Show-Message {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Type = 'Information'
    )

    $icon = [System.Windows.Forms.MessageBoxIcon]::Information

    if ($Type -eq 'Warning') {
        $icon = [System.Windows.Forms.MessageBoxIcon]::Warning
    }
    elseif ($Type -eq 'Error') {
        $icon = [System.Windows.Forms.MessageBoxIcon]::Error
    }

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        $icon
    ) | Out-Null
}

function Ask-YesNo {
    param(
        [string]$Title,
        [string]$Message,
        [switch]$DefaultNo
    )

    $defaultButton = [System.Windows.Forms.MessageBoxDefaultButton]::Button1

    if ($DefaultNo) {
        $defaultButton = [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    }

    $result = [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question,
        $defaultButton
    )

    return $result -eq [System.Windows.Forms.DialogResult]::Yes
}

function Get-DownloadsFolder {
    $knownFolderId = '{374DE290-123F-4565-9164-39C4925E467B}'
    $registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

    try {
        $item = Get-ItemProperty `
            -Path $registryPath `
            -Name $knownFolderId `
            -ErrorAction Stop

        $downloads = [Environment]::ExpandEnvironmentVariables(
            $item.$knownFolderId
        )
    }
    catch {
        $profilePath = [Environment]::GetFolderPath('UserProfile')

        if ([string]::IsNullOrWhiteSpace($profilePath)) {
            $profilePath = $env:USERPROFILE
        }

        $downloads = Join-Path $profilePath 'Downloads'
    }

    if (-not (Test-Path -LiteralPath $downloads -PathType Container)) {
        New-Item -ItemType Directory -Path $downloads -Force | Out-Null
    }

    return $downloads
}

function Get-ToolRoot {
    $baseFolder = $env:LOCALAPPDATA

    if ([string]::IsNullOrWhiteSpace($baseFolder)) {
        $baseFolder = Join-Path `
            ([Environment]::GetFolderPath('UserProfile')) `
            'AppData\Local'
    }

    $toolRoot = Join-Path $baseFolder $ToolRootName
    New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null

    return $toolRoot
}

function Get-CommandPath {
    param([string[]]$Names)

    foreach ($name in $Names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue

        if ($null -ne $command) {
            return $command.Source
        }
    }

    return $null
}

function Invoke-Native {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [string]$FailureMessage,
        [switch]$AllowFailure,
        [switch]$Quiet
    )

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    try {
        if ($Quiet) {
            & $FilePath @Arguments *> $null
        }
        else {
            & $FilePath @Arguments
        }

        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }

    if ((-not $AllowFailure) -and $exitCode -ne 0) {
        throw "$FailureMessage Exit code: $exitCode"
    }

    return [int]$exitCode
}

function Invoke-NativeCapture {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [string]$FailureMessage,
        [switch]$AllowFailure
    )

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    try {
        $output = & $FilePath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }

    if ((-not $AllowFailure) -and $exitCode -ne 0) {
        throw "$FailureMessage Exit code: $exitCode"
    }

    return [pscustomobject]@{
        ExitCode = [int]$exitCode
        Text = (($output | ForEach-Object { "$_" }) -join [Environment]::NewLine).Trim()
    }
}

function Download-File {
    param(
        [string]$Url,
        [string]$OutFile
    )

    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $OutFile `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Full-Project-Updater' } `
        -UseBasicParsing
}

function Install-PortableGit {
    param([string]$ToolRoot)

    Write-Info 'Git was not found. Downloading portable Git...'

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Full-Project-Updater' }

    $asset = $release.assets |
        Where-Object { $_.name -match '^PortableGit-.*-64-bit\.7z\.exe$' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw 'Could not find the current 64-bit PortableGit download.'
    }

    $gitFolder = Join-Path $ToolRoot 'PortableGit'
    $installer = Join-Path $ToolRoot $asset.name

    if (Test-Path -LiteralPath $gitFolder) {
        Remove-Item -LiteralPath $gitFolder -Recurse -Force
    }

    New-Item -ItemType Directory -Path $gitFolder -Force | Out-Null
    Download-File -Url $asset.browser_download_url -OutFile $installer

    $process = Start-Process `
        -FilePath $installer `
        -ArgumentList @("-o`"$gitFolder`"", '-y') `
        -Wait `
        -PassThru

    if ($process.ExitCode -ne 0) {
        throw "PortableGit extraction failed with exit code $($process.ExitCode)."
    }

    Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue

    $gitExe = Join-Path $gitFolder 'cmd\git.exe'

    if (-not (Test-Path -LiteralPath $gitExe -PathType Leaf)) {
        throw 'PortableGit downloaded, but git.exe was not found.'
    }

    return $gitExe
}

function Install-PortableGitHubCli {
    param([string]$ToolRoot)

    Write-Info 'GitHub CLI was not found. Downloading portable GitHub CLI...'

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/cli/cli/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Full-Project-Updater' }

    $asset = $release.assets |
        Where-Object { $_.name -match '^gh_.*_windows_amd64\.zip$' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw 'Could not find the current 64-bit GitHub CLI download.'
    }

    $ghFolder = Join-Path $ToolRoot 'GitHubCLI'
    $zipFile = Join-Path $ToolRoot $asset.name

    if (Test-Path -LiteralPath $ghFolder) {
        Remove-Item -LiteralPath $ghFolder -Recurse -Force
    }

    New-Item -ItemType Directory -Path $ghFolder -Force | Out-Null
    Download-File -Url $asset.browser_download_url -OutFile $zipFile
    Expand-Archive -LiteralPath $zipFile -DestinationPath $ghFolder -Force
    Remove-Item -LiteralPath $zipFile -Force -ErrorAction SilentlyContinue

    $ghExe = Get-ChildItem `
        -LiteralPath $ghFolder `
        -Filter 'gh.exe' `
        -File `
        -Recurse |
        Select-Object -First 1 -ExpandProperty FullName

    if ([string]::IsNullOrWhiteSpace($ghExe)) {
        throw 'GitHub CLI downloaded, but gh.exe was not found.'
    }

    return $ghExe
}

function Ensure-Tools {
    $toolRoot = Get-ToolRoot
    $gitExe = Get-CommandPath -Names @('git.exe', 'git')

    if ([string]::IsNullOrWhiteSpace($gitExe)) {
        $portableGit = Join-Path $toolRoot 'PortableGit\cmd\git.exe'

        if (Test-Path -LiteralPath $portableGit -PathType Leaf) {
            $gitExe = $portableGit
        }
        else {
            $gitExe = Install-PortableGit -ToolRoot $toolRoot
        }
    }

    Write-Ok "Git ready: $gitExe"

    $ghExe = Get-CommandPath -Names @('gh.exe', 'gh')

    if ([string]::IsNullOrWhiteSpace($ghExe)) {
        $portableGh = Get-ChildItem `
            -LiteralPath (Join-Path $toolRoot 'GitHubCLI') `
            -Filter 'gh.exe' `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName

        if (-not [string]::IsNullOrWhiteSpace($portableGh)) {
            $ghExe = $portableGh
        }
        else {
            $ghExe = Install-PortableGitHubCli -ToolRoot $toolRoot
        }
    }

    Write-Ok "GitHub CLI ready: $ghExe"

    $env:PATH = "$(Split-Path -Parent $gitExe);$(Split-Path -Parent $ghExe);$env:PATH"

    return [pscustomobject]@{
        Git = $gitExe
        Gh = $ghExe
    }
}

function Ensure-GitHubLogin {
    param([string]$GhExe)

    $statusCode = Invoke-Native `
        -FilePath $GhExe `
        -Arguments @('auth', 'status', '--hostname', 'github.com') `
        -FailureMessage 'GitHub login check failed.' `
        -AllowFailure `
        -Quiet

    if ($statusCode -ne 0) {
        Show-Message `
            -Title 'GitHub login required' `
            -Message @"
PowerShell will display a one-time code and open GitHub in your browser.

Complete the login, then return to this window.
"@

        [void](Read-Host 'Press Enter to begin GitHub login')

        [void](Invoke-Native `
            -FilePath $GhExe `
            -Arguments @(
                'auth',
                'login',
                '--hostname', 'github.com',
                '--git-protocol', 'https',
                '--web'
            ) `
            -FailureMessage 'GitHub login was not completed.')
    }

    [void](Invoke-Native `
        -FilePath $GhExe `
        -Arguments @('auth', 'setup-git') `
        -FailureMessage 'GitHub authentication could not be connected to Git.')

    $userResult = Invoke-NativeCapture `
        -FilePath $GhExe `
        -Arguments @('api', 'user', '--jq', '.login') `
        -FailureMessage 'Could not read the signed-in GitHub username.'

    if ([string]::IsNullOrWhiteSpace($userResult.Text)) {
        throw 'GitHub returned an empty username.'
    }

    Write-Ok "Signed in as: $($userResult.Text)"
    return $userResult.Text
}

function Get-OriginUrl {
    param(
        [string]$GitExe,
        [string]$Folder
    )

    $result = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @('-C', $Folder, 'remote', 'get-url', 'origin') `
        -FailureMessage 'Could not inspect the Git remote.' `
        -AllowFailure

    if ($result.ExitCode -ne 0) {
        return $null
    }

    return $result.Text
}

function Test-ProjectContent {
    # True when a folder is clearly THIS project, judged purely by its files.
    # This lets the updater recognise a copy that was downloaded/extracted from
    # the ZIP and never turned into a connected Git repository yet.
    param([string]$Folder)

    if ([string]::IsNullOrWhiteSpace($Folder) -or
        (-not (Test-Path -LiteralPath $Folder -PathType Container))) {
        return $false
    }

    # Signature files that, together, uniquely identify this project.
    $signature = @(
        'index.html',
        'solo.html',
        (Join-Path 'etapes' 'registry.js')
    )

    foreach ($relative in $signature) {
        if (-not (Test-Path -LiteralPath (Join-Path $Folder $relative) -PathType Leaf)) {
            return $false
        }
    }

    return $true
}

function Test-ConnectedRepository {
    # True only when the folder is a Git repo whose origin points at our repo.
    param(
        [string]$GitExe,
        [string]$Folder
    )

    if ([string]::IsNullOrWhiteSpace($Folder) -or
        (-not (Test-Path -LiteralPath $Folder -PathType Container)) -or
        (-not (Test-Path -LiteralPath (Join-Path $Folder '.git') -PathType Container))) {
        return $false
    }

    $origin = Get-OriginUrl -GitExe $GitExe -Folder $Folder

    if ([string]::IsNullOrWhiteSpace($origin)) {
        return $false
    }

    return $origin -match (
        [regex]::Escape("$RepositoryOwner/$RepositoryName")
    )
}

function Test-TargetRepository {
    # A folder counts as "the project" if EITHER it is already a connected
    # Git repo for our remote, OR its files match this project's signature.
    # Content matching is what makes automatic detection reliable for copies
    # that came straight from the ZIP.
    param(
        [string]$GitExe,
        [string]$Folder
    )

    if (Test-ConnectedRepository -GitExe $GitExe -Folder $Folder) {
        return $true
    }

    return (Test-ProjectContent -Folder $Folder)
}

function Initialize-ConnectedRepository {
    # Make sure $Folder is a Git repo on branch main with origin set to our
    # remote. Safe to call on a folder that is already correctly connected -
    # in that case it changes nothing.
    param(
        [string]$GitExe,
        [string]$Folder
    )

    $gitFolderPresent = Test-Path -LiteralPath (Join-Path $Folder '.git') -PathType Container

    if (-not $gitFolderPresent) {
        Write-Info 'This copy is not a Git repository yet. Connecting it to GitHub now...'

        [void](Invoke-Native `
            -FilePath $GitExe `
            -Arguments @('-C', $Folder, 'init') `
            -FailureMessage 'Git could not initialise the repository.')
    }

    # Ensure a branch named main exists and is checked out.
    $branchResult = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @('-C', $Folder, 'branch', '--show-current') `
        -FailureMessage 'Git could not read the current branch.' `
        -AllowFailure

    $branch = $branchResult.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($branch)) {
        # Fresh repo with no commits yet - name the unborn branch main.
        [void](Invoke-Native `
            -FilePath $GitExe `
            -Arguments @('-C', $Folder, 'checkout', '-B', 'main') `
            -FailureMessage 'Git could not create the main branch.' `
            -AllowFailure `
            -Quiet)
    }
    elseif ($branch -ne 'main') {
        [void](Invoke-Native `
            -FilePath $GitExe `
            -Arguments @('-C', $Folder, 'branch', '-M', 'main') `
            -FailureMessage 'Git could not rename the branch to main.' `
            -AllowFailure `
            -Quiet)
    }

    # Ensure origin exists and points at our repository.
    $origin = Get-OriginUrl -GitExe $GitExe -Folder $Folder

    if ([string]::IsNullOrWhiteSpace($origin)) {
        [void](Invoke-Native `
            -FilePath $GitExe `
            -Arguments @('-C', $Folder, 'remote', 'add', 'origin', $RepositoryGitUrl) `
            -FailureMessage 'Git could not add the GitHub remote.')

        Write-Ok 'Connected this folder to GitHub.'
    }
    elseif ($origin -notmatch [regex]::Escape("$RepositoryOwner/$RepositoryName")) {
        # An origin exists but points somewhere else - repoint it to ours.
        [void](Invoke-Native `
            -FilePath $GitExe `
            -Arguments @('-C', $Folder, 'remote', 'set-url', 'origin', $RepositoryGitUrl) `
            -FailureMessage 'Git could not update the GitHub remote.')

        Write-Ok 'Updated the GitHub remote for this folder.'
    }
}

function Find-RepositoryFromPath {
    param(
        [string]$GitExe,
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $candidate = $Path

    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $candidate = Split-Path -Parent $candidate
    }

    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) {
        return $null
    }

    $directory = Get-Item -LiteralPath $candidate

    # 1) Walk upward from the starting folder through its parents.
    while ($null -ne $directory) {
        if (Test-TargetRepository -GitExe $GitExe -Folder $directory.FullName) {
            return $directory.FullName
        }

        $directory = $directory.Parent
    }

    # 2) Also look one level down: the project often sits in a subfolder of
    #    the starting path (for example Downloads\linear_algebra_true_or_false-main).
    $children = Get-ChildItem `
        -LiteralPath $candidate `
        -Directory `
        -ErrorAction SilentlyContinue |
        Sort-Object `
            @{ Expression = {
                if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 }
            } },
            @{ Expression = { $_.LastWriteTime }; Descending = $true }

    foreach ($child in $children) {
        if (Test-TargetRepository -GitExe $GitExe -Folder $child.FullName) {
            return $child.FullName
        }
    }

    return $null
}

function Get-SavedRepositoryPaths {
    $stateFolder = Get-ToolRoot
    $paths = @()

    foreach ($fileName in @(
        'last-firebase-project.txt',
        'last-javascript-project.txt',
        'last-local-project.txt'
    )) {
        $stateFile = Join-Path $stateFolder $fileName

        if (-not (Test-Path -LiteralPath $stateFile -PathType Leaf)) {
            continue
        }

        try {
            $saved = [System.IO.File]::ReadAllText($stateFile, [System.Text.Encoding]::UTF8).Trim()

            if (-not [string]::IsNullOrWhiteSpace($saved)) {
                $paths += $saved
            }
        }
        catch {
            # Ignore a damaged remembered-location file.
        }
    }

    return @($paths | Select-Object -Unique)
}

function Find-RepositoryAutomatically {
    param([string]$GitExe)

    $scriptFolder = $PSScriptRoot

    if ([string]::IsNullOrWhiteSpace($scriptFolder)) {
        $scriptFolder = (Get-Location).Path
    }

    # Prefer the project copy that contains this updater. This is important
    # when a repaired ZIP is opened while an older broken clone is remembered.
    $candidatePaths = @(
        $scriptFolder,
        (Get-Location).Path,
        (Get-SavedRepositoryPaths)
    )

    $downloads = Get-DownloadsFolder
    $profile = [Environment]::GetFolderPath('UserProfile')
    $documents = [Environment]::GetFolderPath('MyDocuments')
    $desktop = [Environment]::GetFolderPath('Desktop')

    $candidatePaths += @(
        (Join-Path $downloads $RepositoryName),
        (Join-Path $downloads "$RepositoryName-main"),
        (Join-Path $downloads "$RepositoryName-editor"),
        (Join-Path $downloads "$RepositoryName-fixed-installer-update"),
        (Join-Path $downloads 'Linear Algebra True or False'),
        (Join-Path $documents $RepositoryName),
        (Join-Path $documents "$RepositoryName-main"),
        (Join-Path $documents 'Linear Algebra True or False'),
        (Join-Path $desktop $RepositoryName),
        (Join-Path $desktop "$RepositoryName-main")
    )

    foreach ($candidate in $candidatePaths | Select-Object -Unique) {
        $found = Find-RepositoryFromPath -GitExe $GitExe -Path $candidate

        if (-not [string]::IsNullOrWhiteSpace($found)) {
            return $found
        }
    }

    $searchRoots = @(
        $downloads,
        $documents,
        $desktop,
        (Join-Path $profile 'OneDrive')
    ) | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_) -and
        (Test-Path -LiteralPath $_ -PathType Container)
    } | Select-Object -Unique

    $skipNames = @(
        '.git',
        'node_modules',
        'backups',
        'AppData',
        '$RECYCLE.BIN',
        'System Volume Information'
    )

    foreach ($root in $searchRoots) {
        $queue = New-Object System.Collections.Queue
        $queue.Enqueue([pscustomobject]@{
            Path = $root
            Depth = 0
        })

        $visited = 0

        while ($queue.Count -gt 0 -and $visited -lt 5000) {
            $entry = $queue.Dequeue()
            $visited++

            if (Test-TargetRepository -GitExe $GitExe -Folder $entry.Path) {
                return $entry.Path
            }

            if ($entry.Depth -ge 6) {
                continue
            }

            $children = Get-ChildItem `
                -LiteralPath $entry.Path `
                -Directory `
                -Force `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $skipNames -notcontains $_.Name -and
                    -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
                } |
                Sort-Object `
                    @{ Expression = {
                        if ($_.Name -match '(?i)linear.*algebra|true.*false') {
                            0
                        }
                        else {
                            1
                        }
                    } },
                    @{ Expression = { $_.LastWriteTime }; Descending = $true }

            foreach ($child in $children) {
                $queue.Enqueue([pscustomobject]@{
                    Path = $child.FullName
                    Depth = $entry.Depth + 1
                })
            }
        }
    }

    return $null
}

function Choose-RepositoryFolder {
    param(
        [string]$GitExe,
        [string]$InitialFolder
    )

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose the Linear Algebra project folder (the one containing index.html)'
    $dialog.ShowNewFolderButton = $false

    if (-not [string]::IsNullOrWhiteSpace($InitialFolder) -and
        (Test-Path -LiteralPath $InitialFolder -PathType Container)) {
        $dialog.SelectedPath = $InitialFolder
    }

    $result = $dialog.ShowDialog()
    $selected = $null

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selected = $dialog.SelectedPath
    }

    $dialog.Dispose()

    if ([string]::IsNullOrWhiteSpace($selected)) {
        return $null
    }

    $repository = Find-RepositoryFromPath -GitExe $GitExe -Path $selected

    if ([string]::IsNullOrWhiteSpace($repository)) {
        $folderWarningMessage = @"
That folder does not look like the Linear Algebra project.

Choose the folder that contains index.html and the etapes folder
(it is usually named linear_algebra_true_or_false or
linear_algebra_true_or_false-main).
"@

        Show-Message `
            -Title 'That is not the GitHub repository' `
            -Message $folderWarningMessage `
            -Type 'Warning'

        return $null
    }

    return $repository
}

function Get-ChangedFiles {
    param(
        [string]$GitExe,
        [string]$RepositoryFolder
    )

    $status = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'status',
            '--short',
            '--untracked-files=all'
        ) `
        -FailureMessage 'Git could not inspect the project changes.'

    if ([string]::IsNullOrWhiteSpace($status.Text)) {
        return @()
    }

    return @(
        $status.Text -split '\r?\n' |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
}

function Get-ChangedPathFromStatusLine {
    param([string]$StatusLine)

    if ([string]::IsNullOrWhiteSpace($StatusLine)) {
        return ''
    }

    $pathPart = $StatusLine

    if ($pathPart.Length -ge 4) {
        $pathPart = $pathPart.Substring(3)
    }

    if ($pathPart -match ' -> ') {
        $pathPart = ($pathPart -split ' -> ')[-1]
    }

    return $pathPart.Trim('"', ' ')
}

function Get-SensitiveChangedFiles {
    param([string[]]$StatusLines)

    $suspicious = @()

    foreach ($line in $StatusLines) {
        $path = Get-ChangedPathFromStatusLine -StatusLine $line

        if ($path -match '(?i)(^|[\\/])\.env($|\.)' -or
            $path -match '(?i)service[-_ ]?account' -or
            $path -match '(?i)firebase-adminsdk' -or
            $path -match '(?i)(credentials|secrets?)\.(json|ya?ml|txt)$' -or
            $path -match '(?i)\.(pem|p12|pfx|key)$' -or
            $path -match '(?i)(^|[\\/])id_rsa(\.pub)?$') {
            $suspicious += $line
        }
    }

    return @($suspicious)
}

function Show-ReviewDialog {
    param(
        [string]$RepositoryFolder,
        [string[]]$StatusLines,
        [string]$DefaultCommitMessage
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Review all changes before updating GitHub'
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size(900, 650)
    $form.MinimumSize = New-Object System.Drawing.Size(760, 540)
    $form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
    $form.ShowIcon = $false

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = [System.Windows.Forms.DockStyle]::Top
    $header.Height = 112
    $header.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $form.Controls.Add($header)

    $accent = New-Object System.Windows.Forms.Panel
    $accent.Dock = [System.Windows.Forms.DockStyle]::Left
    $accent.Width = 8
    $accent.BackColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
    $header.Controls.Add($accent)

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'Update the entire project to GitHub'
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(31, 20)
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 18)
    $title.ForeColor = [System.Drawing.Color]::White
    $header.Controls.Add($title)

    $subtitle = New-Object System.Windows.Forms.Label
    $subtitle.Text = 'Review every file below. All non-ignored changes will be committed and pushed to main.'
    $subtitle.AutoSize = $true
    $subtitle.Location = New-Object System.Drawing.Point(34, 68)
    $subtitle.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $header.Controls.Add($subtitle)

    $repositoryLabel = New-Object System.Windows.Forms.Label
    $repositoryLabel.Text = 'Repository folder'
    $repositoryLabel.AutoSize = $true
    $repositoryLabel.Location = New-Object System.Drawing.Point(28, 132)
    $repositoryLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)
    $form.Controls.Add($repositoryLabel)

    $repositoryBox = New-Object System.Windows.Forms.TextBox
    $repositoryBox.ReadOnly = $true
    $repositoryBox.Text = $RepositoryFolder
    $repositoryBox.Location = New-Object System.Drawing.Point(28, 157)
    $repositoryBox.Size = New-Object System.Drawing.Size(824, 30)
    $repositoryBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor
        [System.Windows.Forms.AnchorStyles]::Left -bor
        [System.Windows.Forms.AnchorStyles]::Right
    $form.Controls.Add($repositoryBox)

    $changesLabel = New-Object System.Windows.Forms.Label
    $changesLabel.Text = "Files that will be updated ($($StatusLines.Count))"
    $changesLabel.AutoSize = $true
    $changesLabel.Location = New-Object System.Drawing.Point(28, 205)
    $changesLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)
    $form.Controls.Add($changesLabel)

    $changesBox = New-Object System.Windows.Forms.TextBox
    $changesBox.Multiline = $true
    $changesBox.ReadOnly = $true
    $changesBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
    $changesBox.WordWrap = $false
    $changesBox.Font = New-Object System.Drawing.Font('Consolas', 9.5)
    $changesBox.Text = $StatusLines -join [Environment]::NewLine
    $changesBox.Location = New-Object System.Drawing.Point(28, 232)
    $changesBox.Size = New-Object System.Drawing.Size(824, 235)
    $changesBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor
        [System.Windows.Forms.AnchorStyles]::Bottom -bor
        [System.Windows.Forms.AnchorStyles]::Left -bor
        [System.Windows.Forms.AnchorStyles]::Right
    $form.Controls.Add($changesBox)

    $commitLabel = New-Object System.Windows.Forms.Label
    $commitLabel.Text = 'Commit message'
    $commitLabel.AutoSize = $true
    $commitLabel.Location = New-Object System.Drawing.Point(28, 486)
    $commitLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor
        [System.Windows.Forms.AnchorStyles]::Left
    $commitLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)
    $form.Controls.Add($commitLabel)

    $commitBox = New-Object System.Windows.Forms.TextBox
    $commitBox.Text = $DefaultCommitMessage
    $commitBox.Location = New-Object System.Drawing.Point(28, 511)
    $commitBox.Size = New-Object System.Drawing.Size(824, 30)
    $commitBox.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor
        [System.Windows.Forms.AnchorStyles]::Left -bor
        [System.Windows.Forms.AnchorStyles]::Right
    $form.Controls.Add($commitBox)

    $confirmCheck = New-Object System.Windows.Forms.CheckBox
    $confirmCheck.Text = 'I reviewed the list and want to upload all of these changes.'
    $confirmCheck.AutoSize = $true
    $confirmCheck.Location = New-Object System.Drawing.Point(28, 560)
    $confirmCheck.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor
        [System.Windows.Forms.AnchorStyles]::Left
    $form.Controls.Add($confirmCheck)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = 'Cancel'
    $cancelButton.Size = New-Object System.Drawing.Size(120, 40)
    $cancelButton.Location = New-Object System.Drawing.Point(596, 552)
    $cancelButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor
        [System.Windows.Forms.AnchorStyles]::Right
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($cancelButton)

    $updateButton = New-Object System.Windows.Forms.Button
    $updateButton.Text = 'Update GitHub'
    $updateButton.Size = New-Object System.Drawing.Size(136, 40)
    $updateButton.Location = New-Object System.Drawing.Point(724, 552)
    $updateButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor
        [System.Windows.Forms.AnchorStyles]::Right
    $updateButton.BackColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
    $updateButton.ForeColor = [System.Drawing.Color]::White
    $updateButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $updateButton.Enabled = $false
    $updateButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($updateButton)

    $confirmCheck.Add_CheckedChanged({
        $updateButton.Enabled =
            $confirmCheck.Checked -and
            (-not [string]::IsNullOrWhiteSpace($commitBox.Text))
    })

    $commitBox.Add_TextChanged({
        $updateButton.Enabled =
            $confirmCheck.Checked -and
            (-not [string]::IsNullOrWhiteSpace($commitBox.Text))
    })

    $form.AcceptButton = $updateButton
    $form.CancelButton = $cancelButton

    $result = $form.ShowDialog()
    $commitMessage = $commitBox.Text.Trim()
    $form.Dispose()

    return [pscustomobject]@{
        Approved = ($result -eq [System.Windows.Forms.DialogResult]::OK)
        CommitMessage = $commitMessage
    }
}

try {
    Initialize-Ui
    Clear-Host

    Write-Host 'LINEAR ALGEBRA QUIZ - UPDATE ENTIRE PROJECT TO GITHUB' -ForegroundColor Magenta
    Write-Host 'VERSION 2 - AUTO-DETECT + AUTO-CONNECT REPO' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host "Repository: $RepositoryWebUrl" -ForegroundColor White

    Write-Step 'STEP 1 OF 6 - Preparing Git and GitHub tools'
    $tools = Ensure-Tools

    Write-Step 'STEP 2 OF 6 - Finding the local GitHub repository'
    $repositoryFolder = Find-RepositoryAutomatically -GitExe $tools.Git

    if ([string]::IsNullOrWhiteSpace($repositoryFolder)) {
        Show-Message `
            -Title 'Choose the GitHub repository folder' `
            -Message @"
The repository was not found automatically.

Choose the local folder connected to:
$RepositoryWebUrl
"@

        $repositoryFolder = Choose-RepositoryFolder `
            -GitExe $tools.Git `
            -InitialFolder (Get-DownloadsFolder)
    }

    if ([string]::IsNullOrWhiteSpace($repositoryFolder)) {
        throw 'No GitHub repository folder was selected.'
    }

    Write-Ok "Repository found: $repositoryFolder"

    # Make sure the folder is actually a Git repo on main with our remote.
    # If it came from the ZIP and was never connected, this wires it up now
    # so the rest of the update can proceed automatically.
    Initialize-ConnectedRepository -GitExe $tools.Git -Folder $repositoryFolder

    Write-Step 'STEP 3 OF 6 - Signing in and checking the branch'
    $githubUser = Ensure-GitHubLogin -GhExe $tools.Gh

    $repoCheck = Invoke-Native `
        -FilePath $tools.Gh `
        -Arguments @('repo', 'view', "$RepositoryOwner/$RepositoryName") `
        -FailureMessage 'GitHub could not access the repository.' `
        -AllowFailure `
        -Quiet

    if ($repoCheck -ne 0) {
        throw "GitHub could not access $RepositoryOwner/$RepositoryName using account $githubUser."
    }

    $branchResult = Invoke-NativeCapture `
        -FilePath $tools.Git `
        -Arguments @('-C', $repositoryFolder, 'branch', '--show-current') `
        -FailureMessage 'Git could not determine the current branch.'

    $currentBranch = $branchResult.Text.Trim()

    if ($currentBranch -ne 'main') {
        Write-Info "The current branch is '$currentBranch'. Switching to main..."

        [void](Invoke-Native `
            -FilePath $tools.Git `
            -Arguments @('-C', $repositoryFolder, 'checkout', 'main') `
            -FailureMessage 'Git could not switch to the main branch. Commit or move conflicting changes first.')
    }

    Write-Ok 'The main branch is ready.'

    Write-Step 'STEP 4 OF 6 - Reviewing every local change'
    $changedFiles = @(Get-ChangedFiles `
        -GitExe $tools.Git `
        -RepositoryFolder $repositoryFolder)

    if ($changedFiles.Count -eq 0) {
        Show-Message `
            -Title 'Nothing to update' `
            -Message 'The repository has no changed, deleted, renamed, or new files.'

        Write-Info 'Nothing changed. GitHub is already up to date.'
        [void](Read-Host 'Press Enter to close')
        exit 0
    }

    Write-Host ''
    Write-Host "Git found $($changedFiles.Count) changed file(s):" -ForegroundColor White

    foreach ($line in $changedFiles) {
        Write-Host "  $line"
    }

    $sensitiveFiles = @(Get-SensitiveChangedFiles -StatusLines $changedFiles)

    if ($sensitiveFiles.Count -gt 0) {
        $sensitiveText = $sensitiveFiles -join [Environment]::NewLine

        $sensitiveWarningMessage = @"
These changed files may contain secrets or private keys:

$sensitiveText

Do not upload passwords, service-account keys, .env files, or private certificates.

Continue only if you have checked these files carefully.
"@

        $continueSensitive = Ask-YesNo `
            -Title 'Possible private files detected' `
            -Message $sensitiveWarningMessage `
            -DefaultNo

        if (-not $continueSensitive) {
            throw 'The update was cancelled because possible private files were detected.'
        }
    }

    $review = Show-ReviewDialog `
        -RepositoryFolder $repositoryFolder `
        -StatusLines $changedFiles `
        -DefaultCommitMessage 'Update entire Linear Algebra quiz project'

    if (-not $review.Approved) {
        Write-Info 'Cancelled. Nothing was committed or pushed.'
        [void](Read-Host 'Press Enter to close')
        exit 0
    }

    Write-Step 'STEP 5 OF 6 - Synchronizing and creating the commit'

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $repositoryFolder,
            'config',
            'user.name',
            $githubUser
        ) `
        -FailureMessage 'Git could not set the commit username.')

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $repositoryFolder,
            'config',
            'user.email',
            "$githubUser@users.noreply.github.com"
        ) `
        -FailureMessage 'Git could not set the commit email.')

    # Does the local repo have any commits yet? A copy that came straight from
    # the ZIP and was just connected will not.
    $headCheck = Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @('-C', $repositoryFolder, 'rev-parse', '--verify', 'HEAD') `
        -FailureMessage 'Git could not check the local history.' `
        -AllowFailure `
        -Quiet

    $hasLocalCommits = ($headCheck -eq 0)

    if ($hasLocalCommits) {
        # Normal case: bring in the newest GitHub commits, keeping local edits.
        [void](Invoke-Native `
            -FilePath $tools.Git `
            -Arguments @(
                '-C', $repositoryFolder,
                'pull',
                '--rebase',
                '--autostash',
                'origin',
                'main'
            ) `
            -FailureMessage 'Git could not safely combine the newest GitHub changes with the local project.')
    }
    else {
        # Freshly connected copy with no commits. Fetch the existing GitHub
        # history and adopt it as the starting point, WITHOUT touching the
        # working files - so the local edits become changes on top of main.
        Write-Info 'First-time connection: fetching the existing GitHub history...'

        [void](Invoke-Native `
            -FilePath $tools.Git `
            -Arguments @('-C', $repositoryFolder, 'fetch', 'origin', 'main') `
            -FailureMessage 'Git could not download the existing GitHub history.')

        # Point the branch at origin/main while keeping all working-tree files
        # exactly as they are (mixed reset = move HEAD, leave files untouched).
        [void](Invoke-Native `
            -FilePath $tools.Git `
            -Arguments @('-C', $repositoryFolder, 'reset', '--mixed', 'origin/main') `
            -FailureMessage 'Git could not align the local branch with GitHub.')

        # Make sure the branch is named main and tracks origin/main.
        [void](Invoke-Native `
            -FilePath $tools.Git `
            -Arguments @('-C', $repositoryFolder, 'branch', '-M', 'main') `
            -FailureMessage 'Git could not set the branch name to main.' `
            -AllowFailure `
            -Quiet)

        [void](Invoke-Native `
            -FilePath $tools.Git `
            -Arguments @('-C', $repositoryFolder, 'branch', '--set-upstream-to', 'origin/main', 'main') `
            -FailureMessage 'Git could not set the upstream branch.' `
            -AllowFailure `
            -Quiet)
    }

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $repositoryFolder,
            'add',
            '-A'
        ) `
        -FailureMessage 'Git could not stage all project changes.')

    $stagedCode = Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $repositoryFolder,
            'diff',
            '--cached',
            '--quiet'
        ) `
        -FailureMessage 'Git could not inspect the staged changes.' `
        -AllowFailure `
        -Quiet

    if ($stagedCode -eq 0) {
        Show-Message `
            -Title 'Nothing remained to commit' `
            -Message 'After synchronizing with GitHub, no new changes remained.'

        [void](Read-Host 'Press Enter to close')
        exit 0
    }

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $repositoryFolder,
            'commit',
            '-m',
            $review.CommitMessage
        ) `
        -FailureMessage 'Git could not create the full-project commit.')

    Write-Ok 'All non-ignored project changes were committed.'

    Write-Step 'STEP 6 OF 6 - Pushing everything to GitHub'

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $repositoryFolder,
            'push',
            'origin',
            'main'
        ) `
        -FailureMessage 'GitHub rejected the push.')

    $commitResult = Invoke-NativeCapture `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $repositoryFolder,
            'rev-parse',
            '--short',
            'HEAD'
        ) `
        -FailureMessage 'Git could not read the new commit identifier.' `
        -AllowFailure

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Write-Host "Repository: $RepositoryWebUrl" -ForegroundColor Cyan
    Write-Host "Local folder: $repositoryFolder" -ForegroundColor Cyan

    if (-not [string]::IsNullOrWhiteSpace($commitResult.Text)) {
        Write-Host "Commit: $($commitResult.Text)" -ForegroundColor Cyan
    }

    Write-Host ''
    Write-Host 'Every non-ignored repository change was pushed to main.' -ForegroundColor Green
    Write-Host 'No force push was used.' -ForegroundColor Yellow

    Show-Message `
        -Title 'Entire project updated' `
        -Message @"
All reviewed, non-ignored changes were committed and pushed to GitHub.

Repository:
$RepositoryWebUrl

No force push was used.
"@

    Start-Process -FilePath $RepositoryWebUrl -ErrorAction SilentlyContinue
}
catch {
    $message = $_.Exception.Message

    Write-Host ''
    Write-Host 'FULL PROJECT UPDATE STOPPED' -ForegroundColor Red
    Write-Host $message -ForegroundColor Red
    Write-Host ''
    Write-Host 'No force push was used.' -ForegroundColor Yellow

    try {
        Show-Message `
            -Title 'Full project update stopped' `
            -Message $message `
            -Type 'Error'
    }
    catch {
        # Keep the console error visible if Windows dialogs are unavailable.
    }

    [void](Read-Host 'Press Enter to close')
    exit 1
}

[void](Read-Host 'Press Enter to close')
