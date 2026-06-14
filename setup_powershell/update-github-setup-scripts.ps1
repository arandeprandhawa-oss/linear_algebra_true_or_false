#requires -Version 5.1
<#
Updates the complete Linear Algebra quiz toolkit in GitHub.

Repository:
https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false

Run this through:
Update GitHub Setup Toolkit.cmd

The updater expects all toolkit files to be together in the extracted folder.
It validates every PowerShell file before uploading, clones a fresh repository
copy, replaces the setup_powershell toolkit, commits, and pushes to main.

No force push is used.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepositoryOwner = 'arandeprandhawa-oss'
$RepositoryName = 'linear_algebra_true_or_false'
$RepositoryWebUrl = "https://github.com/$RepositoryOwner/$RepositoryName"
$RepositoryGitUrl = "$RepositoryWebUrl.git"

$ToolkitFiles = @(
    'setup.ps1',
    'Setup Launcher.cmd',
    'setup-new-repo-no-firebase.ps1',
    'Install Local Quiz.cmd',
    'setup-new-repo-with-firebase.ps1',
    'Install Firebase Quiz.cmd',
    'edit-quiz-javascript.ps1',
    'Edit Quiz JavaScript.cmd',
    'edit-flashcards.ps1',
    'Edit Flashcards.cmd',
    'update-entire-project-to-github.ps1',
    'Update Entire Project to GitHub.cmd',
    'update-github-setup-scripts.ps1',
    'Update GitHub Setup Toolkit.cmd'
)

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
        $profile = [Environment]::GetFolderPath('UserProfile')

        if ([string]::IsNullOrWhiteSpace($profile)) {
            $profile = $env:USERPROFILE
        }

        $downloads = Join-Path $profile 'Downloads'
    }

    if (-not (Test-Path -LiteralPath $downloads -PathType Container)) {
        New-Item -ItemType Directory -Path $downloads -Force | Out-Null
    }

    return $downloads
}

function Get-ToolRoot {
    $root = Join-Path $env:LOCALAPPDATA 'LAQuizTools'
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    return $root
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
        -Headers @{ 'User-Agent' = 'LA-Quiz-Toolkit-Updater' } `
        -UseBasicParsing
}

function Install-PortableGit {
    param([string]$ToolRoot)

    Write-Info 'Git was not found. Downloading portable Git...'

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Toolkit-Updater' }

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
        -Headers @{ 'User-Agent' = 'LA-Quiz-Toolkit-Updater' }

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

    $status = Invoke-Native `
        -FilePath $GhExe `
        -Arguments @('auth', 'status', '--hostname', 'github.com') `
        -FailureMessage 'GitHub login check failed.' `
        -AllowFailure `
        -Quiet

    if ($status -ne 0) {
        Write-Info 'GitHub login is required.'
        Write-Host 'A one-time code will appear and GitHub will open in your browser.' -ForegroundColor White
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

function Test-PowerShellSyntax {
    param([string]$Path)

    $tokens = $null
    $errors = $null

    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $Path,
        [ref]$tokens,
        [ref]$errors
    )

    if ($errors.Count -gt 0) {
        $details = ($errors | ForEach-Object {
            "Line $($_.Extent.StartLineNumber): $($_.Message)"
        }) -join [Environment]::NewLine

        throw "PowerShell syntax check failed for:`n$Path`n`n$details"
    }
}

function Backup-WorkingFolder {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = "$Path-backup-$timestamp"
        Move-Item -LiteralPath $Path -Destination $backup
        Write-Info "Older working copy moved safely to: $backup"
    }
}

