#requires -Version 5.1
<#
Double-click helper for editing flashcard files and publishing the change to GitHub.

Repository:
https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false

Use "Edit Flashcards and Publish.cmd" to launch this file.

What it does:
- Finds the current Windows user's Downloads folder.
- Downloads portable Git and GitHub CLI when missing.
- Opens the official GitHub browser login when needed.
- Downloads or reuses a local copy of the repository.
- Lets the user choose an HTML, JavaScript, or JSON flashcard file.
- Creates a timestamped backup.
- Opens the selected file in Notepad.
- Checks whether the file changed.
- Asks before committing and pushing the selected file to GitHub.
- Never force-pushes.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepositoryOwner = 'arandeprandhawa-oss'
$RepositoryName = 'linear_algebra_true_or_false'
$RepositoryWebUrl = "https://github.com/$RepositoryOwner/$RepositoryName"
$RepositoryGitUrl = "$RepositoryWebUrl.git"
$ToolRootName = 'LAQuizTools'

function Initialize-WindowsUi {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName Microsoft.VisualBasic
    [System.Windows.Forms.Application]::EnableVisualStyles()
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
        [string]$Message
    )

    $result = [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button1
    )

    return $result -eq [System.Windows.Forms.DialogResult]::Yes
}

function Ask-OkCancel {
    param(
        [string]$Title,
        [string]$Message
    )

    $result = [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Information,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button1
    )

    return $result -eq [System.Windows.Forms.DialogResult]::OK
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
        $baseFolder = Join-Path (
            [Environment]::GetFolderPath('UserProfile')
        ) 'AppData\Local'
    }

    $toolRoot = Join-Path $baseFolder $ToolRootName
    New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null
    return $toolRoot
}

function Invoke-WebDownload {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$OutFile
    )

    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $OutFile `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Flashcard-Editor' } `
        -UseBasicParsing
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

function Invoke-NativeCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$FailureMessage = 'A command failed.',
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
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$FailureMessage = 'A command failed.',
        [switch]$AllowFailure
    )

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    try {
        $outputLines = & $FilePath @Arguments 2>&1
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
        Text = (($outputLines | ForEach-Object { "$_" }) -join [Environment]::NewLine).Trim()
    }
}

function Install-PortableGit {
    param([string]$ToolsFolder)

    Write-Info 'Git was not found. Downloading portable Git for Windows...'

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Flashcard-Editor' }

    $asset = $release.assets |
        Where-Object { $_.name -match '^PortableGit-.*-64-bit\.7z\.exe$' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw 'Could not find the current 64-bit PortableGit download.'
    }

    $gitFolder = Join-Path $ToolsFolder 'PortableGit'
    $installer = Join-Path $ToolsFolder $asset.name

    if (Test-Path -LiteralPath $gitFolder) {
        Remove-Item -LiteralPath $gitFolder -Recurse -Force
    }

    New-Item -ItemType Directory -Path $gitFolder -Force | Out-Null
    Invoke-WebDownload -Url $asset.browser_download_url -OutFile $installer

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

    if (-not (Test-Path -LiteralPath $gitExe)) {
        throw 'PortableGit downloaded, but git.exe could not be found.'
    }

    return $gitExe
}

function Install-PortableGitHubCli {
    param([string]$ToolsFolder)

    Write-Info 'GitHub CLI was not found. Downloading portable GitHub CLI...'

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/cli/cli/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Flashcard-Editor' }

    $asset = $release.assets |
        Where-Object { $_.name -match '^gh_.*_windows_amd64\.zip$' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw 'Could not find the current 64-bit GitHub CLI download.'
    }

    $ghFolder = Join-Path $ToolsFolder 'GitHubCLI'
    $zipFile = Join-Path $ToolsFolder $asset.name

    if (Test-Path -LiteralPath $ghFolder) {
        Remove-Item -LiteralPath $ghFolder -Recurse -Force
    }

    New-Item -ItemType Directory -Path $ghFolder -Force | Out-Null
    Invoke-WebDownload -Url $asset.browser_download_url -OutFile $zipFile
    Expand-Archive -LiteralPath $zipFile -DestinationPath $ghFolder -Force
    Remove-Item -LiteralPath $zipFile -Force -ErrorAction SilentlyContinue

    $ghExe = Get-ChildItem `
        -LiteralPath $ghFolder `
        -Filter 'gh.exe' `
        -File `
        -Recurse |
        Select-Object -First 1 -ExpandProperty FullName

    if ([string]::IsNullOrWhiteSpace($ghExe)) {
        throw 'GitHub CLI downloaded, but gh.exe could not be found.'
    }

    return $ghExe
}

