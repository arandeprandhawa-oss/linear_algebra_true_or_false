#requires -Version 5.1
<#
Add New Unit — Linear Algebra True or False

Adds a brand-new unit (étape) to the quiz and wires it into everything:
- Creates etapes/etapeN.js from a starter template (or an empty shell).
- Registers the unit in etapes/registry.js.
- Creates the 1v1 page (etapeN.html) by cloning an existing 1v1 page, and/or
  the solo page (soloN.html) by cloning an existing solo page.
- Rebuilds the ETAPE_PAGE_MAP / ETAPE_SOLO_MAP / ETAPE_LOBBY_MAP blocks in
  EVERY page from the registry, so navigation stays consistent.

Works for both layouts automatically:
- LOCAL (solo-only) install: only solo pages exist, so only a solo page is made.
- ONLINE (full) install: both the 1v1 page and the solo page are made.

The project folder is detected automatically (same logic as the editors).
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$RepositoryOwner = 'arandeprandhawa-oss'
$RepositoryName = 'linear_algebra_true_or_false'

# =====================================================================
# UI palette (matches the Beginner editor windows)
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
    $button.Size = New-Object System.Drawing.Size(150, 40)
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

function New-AppWindow {
    param(
        [string]$Title = 'Add a new unit',
        [string]$Subtitle = 'Create a new unit and wire it into every page automatically.',
        [int]$Width = 940,
        [int]$Height = 720
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Linear Algebra True or False - Add a new unit'
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size($Width, $Height)
    $form.MinimumSize = New-Object System.Drawing.Size(860, 640)
    $form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
    $form.ShowIcon = $false

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = [System.Windows.Forms.DockStyle]::Top
    $header.Height = 116
    $header.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $form.Controls.Add($header)

    $accent = New-Object System.Windows.Forms.Panel
    $accent.Dock = [System.Windows.Forms.DockStyle]::Left
    $accent.Width = 7
    $accent.BackColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
    $header.Controls.Add($accent)

    $brand = New-Object System.Windows.Forms.Label
    $brand.Text = 'LINEAR ALGEBRA TRUE OR FALSE'
    $brand.AutoSize = $true
    $brand.Location = New-Object System.Drawing.Point(30, 20)
    $brand.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 8.5)
    $brand.ForeColor = [System.Drawing.Color]::FromArgb(125, 211, 252)
    $header.Controls.Add($brand)

    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = $Title
    $titleLabel.AutoSize = $false
    $titleLabel.Location = New-Object System.Drawing.Point(28, 42)
    $titleLabel.Size = New-Object System.Drawing.Size(($Width - 80), 38)
    $titleLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 19)
    $titleLabel.ForeColor = [System.Drawing.Color]::White
    $header.Controls.Add($titleLabel)

    $subLabel = New-Object System.Windows.Forms.Label
    $subLabel.Text = $Subtitle
    $subLabel.AutoSize = $false
    $subLabel.Location = New-Object System.Drawing.Point(30, 84)
    $subLabel.Size = New-Object System.Drawing.Size(($Width - 80), 24)
    $subLabel.Font = New-Object System.Drawing.Font('Segoe UI', 9.8)
    $subLabel.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $header.Controls.Add($subLabel)

    return [pscustomobject]@{ Form = $form; Header = $header }
}

