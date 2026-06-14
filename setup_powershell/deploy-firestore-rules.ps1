#requires -Version 5.1
<#
Deploy Firestore Rules - Linear Algebra True or False

Reads the project's firestore.rules file, updates it to match the current
registry (units) and page settings (match lengths, categories), then
deploys it to Firebase.

Run this after:
  - Adding a new unit with "Add New Unit"
  - Changing match lengths with "Adjust Timing and Length"
  - Editing firestore.rules manually

The script auto-detects the project folder and the Firebase CLI from the
location the installer downloaded it to. Firebase login is re-used from the
previous session - you only log in once.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$env:FIREBASE_CLI_DISABLE_TELEMETRY = '1'
$env:NO_UPDATE_NOTIFIER = '1'

# =====================================================================
# UI palette
# =====================================================================
function Initialize-Ui {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function New-UiButton {
    param([string]$Text, [switch]$Primary)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Size = New-Object System.Drawing.Size(170, 42)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)
    $button.FlatAppearance.BorderSize = 1
    if ($Primary) {
        $button.BackColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
        $button.ForeColor = [System.Drawing.Color]::White
        $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
    } else {
        $button.BackColor = [System.Drawing.Color]::White
        $button.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
        $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    }
    return $button
}

function Show-AppMessage {
    param([string]$Title, [string]$Message,
          [ValidateSet('Info','Success','Warning','Error')][string]$Type = 'Info')
    $icon = switch ($Type) {
        'Warning' { [System.Windows.Forms.MessageBoxIcon]::Warning }
        'Error'   { [System.Windows.Forms.MessageBoxIcon]::Error }
        default   { [System.Windows.Forms.MessageBoxIcon]::Information }
    }
    [void][System.Windows.Forms.MessageBox]::Show(
        $Message, $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

function Write-Step { param([string]$m) Write-Host ''; Write-Host '====================================================================' -ForegroundColor DarkGray; Write-Host $m -ForegroundColor Cyan; Write-Host '====================================================================' -ForegroundColor DarkGray }
function Write-Ok   { param([string]$m) Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Info { param([string]$m) Write-Host "[INFO] $m" -ForegroundColor Yellow }

function Save-Utf8NoBom {
    param([string]$Path, [AllowEmptyString()][string]$Text)
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

function Invoke-Native {
    param([string]$FilePath, [string[]]$Arguments,
          [string]$FailureMessage = 'A command failed.',
          [switch]$AllowFailure, [switch]$Quiet)
    $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        if ($Quiet) { & $FilePath @Arguments *> $null } else { & $FilePath @Arguments }
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $old }
    if (-not $AllowFailure -and $code -ne 0) { throw "$FailureMessage Exit code: $code" }
    return [int]$code
}

# =====================================================================
# Project detection
# =====================================================================
function Get-DownloadsFolder {
    try {
        $item = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name '{374DE290-123F-4565-9164-39C4925E467B}' -ErrorAction Stop
        return [Environment]::ExpandEnvironmentVariables($item.'{374DE290-123F-4565-9164-39C4925E467B}')
    } catch {
        $p = [Environment]::GetFolderPath('UserProfile')
        if ([string]::IsNullOrWhiteSpace($p)) { $p = $env:USERPROFILE }
        return Join-Path $p 'Downloads'
    }
}

function Get-StateFolder {
    $root = $env:LOCALAPPDATA
    if ([string]::IsNullOrWhiteSpace($root)) { $root = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'AppData\Local' }
    $f = Join-Path $root 'LAQuizTools'
    New-Item -ItemType Directory -Path $f -Force | Out-Null
    return $f
}

function Test-QuizProject {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path) -or (-not (Test-Path -LiteralPath $Path -PathType Container))) { return $false }
    return (Test-Path -LiteralPath (Join-Path $Path 'index.html') -PathType Leaf) -and
           (Test-Path -LiteralPath (Join-Path $Path (Join-Path 'etapes' 'registry.js')) -PathType Leaf)
}

function Find-ProjectRootFromPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $candidate = if (Test-Path -LiteralPath $Path -PathType Leaf) { Split-Path -Parent $Path } else { $Path }
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) { return $null }
    $directory = Get-Item -LiteralPath $candidate
    while ($null -ne $directory) {
        if (Test-QuizProject -Path $directory.FullName) { return $directory.FullName }
        $directory = $directory.Parent
    }
    $children = Get-ChildItem -LiteralPath $candidate -Directory -ErrorAction SilentlyContinue |
        Sort-Object @{ Expression = { if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 } } },
                    @{ Expression = { $_.LastWriteTime }; Descending = $true }
    foreach ($child in $children) {
        if (Test-QuizProject -Path $child.FullName) { return $child.FullName }
    }
    return $null
}