function Ensure-GitAndGitHubCli {
    param([string]$ToolsFolder)

    $gitExe = Get-CommandPath -Names @('git.exe', 'git')

    if ([string]::IsNullOrWhiteSpace($gitExe)) {
        $portableGit = Join-Path $ToolsFolder 'PortableGit\cmd\git.exe'

        if (Test-Path -LiteralPath $portableGit) {
            $gitExe = $portableGit
        }
        else {
            $gitExe = Install-PortableGit -ToolsFolder $ToolsFolder
        }
    }

    Write-Ok "Git ready: $gitExe"

    $ghExe = Get-CommandPath -Names @('gh.exe', 'gh')

    if ([string]::IsNullOrWhiteSpace($ghExe)) {
        $portableGh = Get-ChildItem `
            -LiteralPath (Join-Path $ToolsFolder 'GitHubCLI') `
            -Filter 'gh.exe' `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName

        if (-not [string]::IsNullOrWhiteSpace($portableGh)) {
            $ghExe = $portableGh
        }
        else {
            $ghExe = Install-PortableGitHubCli -ToolsFolder $ToolsFolder
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

    $statusCode = Invoke-NativeCommand `
        -FilePath $GhExe `
        -Arguments @('auth', 'status', '--hostname', 'github.com') `
        -AllowFailure `
        -Quiet

    if ($statusCode -ne 0) {
        Show-Message `
            -Title 'GitHub login required' `
            -Message 'PowerShell will show a one-time code and open GitHub in your browser. Complete the login, then return to PowerShell.'

        [void](Read-Host 'Press Enter to begin GitHub login')

        [void](Invoke-NativeCommand `
            -FilePath $GhExe `
            -Arguments @(
                'auth',
                'login',
                '--hostname', 'github.com',
                '--git-protocol', 'https',
                '--web'
            ) `
            -FailureMessage 'GitHub sign-in was not completed.')
    }

    [void](Invoke-NativeCommand `
        -FilePath $GhExe `
        -Arguments @('auth', 'setup-git') `
        -FailureMessage 'GitHub authentication could not be connected to Git.')

    $userResult = Invoke-NativeCapture `
        -FilePath $GhExe `
        -Arguments @('api', 'user', '--jq', '.login') `
        -FailureMessage 'Could not read the signed-in GitHub username.'

    $username = $userResult.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($username)) {
        throw 'GitHub returned an empty username.'
    }

    Write-Ok "Signed in to GitHub as: $username"
    return $username
}

function Test-RepositoryAccess {
    param(
        [string]$GhExe,
        [string]$Username
    )

    $checkCode = Invoke-NativeCommand `
        -FilePath $GhExe `
        -Arguments @('repo', 'view', "$RepositoryOwner/$RepositoryName") `
        -AllowFailure `
        -Quiet

    if ($checkCode -ne 0) {
        throw "GitHub could not access $RepositoryOwner/$RepositoryName using account $Username."
    }

    if ($Username -ne $RepositoryOwner) {
        Write-Warn "Signed in as $Username. The update works only if this account has write access."
    }

    Write-Ok "Repository access confirmed: $RepositoryWebUrl"
}

