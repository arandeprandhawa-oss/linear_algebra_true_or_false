#requires -Version 5.1
<#
Beginner-friendly flashcard editor for both setup types.

Modes:
- Local-only mode:
  Edits flashcard files on this computer and does not use GitHub.
- Firebase + GitHub mode:
  Edits a repository file, creates a backup, and optionally commits and pushes
  the selected file to GitHub.

Use "Edit Flashcards.cmd" to launch this file.
Keep the .cmd and .ps1 files together in the same folder.
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

function Choose-Mode {
    $message = @'
Choose how you want to edit the flashcards.

YES = Firebase + GitHub version
Edit a repository file and optionally publish it to GitHub.

NO = Local-only version
Edit a file on this computer without GitHub.

CANCEL = Exit
'@

    return [System.Windows.Forms.MessageBox]::Show(
        $message,
        'Choose the flashcard editor mode',
        [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
        [System.Windows.Forms.MessageBoxIcon]::Question,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
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
        $baseFolder = Join-Path `
            ([Environment]::GetFolderPath('UserProfile')) `
            'AppData\Local'
    }

    $toolRoot = Join-Path $baseFolder $ToolRootName
    New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null

    return $toolRoot
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

function Select-ProjectFolder {
    param(
        [string]$Title,
        [string]$InitialFolder
    )

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $Title
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
    return $selected
}

function Select-FlashcardFile {
    param([string]$ProjectFolder)

    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Choose the flashcard file to edit'
    $dialog.InitialDirectory = $ProjectFolder
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

    $commonFiles = @(
        'solo.html',
        'solo1.html',
        'solo3.html',
        'solo4.html',
        'index.html'
    )

    foreach ($commonFile in $commonFiles) {
        if (Test-Path -LiteralPath (Join-Path $ProjectFolder $commonFile)) {
            $dialog.FileName = $commonFile
            break
        }
    }

    $result = $dialog.ShowDialog()
    $selected = $null

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selected = $dialog.FileName
    }

    $dialog.Dispose()

    if ([string]::IsNullOrWhiteSpace($selected)) {
        return $null
    }

    $rootPath = [System.IO.Path]::GetFullPath($ProjectFolder).TrimEnd('\') + '\'
    $filePath = [System.IO.Path]::GetFullPath($selected)

    if (-not $filePath.StartsWith(
        $rootPath,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        Show-Message `
            -Title 'Choose a project file' `
            -Message 'Choose a flashcard file inside the selected project folder.' `
            -Type 'Warning'

        return $null
    }

    if ($filePath -match '[\\/]\.git[\\/]') {
        Show-Message `
            -Title 'Protected Git folder' `
            -Message 'Files inside the hidden .git folder cannot be edited.' `
            -Type 'Warning'

        return $null
    }

    return $filePath
}

function Create-Backup {
    param(
        [string]$ProjectFolder,
        [string]$SelectedFile,
        [string]$BackupCategory
    )

    $relativePath = Get-RelativePathSafe `
        -BasePath $ProjectFolder `
        -FullPath $SelectedFile

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupRoot = Join-Path `
        $ProjectFolder `
        (Join-Path 'backups' (Join-Path $BackupCategory $timestamp))

    $backupFile = Join-Path $backupRoot $relativePath
    $backupDirectory = Split-Path -Parent $backupFile

    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    Copy-Item -LiteralPath $SelectedFile -Destination $backupFile -Force

    return $backupFile
}

function Open-FileForEditing {
    param(
        [string]$ProjectFolder,
        [string]$SelectedFile,
        [string]$BackupCategory
    )

    $backupFile = Create-Backup `
        -ProjectFolder $ProjectFolder `
        -SelectedFile $SelectedFile `
        -BackupCategory $BackupCategory

    Write-Ok "Backup created: $backupFile"

    Start-Process `
        -FilePath 'notepad.exe' `
        -ArgumentList "`"$SelectedFile`""

    return Ask-OkCancel `
        -Title 'Finish editing the flashcards' `
        -Message @"
The flashcard file is open in Notepad.

1. Press Ctrl+F to find a question.
2. Make the change.
3. Press Ctrl+S to save.
4. Return here and choose OK.

Choose Cancel to stop.
"@
}

function Open-LocalWebsite {
    param([string]$ProjectFolder)

    $indexPath = Join-Path $ProjectFolder 'index.html'

    if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
        Start-Process -FilePath $indexPath -ErrorAction SilentlyContinue
    }
    else {
        Start-Process -FilePath $ProjectFolder -ErrorAction SilentlyContinue
    }
}

function Start-LocalEditor {
    $downloads = Get-DownloadsFolder

    Show-Message `
        -Title 'Local flashcard editor' `
        -Message @"
Choose the main local quiz folder.

It is usually the folder containing index.html, solo.html, or other quiz pages.

This mode does not use GitHub or Firebase.
"@

    $projectFolder = Select-ProjectFolder `
        -Title 'Choose the main local Linear Algebra quiz folder' `
        -InitialFolder $downloads

    if ([string]::IsNullOrWhiteSpace($projectFolder)) {
        return
    }

    $editAnother = $true

    while ($editAnother) {
        $selectedFile = Select-FlashcardFile `
            -ProjectFolder $projectFolder

        if ([string]::IsNullOrWhiteSpace($selectedFile)) {
            return
        }

        $finished = Open-FileForEditing `
            -ProjectFolder $projectFolder `
            -SelectedFile $selectedFile `
            -BackupCategory 'local-flashcard-editor'

        if (-not $finished) {
            return
        }

        Show-Message `
            -Title 'Local flashcards saved' `
            -Message @"
Your saved changes remain on this computer.

A backup was created before editing.

The local website will open next so you can test the change.
"@

        Open-LocalWebsite -ProjectFolder $projectFolder

        $editAnother = Ask-YesNo `
            -Title 'Edit another local flashcard file?' `
            -Message 'Choose Yes to edit another file, or No to finish.'
    }
}

function Invoke-WebDownload {
    param(
        [string]$Url,
        [string]$OutFile
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

function Install-PortableGit {
    param([string]$ToolRoot)

    Write-Info 'Git was not found. Downloading portable Git...'

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Flashcard-Editor' }

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
        throw 'PortableGit downloaded, but git.exe was not found.'
    }

    return $gitExe
}

function Install-PortableGitHubCli {
    param([string]$ToolRoot)

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

    $ghFolder = Join-Path $ToolRoot 'GitHubCLI'
    $zipFile = Join-Path $ToolRoot $asset.name

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
        throw 'GitHub CLI downloaded, but gh.exe was not found.'
    }

    return $ghExe
}

function Ensure-GitTools {
    $toolRoot = Get-ToolRoot

    $gitExe = Get-CommandPath -Names @('git.exe', 'git')

    if ([string]::IsNullOrWhiteSpace($gitExe)) {
        $portableGit = Join-Path $toolRoot 'PortableGit\cmd\git.exe'

        if (Test-Path -LiteralPath $portableGit) {
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

    $status = Invoke-Native `
        -FilePath $GhExe `
        -Arguments @('auth', 'status', '--hostname', 'github.com') `
        -FailureMessage 'GitHub login check failed.' `
        -AllowFailure `
        -Quiet

    if ($status -ne 0) {
        Show-Message `
            -Title 'GitHub login required' `
            -Message @"
PowerShell will show a one-time code and open GitHub in your browser.

Complete the login, then return to PowerShell.
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

    $user = Invoke-NativeCapture `
        -FilePath $GhExe `
        -Arguments @('api', 'user', '--jq', '.login') `
        -FailureMessage 'Could not read the signed-in GitHub username.'

    if ([string]::IsNullOrWhiteSpace($user.Text)) {
        throw 'GitHub returned an empty username.'
    }

    Write-Ok "Signed in as: $($user.Text)"
    return $user.Text
}

function Test-CorrectRepository {
    param(
        [string]$GitExe,
        [string]$Folder
    )

    if (-not (Test-Path -LiteralPath (Join-Path $Folder '.git') -PathType Container)) {
        return $false
    }

    $remote = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @('-C', $Folder, 'remote', 'get-url', 'origin') `
        -FailureMessage 'Could not inspect the repository remote.' `
        -AllowFailure

    if ($remote.ExitCode -ne 0) {
        return $false
    }

    return $remote.Text -match (
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
        (Join-Path $DownloadsFolder "$RepositoryName-fixed-installer-update")
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
        $backup = "$editorFolder-backup-$timestamp"
        Move-Item -LiteralPath $editorFolder -Destination $backup
        Write-Info "Existing folder backed up to: $backup"
    }

    [void](Invoke-Native `
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

function Sync-Repository {
    param(
        [string]$GitExe,
        [string]$RepositoryFolder
    )

    $status = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @('-C', $RepositoryFolder, 'status', '--porcelain') `
        -FailureMessage 'Git could not inspect the local repository.' `
        -AllowFailure

    if (-not [string]::IsNullOrWhiteSpace($status.Text)) {
        Write-Warn 'The local repository already has uncommitted changes.'
        Write-Warn 'They will be preserved, but an automatic pull is being skipped.'
        return
    }

    $pull = Invoke-Native `
        -FilePath $GitExe `
        -Arguments @('-C', $RepositoryFolder, 'pull', '--rebase', 'origin', 'main') `
        -FailureMessage 'Git could not pull the latest changes.' `
        -AllowFailure

    if ($pull -eq 0) {
        Write-Ok 'The local repository is up to date.'
    }
    else {
        Write-Warn 'The newest GitHub changes could not be pulled automatically.'
    }
}

function Publish-File {
    param(
        [string]$GitExe,
        [string]$RepositoryFolder,
        [string]$SelectedFile,
        [string]$GitHubUser
    )

    $relativePath = Get-RelativePathSafe `
        -BasePath $RepositoryFolder `
        -FullPath $SelectedFile

    $status = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'status',
            '--porcelain',
            '--',
            $relativePath
        ) `
        -FailureMessage 'Git could not check the selected file.' `
        -AllowFailure

    if ([string]::IsNullOrWhiteSpace($status.Text)) {
        Show-Message `
            -Title 'No changes found' `
            -Message 'The selected file was not changed, so nothing needs to be uploaded.'

        return
    }

    $publish = Ask-YesNo `
        -Title 'Publish this flashcard change?' `
        -Message @"
A saved change was found in:

$relativePath

Choose Yes to commit and push only this file to GitHub.
Choose No to keep the change only on this computer.
"@

    if (-not $publish) {
        Show-Message `
            -Title 'Change kept locally' `
            -Message 'The file remains changed on this computer and was not uploaded.'

        return
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

    [void](Invoke-Native `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'config',
            'user.name',
            $GitHubUser
        ) `
        -FailureMessage 'Git could not set the commit username.')

    [void](Invoke-Native `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'config',
            'user.email',
            "$GitHubUser@users.noreply.github.com"
        ) `
        -FailureMessage 'Git could not set the commit email.')

    [void](Invoke-Native `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'pull',
            '--rebase',
            '--autostash',
            'origin',
            'main'
        ) `
        -FailureMessage 'Git could not safely combine the latest GitHub changes.')

    [void](Invoke-Native `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'add',
            '--',
            $relativePath
        ) `
        -FailureMessage 'Git could not stage the selected flashcard file.')

    [void](Invoke-Native `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'commit',
            '-m',
            $commitMessage
        ) `
        -FailureMessage 'Git could not create the flashcard update commit.')

    [void](Invoke-Native `
        -FilePath $GitExe `
        -Arguments @(
            '-C', $RepositoryFolder,
            'push',
            'origin',
            'main'
        ) `
        -FailureMessage 'GitHub rejected the flashcard update.')

    $encodedParts = @()

    foreach ($part in $relativePath.Replace('\', '/').Split('/')) {
        $encodedParts += [System.Uri]::EscapeDataString($part)
    }

    $fileUrl = "$RepositoryWebUrl/blob/main/$($encodedParts -join '/')"

    Show-Message `
        -Title 'Flashcards published' `
        -Message @"
The selected flashcard file was committed and pushed to GitHub.

$fileUrl
"@

    Start-Process -FilePath $fileUrl -ErrorAction SilentlyContinue
}