try {
    Clear-Host

    Write-Host 'LINEAR ALGEBRA QUIZ - COMPLETE TOOLKIT UPDATE' -ForegroundColor Magenta
    Write-Host 'VERSION 10 - REPAIRED CMD LAUNCHERS AND FULL PROJECT UPDATER' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host "Repository: $RepositoryWebUrl" -ForegroundColor White

    $sourceFolder = $PSScriptRoot

    if ([string]::IsNullOrWhiteSpace($sourceFolder)) {
        $sourceFolder = (Get-Location).Path
    }

    Write-Step 'STEP 1 OF 6 - Checking every toolkit file'

    $missingFiles = @()

    foreach ($fileName in $ToolkitFiles) {
        $sourcePath = Join-Path $sourceFolder $fileName

        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            $missingFiles += $fileName
        }
    }

    if ($missingFiles.Count -gt 0) {
        $missingText = $missingFiles -join [Environment]::NewLine

        throw "The ZIP was not fully extracted, or files are missing:`n`n$missingText`n`nExtract the complete ZIP before running the updater."
    }

    foreach ($fileName in $ToolkitFiles | Where-Object { $_ -like '*.ps1' }) {
        $path = Join-Path $sourceFolder $fileName
        Test-PowerShellSyntax -Path $path
        Write-Ok "Syntax passed: $fileName"
    }

    Write-Step 'STEP 2 OF 6 - Preparing Git and GitHub tools'
    $tools = Ensure-Tools

    Write-Step 'STEP 3 OF 6 - Signing in to GitHub'
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

    Write-Ok 'Repository access confirmed.'

    Write-Step 'STEP 4 OF 6 - Downloading a fresh repository copy'

    $downloads = Get-DownloadsFolder
    $workingFolder = Join-Path $downloads "$RepositoryName-toolkit-update"
    Backup-WorkingFolder -Path $workingFolder

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            'clone',
            '--branch', 'main',
            '--single-branch',
            $RepositoryGitUrl,
            $workingFolder
        ) `
        -FailureMessage 'The repository could not be downloaded.')

    Write-Step 'STEP 5 OF 6 - Replacing the complete setup toolkit'

    $setupFolder = Join-Path $workingFolder 'setup_powershell'
    New-Item -ItemType Directory -Path $setupFolder -Force | Out-Null

    foreach ($fileName in $ToolkitFiles) {
        Copy-Item `
            -LiteralPath (Join-Path $sourceFolder $fileName) `
            -Destination (Join-Path $setupFolder $fileName) `
            -Force

        Write-Ok "Copied: $fileName"
    }

    foreach ($obsoleteName in @(
        'Edit Flashcards and Publish.cmd',
        'edit-flashcards-and-publish.ps1'
    )) {
        $obsoletePath = Join-Path $setupFolder $obsoleteName

        if (Test-Path -LiteralPath $obsoletePath -PathType Leaf) {
            Remove-Item -LiteralPath $obsoletePath -Force
            Write-Info "Removed obsolete file: $obsoleteName"
        }
    }

    Write-Step 'STEP 6 OF 6 - Committing and pushing'

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @('-C', $workingFolder, 'config', 'user.name', $githubUser) `
        -FailureMessage 'Git could not set the commit username.')

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $workingFolder,
            'config',
            'user.email',
            "$githubUser@users.noreply.github.com"
        ) `
        -FailureMessage 'Git could not set the commit email.')

    [void](Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @(
            '-C', $workingFolder,
            'add',
            '-A',
            'setup_powershell'
        ) `
        -FailureMessage 'Git could not stage the toolkit changes.')

    $changed = Invoke-Native `
        -FilePath $tools.Git `
        -Arguments @('-C', $workingFolder, 'diff', '--cached', '--quiet') `
        -FailureMessage 'Git could not inspect the staged changes.' `
        -AllowFailure `
        -Quiet

    if ($changed -eq 0) {
        Write-Info 'GitHub already contains these exact toolkit files.'
    }
    else {
        [void](Invoke-Native `
            -FilePath $tools.Git `
            -Arguments @(
                '-C', $workingFolder,
                'commit',
                '-m',
                'Repair all CMD launchers and add full-project updater'
            ) `
            -FailureMessage 'Git could not create the toolkit commit.')

        [void](Invoke-Native `
            -FilePath $tools.Git `
            -Arguments @('-C', $workingFolder, 'push', 'origin', 'main') `
            -FailureMessage 'GitHub rejected the toolkit push.')

        Write-Ok 'The complete repaired toolkit was pushed to GitHub.'
    }

    $setupUrl = "$RepositoryWebUrl/tree/main/setup_powershell"

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Write-Host "GitHub folder: $setupUrl" -ForegroundColor Cyan
    Write-Host "Local copy:    $workingFolder" -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'No force push was used.' -ForegroundColor Yellow

    Start-Process -FilePath $setupUrl -ErrorAction SilentlyContinue
}
catch {
    Write-Host ''
    Write-Host 'TOOLKIT UPDATE STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ''
    Write-Host 'No force push was used.' -ForegroundColor Yellow
    [void](Read-Host 'Press Enter to close')
    exit 1
}

[void](Read-Host 'Press Enter to close')
