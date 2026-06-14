#requires -Version 5.1
<#
Deploy Firestore Rules — Linear Algebra True or False

Reads the project's firestore.rules file, updates it to match the current
registry (units) and page settings (match lengths, categories), then
deploys it to Firebase.

Run this after:
  - Adding a new unit with "Add New Unit"
  - Changing match lengths with "Adjust Timing and Length"
  - Editing firestore.rules manually

The script auto-detects the project folder and the Firebase CLI from the
location the installer downloaded it to. Firebase login is re-used from the
previous session — you only log in once.
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
# Complete 2-to-6 player Firestore rules builder
# =====================================================================
function Read-ConfiguredPlayerCount {
    param([string]$ProjectFolder)

    $configPath = Join-Path $ProjectFolder 'multiplayer-config.js'
    if (Test-Path -LiteralPath $configPath -PathType Leaf) {
        try {
            $configText = [System.IO.File]::ReadAllText($configPath, [System.Text.Encoding]::UTF8)
            $match = [regex]::Match($configText, 'playerCount\s*:\s*([2-6])')
            if ($match.Success) { return [int]$match.Groups[1].Value }
        }
        catch { }
    }

    return 2
}

function Get-FirestoreRuleMetadata {
    param([string]$ProjectFolder)

    $etapeIds = @()
    $registryPath = Join-Path $ProjectFolder (Join-Path 'etapes' 'registry.js')
    if (Test-Path -LiteralPath $registryPath -PathType Leaf) {
        $registryText = [System.IO.File]::ReadAllText($registryPath, [System.Text.Encoding]::UTF8)
        $etapeIds = @(
            [regex]::Matches($registryText, 'id\s*:\s*["\x27](e\d+)["\x27]') |
                ForEach-Object { $_.Groups[1].Value } |
                Sort-Object -Unique
        )
    }
    if ($etapeIds.Count -eq 0) { $etapeIds = @('e1', 'e2', 'e3', 'e4') }

    $categories = [System.Collections.Generic.SortedSet[string]]::new()
    [void]$categories.Add('all')
    $etapesFolder = Join-Path $ProjectFolder 'etapes'
    if (Test-Path -LiteralPath $etapesFolder -PathType Container) {
        $jsFiles = Get-ChildItem -LiteralPath $etapesFolder -Filter 'etape*.js' -File -ErrorAction SilentlyContinue
        foreach ($jsFile in $jsFiles) {
            $jsText = [System.IO.File]::ReadAllText($jsFile.FullName, [System.Text.Encoding]::UTF8)
            foreach ($categoryMatch in [regex]::Matches($jsText, 'category\s*:\s*["\x27]([^"\x27\s]+)["\x27]')) {
                $category = $categoryMatch.Groups[1].Value.Trim()
                if (-not [string]::IsNullOrWhiteSpace($category)) {
                    [void]$categories.Add($category)
                }
            }
        }
    }

    $lengths = @(20, 30, 40, 50, 60, 70, 80)
    $indexPath = Join-Path $ProjectFolder 'index.html'
    if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
        $indexText = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
        $lengthMatch = [regex]::Match($indexText, 'const\s+LENGTH_OPTIONS\s*=\s*\[([^\]]+)\]')
        if ($lengthMatch.Success) {
            $foundLengths = @(
                $lengthMatch.Groups[1].Value -split ',' |
                    ForEach-Object { $_.Trim() } |
                    Where-Object { $_ -match '^\d+$' } |
                    ForEach-Object { [int]$_ } |
                    Sort-Object -Unique
            )
            if ($foundLengths.Count -gt 0) { $lengths = $foundLengths }
        }
    }

    return [pscustomobject]@{
        EtapeList = ($etapeIds | ForEach-Object { "'$_'" }) -join ', '
        CategoryLines = ($categories | ForEach-Object { "          '$_'" }) -join ",`r`n"
        LengthList = ($lengths -join ', ')
    }
}