function Start-FirebaseEditor {
    Write-Step 'Preparing the Firebase + GitHub flashcard editor'

    $downloads = Get-DownloadsFolder
    $tools = Ensure-GitTools
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

    $repositoryFolder = Get-OrCloneRepository `
        -GitExe $tools.Git `
        -DownloadsFolder $downloads

    Sync-Repository `
        -GitExe $tools.Git `
        -RepositoryFolder $repositoryFolder

    $editAnother = $true

    while ($editAnother) {
        Show-Message `
            -Title 'Firebase + GitHub flashcard editor' `
            -Message @"
Choose an HTML, JavaScript, or JSON file from the repository.

Common flashcard pages begin with "solo".

After Notepad opens:
1. Find the question with Ctrl+F.
2. Make the change.
3. Save with Ctrl+S.
4. Return here and choose OK.
"@

        $selectedFile = Select-FlashcardFile `
            -ProjectFolder $repositoryFolder

        if ([string]::IsNullOrWhiteSpace($selectedFile)) {
            return
        }

        $finished = Open-FileForEditing `
            -ProjectFolder $repositoryFolder `
            -SelectedFile $selectedFile `
            -BackupCategory 'firebase-flashcard-editor'

        if (-not $finished) {
            return
        }

        Publish-File `
            -GitExe $tools.Git `
            -RepositoryFolder $repositoryFolder `
            -SelectedFile $selectedFile `
            -GitHubUser $githubUser

        $editAnother = Ask-YesNo `
            -Title 'Edit another Firebase flashcard file?' `
            -Message 'Choose Yes to edit another file, or No to finish.'
    }
}

try {
    Initialize-Ui
    Clear-Host

    Write-Host 'LINEAR ALGEBRA QUIZ - FLASHCARD EDITOR' -ForegroundColor Magenta
    Write-Host 'VERSION 1 - LOCAL OR FIREBASE MODE' -ForegroundColor DarkCyan
    Write-Host ''

    $choice = Choose-Mode

    if ($choice -eq [System.Windows.Forms.DialogResult]::Yes) {
        Start-FirebaseEditor
    }
    elseif ($choice -eq [System.Windows.Forms.DialogResult]::No) {
        Start-LocalEditor
    }
    else {
        Write-Host 'Cancelled. Nothing was changed.' -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
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
        # Keep the PowerShell error visible if Windows dialogs are unavailable.
    }

    [void](Read-Host 'Press Enter to close')
    exit 1
}