function Show-AppMessage {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )

    $icon = [System.Windows.Forms.MessageBoxIcon]::Information
    switch ($Type) {
        'Success' { $icon = [System.Windows.Forms.MessageBoxIcon]::Information }
        'Warning' { $icon = [System.Windows.Forms.MessageBoxIcon]::Warning }
        'Error'   { $icon = [System.Windows.Forms.MessageBoxIcon]::Error }
    }

    [void][System.Windows.Forms.MessageBox]::Show(
        $Message, $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

# =====================================================================
# Console helpers
# =====================================================================
function Write-Step { param([string]$m) Write-Host ''; Write-Host '====================================================================' -ForegroundColor DarkGray; Write-Host $m -ForegroundColor Cyan; Write-Host '====================================================================' -ForegroundColor DarkGray }
function Write-Ok   { param([string]$m) Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Info { param([string]$m) Write-Host "[INFO] $m" -ForegroundColor Yellow }
function Write-Warn { param([string]$m) Write-Host "[WARNING] $m" -ForegroundColor DarkYellow }

function Save-Utf8NoBom {
    param([string]$Path, [AllowEmptyString()][string]$Text)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}

# =====================================================================
# Project detection (compact version of the editor's logic)
# =====================================================================
function Get-DownloadsFolder {
    try {
        $item = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name '{374DE290-123F-4565-9164-39C4925E467B}' -ErrorAction Stop
        return [Environment]::ExpandEnvironmentVariables($item.'{374DE290-123F-4565-9164-39C4925E467B}')
    }
    catch {
        $profilePath = [Environment]::GetFolderPath('UserProfile')
        if ([string]::IsNullOrWhiteSpace($profilePath)) { $profilePath = $env:USERPROFILE }
        return Join-Path $profilePath 'Downloads'
    }
}

function Get-StateFolder {
    $root = $env:LOCALAPPDATA
    if ([string]::IsNullOrWhiteSpace($root)) { $root = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'AppData\Local' }
    $stateFolder = Join-Path $root 'LAQuizTools'
    New-Item -ItemType Directory -Path $stateFolder -Force | Out-Null
    return $stateFolder
}

function Get-RememberedProject {
    foreach ($mode in @('javascript', 'local', 'firebase')) {
        $stateFile = Join-Path (Get-StateFolder) "last-$mode-project.txt"
        if (Test-Path -LiteralPath $stateFile -PathType Leaf) {
            try {
                $saved = [System.IO.File]::ReadAllText($stateFile).Trim()
                if (Test-QuizProject -Path $saved) { return $saved }
            }
            catch { }
        }
    }
    return $null
}

function Test-QuizProject {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or (-not (Test-Path -LiteralPath $Path -PathType Container))) { return $false }
    if (-not (Test-Path -LiteralPath (Join-Path $Path 'index.html') -PathType Leaf)) { return $false }
    if (-not (Test-Path -LiteralPath (Join-Path $Path (Join-Path 'etapes' 'registry.js')) -PathType Leaf)) { return $false }
    return $true
}

function Find-ProjectRootFromPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $candidate = $Path
    if (Test-Path -LiteralPath $candidate -PathType Leaf) { $candidate = Split-Path -Parent $candidate }
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) { return $null }

    $directory = Get-Item -LiteralPath $candidate
    while ($null -ne $directory) {
        if (Test-QuizProject -Path $directory.FullName) { return $directory.FullName }
        $directory = $directory.Parent
    }

    # also one level down
    $children = Get-ChildItem -LiteralPath $candidate -Directory -ErrorAction SilentlyContinue |
        Sort-Object @{ Expression = { if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 } } }, @{ Expression = { $_.LastWriteTime }; Descending = $true }
    foreach ($child in $children) {
        if (Test-QuizProject -Path $child.FullName) { return $child.FullName }
    }
    return $null
}

function Get-SearchRoots {
    $profilePath = [Environment]::GetFolderPath('UserProfile')
    $roots = @(
        (Get-DownloadsFolder),
        [Environment]::GetFolderPath('MyDocuments'),
        [Environment]::GetFolderPath('Desktop'),
        (Join-Path $profilePath 'OneDrive'),
        (Join-Path $profilePath 'OneDrive\Documents'),
        (Join-Path $profilePath 'OneDrive\Desktop')
    )
    return @($roots | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_ -PathType Container) } | Select-Object -Unique)
}