function New-CompleteFirestoreRulesText {
    param(
        [string]$ProjectFolder,
        [int]$PlayerCount
    )

    if ($PlayerCount -lt 2 -or $PlayerCount -gt 6) { $PlayerCount = 2 }
    $meta = Get-FirestoreRuleMetadata -ProjectFolder $ProjectFolder

    return @"
rules_version = '2';

// Configured default for newly created matches: $PlayerCount players.
// The rules intentionally support every value from 2 through 6 so the
// Change Player Count tool can switch the website without another rules redesign.
service cloud.firestore {
  match /databases/{database}/documents {

    match /matches/{matchId} {

      function validCode() {
        return matchId.matches('^[A-Z]{4}$');
      }

      function validEtape(e) {
        return e in [$($meta.EtapeList)];
      }

      function validCategory(c) {
        return c in [
$($meta.CategoryLines)
        ];
      }

      function validPresence(joined, ready, id, active) {
        return joined is bool
          && ready is bool
          && id is string
          && (!ready || joined)
          && ((joined && id != '') || (!joined && id == ''))
          && (active || (!joined && !ready && id == ''));
      }

      function validProgress(score, done, time, currentCard, length, active) {
        return score is int
          && score >= 0
          && score <= length
          && done is bool
          && time is int
          && time >= 0
          && currentCard is int
          && currentCard >= 0
          && currentCard <= length
          && (active || (score == 0 && done == false && time == 0 && currentCard == 0));
      }

      function validPlayers(d) {
        return d.requiredPlayers is int
          && d.requiredPlayers >= 2
          && d.requiredPlayers <= 6
          && validPresence(d.p1Joined, d.p1Ready, d.p1Id, true)
          && validProgress(d.p1Score, d.p1Done, d.p1Time, d.p1CurrentCard, d.length, true)
          && validPresence(d.p2Joined, d.p2Ready, d.p2Id, true)
          && validProgress(d.p2Score, d.p2Done, d.p2Time, d.p2CurrentCard, d.length, true)
          && validPresence(d.p3Joined, d.p3Ready, d.p3Id, d.requiredPlayers >= 3)
          && validProgress(d.p3Score, d.p3Done, d.p3Time, d.p3CurrentCard, d.length, d.requiredPlayers >= 3)
          && validPresence(d.p4Joined, d.p4Ready, d.p4Id, d.requiredPlayers >= 4)
          && validProgress(d.p4Score, d.p4Done, d.p4Time, d.p4CurrentCard, d.length, d.requiredPlayers >= 4)
          && validPresence(d.p5Joined, d.p5Ready, d.p5Id, d.requiredPlayers >= 5)
          && validProgress(d.p5Score, d.p5Done, d.p5Time, d.p5CurrentCard, d.length, d.requiredPlayers >= 5)
          && validPresence(d.p6Joined, d.p6Ready, d.p6Id, d.requiredPlayers >= 6)
          && validProgress(d.p6Score, d.p6Done, d.p6Time, d.p6CurrentCard, d.length, d.requiredPlayers >= 6);
      }

      function allRequiredPlayersReady(d) {
        return d.p1Joined && d.p1Ready
          && d.p2Joined && d.p2Ready
          && (d.requiredPlayers < 3 || (d.p3Joined && d.p3Ready))
          && (d.requiredPlayers < 4 || (d.p4Joined && d.p4Ready))
          && (d.requiredPlayers < 5 || (d.p5Joined && d.p5Ready))
          && (d.requiredPlayers < 6 || (d.p6Joined && d.p6Ready));
      }

      function validCreate() {
        return validCode()
          && request.resource.data.keys().hasOnly([
            'createdAt', 'lastUpdate', 'status', 'etape', 'cards', 'length',
            'category', 'requiredPlayers',
            'p1Joined', 'p1Ready', 'p1Score', 'p1Done', 'p1Time', 'p1CurrentCard', 'p1Id',
            'p2Joined', 'p2Ready', 'p2Score', 'p2Done', 'p2Time', 'p2CurrentCard', 'p2Id',
            'p3Joined', 'p3Ready', 'p3Score', 'p3Done', 'p3Time', 'p3CurrentCard', 'p3Id',
            'p4Joined', 'p4Ready', 'p4Score', 'p4Done', 'p4Time', 'p4CurrentCard', 'p4Id',
            'p5Joined', 'p5Ready', 'p5Score', 'p5Done', 'p5Time', 'p5CurrentCard', 'p5Id',
            'p6Joined', 'p6Ready', 'p6Score', 'p6Done', 'p6Time', 'p6CurrentCard', 'p6Id'
          ])
          && request.resource.data.status == 'waiting'
          && validEtape(request.resource.data.etape)
          && request.resource.data.length in [$($meta.LengthList)]
          && validCategory(request.resource.data.category)
          && request.resource.data.cards is list
          && request.resource.data.cards.size() == request.resource.data.length
          && request.resource.data.p1Joined == true
          && request.resource.data.p1Ready == false
          && request.resource.data.p1Id != ''
          && request.resource.data.p2Joined == false
          && request.resource.data.p3Joined == false
          && request.resource.data.p4Joined == false
          && request.resource.data.p5Joined == false
          && request.resource.data.p6Joined == false
          && validPlayers(request.resource.data);
      }

      function validLobbyUpdate() {
        return resource.data.status == 'waiting'
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly([
            'lastUpdate', 'status', 'p1Ready',
            'p2Joined', 'p2Ready', 'p2Id',
            'p3Joined', 'p3Ready', 'p3Id',
            'p4Joined', 'p4Ready', 'p4Id',
            'p5Joined', 'p5Ready', 'p5Id',
            'p6Joined', 'p6Ready', 'p6Id'
          ])
          && request.resource.data.status in ['waiting', 'playing']
          && request.resource.data.p1Joined == true
          && validPlayers(request.resource.data)
          && (request.resource.data.status == 'waiting'
              || allRequiredPlayersReady(request.resource.data));
      }

      function validGameUpdate() {
        return resource.data.status == 'playing'
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly([
            'lastUpdate', 'status',
            'p1Score', 'p1Done', 'p1Time', 'p1CurrentCard',
            'p2Score', 'p2Done', 'p2Time', 'p2CurrentCard',
            'p3Score', 'p3Done', 'p3Time', 'p3CurrentCard',
            'p4Score', 'p4Done', 'p4Time', 'p4CurrentCard',
            'p5Score', 'p5Done', 'p5Time', 'p5CurrentCard',
            'p6Score', 'p6Done', 'p6Time', 'p6CurrentCard'
          ])
          && request.resource.data.status in ['playing', 'done']
          && validPlayers(request.resource.data);
      }

      function validResign() {
        return resource.data.status == 'playing'
          && request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['status', 'resignedBy', 'lastUpdate'])
          && request.resource.data.status == 'resigned'
          && request.resource.data.resignedBy is int
          && request.resource.data.resignedBy >= 1
          && request.resource.data.resignedBy <= resource.data.requiredPlayers;
      }

      allow read: if validCode();
      allow create: if validCreate();
      allow update: if validCode()
                    && (validLobbyUpdate() || validGameUpdate() || validResign());
      allow delete: if validCode() && resource.data.status == 'waiting';
    }
  }
}
"@
}

