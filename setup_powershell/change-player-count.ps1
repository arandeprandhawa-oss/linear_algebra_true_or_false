#requires -Version 5.1
<#
Change Player Count - Linear Algebra True or False

Visual editor for choosing how many players are required in a new online match.
Supported choices: 2, 3, 4, 5, or 6 players.

The tool:
- Finds the quiz project automatically.
- Updates multiplayer-config.js, which every multiplayer page reads.
- Verifies every multiplayer page loads that shared setting.
- Rebuilds firestore.rules for the 2-to-6-player lobby, ready states,
  scores, finish states, and resign state.
- Creates timestamped backups before changing files.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# =====================================================================
# UI helpers
# =====================================================================
function Initialize-Ui {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function New-UiButton {
    param(
        [string]$Text,
        [int]$Width = 190,
        [switch]$Primary
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Size = New-Object System.Drawing.Size($Width, 44)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)
    $button.FlatAppearance.BorderSize = 1

    if ($Primary) {
        $button.BackColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
        $button.ForeColor = [System.Drawing.Color]::White
        $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
    }
    else {
        $button.BackColor = [System.Drawing.Color]::White
        $button.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
        $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    }

    return $button
}

function Show-AppMessage {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error')]
        [string]$Type = 'Info'
    )

    $icon = [System.Windows.Forms.MessageBoxIcon]::Information
    if ($Type -eq 'Warning') { $icon = [System.Windows.Forms.MessageBoxIcon]::Warning }
    if ($Type -eq 'Error')   { $icon = [System.Windows.Forms.MessageBoxIcon]::Error }

    [void][System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        $icon
    )
}

function Save-Utf8NoBom {
    param(
        [string]$Path,
        [AllowEmptyString()]
        [string]$Text
    )

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}

# =====================================================================
# Project detection
# =====================================================================
function Get-DownloadsFolder {
    try {
        $registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
        $knownFolderId = '{374DE290-123F-4565-9164-39C4925E467B}'
        $item = Get-ItemProperty -Path $registryPath -Name $knownFolderId -ErrorAction Stop
        return [Environment]::ExpandEnvironmentVariables($item.$knownFolderId)
    }
    catch {
        $profilePath = [Environment]::GetFolderPath('UserProfile')
        if ([string]::IsNullOrWhiteSpace($profilePath)) { $profilePath = $env:USERPROFILE }
        return Join-Path $profilePath 'Downloads'
    }
}

function Get-StateFolder {
    $root = $env:LOCALAPPDATA
    if ([string]::IsNullOrWhiteSpace($root)) {
        $root = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'AppData\Local'
    }

    $folder = Join-Path $root 'LAQuizTools'
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    return $folder
}

function Test-QuizProject {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return $false }
    if (-not (Test-Path -LiteralPath (Join-Path $Path 'index.html') -PathType Leaf)) { return $false }
    if (-not (Test-Path -LiteralPath (Join-Path $Path 'firestore.rules') -PathType Leaf)) { return $false }
    if (-not (Test-Path -LiteralPath (Join-Path $Path 'etapes\registry.js') -PathType Leaf)) { return $false }
    return $true
}

function Find-ProjectRootFromPath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }

    $candidate = $Path
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $candidate = Split-Path -Parent $candidate
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) { return $null }

    $directory = Get-Item -LiteralPath $candidate
    while ($null -ne $directory) {
        if (Test-QuizProject -Path $directory.FullName) { return $directory.FullName }
        $directory = $directory.Parent
    }

    $children = Get-ChildItem -LiteralPath $candidate -Directory -ErrorAction SilentlyContinue |
        Sort-Object `
            @{ Expression = { if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 } } }, `
            @{ Expression = { $_.LastWriteTime }; Descending = $true }

    foreach ($child in $children) {
        if (Test-QuizProject -Path $child.FullName) { return $child.FullName }
    }

    return $null
}