function Find-QuizProjectUnderRoot {
    param([string]$Root, [int]$MaximumDepth = 7, [int]$MaximumDirectories = 6000)

    if ([string]::IsNullOrWhiteSpace($Root) -or (-not (Test-Path -LiteralPath $Root -PathType Container))) { return $null }

    $skip = @('.git', 'node_modules', 'backups', 'AppData', '$RECYCLE.BIN', 'System Volume Information', 'Windows', 'Program Files', 'Program Files (x86)')
    $queue = New-Object System.Collections.Queue
    $queue.Enqueue([pscustomobject]@{ Path = $Root; Depth = 0 })
    $visited = 0

    while ($queue.Count -gt 0 -and $visited -lt $MaximumDirectories) {
        $entry = $queue.Dequeue()
        $visited++
        if (Test-QuizProject -Path $entry.Path) { return $entry.Path }
        if ($entry.Depth -ge $MaximumDepth) { continue }

        $kids = Get-ChildItem -LiteralPath $entry.Path -Directory -Force -ErrorAction SilentlyContinue |
            Where-Object { $skip -notcontains $_.Name -and -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) } |
            Sort-Object @{ Expression = { if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 } } }, @{ Expression = { $_.LastWriteTime }; Descending = $true }

        foreach ($child in $kids) { $queue.Enqueue([pscustomobject]@{ Path = $child.FullName; Depth = $entry.Depth + 1 }) }
    }
    return $null
}

function Find-AutomaticProject {
    $remembered = Get-RememberedProject
    if (-not [string]::IsNullOrWhiteSpace($remembered)) { return $remembered }

    $scriptFolder = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptFolder)) { $scriptFolder = (Get-Location).Path }

    $fromScript = Find-ProjectRootFromPath -Path $scriptFolder
    if (-not [string]::IsNullOrWhiteSpace($fromScript)) { return $fromScript }

    $fromCwd = Find-ProjectRootFromPath -Path (Get-Location).Path
    if (-not [string]::IsNullOrWhiteSpace($fromCwd)) { return $fromCwd }

    foreach ($root in Get-SearchRoots) {
        $hit = Find-QuizProjectUnderRoot -Root $root
        if (-not [string]::IsNullOrWhiteSpace($hit)) { return $hit }
    }
    return $null
}

function Show-ProjectFolderDialog {
    param([string]$InitialFolder)
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose the Linear Algebra project folder (the one containing index.html)'
    $dialog.ShowNewFolderButton = $false
    if (-not [string]::IsNullOrWhiteSpace($InitialFolder) -and (Test-Path -LiteralPath $InitialFolder -PathType Container)) { $dialog.SelectedPath = $InitialFolder }
    $result = $dialog.ShowDialog()
    $selected = $null
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) { $selected = $dialog.SelectedPath }
    $dialog.Dispose()
    if ([string]::IsNullOrWhiteSpace($selected)) { return $null }
    return (Find-ProjectRootFromPath -Path $selected)
}

# =====================================================================
# Registry parsing / rebuilding
# =====================================================================
function Get-RegistryUnits {
    # Returns an ordered array of unit objects parsed from registry.js.
    param([string]$ProjectFolder)

    $registryPath = Join-Path $ProjectFolder (Join-Path 'etapes' 'registry.js')
    if (-not (Test-Path -LiteralPath $registryPath -PathType Leaf)) {
        throw "registry.js was not found at: $registryPath"
    }

    $text = [System.IO.File]::ReadAllText($registryPath)

    $units = @()
    # Match each { ... } object block inside the ETAPES array.
    $blockMatches = [regex]::Matches($text, '(?s)\{(.*?)\}')

    foreach ($m in $blockMatches) {
        $body = $m.Groups[1].Value
        if ($body -notmatch "id\s*:") { continue }

        $unit = [ordered]@{}
        foreach ($field in @('id', 'label', 'sublabel', 'titleMulti', 'titleSolo', 'sub', 'file')) {
            $fieldMatch = [regex]::Match($body, "$field\s*:\s*'((?:[^'\\]|\\.)*)'")
            if ($fieldMatch.Success) { $unit[$field] = $fieldMatch.Groups[1].Value } else { $unit[$field] = '' }
        }
        if (-not [string]::IsNullOrWhiteSpace($unit['id'])) { $units += ,([pscustomobject]$unit) }
    }

    return $units
}