function Find-AutomaticProject {
    foreach ($mode in @('javascript','local','firebase')) {
        $f = Join-Path (Get-StateFolder) "last-$mode-project.txt"
        if (Test-Path -LiteralPath $f -PathType Leaf) {
            try {
                $saved = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8).Trim()
                if (Test-QuizProject -Path $saved) { return $saved }
            } catch { }
        }
    }
    $scriptFolder = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptFolder)) { $scriptFolder = (Get-Location).Path }
    $hit = Find-ProjectRootFromPath -Path $scriptFolder
    if (-not [string]::IsNullOrWhiteSpace($hit)) { return $hit }
    $hit = Find-ProjectRootFromPath -Path (Get-Location).Path
    if (-not [string]::IsNullOrWhiteSpace($hit)) { return $hit }
    $profilePath = [Environment]::GetFolderPath('UserProfile')
    foreach ($root in @((Get-DownloadsFolder), [Environment]::GetFolderPath('MyDocuments'),
                         [Environment]::GetFolderPath('Desktop'),
                         (Join-Path $profilePath 'OneDrive'))) {
        if ([string]::IsNullOrWhiteSpace($root) -or (-not (Test-Path -LiteralPath $root -PathType Container))) { continue }
        $skip = @('.git','node_modules','backups','AppData','$RECYCLE.BIN','System Volume Information','Windows','Program Files','Program Files (x86)')
        $queue = New-Object System.Collections.Queue
        $queue.Enqueue([pscustomobject]@{ Path = $root; Depth = 0 })
        $visited = 0
        while ($queue.Count -gt 0 -and $visited -lt 6000) {
            $entry = $queue.Dequeue(); $visited++
            if (Test-QuizProject -Path $entry.Path) { return $entry.Path }
            if ($entry.Depth -ge 7) { continue }
            $kids = Get-ChildItem -LiteralPath $entry.Path -Directory -Force -ErrorAction SilentlyContinue |
                Where-Object { $skip -notcontains $_.Name -and -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) } |
                Sort-Object @{ Expression = { if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 } } },
                            @{ Expression = { $_.LastWriteTime }; Descending = $true }
            foreach ($child in $kids) { $queue.Enqueue([pscustomobject]@{ Path = $child.FullName; Depth = $entry.Depth + 1 }) }
        }
    }
    return $null
}