function Get-RememberedProject {
    $stateFile = Join-Path (Get-StateFolder) 'last-player-count-project.txt'
    if (Test-Path -LiteralPath $stateFile -PathType Leaf) {
        try {
            $saved = [System.IO.File]::ReadAllText($stateFile, [System.Text.Encoding]::UTF8).Trim()
            if (Test-QuizProject -Path $saved) { return $saved }
        }
        catch { }
    }

    foreach ($name in @('last-javascript-project.txt','last-firebase-project.txt','last-local-project.txt')) {
        $candidateFile = Join-Path (Get-StateFolder) $name
        if (Test-Path -LiteralPath $candidateFile -PathType Leaf) {
            try {
                $saved = [System.IO.File]::ReadAllText($candidateFile, [System.Text.Encoding]::UTF8).Trim()
                if (Test-QuizProject -Path $saved) { return $saved }
            }
            catch { }
        }
    }

    return $null
}

function Find-AutomaticProject {
    $remembered = Get-RememberedProject
    if (-not [string]::IsNullOrWhiteSpace($remembered)) { return $remembered }

    $scriptFolder = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptFolder)) { $scriptFolder = (Get-Location).Path }

    $hit = Find-ProjectRootFromPath -Path $scriptFolder
    if (-not [string]::IsNullOrWhiteSpace($hit)) { return $hit }

    $hit = Find-ProjectRootFromPath -Path (Get-Location).Path
    if (-not [string]::IsNullOrWhiteSpace($hit)) { return $hit }

    $profilePath = [Environment]::GetFolderPath('UserProfile')
    $searchRoots = @(
        (Get-DownloadsFolder),
        [Environment]::GetFolderPath('Desktop'),
        [Environment]::GetFolderPath('MyDocuments'),
        (Join-Path $profilePath 'OneDrive'),
        (Join-Path $profilePath 'OneDrive\Desktop'),
        (Join-Path $profilePath 'OneDrive\Documents')
    ) | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_) -and
        (Test-Path -LiteralPath $_ -PathType Container)
    } | Select-Object -Unique

    $skip = @('.git','node_modules','backups','AppData','$RECYCLE.BIN','System Volume Information')

    foreach ($root in $searchRoots) {
        $queue = New-Object System.Collections.Queue
        $queue.Enqueue([pscustomobject]@{ Path = $root; Depth = 0 })
        $visited = 0

        while ($queue.Count -gt 0 -and $visited -lt 5000) {
            $entry = $queue.Dequeue()
            $visited++

            if (Test-QuizProject -Path $entry.Path) { return $entry.Path }
            if ($entry.Depth -ge 7) { continue }

            $children = Get-ChildItem -LiteralPath $entry.Path -Directory -Force -ErrorAction SilentlyContinue |
                Where-Object {
                    $skip -notcontains $_.Name -and
                    -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
                } |
                Sort-Object `
                    @{ Expression = { if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 } } }, `
                    @{ Expression = { $_.LastWriteTime }; Descending = $true }

            foreach ($child in $children) {
                $queue.Enqueue([pscustomobject]@{ Path = $child.FullName; Depth = $entry.Depth + 1 })
            }
        }
    }

    return $null
}

function Show-ProjectFolderDialog {
    param([string]$InitialFolder)

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose the Linear Algebra quiz folder that contains index.html'
    $dialog.ShowNewFolderButton = $false

    if (-not [string]::IsNullOrWhiteSpace($InitialFolder) -and
        (Test-Path -LiteralPath $InitialFolder -PathType Container)) {
        $dialog.SelectedPath = $InitialFolder
    }

    $result = $dialog.ShowDialog()
    $selected = $null
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selected = Find-ProjectRootFromPath -Path $dialog.SelectedPath
    }
    $dialog.Dispose()
    return $selected
}

# =====================================================================
# Project reading and writing
# =====================================================================
function Get-GamePages {
    param([string]$ProjectFolder)

    return @(
        Get-ChildItem -LiteralPath $ProjectFolder -Filter '*.html' -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^(?i:index|etape\d+)\.html$' } |
            Sort-Object Name
    )
}

function Read-CurrentPlayerCount {
    param([string]$ProjectFolder)

    $configPath = Join-Path $ProjectFolder 'multiplayer-config.js'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return 2 }

    $text = [System.IO.File]::ReadAllText($configPath, [System.Text.Encoding]::UTF8)
    $match = [regex]::Match($text, 'playerCount\s*:\s*([2-6])')
    if ($match.Success) { return [int]$match.Groups[1].Value }
    return 2
}

