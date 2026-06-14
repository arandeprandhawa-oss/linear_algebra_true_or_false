#requires -Version 5.1
<#
Adjust Timing & Length — Linear Algebra True or False

Opens a UI (same style as the Beginner editor) to change how the quiz behaves,
then writes the changes into every 1v1 page (index.html, etape1/3/4.html):

- Auto-advance timer: how long the answer/explanation stays on screen before
  the next card appears. Updates BOTH the countdown bar animation and the
  setTimeout that triggers the next card, so they stay in sync.
- Match length options: the list of choices on the lobby length picker, plus
  the default selected length.

The project folder is detected automatically (same logic as the editors).
A timestamped backup of each changed page is made before editing.
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
    $button.Size = New-Object System.Drawing.Size(160, 42)
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
    param([string]$Title, [string]$Subtitle, [int]$Width = 940, [int]$Height = 720)
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Linear Algebra True or False - Adjust timing and length'
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
    param([string]$Title, [string]$Message, [ValidateSet('Info','Success','Warning','Error')][string]$Type = 'Info')
    $icon = [System.Windows.Forms.MessageBoxIcon]::Information
    switch ($Type) {
        'Warning' { $icon = [System.Windows.Forms.MessageBoxIcon]::Warning }
        'Error'   { $icon = [System.Windows.Forms.MessageBoxIcon]::Error }
    }
    [void][System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

function Write-Step { param([string]$m) Write-Host ''; Write-Host '====================================================================' -ForegroundColor DarkGray; Write-Host $m -ForegroundColor Cyan; Write-Host '====================================================================' -ForegroundColor DarkGray }
function Write-Ok   { param([string]$m) Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Info { param([string]$m) Write-Host "[INFO] $m" -ForegroundColor Yellow }

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
# Reading and writing the tunable values
# =====================================================================
function Get-OneVOnePages {
    # Returns the 1v1 pages (these hold the timer + length settings).
    param([string]$ProjectFolder)
    Get-ChildItem -LiteralPath $ProjectFolder -Filter '*.html' -File |
        Where-Object { $_.Name -match '(?i)^(index|etape\d+)\.html$' }
}

function Read-CurrentSettings {
    # Reads the current timer (ms) and length options from index.html.
    param([string]$ProjectFolder)

    $indexPath = Join-Path $ProjectFolder 'index.html'
    $text = [System.IO.File]::ReadAllText($indexPath)

    $timerMs = 2000
    $m = [regex]::Match($text, "setTimeout\(\(\)=>\{autoTimer=null;nextCard\(\);\}\s*,\s*(\d+)\)")
    if ($m.Success) { $timerMs = [int]$m.Groups[1].Value }

    $lengthOptions = @(20, 30, 40, 50, 60, 70, 80)
    $lm = [regex]::Match($text, "const LENGTH_OPTIONS\s*=\s*\[([^\]]+)\]")
    if ($lm.Success) {
        $nums = $lm.Groups[1].Value -split ',' | ForEach-Object { ($_ -replace '[^0-9]', '') } | Where-Object { $_ -ne '' }
        if ($nums.Count -gt 0) { $lengthOptions = @($nums | ForEach-Object { [int]$_ }) }
    }

    $defaultLength = 20
    $dm = [regex]::Match($text, "let selectedLength\s*=\s*(\d+)")
    if ($dm.Success) { $defaultLength = [int]$dm.Groups[1].Value }

    return [pscustomobject]@{
        TimerMs = $timerMs
        LengthOptions = $lengthOptions
        DefaultLength = $defaultLength
    }
}

function Set-SettingsInFile {
    param(
        [string]$FilePath,
        [int]$TimerMs,
        [int[]]$LengthOptions,
        [int]$DefaultLength
    )

    $content = [System.IO.File]::ReadAllText($FilePath)
    $original = $content

    $timerSeconds = [math]::Round($TimerMs / 1000.0, 2)
    # Trim trailing zeros for the CSS value (e.g. 2.5s, 2s).
    $secondsText = ($timerSeconds.ToString([System.Globalization.CultureInfo]::InvariantCulture)).TrimEnd('0').TrimEnd('.')
    if ([string]::IsNullOrWhiteSpace($secondsText)) { $secondsText = '0' }

    # 1) setTimeout( ... , NNNN )
    $content = [regex]::Replace($content, "(setTimeout\(\(\)=>\{autoTimer=null;nextCard\(\);\}\s*,\s*)\d+(\))", "`${1}$TimerMs`$2")

    # 2) Countdown bar animation duration (autoBarShrink Xs ...)
    $content = [regex]::Replace($content, "(animation:autoBarShrink\s*)[0-9.]+s", "`${1}${secondsText}s")

    # 3) LENGTH_OPTIONS array
    $lengthList = ($LengthOptions -join ', ')
    $content = [regex]::Replace($content, "(const LENGTH_OPTIONS\s*=\s*\[)[^\]]*(\])", "`${1}$lengthList`$2")

    # 4) Default selected length
    $content = [regex]::Replace($content, "(let selectedLength\s*=\s*)\d+", "`${1}$DefaultLength")

    if ($content -ne $original) {
        Save-Utf8NoBom -Path $FilePath -Text $content
        return $true
    }
    return $false
}

function Backup-File {
    param([string]$ProjectFolder, [string]$FilePath)
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupRoot = Join-Path $ProjectFolder (Join-Path 'backups' (Join-Path 'timing-editor' $timestamp))
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    Copy-Item -LiteralPath $FilePath -Destination (Join-Path $backupRoot (Split-Path -Leaf $FilePath)) -Force
}

# =====================================================================
# MAIN
# =====================================================================
try {
    Clear-Host
    Write-Host 'LINEAR ALGEBRA QUIZ - ADJUST TIMING AND LENGTH' -ForegroundColor Magenta
    Write-Host 'VERSION 1 - TIMER + MATCH LENGTH EDITOR' -ForegroundColor DarkCyan
    Write-Host ''

    Initialize-Ui

    Write-Step 'STEP 1 OF 3 - Finding the project'
    $projectFolder = Find-AutomaticProject

    if ([string]::IsNullOrWhiteSpace($projectFolder)) {
        Show-AppMessage -Title 'Choose the project folder' -Message "The project was not found automatically.`r`n`r`nChoose the folder that contains index.html and the etapes folder." -Type 'Warning'
        $projectFolder = Show-ProjectFolderDialog -InitialFolder (Get-DownloadsFolder)
    }

    if ([string]::IsNullOrWhiteSpace($projectFolder)) { throw 'No project folder was selected.' }
    Write-Ok "Project: $projectFolder"

    $pages = @(Get-OneVOnePages -ProjectFolder $projectFolder)
    if ($pages.Count -eq 0) {
        Show-AppMessage -Title 'Nothing to adjust' -Message "This looks like a LOCAL (solo-only) install. The timer and length settings live on the 1v1 pages, which a local install does not include.`r`n`r`nUse the online (Firebase) install to adjust these." -Type 'Warning'
        Write-Info 'Local layout has no 1v1 pages — nothing to change.'
        [void](Read-Host 'Press Enter to close')
        exit 0
    }

    Write-Step 'STEP 2 OF 3 - Reading current settings'
    $current = Read-CurrentSettings -ProjectFolder $projectFolder
    Write-Ok ("Timer: {0:n1}s   Default length: {1}   Options: {2}" -f ($current.TimerMs/1000.0), $current.DefaultLength, ($current.LengthOptions -join ', '))

    # ---------- Build the settings window ----------
    $ui = New-AppWindow -Title 'Adjust timing and length' -Subtitle "Changes apply to all $($pages.Count) game page(s). A backup is made first."
    $form = $ui.Form

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $panel.Padding = New-Object System.Windows.Forms.Padding(30, 18, 30, 18)
    $panel.AutoScroll = $true
    $form.Controls.Add($panel)
    $ui.Header.BringToFront()

    $y = 10

    # --- Auto-advance timer ---
    $tLabel = New-Object System.Windows.Forms.Label
    $tLabel.Text = 'Auto-advance timer'
    $tLabel.Location = New-Object System.Drawing.Point(4, $y)
    $tLabel.Size = New-Object System.Drawing.Size(820, 22)
    $tLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 11)
    $tLabel.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $panel.Controls.Add($tLabel)
    $y += 26

    $tHint = New-Object System.Windows.Forms.Label
    $tHint.Text = 'How long the answer and explanation stay on screen before the next card. Higher = more time to read.'
    $tHint.Location = New-Object System.Drawing.Point(4, $y)
    $tHint.Size = New-Object System.Drawing.Size(840, 20)
    $tHint.Font = New-Object System.Drawing.Font('Segoe UI', 8.9)
    $tHint.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $panel.Controls.Add($tHint)
    $y += 26

    $tValueLabel = New-Object System.Windows.Forms.Label
    $tValueLabel.Location = New-Object System.Drawing.Point(640, $y)
    $tValueLabel.Size = New-Object System.Drawing.Size(180, 30)
    $tValueLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
    $tValueLabel.ForeColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
    $tValueLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $panel.Controls.Add($tValueLabel)

    $tBar = New-Object System.Windows.Forms.TrackBar
    $tBar.Minimum = 5     # 0.5s   (tenths of a second)
    $tBar.Maximum = 100   # 10.0s
    $tBar.TickFrequency = 5
    $tBar.SmallChange = 1
    $tBar.LargeChange = 5
    $tBar.Location = New-Object System.Drawing.Point(0, $y)
    $tBar.Size = New-Object System.Drawing.Size(630, 45)
    $tBar.Value = [Math]::Min(100, [Math]::Max(5, [int][math]::Round($current.TimerMs / 100.0)))
    $panel.Controls.Add($tBar)

    $updateTimerLabel = {
        $tenths = $tBar.Value
        $seconds = $tenths / 10.0
        $tValueLabel.Text = ('{0:n1} seconds' -f $seconds)
    }
    $tBar.Add_ValueChanged($updateTimerLabel)
    & $updateTimerLabel
    $y += 60

    # --- Default match length ---
    $dLabel = New-Object System.Windows.Forms.Label
    $dLabel.Text = 'Default match length'
    $dLabel.Location = New-Object System.Drawing.Point(4, $y)
    $dLabel.Size = New-Object System.Drawing.Size(820, 22)
    $dLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 11)
    $dLabel.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $panel.Controls.Add($dLabel)
    $y += 26

    $dHint = New-Object System.Windows.Forms.Label
    $dHint.Text = 'How many cards a Random match has by default (the highlighted choice in the length picker).'
    $dHint.Location = New-Object System.Drawing.Point(4, $y)
    $dHint.Size = New-Object System.Drawing.Size(840, 20)
    $dHint.Font = New-Object System.Drawing.Font('Segoe UI', 8.9)
    $dHint.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $panel.Controls.Add($dHint)
    $y += 26

    $dCombo = New-Object System.Windows.Forms.ComboBox
    $dCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $dCombo.Location = New-Object System.Drawing.Point(4, $y)
    $dCombo.Size = New-Object System.Drawing.Size(200, 28)
    $dCombo.Font = New-Object System.Drawing.Font('Segoe UI', 10.5)
    $panel.Controls.Add($dCombo)
    $y += 50

    # --- Length options ---
    $oLabel = New-Object System.Windows.Forms.Label
    $oLabel.Text = 'Match length choices'
    $oLabel.Location = New-Object System.Drawing.Point(4, $y)
    $oLabel.Size = New-Object System.Drawing.Size(820, 22)
    $oLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 11)
    $oLabel.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $panel.Controls.Add($oLabel)
    $y += 26

    $oHint = New-Object System.Windows.Forms.Label
    $oHint.Text = 'The buttons shown on the length picker. Enter whole numbers separated by commas (e.g. 20, 30, 40, 50).'
    $oHint.Location = New-Object System.Drawing.Point(4, $y)
    $oHint.Size = New-Object System.Drawing.Size(840, 20)
    $oHint.Font = New-Object System.Drawing.Font('Segoe UI', 8.9)
    $oHint.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $panel.Controls.Add($oHint)
    $y += 26

    $oBox = New-Object System.Windows.Forms.TextBox
    $oBox.Text = ($current.LengthOptions -join ', ')
    $oBox.Location = New-Object System.Drawing.Point(4, $y)
    $oBox.Size = New-Object System.Drawing.Size(820, 28)
    $oBox.Font = New-Object System.Drawing.Font('Segoe UI', 10.5)
    $panel.Controls.Add($oBox)
    $y += 50

    # Populate default-length dropdown from current options and keep it in sync.
    $refreshDefaults = {
        $dCombo.Items.Clear()
        $nums = $oBox.Text -split ',' | ForEach-Object { ($_ -replace '[^0-9]', '') } | Where-Object { $_ -ne '' } | ForEach-Object { [int]$_ }
        foreach ($n in $nums) { [void]$dCombo.Items.Add("$n cards") }
        if ($dCombo.Items.Count -gt 0) {
            $idx = 0
            for ($i = 0; $i -lt $nums.Count; $i++) { if ($nums[$i] -eq $current.DefaultLength) { $idx = $i; break } }
            $dCombo.SelectedIndex = $idx
        }
    }
    $oBox.Add_TextChanged($refreshDefaults)
    & $refreshDefaults

    # --- Buttons ---
    $applyBtn = New-UiButton -Text 'Apply to all pages' -Primary
    $applyBtn.Location = New-Object System.Drawing.Point(654, $y)
    $applyBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $panel.Controls.Add($applyBtn)

    $cancelBtn = New-UiButton -Text 'Cancel'
    $cancelBtn.Location = New-Object System.Drawing.Point(484, $y)
    $cancelBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $panel.Controls.Add($cancelBtn)

    $form.AcceptButton = $applyBtn
    $form.CancelButton = $cancelBtn

    $result = $form.ShowDialog()

    $newTimerMs = $tBar.Value * 100
    $newOptionsText = $oBox.Text
    $newDefaultText = if ($dCombo.SelectedItem) { ($dCombo.SelectedItem -replace '[^0-9]', '') } else { '' }
    $form.Dispose()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Info 'Cancelled. Nothing was changed.'
        [void](Read-Host 'Press Enter to close')
        exit 0
    }

    # Validate options
    $newOptions = @($newOptionsText -split ',' | ForEach-Object { ($_ -replace '[^0-9]', '') } | Where-Object { $_ -ne '' } | ForEach-Object { [int]$_ } | Sort-Object -Unique)
    if ($newOptions.Count -eq 0) { throw 'No valid length numbers were entered.' }

    $newDefault = if ([string]::IsNullOrWhiteSpace($newDefaultText)) { $newOptions[0] } else { [int]$newDefaultText }
    if ($newOptions -notcontains $newDefault) { $newDefault = $newOptions[0] }

    Write-Step 'STEP 3 OF 3 - Applying changes'
    Write-Info ("Timer -> {0:n1}s   Default -> {1}   Options -> {2}" -f ($newTimerMs/1000.0), $newDefault, ($newOptions -join ', '))

    $changed = 0
    foreach ($page in $pages) {
        Backup-File -ProjectFolder $projectFolder -FilePath $page.FullName
        if (Set-SettingsInFile -FilePath $page.FullName -TimerMs $newTimerMs -LengthOptions $newOptions -DefaultLength $newDefault) {
            $changed++
            Write-Host "  Updated: $($page.Name)" -ForegroundColor DarkCyan
        }
        else {
            Write-Host "  No change needed: $($page.Name)" -ForegroundColor DarkGray
        }
    }

    Write-Ok "Applied settings to $changed page(s). Backups are in backups\timing-editor\."

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Show-AppMessage -Title 'Settings applied' -Message "Updated $changed game page(s).`r`n`r`nTimer: $('{0:n1}' -f ($newTimerMs/1000.0)) seconds`r`nDefault length: $newDefault cards`r`nChoices: $($newOptions -join ', ')`r`n`r`nA backup of each page was saved under backups\timing-editor. Refresh the website to see the changes, then push with 'Update Entire Project to GitHub'." -Type 'Success'
}
catch {
    Write-Host ''
    Write-Host 'ADJUST TIMING STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    try { Show-AppMessage -Title 'Adjust timing stopped' -Message $_.Exception.Message -Type 'Error' } catch { }
    [void](Read-Host 'Press Enter to close')
    exit 1
}

[void](Read-Host 'Press Enter to close')