# =====================================================================
# Firestore rules patching
# =====================================================================
function Update-FirestoreRules {
    param([string]$ProjectFolder)

    $rulesPath = Join-Path $ProjectFolder 'firestore.rules'
    if (-not (Test-Path -LiteralPath $rulesPath -PathType Leaf)) {
        Write-Info 'No firestore.rules found - this is a local-only install, nothing to deploy.'
        return $false
    }

    $content = [System.IO.File]::ReadAllText($rulesPath, [System.Text.Encoding]::UTF8)
    $original = $content

    # ---- 1. validEtape - read unit IDs from registry.js ----
    $registryPath = Join-Path $ProjectFolder (Join-Path 'etapes' 'registry.js')
    $regText = [System.IO.File]::ReadAllText($registryPath, [System.Text.Encoding]::UTF8)
    $etapeIds = @(
        [regex]::Matches($regText, "id\s*:\s*'(e\d+)'") |
            ForEach-Object { $_.Groups[1].Value } |
            Sort-Object -Unique
    )
    $etapeList = ($etapeIds | ForEach-Object { "'$_'" }) -join ', '
    $content = [regex]::Replace(
        $content,
        "(function validEtape\(e\)\s*\{\s*return e in \[)[^\]]*(\])",
        "`${1}$etapeList`${2}"
    )

    # ---- 2. length in [...] - read LENGTH_OPTIONS from index.html ----
    $indexPath = Join-Path $ProjectFolder 'index.html'
    if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
        $indexText = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
        $lm = [regex]::Match($indexText, "const LENGTH_OPTIONS\s*=\s*\[([^\]]+)\]")
        if ($lm.Success) {
            $lengths = $lm.Groups[1].Value -split ',' |
                ForEach-Object { $_.Trim() } |
                Where-Object { $_ -match '^\d+$' }
            $lengthList = $lengths -join ', '
            $content = [regex]::Replace(
                $content,
                "(\&\& request\.resource\.data\.length in \[)[^\]]*(\])",
                "`${1}$lengthList`${2}"
            )
        }
    }

    # ---- 3. validCategory - scan all etape*.js vocab files ----
    $allCategories = [System.Collections.Generic.SortedSet[string]]::new()
    [void]$allCategories.Add('all')
    $jsFiles = Get-ChildItem -LiteralPath (Join-Path $ProjectFolder 'etapes') -Filter 'etape*.js' -File -ErrorAction SilentlyContinue
    foreach ($jsFile in $jsFiles) {
        $jsText = [System.IO.File]::ReadAllText($jsFile.FullName, [System.Text.Encoding]::UTF8)
        $catMatches = [regex]::Matches($jsText, 'category\s*:\s*["\x27]([^"\x27\s]+)["\x27]')
        foreach ($m in $catMatches) {
            $cat = $m.Groups[1].Value.Trim()
            if (-not [string]::IsNullOrWhiteSpace($cat)) { [void]$allCategories.Add($cat) }
        }
    }
    $catList = ($allCategories | ForEach-Object { "'$_'" }) -join ",`n          "
    $content = [regex]::Replace(
        $content,
        "(?s)(function validCategory\(c\)\s*\{\s*return c in \[).*?(\]\s*;)",
        "`${1}`n          $catList`n        `${2}"
    )

    if ($content -ne $original) {
        Save-Utf8NoBom -Path $rulesPath -Text $content
        Write-Ok 'firestore.rules was updated to match the current units, lengths, and categories.'
        return $true
    }

    Write-Ok 'firestore.rules is already up to date - no changes needed.'
    return $false
}

# =====================================================================
# Firebase CLI location
# =====================================================================
function Find-FirebaseCli {
    # The connection helper installs firebase-tools locally through npm.
    # Prefer that firebase.cmd and intentionally ignore the old standalone
    # firebase.exe, which can crash in firepit/welcome.js on Windows.
    $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
    if ([string]::IsNullOrWhiteSpace($localAppData)) { $localAppData = $env:LOCALAPPDATA }

    if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
        $localNpm = [System.IO.Path]::Combine(
            $localAppData,
            'LAQuizTools',
            'FirebaseCLI-NPM',
            'node_modules',
            '.bin',
            'firebase.cmd'
        )
        if (Test-Path -LiteralPath $localNpm -PathType Leaf) { return $localNpm }
    }

    $globalCmd = Get-Command 'firebase.cmd' -ErrorAction SilentlyContinue
    if ($null -ne $globalCmd -and -not [string]::IsNullOrWhiteSpace($globalCmd.Source)) {
        return $globalCmd.Source
    }

    return $null
}

function Read-ProjectId {
    param([string]$ProjectFolder)
    $rcPath = Join-Path $ProjectFolder '.firebaserc'
    if (-not (Test-Path -LiteralPath $rcPath -PathType Leaf)) { return $null }
    $text = [System.IO.File]::ReadAllText($rcPath, [System.Text.Encoding]::UTF8)
    $m = [regex]::Match($text, '"default"\s*:\s*"([^"]+)"')
    if ($m.Success) { return $m.Groups[1].Value.Trim() }
    return $null
}