function Backup-ProjectFiles {
    param(
        [string]$ProjectFolder,
        [System.IO.FileInfo[]]$GamePages,
        [string]$Stamp
    )

    $backupRoot = Join-Path $ProjectFolder (Join-Path 'backups' (Join-Path 'player-count-editor' $Stamp))
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

    $targets = @(
        (Join-Path $ProjectFolder 'multiplayer-config.js'),
        (Join-Path $ProjectFolder 'firestore.rules')
    )
    $targets += @($GamePages | ForEach-Object { $_.FullName })

    foreach ($file in $targets | Select-Object -Unique) {
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            Copy-Item -LiteralPath $file -Destination (Join-Path $backupRoot (Split-Path -Leaf $file)) -Force
        }
    }

    return $backupRoot
}

function Ensure-ConfigLoaderInPage {
    param(
        [string]$PagePath,
        [string]$VersionToken
    )

    $content = [System.IO.File]::ReadAllText($PagePath, [System.Text.Encoding]::UTF8)
    $original = $content
    $loader = "<script src=`"multiplayer-config.js?v=$VersionToken`"></script>"

    # Always rewrite the loader with a new query string. This prevents the
    # browser and GitHub Pages from reusing an older cached player-count file.
    $existingPattern = '<script\s+src=["'']multiplayer-config\.js(?:\?[^"'']*)?["'']\s*></script>'
    if ([regex]::IsMatch($content, $existingPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $content = [regex]::Replace(
            $content,
            $existingPattern,
            $loader,
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }
    elseif ($content -match '<!--\s*Firebase \+ game logic\s*-->') {
        $replacement = '$1' + "`r`n" + $loader
        $content = [regex]::Replace(
            $content,
            '(<!--\s*Firebase \+ game logic\s*-->)',
            $replacement,
            1
        )
    }
    elseif ($content -match '<script\s+type=["'']module["'']>') {
        $replacement = $loader + "`r`n" + '$1'
        $content = [regex]::Replace(
            $content,
            '(<script\s+type=["'']module["'']>)',
            $replacement,
            1
        )
    }
    else {
        $content = $content.Replace('</body>', $loader + "`r`n</body>")
    }

    if ($content -ne $original) {
        Save-Utf8NoBom -Path $PagePath -Text $content
        return $true
    }

    return $false
}

function Get-RuleMetadata {
    param([string]$ProjectFolder)

    $registryPath = Join-Path $ProjectFolder 'etapes\registry.js'
    $registryText = [System.IO.File]::ReadAllText($registryPath, [System.Text.Encoding]::UTF8)
    $etapeIds = @(
        [regex]::Matches($registryText, "id\s*:\s*'(e\d+)'\s*,") |
            ForEach-Object { $_.Groups[1].Value } |
            Sort-Object -Unique
    )
    if ($etapeIds.Count -eq 0) { $etapeIds = @('e1','e2','e3','e4') }

    $categories = [System.Collections.Generic.SortedSet[string]]::new()
    [void]$categories.Add('all')
    $dataFiles = Get-ChildItem -LiteralPath (Join-Path $ProjectFolder 'etapes') -Filter 'etape*.js' -File -ErrorAction SilentlyContinue
    foreach ($file in $dataFiles) {
        $text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        foreach ($match in [regex]::Matches($text, 'category\s*:\s*["'']([^"''\s]+)["'']')) {
            [void]$categories.Add($match.Groups[1].Value)
        }
    }

    $lengths = @('20','30','40','50','60','70','80')
    $indexText = [System.IO.File]::ReadAllText((Join-Path $ProjectFolder 'index.html'), [System.Text.Encoding]::UTF8)
    $lengthMatch = [regex]::Match($indexText, 'const\s+LENGTH_OPTIONS\s*=\s*\[([^\]]+)\]')
    if ($lengthMatch.Success) {
        $foundLengths = @(
            $lengthMatch.Groups[1].Value -split ',' |
                ForEach-Object { $_.Trim() } |
                Where-Object { $_ -match '^\d+$' }
        )
        if ($foundLengths.Count -gt 0) { $lengths = $foundLengths }
    }

    return [pscustomobject]@{
        EtapeList = ($etapeIds | ForEach-Object { "'$_'" }) -join ', '
        CategoryLines = ($categories | ForEach-Object { "          '$_'" }) -join ",`r`n"
        LengthList = $lengths -join ', '
    }
}

function New-MultiplayerRulesText {
    param(
        [string]$ProjectFolder,
        [int]$PlayerCount
    )

    $meta = Get-RuleMetadata -ProjectFolder $ProjectFolder

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

function Apply-PlayerCount {
    param(
        [string]$ProjectFolder,
        [int]$PlayerCount,
        [bool]$CreateBackup
    )

    if (-not (Test-QuizProject -Path $ProjectFolder)) {
        throw 'The selected folder is not the online Linear Algebra quiz project.'
    }
    if ($PlayerCount -lt 2 -or $PlayerCount -gt 6) {
        throw 'Player count must be between 2 and 6.'
    }

    $gamePages = @(Get-GamePages -ProjectFolder $ProjectFolder)
    if ($gamePages.Count -eq 0) { throw 'No multiplayer HTML pages were found.' }

    $stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $backupPath = $null
    if ($CreateBackup) {
        $backupPath = Backup-ProjectFiles -ProjectFolder $ProjectFolder -GamePages $gamePages -Stamp $stamp
    }

    $configPath = Join-Path $ProjectFolder 'multiplayer-config.js'
    $configText = @"
// Change this value with "Change Player Count.cmd".
// Supported values: 2, 3, 4, 5, or 6.
window.MULTIPLAYER_CONFIG = Object.freeze({
  playerCount: $PlayerCount
});
"@
    Save-Utf8NoBom -Path $configPath -Text $configText

    $versionToken = (Get-Date -Format 'yyyyMMddHHmmss')
    $pageChanges = 0
    foreach ($page in $gamePages) {
        if (Ensure-ConfigLoaderInPage -PagePath $page.FullName -VersionToken $versionToken) { $pageChanges++ }
    }

    $rulesPath = Join-Path $ProjectFolder 'firestore.rules'
    $rulesText = New-MultiplayerRulesText -ProjectFolder $ProjectFolder -PlayerCount $PlayerCount
    Save-Utf8NoBom -Path $rulesPath -Text $rulesText

    $stateFile = Join-Path (Get-StateFolder) 'last-player-count-project.txt'
    Save-Utf8NoBom -Path $stateFile -Text $ProjectFolder

    return [pscustomobject]@{
        PlayerCount = $PlayerCount
        PageCount = $gamePages.Count
        PageChanges = $pageChanges
        BackupPath = $backupPath
        ConfigPath = $configPath
        RulesPath = $rulesPath
    }
}

# =====================================================================
# Main window
# =====================================================================
Initialize-Ui

$script:ProjectFolder = Find-AutomaticProject
$script:CurrentPlayerCount = 2
if (-not [string]::IsNullOrWhiteSpace($script:ProjectFolder)) {
    $script:CurrentPlayerCount = Read-CurrentPlayerCount -ProjectFolder $script:ProjectFolder
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Linear Algebra True or False - Change Player Count'
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ClientSize = New-Object System.Drawing.Size(1220, 800)
$form.MinimumSize = New-Object System.Drawing.Size(1080, 720)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
$form.ShowIcon = $false

# A root table reserves a real row for the header. This prevents the content
# panel from starting at Y=0 underneath the header on high-DPI displays.
$root = New-Object System.Windows.Forms.TableLayoutPanel
$root.Dock = [System.Windows.Forms.DockStyle]::Fill
$root.Margin = New-Object System.Windows.Forms.Padding(0)
$root.Padding = New-Object System.Windows.Forms.Padding(0)
$root.ColumnCount = 1
$root.RowCount = 2
$root.GrowStyle = [System.Windows.Forms.TableLayoutPanelGrowStyle]::FixedSize

$rootColumn = New-Object System.Windows.Forms.ColumnStyle
$rootColumn.SizeType = [System.Windows.Forms.SizeType]::Percent
$rootColumn.Width = 100
[void]$root.ColumnStyles.Add($rootColumn)

$headerRow = New-Object System.Windows.Forms.RowStyle
$headerRow.SizeType = [System.Windows.Forms.SizeType]::Absolute
$headerRow.Height = 135
[void]$root.RowStyles.Add($headerRow)

$contentRow = New-Object System.Windows.Forms.RowStyle
$contentRow.SizeType = [System.Windows.Forms.SizeType]::Percent
$contentRow.Height = 100
[void]$root.RowStyles.Add($contentRow)

$form.Controls.Add($root)

$header = New-Object System.Windows.Forms.Panel
$header.Dock = [System.Windows.Forms.DockStyle]::Fill
$header.Margin = New-Object System.Windows.Forms.Padding(0)
$header.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$root.Controls.Add($header, 0, 0)

$accent = New-Object System.Windows.Forms.Panel
$accent.Dock = [System.Windows.Forms.DockStyle]::Left
$accent.Width = 8
$accent.BackColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
$header.Controls.Add($accent)

$brand = New-Object System.Windows.Forms.Label
$brand.Text = 'LINEAR ALGEBRA TRUE OR FALSE'
$brand.AutoSize = $true
$brand.Location = New-Object System.Drawing.Point(38, 23)
$brand.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$brand.ForeColor = [System.Drawing.Color]::FromArgb(125, 211, 252)
$header.Controls.Add($brand)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'Multiplayer player-count editor'
$title.AutoSize = $false
$title.Location = New-Object System.Drawing.Point(36, 50)
$title.Size = New-Object System.Drawing.Size(1080, 40)
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 21)
$title.ForeColor = [System.Drawing.Color]::White
$header.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Choose 2, 3, 4, 5, or 6 players. Every multiplayer page and the Firestore rules stay in sync.'
$subtitle.AutoSize = $false
$subtitle.Location = New-Object System.Drawing.Point(38, 96)
$subtitle.Size = New-Object System.Drawing.Size(1100, 25)
$subtitle.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
$header.Controls.Add($subtitle)

# Use a two-column table instead of overlapping Dock=Fill/Dock=Left panels.
# The old docking order caused the right-hand controls to sit underneath the
# left panel on displays using Windows scaling, making the app appear stuck at
# "Find automatically". A TableLayoutPanel gives each side its own real column.
$body = New-Object System.Windows.Forms.TableLayoutPanel
$body.Dock = [System.Windows.Forms.DockStyle]::Fill
$body.Padding = New-Object System.Windows.Forms.Padding(0)
$body.Margin = New-Object System.Windows.Forms.Padding(0)
$body.ColumnCount = 2
$body.RowCount = 1
$body.GrowStyle = [System.Windows.Forms.TableLayoutPanelGrowStyle]::FixedSize

$leftColumn = New-Object System.Windows.Forms.ColumnStyle
$leftColumn.SizeType = [System.Windows.Forms.SizeType]::Absolute
$leftColumn.Width = 430
[void]$body.ColumnStyles.Add($leftColumn)

$rightColumn = New-Object System.Windows.Forms.ColumnStyle
$rightColumn.SizeType = [System.Windows.Forms.SizeType]::Percent
$rightColumn.Width = 100
[void]$body.ColumnStyles.Add($rightColumn)

$onlyRow = New-Object System.Windows.Forms.RowStyle
$onlyRow.SizeType = [System.Windows.Forms.SizeType]::Percent
$onlyRow.Height = 100
[void]$body.RowStyles.Add($onlyRow)
$root.Controls.Add($body, 0, 1)

$left = New-Object System.Windows.Forms.Panel
$left.Dock = [System.Windows.Forms.DockStyle]::Fill
$left.Margin = New-Object System.Windows.Forms.Padding(0)
$left.BackColor = [System.Drawing.Color]::White
$left.Padding = New-Object System.Windows.Forms.Padding(28, 26, 28, 24)
$body.Controls.Add($left, 0, 0)

$divider = New-Object System.Windows.Forms.Panel
$divider.Dock = [System.Windows.Forms.DockStyle]::Right
$divider.Width = 1
$divider.BackColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
$left.Controls.Add($divider)

$howTitle = New-Object System.Windows.Forms.Label
$howTitle.Text = 'How to use it'
$howTitle.AutoSize = $true
$howTitle.Location = New-Object System.Drawing.Point(34, 28)
$howTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 12)
$howTitle.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
$left.Controls.Add($howTitle)

$instructions = New-Object System.Windows.Forms.Label
$instructions.Text = "1. The project is found automatically.`r`n`r`n2. Choose the total number of players.`r`n`r`n3. Click Apply player count.`r`n`r`n4. For the live website, deploy the Firestore rules and push the project to GitHub."
$instructions.AutoSize = $false
$instructions.Location = New-Object System.Drawing.Point(34, 72)
$instructions.Size = New-Object System.Drawing.Size(345, 190)
$instructions.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$instructions.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$left.Controls.Add($instructions)

$detectionBox = New-Object System.Windows.Forms.Panel
$detectionBox.Location = New-Object System.Drawing.Point(28, 285)
$detectionBox.Size = New-Object System.Drawing.Size(350, 145)
$detectionBox.BackColor = [System.Drawing.Color]::FromArgb(239, 246, 255)
$detectionBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$left.Controls.Add($detectionBox)

$detectionTitle = New-Object System.Windows.Forms.Label
$detectionTitle.Text = 'Automatic project detection'
$detectionTitle.AutoSize = $false
$detectionTitle.Location = New-Object System.Drawing.Point(16, 18)
$detectionTitle.Size = New-Object System.Drawing.Size(315, 24)
$detectionTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$detectionTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
$detectionTitle.ForeColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
$detectionBox.Controls.Add($detectionTitle)

$detectionText = New-Object System.Windows.Forms.Label
$detectionText.AutoSize = $false
$detectionText.Location = New-Object System.Drawing.Point(18, 50)
$detectionText.Size = New-Object System.Drawing.Size(312, 80)
$detectionText.TextAlign = [System.Drawing.ContentAlignment]::TopCenter
$detectionText.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$detectionText.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$detectionBox.Controls.Add($detectionText)

$findButton = New-UiButton -Text 'Find automatically' -Width 350
$findButton.Location = New-Object System.Drawing.Point(28, 448)
$left.Controls.Add($findButton)

$chooseButton = New-UiButton -Text 'Choose a different folder' -Width 350
$chooseButton.Location = New-Object System.Drawing.Point(28, 502)
$left.Controls.Add($chooseButton)

$openButton = New-UiButton -Text 'Open project folder' -Width 350
$openButton.Location = New-Object System.Drawing.Point(28, 556)
$left.Controls.Add($openButton)

$right = New-Object System.Windows.Forms.Panel
$right.Dock = [System.Windows.Forms.DockStyle]::Fill
$right.Margin = New-Object System.Windows.Forms.Padding(0)
$right.AutoScroll = $true
$right.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
$body.Controls.Add($right, 1, 0)

$modeLabel = New-Object System.Windows.Forms.Label
$modeLabel.Text = 'Players required for each new match'
$modeLabel.AutoSize = $true
$modeLabel.Location = New-Object System.Drawing.Point(48, 34)
$modeLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
$modeLabel.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
$right.Controls.Add($modeLabel)

$playerCombo = New-Object System.Windows.Forms.ComboBox
$playerCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$playerCombo.Location = New-Object System.Drawing.Point(48, 66)
$playerCombo.Size = New-Object System.Drawing.Size(650, 34)
$playerCombo.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$playerCombo.Font = New-Object System.Drawing.Font('Segoe UI', 10)
foreach ($number in 2..6) {
    [void]$playerCombo.Items.Add("$number players")
}
$playerCombo.SelectedIndex = [Math]::Max(0, [Math]::Min(4, $script:CurrentPlayerCount - 2))
$right.Controls.Add($playerCombo)

$projectLabel = New-Object System.Windows.Forms.Label
$projectLabel.Text = 'Automatically detected project folder'
$projectLabel.AutoSize = $true
$projectLabel.Location = New-Object System.Drawing.Point(48, 120)
$projectLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
$projectLabel.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
$right.Controls.Add($projectLabel)

$projectBox = New-Object System.Windows.Forms.TextBox
$projectBox.Location = New-Object System.Drawing.Point(48, 151)
$projectBox.Size = New-Object System.Drawing.Size(650, 30)
$projectBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$projectBox.ReadOnly = $true
$projectBox.BackColor = [System.Drawing.Color]::White
$projectBox.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$right.Controls.Add($projectBox)

$details = New-Object System.Windows.Forms.Panel
$details.Location = New-Object System.Drawing.Point(48, 212)
$details.Size = New-Object System.Drawing.Size(650, 260)
$details.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$details.BackColor = [System.Drawing.Color]::White
$details.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$right.Controls.Add($details)

$detailsTitle = New-Object System.Windows.Forms.Label
$detailsTitle.Text = 'What will change'
$detailsTitle.AutoSize = $true
$detailsTitle.Location = New-Object System.Drawing.Point(22, 18)
$detailsTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 11)
$detailsTitle.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
$details.Controls.Add($detailsTitle)

$detailsText = New-Object System.Windows.Forms.Label
$detailsText.AutoSize = $false
$detailsText.Location = New-Object System.Drawing.Point(22, 56)
$detailsText.Size = New-Object System.Drawing.Size(600, 178)
$detailsText.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$detailsText.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$details.Controls.Add($detailsText)

$backupCheck = New-Object System.Windows.Forms.CheckBox
$backupCheck.Text = 'Create a timestamped backup before changing files'
$backupCheck.Checked = $true
$backupCheck.AutoSize = $true
$backupCheck.Location = New-Object System.Drawing.Point(48, 500)
$backupCheck.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$right.Controls.Add($backupCheck)

$refreshButton = New-UiButton -Text 'Refresh project' -Width 190
$refreshButton.Location = New-Object System.Drawing.Point(48, 548)
$right.Controls.Add($refreshButton)

$applyButton = New-UiButton -Text 'Apply player count' -Width 220 -Primary
$applyButton.Location = New-Object System.Drawing.Point(478, 548)
$right.Controls.Add($applyButton)
$form.AcceptButton = $applyButton

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.AutoSize = $false
$statusLabel.Location = New-Object System.Drawing.Point(48, 610)
$statusLabel.Size = New-Object System.Drawing.Size(650, 58)
$statusLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$statusLabel.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$right.Controls.Add($statusLabel)

function Refresh-WindowState {
    if (-not [string]::IsNullOrWhiteSpace($script:ProjectFolder) -and
        (Test-QuizProject -Path $script:ProjectFolder)) {
        $projectBox.Text = $script:ProjectFolder
        $detectionText.Text = "Found the online quiz project:`r`n$script:ProjectFolder"
        $detectionBox.BackColor = [System.Drawing.Color]::FromArgb(239, 246, 255)
        $applyButton.Enabled = $true
        $openButton.Enabled = $true

        $script:CurrentPlayerCount = Read-CurrentPlayerCount -ProjectFolder $script:ProjectFolder
        $playerCombo.SelectedIndex = [Math]::Max(0, [Math]::Min(4, $script:CurrentPlayerCount - 2))
        $statusLabel.Text = "Project detected. Current setting: $script:CurrentPlayerCount players. Choose a number above, then click Apply player count."
    }
    else {
        $projectBox.Text = ''
        $detectionText.Text = 'No online quiz project was found. Choose the folder that contains index.html and firestore.rules.'
        $detectionBox.BackColor = [System.Drawing.Color]::FromArgb(254, 242, 242)
        $applyButton.Enabled = $false
        $openButton.Enabled = $false
        $statusLabel.Text = 'Choose a project folder to continue.'
    }
}

function Refresh-DetailsText {
    $count = $playerCombo.SelectedIndex + 2
    $friendCount = $count - 1
    $friendWord = 'friends'
    if ($friendCount -eq 1) { $friendWord = 'friend' }

    $detailsText.Text = "New matches will require $count players total.`r`n`r`n" +
        "The host shares one code with $friendCount $friendWord. The waiting room shows Player 1 is ready, Player 2 is ready, and the same status for every extra player.`r`n`r`n" +
        "The scoreboard and final ranking expand automatically for all $count players.`r`n`r`n" +
        "Files updated: multiplayer-config.js, firestore.rules, and any multiplayer page missing the shared config loader."
}

$playerCombo.Add_SelectedIndexChanged({ Refresh-DetailsText })

$findButton.Add_Click({
    $form.UseWaitCursor = $true
    try {
        $found = Find-AutomaticProject
        if (-not [string]::IsNullOrWhiteSpace($found)) {
            $script:ProjectFolder = $found
        }
        else {
            Show-AppMessage -Title 'Project not found' -Message 'The project was not found automatically. Use Choose a different folder.' -Type Warning
        }
        Refresh-WindowState
        Refresh-DetailsText
    }
    finally {
        $form.UseWaitCursor = $false
    }
})

$chooseButton.Add_Click({
    $selected = Show-ProjectFolderDialog -InitialFolder $script:ProjectFolder
    if (-not [string]::IsNullOrWhiteSpace($selected)) {
        $script:ProjectFolder = $selected
        Refresh-WindowState
        Refresh-DetailsText
    }
    elseif (-not [string]::IsNullOrWhiteSpace($script:ProjectFolder)) {
        Show-AppMessage -Title 'Folder not changed' -Message 'No valid quiz project was selected.' -Type Warning
    }
})

$openButton.Add_Click({
    if (-not [string]::IsNullOrWhiteSpace($script:ProjectFolder) -and
        (Test-Path -LiteralPath $script:ProjectFolder -PathType Container)) {
        Start-Process explorer.exe -ArgumentList ('"' + $script:ProjectFolder + '"')
    }
})

$refreshButton.Add_Click({
    if (-not [string]::IsNullOrWhiteSpace($script:ProjectFolder)) {
        $script:CurrentPlayerCount = Read-CurrentPlayerCount -ProjectFolder $script:ProjectFolder
        $playerCombo.SelectedIndex = [Math]::Max(0, [Math]::Min(4, $script:CurrentPlayerCount - 2))
        Refresh-WindowState
        Refresh-DetailsText
    }
})

$applyButton.Add_Click({
    try {
        $count = $playerCombo.SelectedIndex + 2
        $applyButton.Enabled = $false
        $form.UseWaitCursor = $true
        $statusLabel.Text = "Updating every multiplayer page for $count players..."
        $form.Refresh()

        $result = Apply-PlayerCount `
            -ProjectFolder $script:ProjectFolder `
            -PlayerCount $count `
            -CreateBackup $backupCheck.Checked

        $script:CurrentPlayerCount = $count
        $statusLabel.Text = "Saved: $count players. Firestore rules were rebuilt."

        $backupLine = ''
        if (-not [string]::IsNullOrWhiteSpace($result.BackupPath)) {
            $backupLine = "`r`n`r`nBackup:`r`n$($result.BackupPath)"
        }

        $message = "The quiz is now configured for $count players.`r`n`r`n" +
            "Updated $($result.PageCount) multiplayer page(s).`r`n" +
            "Updated multiplayer-config.js.`r`n" +
            "Rebuilt firestore.rules for 2 through 6 players." +
            $backupLine +
            "`r`n`r`nFor the live site, next double-click:`r`n" +
            "1. Deploy Firestore Rules.cmd`r`n" +
            "2. Update Entire Project to GitHub.cmd`r`n" +
            "3. After GitHub finishes, press Ctrl+F5 on the website."

        Show-AppMessage -Title 'Player count updated' -Message $message -Type Success
    }
    catch {
        $statusLabel.Text = 'The update stopped because of an error.'
        Show-AppMessage -Title 'Could not update player count' -Message $_.Exception.Message -Type Error
    }
    finally {
        $form.UseWaitCursor = $false
        $applyButton.Enabled = $true
    }
})

Refresh-WindowState
Refresh-DetailsText
[void]$form.ShowDialog()
