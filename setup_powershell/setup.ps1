#requires -Version 5.1
<#
Beginner-friendly launcher for the Linear Algebra True or False setup toolkit.

What it does:
- Detects the current Windows user's real Downloads folder.
- Looks beside this file and in Downloads for the two installer scripts.
- If only one installer exists, it starts that installer automatically.
- If both installers exist, it shows a standard Windows popup:
    Yes    = Firebase + GitHub online version
    No     = local-only version
    Cancel = stop
- Supports filenames such as "setup-new-repo-no-firebase (1).ps1".
- Does not install anything by itself; it launches the selected installer.
#>

$ErrorActionPreference = 'Stop'

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
        $userProfile = [Environment]::GetFolderPath('UserProfile')

        if ([string]::IsNullOrWhiteSpace($userProfile)) {
            $userProfile = $env:USERPROFILE
        }

        $downloads = Join-Path $userProfile 'Downloads'
    }

    return $downloads
}

function Find-NewestInstaller {
    param(
        [string[]]$SearchFolders,
        [string]$BaseName
    )

    $pattern = '^' +
        [regex]::Escape($BaseName) +
        '(?:\s*\(\d+\))?\.ps1$'

    $matches = @()

    foreach ($folder in $SearchFolders | Select-Object -Unique) {
        if ([string]::IsNullOrWhiteSpace($folder)) {
            continue
        }

        if (-not (Test-Path -LiteralPath $folder -PathType Container)) {
            continue
        }

        $matches += Get-ChildItem `
            -LiteralPath $folder `
            -File `
            -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -match $pattern
            }
    }

    return $matches |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

function Show-ChoicePopup {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $message = @'
Both setup choices were found.

Choose what you want to install:

YES  = Firebase + GitHub online version
NO   = Local-only version on this computer
CANCEL = Stop without changing anything
'@

    return [System.Windows.Forms.MessageBox]::Show(
        $message,
        'Choose the Linear Algebra quiz setup',
        [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
        [System.Windows.Forms.MessageBoxIcon]::Question,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button2
    )
}

function Show-ErrorPopup {
    param([string]$Message)

    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Application]::EnableVisualStyles()

        [System.Windows.Forms.MessageBox]::Show(
            $Message,
            'Linear Algebra quiz setup',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    catch {
        Write-Host $Message -ForegroundColor Red
    }
}

try {
    Clear-Host
    Write-Host 'LINEAR ALGEBRA QUIZ - SETUP LAUNCHER' -ForegroundColor Magenta
    Write-Host 'Automatically finding your installer...' -ForegroundColor Cyan
    Write-Host ''

    $downloads = Get-DownloadsFolder
    $scriptFolder = $PSScriptRoot

    if ([string]::IsNullOrWhiteSpace($scriptFolder)) {
        $scriptFolder = (Get-Location).Path
    }

    $searchFolders = @(
        $scriptFolder,
        $downloads
    )

    $localInstaller = Find-NewestInstaller `
        -SearchFolders $searchFolders `
        -BaseName 'setup-new-repo-no-firebase'

    $firebaseInstaller = Find-NewestInstaller `
        -SearchFolders $searchFolders `
        -BaseName 'setup-new-repo-with-firebase'

    $selectedInstaller = $null
    $selectedName = $null

    if ($null -ne $localInstaller -and $null -ne $firebaseInstaller) {
        $choice = Show-ChoicePopup

        if ($choice -eq [System.Windows.Forms.DialogResult]::Yes) {
            $selectedInstaller = $firebaseInstaller
            $selectedName = 'Firebase + GitHub online setup'
        }
        elseif ($choice -eq [System.Windows.Forms.DialogResult]::No) {
            $selectedInstaller = $localInstaller
            $selectedName = 'local-only setup'
        }
        else {
            Write-Host 'Setup cancelled. Nothing was changed.' -ForegroundColor Yellow
            exit 0
        }
    }
    elseif ($null -ne $firebaseInstaller) {
        $selectedInstaller = $firebaseInstaller
        $selectedName = 'Firebase + GitHub online setup'
    }
    elseif ($null -ne $localInstaller) {
        $selectedInstaller = $localInstaller
        $selectedName = 'local-only setup'
    }
    else {
        $message = @"
No installer scripts were found.

Place setup.ps1 in the same folder as at least one of these files:

- setup-new-repo-no-firebase.ps1
- setup-new-repo-with-firebase.ps1

The launcher also checked your Downloads folder:

$downloads
"@

        Show-ErrorPopup -Message $message
        throw 'No setup installer was found.'
    }

    Write-Host "Selected: $selectedName" -ForegroundColor Green
    Write-Host "File:     $($selectedInstaller.FullName)" -ForegroundColor Green
    Write-Host ''

    try {
        Unblock-File `
            -LiteralPath $selectedInstaller.FullName `
            -ErrorAction SilentlyContinue
    }
    catch {
        # ExecutionPolicy Bypass is enough when Unblock-File is unavailable.
    }

    $installerFolder = Split-Path -Parent $selectedInstaller.FullName
    Push-Location -LiteralPath $installerFolder

    try {
        & $selectedInstaller.FullName
    }
    finally {
        Pop-Location
    }
}
catch {
    Write-Host ''
    Write-Host 'SETUP LAUNCHER STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ''
    [void](Read-Host 'Press Enter to close')
    exit 1
}