# =====================================================================
# MAIN
# =====================================================================
try {
    Clear-Host
    Write-Host 'LINEAR ALGEBRA QUIZ - DEPLOY FIRESTORE RULES' -ForegroundColor Magenta
    Write-Host 'VERSION 1.1 - WINDOWS POWERSHELL 5.1 SAFE' -ForegroundColor DarkCyan
    Write-Host ''

    Initialize-Ui

    Write-Step 'STEP 1 OF 4 - Finding the project'
    $projectFolder = Find-AutomaticProject
    if ([string]::IsNullOrWhiteSpace($projectFolder)) {
        Show-AppMessage -Title 'Choose the project folder' `
            -Message "The project was not found automatically.`r`n`r`nChoose the folder that contains index.html and the etapes folder." `
            -Type 'Warning'
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = 'Choose the project folder (the one containing index.html)'
        $dialog.ShowNewFolderButton = $false
        $result = $dialog.ShowDialog()
        $selected = if ($result -eq [System.Windows.Forms.DialogResult]::OK) { $dialog.SelectedPath } else { $null }
        $dialog.Dispose()
        if ([string]::IsNullOrWhiteSpace($selected)) { throw 'No project folder was selected.' }
        $projectFolder = Find-ProjectRootFromPath -Path $selected
        if ([string]::IsNullOrWhiteSpace($projectFolder)) { throw 'The selected folder does not look like the Linear Algebra project.' }
    }
    Write-Ok "Project: $projectFolder"

    # Check this is an online project
    $rulesPath = Join-Path $projectFolder 'firestore.rules'
    if (-not (Test-Path -LiteralPath $rulesPath -PathType Leaf)) {
        Show-AppMessage -Title 'Local install - nothing to deploy' `
            -Message "This is a local (solo-only) install. It has no firestore.rules and does not use Firebase.`r`n`r`nFirestore rules only apply to the online (Firebase + GitHub) version." `
            -Type 'Info'
        Write-Info 'Local install - no Firestore rules to deploy.'
        [void](Read-Host 'Press Enter to close')
        exit 0
    }

    Write-Step 'STEP 2 OF 4 - Updating firestore.rules from current project state'
    [void](Update-FirestoreRules -ProjectFolder $projectFolder)

    Write-Step 'STEP 3 OF 4 - Connecting the Firebase login and project'
    $connectorScript = Join-Path $PSScriptRoot 'login-and-connect-firebase.ps1'
    if (-not (Test-Path -LiteralPath $connectorScript -PathType Leaf)) {
        throw "The Firebase connection helper is missing:`r`n$connectorScript"
    }

    $powershellExe = Join-Path $PSHOME 'powershell.exe'
    if (-not (Test-Path -LiteralPath $powershellExe -PathType Leaf)) {
        $powershellExe = 'powershell.exe'
    }

    & $powershellExe `
        -NoLogo `
        -NoProfile `
        -STA `
        -ExecutionPolicy Bypass `
        -File $connectorScript `
        -ProjectFolder $projectFolder `
        -CalledByDeploy

    $connectorExitCode = $LASTEXITCODE
    if ($connectorExitCode -ne 0) {
        throw 'Firebase login/project connection was not completed.'
    }

    $projectId = Read-ProjectId -ProjectFolder $projectFolder
    if ([string]::IsNullOrWhiteSpace($projectId)) {
        throw 'Firebase connected, but the project ID was not saved in .firebaserc.'
    }
    Write-Ok "Firebase project: $projectId"

    $firebaseExe = Find-FirebaseCli
    if ([string]::IsNullOrWhiteSpace($firebaseExe)) {
        throw 'Firebase CLI could not be found after the connection helper finished.'
    }
    Write-Ok "Firebase CLI: $firebaseExe"

    $firebaseDir = [System.IO.Path]::GetDirectoryName([string]$firebaseExe)
    if (-not [string]::IsNullOrWhiteSpace($firebaseDir) -and
        $env:PATH -notlike "*$firebaseDir*") {
        $env:PATH = "$firebaseDir;$env:PATH"
    }

    Write-Step 'STEP 4 OF 4 - Deploying firestore.rules'
    Set-Location -LiteralPath $projectFolder
    [void](Invoke-Native `
        -FilePath $firebaseExe `
        -Arguments @('deploy', '--only', 'firestore:rules', '--project', $projectId) `
        -FailureMessage 'Firestore rules could not be deployed. Make sure the Firestore database exists in your Firebase project.')

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Write-Host "Rules deployed to: $projectId" -ForegroundColor Cyan
    Write-Host "Local rules file:  $rulesPath" -ForegroundColor Cyan

    Show-AppMessage -Title 'Firestore rules deployed' `
        -Message "The rules were updated to match the current units, match lengths, and categories, then deployed to Firebase project:`r`n`r`n$projectId`r`n`r`nThe changes take effect immediately - no page refresh needed." `
        -Type 'Success'
}
catch {
    Write-Host ''
    Write-Host 'DEPLOY STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    try { Show-AppMessage -Title 'Deploy stopped' -Message $_.Exception.Message -Type 'Error' } catch { }
    [void](Read-Host 'Press Enter to close')
    exit 1
}

[void](Read-Host 'Press Enter to close')