function Write-CurrentFirestoreRules {
    param([string]$ProjectFolder)

    $rulesPath = Join-Path $ProjectFolder 'firestore.rules'
    $playerCount = Read-ConfiguredPlayerCount -ProjectFolder $ProjectFolder
    $rulesText = New-CompleteFirestoreRulesText -ProjectFolder $ProjectFolder -PlayerCount $playerCount
    $oldText = $null
    if (Test-Path -LiteralPath $rulesPath -PathType Leaf) {
        try { $oldText = [System.IO.File]::ReadAllText($rulesPath, [System.Text.Encoding]::UTF8) } catch { }
    }

    if ($oldText -ne $rulesText) {
        Save-Utf8NoBom -Path $rulesPath -Text $rulesText
        return [pscustomobject]@{ Path = $rulesPath; Changed = $true; PlayerCount = $playerCount }
    }

    return [pscustomobject]@{ Path = $rulesPath; Changed = $false; PlayerCount = $playerCount }
}

function Update-FirestoreRules {
    param([string]$ProjectFolder)

    $result = Write-CurrentFirestoreRules -ProjectFolder $ProjectFolder
    if ($result.Changed) {
        Write-Ok "firestore.rules was completely rebuilt for 2 through 6 players. Current website default: $($result.PlayerCount) players."
        return $true
    }

    Write-Ok "firestore.rules is already the complete 2-through-6-player version. Current website default: $($result.PlayerCount) players."
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
    Write-Host 'VERSION 1.2 - FULL 2-TO-6 PLAYER RULES AUTO-BUILDER' -ForegroundColor DarkCyan
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
        Show-AppMessage -Title 'Local install — nothing to deploy' `
            -Message "This is a local (solo-only) install. It has no firestore.rules and does not use Firebase.`r`n`r`nFirestore rules only apply to the online (Firebase + GitHub) version." `
            -Type 'Info'
        Write-Info 'Local install — no Firestore rules to deploy.'
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
        -Message "The complete 2-to-6-player rules were rebuilt from the current units, categories, match lengths, and player-count setting, then deployed to Firebase project:`r`n`r`n$projectId`r`n`r`nThe changes take effect immediately - no page refresh needed." `
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