function Get-DefaultEtape {
    param([string]$ProjectFolder)
    $registryPath = Join-Path $ProjectFolder (Join-Path 'etapes' 'registry.js')
    $text = [System.IO.File]::ReadAllText($registryPath)
    $m = [regex]::Match($text, "DEFAULT_ETAPE\s*=\s*'([^']+)'")
    if ($m.Success) { return $m.Groups[1].Value }
    return 'e1'
}

function Get-PageForEtape {
    # Returns the 1v1/lobby page filename for a unit id. e2 = index.html.
    param([string]$EtapeId)
    $num = $EtapeId -replace '^e', ''
    if ($num -eq '2') { return 'index.html' }
    return "etape$num.html"
}

function Get-SoloPageForEtape {
    # Returns the solo page filename for a unit id. e2 = solo.html.
    param([string]$EtapeId)
    $num = $EtapeId -replace '^e', ''
    if ($num -eq '2') { return 'solo.html' }
    return "solo$num.html"
}

function Build-MapBlock {
    # Builds a JS object body (without the closing brace) for a *_MAP.
    param(
        [string]$VariableName,   # e.g. 'window.ETAPE_PAGE_MAP'
        [pscustomobject[]]$Units,
        [scriptblock]$ValueFor   # given a unit id, returns the page filename
    )

    $lines = @()
    $lines += "$VariableName = {"
    for ($i = 0; $i -lt $Units.Count; $i++) {
        $id = $Units[$i].id
        $value = & $ValueFor $id
        $comma = if ($i -lt ($Units.Count - 1)) { ',' } else { '' }
        $lines += "  ${id}: '$value'$comma"
    }
    return ($lines -join "`n")
}

function Update-MapsInFile {
    # Rewrites whichever of the three maps exist in a page, from the registry.
    param(
        [string]$FilePath,
        [pscustomobject[]]$Units
    )

    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) { return $false }

    $content = [System.IO.File]::ReadAllText($FilePath)
    $original = $content

    $pageMap = Build-MapBlock -VariableName 'window.ETAPE_PAGE_MAP' -Units $Units -ValueFor { param($id) Get-PageForEtape -EtapeId $id }
    $soloMap = Build-MapBlock -VariableName 'window.ETAPE_SOLO_MAP' -Units $Units -ValueFor { param($id) Get-SoloPageForEtape -EtapeId $id }
    # LOBBY_MAP: in a local install index.html is a redirect, so if the 1v1
    # pages are absent we point lobby targets at index.html. Otherwise the
    # lobby target is the unit's 1v1 page.
    $projectFolder = Split-Path -Parent $FilePath
    $hasMultiplayerPages = Test-Path -LiteralPath (Join-Path $projectFolder 'etape1.html') -PathType Leaf
    $lobbyMap = Build-MapBlock -VariableName 'window.ETAPE_LOBBY_MAP' -Units $Units -ValueFor {
        param($id)
        if ($hasMultiplayerPages) { Get-PageForEtape -EtapeId $id } else { 'index.html' }
    }

    # Replace each map block's body up to (but not including) its closing brace.
    $content = [regex]::Replace($content, "(?s)window\.ETAPE_PAGE_MAP\s*=\s*\{.*?(?=\n\s*\})", [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $pageMap })
    $content = [regex]::Replace($content, "(?s)window\.ETAPE_SOLO_MAP\s*=\s*\{.*?(?=\n\s*\})", [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $soloMap })
    $content = [regex]::Replace($content, "(?s)window\.ETAPE_LOBBY_MAP\s*=\s*\{.*?(?=\n\s*\})", [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $lobbyMap })

    if ($content -ne $original) {
        Save-Utf8NoBom -Path $FilePath -Text $content
        return $true
    }
    return $false
}