function Test-CorrectRepository {
    param(
        [string]$GitExe,
        [string]$Folder
    )

    if (-not (Test-Path -LiteralPath (Join-Path $Folder '.git'))) {
        return $false
    }

    $remoteResult = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @('-C', $Folder, 'remote', 'get-url', 'origin') `
        -AllowFailure

    if ($remoteResult.ExitCode -ne 0) {
        return $false
    }

    return $remoteResult.Text -match (
        [regex]::Escape("$RepositoryOwner/$RepositoryName")
    )
}

function Get-OrCloneRepository {
    param(
        [string]$GitExe,
        [string]$DownloadsFolder
    )

    $candidateFolders = @()

    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $scriptFolder = Get-Item -LiteralPath $PSScriptRoot

        if ($scriptFolder.Name -ieq 'setup_powershell' -and
            $null -ne $scriptFolder.Parent) {
            $candidateFolders += $scriptFolder.Parent.FullName
        }

        $candidateFolders += $scriptFolder.FullName
    }

    $candidateFolders += @(
        (Join-Path $DownloadsFolder $RepositoryName),
        (Join-Path $DownloadsFolder "$RepositoryName-editor"),
        (Join-Path $DownloadsFolder "$RepositoryName-toolkit-update")
    )

    foreach ($candidate in $candidateFolders | Select-Object -Unique) {
        if (Test-CorrectRepository -GitExe $GitExe -Folder $candidate) {
            Write-Ok "Using local repository: $candidate"
            return $candidate
        }
    }

    $editorFolder = Join-Path $DownloadsFolder "$RepositoryName-editor"

    if (Test-Path -LiteralPath $editorFolder) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backupFolder = "$editorFolder-backup-$timestamp"
        Move-Item -LiteralPath $editorFolder -Destination $backupFolder
        Write-Info "Existing non-repository folder was backed up to: $backupFolder"
    }

    Write-Info 'Downloading a fresh editing copy of the repository...'

    [void](Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            'clone',
            '--branch', 'main',
            '--single-branch',
            $RepositoryGitUrl,
            $editorFolder
        ) `
        -FailureMessage 'The GitHub repository could not be downloaded.')

    Write-Ok "Repository downloaded to: $editorFolder"
    return $editorFolder
}

function Sync-RepositoryBeforeEditing {
    param(
        [string]$GitExe,
        [string]$RepositoryFolder
    )

    $status = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @('-C', $RepositoryFolder, 'status', '--porcelain') `
        -AllowFailure

    if ($status.ExitCode -ne 0) {
        throw 'Git could not inspect the local repository.'
    }

    if (-not [string]::IsNullOrWhiteSpace($status.Text)) {
        Write-Warn 'The local repository already contains uncommitted changes.'
        Write-Warn 'The script will preserve them and will not pull over them automatically.'
        return
    }

    $pullCode = Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @('-C', $RepositoryFolder, 'pull', '--rebase', 'origin', 'main') `
        -AllowFailure

    if ($pullCode -ne 0) {
        Write-Warn 'The latest GitHub changes could not be pulled automatically. Editing can still continue.'
    }
    else {
        Write-Ok 'Local editing copy is up to date.'
    }
}