function Add-RegistryEntry {
    param(
        [string]$ProjectFolder,
        [string]$EtapeId,
        [string]$Label,
        [string]$Sublabel,
        [string]$Topic,
        [int]$UnitNumber
    )

    $registryPath = Join-Path $ProjectFolder (Join-Path 'etapes' 'registry.js')
    $text = [System.IO.File]::ReadAllText($registryPath)

    $escTopic = $Topic.Replace("\", "\\").Replace("'", "\'")
    $escLabel = $Label.Replace("\", "\\").Replace("'", "\'")
    $escSub = $Sublabel.Replace("\", "\\").Replace("'", "\'")

    $newEntry = @"
  {
    id: '$EtapeId',
    label: '$escLabel',
    sublabel: '$escSub',
    titleMulti: 'Linear Algebra · True or False · $escLabel',
    titleSolo:  'Linear Algebra · Solo · $escLabel',
    sub: '$escTopic',
    file: 'etapes/etape$UnitNumber.js'
  }
"@

    # Insert before the closing "];" of the ETAPES array. Find the last "}" that
    # precedes the array close, and add a comma + the new entry.
    $arrayClose = [regex]::Match($text, "(?s)(window\.ETAPES\s*=\s*\[.*?)(\n\];)")
    if (-not $arrayClose.Success) {
        throw 'Could not locate the window.ETAPES array end in registry.js.'
    }

    $arrayBody = $arrayClose.Groups[1].Value
    $arrayEnd = $arrayClose.Groups[2].Value

    # Ensure the previous entry gets a trailing comma.
    $arrayBodyTrimmed = $arrayBody.TrimEnd()
    if (-not $arrayBodyTrimmed.EndsWith(',')) {
        $arrayBodyTrimmed += ','
    }

    $rebuilt = $arrayBodyTrimmed + "`n" + $newEntry + $arrayEnd
    $text = $text.Substring(0, $arrayClose.Index) + $rebuilt + $text.Substring($arrayClose.Index + $arrayClose.Length)

    Save-Utf8NoBom -Path $registryPath -Text $text
}

function New-EtapeDataFile {
    param(
        [string]$ProjectFolder,
        [int]$UnitNumber,
        [string]$Label,
        [string]$Topic,
        [string]$SourceJsFile   # optional path to an existing .js to copy questions from
    )

    $target = Join-Path $ProjectFolder (Join-Path 'etapes' "etape$UnitNumber.js")

    if (-not [string]::IsNullOrWhiteSpace($SourceJsFile) -and (Test-Path -LiteralPath $SourceJsFile -PathType Leaf)) {
        Copy-Item -LiteralPath $SourceJsFile -Destination $target -Force
        return $target
    }

    $starter = @"
// =====================================================================
// MATH 2210 Applied Linear Algebra — $Label — $Topic
// True/False flashcards
// =====================================================================

window.ETAPE_DATA = {
  vocab: [
    {en:"Replace this with your first true/false statement.", fr:"True", alts:["True","true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Explain why it is true here.", category:"topic"},
    {en:"Replace this with a false statement.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Explain why it is false here.", category:"topic"},
  ],
  categoryLabels: {
    all:"All Topics",
    topic:"$Topic",
  }
};
"@

    Save-Utf8NoBom -Path $target -Text $starter
    return $target
}

function New-UnitPageFromTemplate {
    # Clones an existing page of the same kind, swapping the étape id and js src.
    param(
        [string]$TemplatePath,
        [string]$NewPagePath,
        [string]$NewEtapeId,
        [int]$UnitNumber
    )

    $content = [System.IO.File]::ReadAllText($TemplatePath)

    # 1) Swap CURRENT_ETAPE_ID = '...'
    $content = [regex]::Replace($content, "window\.CURRENT_ETAPE_ID\s*=\s*'[^']+'", "window.CURRENT_ETAPE_ID = '$NewEtapeId'")

    # 2) Swap the étape data <script src="etapes/etapeN.js">
    $content = [regex]::Replace($content, "etapes/etape\d+\.js", "etapes/etape$UnitNumber.js")

    Save-Utf8NoBom -Path $NewPagePath -Text $content
}

# =====================================================================
# MAIN
# =====================================================================
try {
    Clear-Host
    Write-Host 'LINEAR ALGEBRA QUIZ - ADD A NEW UNIT' -ForegroundColor Magenta
    Write-Host 'VERSION 1 - AUTO-WIRE REGISTRY, PAGES, AND MAPS' -ForegroundColor DarkCyan
    Write-Host ''

    Initialize-Ui

    Write-Step 'STEP 1 OF 5 - Finding the project'
    $projectFolder = Find-AutomaticProject

    if ([string]::IsNullOrWhiteSpace($projectFolder)) {
        Show-AppMessage -Title 'Choose the project folder' -Message "The project was not found automatically.`r`n`r`nChoose the folder that contains index.html and the etapes folder." -Type 'Warning'
        $projectFolder = Show-ProjectFolderDialog -InitialFolder (Get-DownloadsFolder)
    }

    if ([string]::IsNullOrWhiteSpace($projectFolder)) {
        throw 'No project folder was selected.'
    }
    Write-Ok "Project: $projectFolder"

    # Detect layout: does this install have the 1v1 pages, or is it solo-only?
    $hasMultiplayer = Test-Path -LiteralPath (Join-Path $projectFolder 'etape1.html') -PathType Leaf
    $layoutName = if ($hasMultiplayer) { 'Online (1v1 + solo)' } else { 'Local (solo only)' }
    Write-Info "Detected layout: $layoutName"

    Write-Step 'STEP 2 OF 5 - Reading the current units'
    $existingUnits = @(Get-RegistryUnits -ProjectFolder $projectFolder)
    if ($existingUnits.Count -eq 0) { throw 'No existing units were found in registry.js.' }

    $usedNumbers = @()
    foreach ($u in $existingUnits) { $usedNumbers += [int]($u.id -replace '^e', '') }
    $nextNumber = ($usedNumbers | Measure-Object -Maximum).Maximum + 1
    Write-Ok "Found $($existingUnits.Count) unit(s). The new unit will be Unit $nextNumber (e$nextNumber)."

    # ---------- Build the input window ----------
    $ui = New-AppWindow -Title 'Add a new unit' -Subtitle "Detected: $layoutName  -  New unit will be e$nextNumber"
    $form = $ui.Form

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $panel.Padding = New-Object System.Windows.Forms.Padding(30, 18, 30, 18)
    $panel.AutoScroll = $true
    $form.Controls.Add($panel)
    $ui.Header.BringToFront()

    $y = 8
    function Add-FieldLabel {
        param([string]$Text, [string]$Hint)
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $Text
        $lbl.AutoSize = $false
        $lbl.Location = New-Object System.Drawing.Point(4, $script:y)
        $lbl.Size = New-Object System.Drawing.Size(840, 20)
        $lbl.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
        $lbl.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
        $panel.Controls.Add($lbl)
        $script:y += 22
        if (-not [string]::IsNullOrWhiteSpace($Hint)) {
            $h = New-Object System.Windows.Forms.Label
            $h.Text = $Hint
            $h.AutoSize = $false
            $h.Location = New-Object System.Drawing.Point(4, $script:y)
            $h.Size = New-Object System.Drawing.Size(840, 18)
            $h.Font = New-Object System.Drawing.Font('Segoe UI', 8.7)
            $h.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
            $panel.Controls.Add($h)
            $script:y += 20
        }
    }

    function Add-TextBox {
        param([string]$Default)
        $tb = New-Object System.Windows.Forms.TextBox
        $tb.Text = $Default
        $tb.Location = New-Object System.Drawing.Point(4, $script:y)
        $tb.Size = New-Object System.Drawing.Size(820, 28)
        $tb.Font = New-Object System.Drawing.Font('Segoe UI', 10.5)
        $panel.Controls.Add($tb)
        $script:y += 40
        return $tb
    }

    Add-FieldLabel -Text "Unit label" -Hint "Shown on the tab, e.g. 'Unit $nextNumber'."
    $labelBox = Add-TextBox -Default "Unit $nextNumber"

    Add-FieldLabel -Text "Topic / subtitle" -Hint "Short description shown under the title, e.g. 'Orthogonality & Least Squares'."
    $topicBox = Add-TextBox -Default ""

    Add-FieldLabel -Text "Tab badge (sublabel)" -Hint "The little number badge on the tab. A plain number is fine."
    $subBox = Add-TextBox -Default "$nextNumber"

    Add-FieldLabel -Text "Starter questions (optional)" -Hint "Pick an existing unit's .js to copy its questions as a starting point, or leave as 'Empty starter'."
    $sourceCombo = New-Object System.Windows.Forms.ComboBox
    $sourceCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $sourceCombo.Location = New-Object System.Drawing.Point(4, $y)
    $sourceCombo.Size = New-Object System.Drawing.Size(820, 28)
    $sourceCombo.Font = New-Object System.Drawing.Font('Segoe UI', 10.5)
    [void]$sourceCombo.Items.Add('Empty starter (2 placeholder cards)')
    foreach ($u in $existingUnits) {
        [void]$sourceCombo.Items.Add("Copy from $($u.label)  ($($u.file))")
    }
    $sourceCombo.SelectedIndex = 0
    $panel.Controls.Add($sourceCombo)
    $y += 48

    # Buttons at the bottom
    $createBtn = New-UiButton -Text 'Create unit' -Primary
    $createBtn.Location = New-Object System.Drawing.Point(674, $y)
    $createBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $panel.Controls.Add($createBtn)

    $cancelBtn = New-UiButton -Text 'Cancel'
    $cancelBtn.Location = New-Object System.Drawing.Point(514, $y)
    $cancelBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $panel.Controls.Add($cancelBtn)

    $form.AcceptButton = $createBtn
    $form.CancelButton = $cancelBtn

    $result = $form.ShowDialog()

    $label = $labelBox.Text.Trim()
    $topic = $topicBox.Text.Trim()
    $sublabel = $subBox.Text.Trim()
    $sourceIndex = $sourceCombo.SelectedIndex
    $form.Dispose()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Info 'Cancelled. No unit was added.'
        [void](Read-Host 'Press Enter to close')
        exit 0
    }

    if ([string]::IsNullOrWhiteSpace($label)) { $label = "Unit $nextNumber" }
    if ([string]::IsNullOrWhiteSpace($sublabel)) { $sublabel = "$nextNumber" }
    if ([string]::IsNullOrWhiteSpace($topic)) { $topic = "$label" }

    $newEtapeId = "e$nextNumber"
    $sourceJs = $null
    if ($sourceIndex -gt 0) {
        $sourceUnit = $existingUnits[$sourceIndex - 1]
        $sourceJs = Join-Path $projectFolder ($sourceUnit.file -replace '/', '\')
    }

    Write-Step 'STEP 3 OF 5 - Creating the unit data and registry entry'

    $jsPath = New-EtapeDataFile -ProjectFolder $projectFolder -UnitNumber $nextNumber -Label $label -Topic $topic -SourceJsFile $sourceJs
    Write-Ok "Created data file: $(Split-Path -Leaf $jsPath)"

    Add-RegistryEntry -ProjectFolder $projectFolder -EtapeId $newEtapeId -Label $label -Sublabel $sublabel -Topic $topic -UnitNumber $nextNumber
    Write-Ok "Registered $newEtapeId in registry.js"

    Write-Step 'STEP 4 OF 5 - Creating the unit pages'

    # Solo page (always — both layouts have solo pages).
    $defaultEtape = Get-DefaultEtape -ProjectFolder $projectFolder
    $soloTemplateId = if ($defaultEtape -ne $newEtapeId) { $defaultEtape } else { $existingUnits[0].id }
    $soloTemplate = Join-Path $projectFolder (Get-SoloPageForEtape -EtapeId $soloTemplateId)
    if (-not (Test-Path -LiteralPath $soloTemplate -PathType Leaf)) {
        # fall back to any existing solo page
        $soloTemplate = Join-Path $projectFolder (Get-SoloPageForEtape -EtapeId $existingUnits[0].id)
    }
    $newSoloPage = Join-Path $projectFolder (Get-SoloPageForEtape -EtapeId $newEtapeId)
    New-UnitPageFromTemplate -TemplatePath $soloTemplate -NewPagePath $newSoloPage -NewEtapeId $newEtapeId -UnitNumber $nextNumber
    Write-Ok "Created solo page: $(Split-Path -Leaf $newSoloPage)"

    # 1v1 page (only when the online layout is present).
    if ($hasMultiplayer) {
        $multiTemplateId = $existingUnits[0].id
        # Prefer a numbered 1v1 page as template (not index.html) for simplicity.
        foreach ($u in $existingUnits) {
            if (($u.id -replace '^e', '') -ne '2') { $multiTemplateId = $u.id; break }
        }
        $multiTemplate = Join-Path $projectFolder (Get-PageForEtape -EtapeId $multiTemplateId)
        if (-not (Test-Path -LiteralPath $multiTemplate -PathType Leaf)) {
            $multiTemplate = Join-Path $projectFolder 'index.html'
        }
        $newMultiPage = Join-Path $projectFolder (Get-PageForEtape -EtapeId $newEtapeId)
        New-UnitPageFromTemplate -TemplatePath $multiTemplate -NewPagePath $newMultiPage -NewEtapeId $newEtapeId -UnitNumber $nextNumber
        Write-Ok "Created 1v1 page: $(Split-Path -Leaf $newMultiPage)"
    }
    else {
        Write-Info 'Local layout — skipping the 1v1 page (solo only).'
    }

    Write-Step 'STEP 5 OF 5 - Updating navigation on every page'

    $allUnits = @(Get-RegistryUnits -ProjectFolder $projectFolder)
    $pagesToUpdate = Get-ChildItem -LiteralPath $projectFolder -Filter '*.html' -File |
        Where-Object { $_.Name -match '(?i)^(index|etape\d+|solo\d*)\.html$' }

    $updated = 0
    foreach ($page in $pagesToUpdate) {
        if (Update-MapsInFile -FilePath $page.FullName -Units $allUnits) {
            $updated++
            Write-Host "  Updated navigation: $($page.Name)" -ForegroundColor DarkCyan
        }
    }
    Write-Ok "Navigation maps refreshed in $updated page(s)."

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Write-Host "New unit: $label ($newEtapeId)" -ForegroundColor Cyan
    Write-Host "Edit its questions in: etapes\etape$nextNumber.js" -ForegroundColor Cyan
    Write-Host 'Tip: use Edit Quiz JavaScript to fill in the real questions.' -ForegroundColor Yellow

    Show-AppMessage -Title 'New unit added' -Message "Added $label ($newEtapeId).`r`n`r`nData file: etapes\etape$nextNumber.js`r`nSolo page: $(Split-Path -Leaf $newSoloPage)$(if($hasMultiplayer){"`r`n1v1 page: $(Split-Path -Leaf (Join-Path $projectFolder (Get-PageForEtape -EtapeId $newEtapeId)))"})`r`n`r`nNavigation was updated on every page. Use 'Edit Quiz JavaScript' to add the real questions, then push with 'Update Entire Project to GitHub'." -Type 'Success'
}
catch {
    Write-Host ''
    Write-Host 'ADD UNIT STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    try {
        Show-AppMessage -Title 'Add unit stopped' -Message $_.Exception.Message -Type 'Error'
    }
    catch { }
    [void](Read-Host 'Press Enter to close')
    exit 1
}

[void](Read-Host 'Press Enter to close')