function Select-FlashcardFile {
    param([string]$RepositoryFolder)

    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Choose the flashcard file to edit'
    $dialog.InitialDirectory = $RepositoryFolder
    $dialog.Filter = (
        'Flashcard files (*.html;*.js;*.json)|*.html;*.js;*.json|' +
        'HTML files (*.html)|*.html|' +
        'JavaScript files (*.js)|*.js|' +
        'JSON files (*.json)|*.json|' +
        'All files (*.*)|*.*'
    )
    $dialog.Multiselect = $false
    $dialog.CheckFileExists = $true
    $dialog.RestoreDirectory = $true
    $dialog.FileName = 'solo.html'

    $result = $dialog.ShowDialog()
    $selectedFile = $null

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedFile = $dialog.FileName
    }

    $dialog.Dispose()

    if ([string]::IsNullOrWhiteSpace($selectedFile)) {
        return $null
    }

    $repoFull = [System.IO.Path]::GetFullPath($RepositoryFolder).TrimEnd('\') + '\'
    $fileFull = [System.IO.Path]::GetFullPath($selectedFile)

    if (-not $fileFull.StartsWith(
        $repoFull,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        Show-Message `
            -Title 'Choose a repository file' `
            -Message 'The selected file must be inside the local repository folder.' `
            -Type 'Warning'

        return $null
    }

    if ($fileFull -match '[\\/]\.git[\\/]') {
        Show-Message `
            -Title 'Protected Git folder' `
            -Message 'Files inside the hidden .git folder cannot be edited with this tool.' `
            -Type 'Warning'

        return $null
    }

    return $fileFull
}

function Get-RelativePathSafe {
    param(
        [string]$BasePath,
        [string]$FullPath
    )

    $baseUri = New-Object System.Uri(($BasePath.TrimEnd('\') + '\'))
    $fileUri = New-Object System.Uri($FullPath)
    $relative = $baseUri.MakeRelativeUri($fileUri).ToString()

    return [System.Uri]::UnescapeDataString($relative).Replace('/', '\')
}

function Create-Backup {
    param(
        [string]$RepositoryFolder,
        [string]$SelectedFile
    )

    $relativePath = Get-RelativePathSafe `
        -BasePath $RepositoryFolder `
        -FullPath $SelectedFile

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupFile = Join-Path `
        (Join-Path $RepositoryFolder "backups\flashcard-editor\$timestamp") `
        $relativePath

    $backupDirectory = Split-Path -Parent $backupFile
    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    Copy-Item -LiteralPath $SelectedFile -Destination $backupFile -Force

    return $backupFile
}

function Get-GitHubFileUrl {
    param([string]$RelativePath)

    $parts = $RelativePath.Replace('\', '/').Split('/')
    $encodedParts = @()

    foreach ($part in $parts) {
        $encodedParts += [System.Uri]::EscapeDataString($part)
    }

    return "$RepositoryWebUrl/blob/main/$($encodedParts -join '/')"
}

function Publish-SelectedFile {
    param(
        [string]$GitExe,
        [string]$RepositoryFolder,
        [string]$SelectedFile,
        [string]$GitHubUsername
    )

    $relativePath = Get-RelativePathSafe `
        -BasePath $RepositoryFolder `
        -FullPath $SelectedFile

    $diffCode = Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'diff',
            '--quiet',
            '--',
            $relativePath
        ) `
        -AllowFailure `
        -Quiet

    $untrackedResult = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'status',
            '--porcelain',
            '--',
            $relativePath
        ) `
        -AllowFailure

    if ($diffCode -eq 0 -and
        [string]::IsNullOrWhiteSpace($untrackedResult.Text)) {
        Show-Message `
            -Title 'No changes found' `
            -Message 'The selected file was not changed, so nothing needs to be uploaded.'

        return $false
    }

    $shouldUpload = Ask-YesNo `
        -Title 'Upload this flashcard change?' `
        -Message @"
A change was found in:

$relativePath

Choose Yes to commit and push this file to GitHub.
Choose No to keep the change only on this computer.
"@

    if (-not $shouldUpload) {
        Show-Message `
            -Title 'Change kept locally' `
            -Message 'The file was changed on this computer but was not uploaded to GitHub.'

        return $false
    }

    $defaultMessage = "Update flashcards in $([System.IO.Path]::GetFileName($relativePath))"

    $commitMessage = [Microsoft.VisualBasic.Interaction]::InputBox(
        'Enter a short description for the GitHub update:',
        'GitHub commit message',
        $defaultMessage
    )

    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = $defaultMessage
    }

    [void](Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'config',
            'user.name',
            $GitHubUsername
        ) `
        -FailureMessage 'Git could not set the commit username.')

    [void](Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'config',
            'user.email',
            "$GitHubUsername@users.noreply.github.com"
        ) `
        -FailureMessage 'Git could not set the commit email.')

    $pullCode = Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'pull',
            '--rebase',
            '--autostash',
            'origin',
            'main'
        ) `
        -AllowFailure

    if ($pullCode -ne 0) {
        throw 'Git could not safely combine the newest GitHub changes with the local edit.'
    }

    [void](Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'add',
            '--',
            $relativePath
        ) `
        -FailureMessage 'Git could not stage the selected flashcard file.')

    $stagedCode = Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'diff',
            '--cached',
            '--quiet'
        ) `
        -AllowFailure `
        -Quiet

    if ($stagedCode -eq 0) {
        Show-Message `
            -Title 'Nothing to upload' `
            -Message 'After synchronizing with GitHub, no new change remained to commit.'

        return $false
    }

    [void](Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'commit',
            '-m',
            $commitMessage
        ) `
        -FailureMessage 'Git could not create the flashcard update commit.')

    [void](Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'push',
            'origin',
            'main'
        ) `
        -FailureMessage 'GitHub rejected the flashcard update.')

    $fileUrl = Get-GitHubFileUrl -RelativePath $relativePath

    Show-Message `
        -Title 'Flashcards published' `
        -Message @"
The selected file was committed and pushed to GitHub.

File:
$relativePath

The GitHub page will open next.
"@

    Start-Process $fileUrl -ErrorAction SilentlyContinue
    return $true
}

try {
    Initialize-WindowsUi
    Clear-Host

    Write-Host 'LINEAR ALGEBRA QUIZ - EDIT FLASHCARDS AND PUBLISH' -ForegroundColor Magenta
    Write-Host 'VERSION 1 - DOUBLE-CLICK EDITOR' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host "Repository: $RepositoryWebUrl" -ForegroundColor White

    $downloads = Get-DownloadsFolder
    $toolRoot = Get-ToolRoot

    Write-Step 'STEP 1 OF 4 - Preparing GitHub tools'
    $tools = Ensure-GitAndGitHubCli -ToolsFolder $toolRoot

    Write-Step 'STEP 2 OF 4 - Signing in and finding the repository'
    $githubUser = Ensure-GitHubLogin -GhExe $tools.Gh
    Test-RepositoryAccess -GhExe $tools.Gh -Username $githubUser

    $repositoryFolder = Get-OrCloneRepository `
        -GitExe $tools.Git `
        -DownloadsFolder $downloads

    Sync-RepositoryBeforeEditing `
        -GitExe $tools.Git `
        -RepositoryFolder $repositoryFolder

    $editAnother = $true

    while ($editAnother) {
        Write-Step 'STEP 3 OF 4 - Choosing and editing a flashcard file'

        Show-Message `
            -Title 'Choose a flashcard file' `
            -Message @"
A file window will open.

Choose an HTML, JavaScript, or JSON file containing the flashcards you want to change.

Common flashcard pages include files whose names begin with "solo".

After Notepad opens:
1. Use Ctrl+F to find the question.
2. Make the change.
3. Press Ctrl+S to save.
4. Return to this setup window.
"@

        $selectedFile = Select-FlashcardFile `
            -RepositoryFolder $repositoryFolder

        if ([string]::IsNullOrWhiteSpace($selectedFile)) {
            $editAnother = $false
            continue
        }

        $backupFile = Create-Backup `
            -RepositoryFolder $repositoryFolder `
            -SelectedFile $selectedFile

        Write-Ok "Backup created: $backupFile"

        Start-Process `
            -FilePath 'notepad.exe' `
            -ArgumentList "`"$selectedFile`""

        $finishedEditing = Ask-OkCancel `
            -Title 'Finish editing in Notepad' `
            -Message @"
Notepad has opened the selected flashcard file.

Make your changes and press Ctrl+S.

When the file is saved, return here and choose OK.
Choose Cancel to stop without uploading.
"@

        if (-not $finishedEditing) {
            Show-Message `
                -Title 'Upload cancelled' `
                -Message 'The GitHub upload was cancelled. Any saved Notepad changes remain on this computer.'

            $editAnother = $false
            continue
        }

        Write-Step 'STEP 4 OF 4 - Checking and publishing the change'

        [void](Publish-SelectedFile `
            -GitExe $tools.Git `
            -RepositoryFolder $repositoryFolder `
            -SelectedFile $selectedFile `
            -GitHubUsername $githubUser)

        $editAnother = Ask-YesNo `
            -Title 'Edit another flashcard file?' `
            -Message 'Choose Yes to edit another file, or No to finish.'
    }

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Write-Host "Local repository: $repositoryFolder" -ForegroundColor Cyan
    Write-Host 'No force push was used.' -ForegroundColor Yellow
}
catch {
    $message = $_.Exception.Message

    Write-Host ''
    Write-Host 'FLASHCARD EDITOR STOPPED' -ForegroundColor Red
    Write-Host $message -ForegroundColor Red
    Write-Host ''

    try {
        Show-Message `
            -Title 'Flashcard editor stopped' `
            -Message $message `
            -Type 'Error'
    }
    catch {
        # Keep the console error visible if Windows dialogs are unavailable.
    }

    [void](Read-Host 'Press Enter to close')
    exit 1
}
