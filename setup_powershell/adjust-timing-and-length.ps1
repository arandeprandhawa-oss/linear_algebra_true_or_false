#requires -Version 5.1
<#
Adjust Timers — Linear Algebra True or False

A simple typed-value editor for the quiz timing. It auto-detects the project
and writes the changes into every page that uses each value:

SOLO pages (solo*.html) — spaced repetition:
  - Auto-advance delay: how long the Again/Hard/Good/Easy panel stays before the
    card auto-advances with the suggested rating.
  - Learning steps: the two short intervals (in minutes) used while a card is
    still being learned. These drive the times shown on the Again / Good buttons.

1v1 pages (index.html, etape*.html) — head-to-head game:
  - Auto-advance delay: how long the answer/explanation stays on screen before
    the next card. The countdown bar and the actual delay are kept in sync.

A timestamped backup of each changed page is made first (backups\timing-editor).
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
    $button.Size = New-Object System.Drawing.Size(170, 42)
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
    param([string]$Title, [string]$Subtitle, [int]$Width = 940, [int]$Height = 760)
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Linear Algebra True or False - Adjust timers'
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size($Width, $Height)
    $form.MinimumSize = New-Object System.Drawing.Size(860, 680)
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
# Reading / writing the timer values
# =====================================================================
function Get-SoloPages   { param([string]$P) Get-ChildItem -LiteralPath $P -Filter 'solo*.html' -File }
function Get-GamePages   { param([string]$P) Get-ChildItem -LiteralPath $P -Filter '*.html' -File | Where-Object { $_.Name -match '(?i)^(index|etape\d+)\.html$' } }

function Read-CurrentTimers {
    param([string]$ProjectFolder)

    $soloDelayMs = 1500
    $stepAgain = 1
    $stepGood = 10
    $gameDelayMs = 2000

    $soloPages = @(Get-SoloPages -P $ProjectFolder)
    if ($soloPages.Count -gt 0) {
        $t = [System.IO.File]::ReadAllText($soloPages[0].FullName)
        $m = [regex]::Match($t, "const\s+autoDelay\s*=\s*(\d+)")
        if ($m.Success) { $soloDelayMs = [int]$m.Groups[1].Value }
        $sm = [regex]::Match($t, "steps\s*:\s*\[\s*(\d+)\s*,\s*(\d+)\s*\]")
        if ($sm.Success) { $stepAgain = [int]$sm.Groups[1].Value; $stepGood = [int]$sm.Groups[2].Value }
    }

    $gamePages = @(Get-GamePages -P $ProjectFolder)
    if ($gamePages.Count -gt 0) {
        $t = [System.IO.File]::ReadAllText($gamePages[0].FullName)
        $gm = [regex]::Match($t, "setTimeout\(\(\)=>\{autoTimer=null;nextCard\(\);\}\s*,\s*(\d+)\)")
        if ($gm.Success) { $gameDelayMs = [int]$gm.Groups[1].Value }
    }

    return [pscustomobject]@{
        SoloDelayMs = $soloDelayMs
        StepAgain = $stepAgain
        StepGood = $stepGood
        GameDelayMs = $gameDelayMs
        SoloCount = $soloPages.Count
        GameCount = $gamePages.Count
    }
}

function Backup-File {
    param([string]$ProjectFolder, [string]$FilePath, [string]$Stamp)
    $backupRoot = Join-Path $ProjectFolder (Join-Path 'backups' (Join-Path 'timing-editor' $Stamp))
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    Copy-Item -LiteralPath $FilePath -Destination (Join-Path $backupRoot (Split-Path -Leaf $FilePath)) -Force
}

function Set-SoloTimers {
    param([string]$FilePath, [int]$DelayMs, [int]$StepAgain, [int]$StepGood)
    $c = [System.IO.File]::ReadAllText($FilePath)
    $o = $c
    $c = [regex]::Replace($c, "(const\s+autoDelay\s*=\s*)\d+", "`${1}$DelayMs")
    $c = [regex]::Replace($c, "(steps\s*:\s*\[\s*)\d+(\s*,\s*)\d+(\s*\])", "`${1}$StepAgain`${2}$StepGood`${3}")
    if ($c -ne $o) { Save-Utf8NoBom -Path $FilePath -Text $c; return $true }
    return $false
}

function Set-GameTimer {
    param([string]$FilePath, [int]$DelayMs)
    $c = [System.IO.File]::ReadAllText($FilePath)
    $o = $c
    $seconds = [math]::Round($DelayMs / 1000.0, 2)
    $secondsText = ($seconds.ToString([System.Globalization.CultureInfo]::InvariantCulture)).TrimEnd('0').TrimEnd('.')
    if ([string]::IsNullOrWhiteSpace($secondsText)) { $secondsText = '0' }
    $c = [regex]::Replace($c, "(setTimeout\(\(\)=>\{autoTimer=null;nextCard\(\);\}\s*,\s*)\d+(\))", "`${1}$DelayMs`$2")
    $c = [regex]::Replace($c, "(animation:autoBarShrink\s*)[0-9.]+s", "`${1}${secondsText}s")
    if ($c -ne $o) { Save-Utf8NoBom -Path $FilePath -Text $c; return $true }
    return $false
}

# Add a labelled number box to a panel; returns the textbox.
function Add-NumberField {
    param(
        [System.Windows.Forms.Panel]$Panel,
        [ref]$Y,
        [string]$Title,
        [string]$Hint,
        [string]$Value,
        [string]$Suffix
    )
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $Title
    $lbl.Location = New-Object System.Drawing.Point(4, $Y.Value)
    $lbl.Size = New-Object System.Drawing.Size(820, 22)
    $lbl.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 11)
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $Panel.Controls.Add($lbl)
    $Y.Value += 26

    $h = New-Object System.Windows.Forms.Label
    $h.Text = $Hint
    $h.Location = New-Object System.Drawing.Point(4, $Y.Value)
    $h.Size = New-Object System.Drawing.Size(840, 36)
    $h.Font = New-Object System.Drawing.Font('Segoe UI', 8.9)
    $h.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $Panel.Controls.Add($h)
    $Y.Value += 40

    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Text = $Value
    $tb.Location = New-Object System.Drawing.Point(4, $Y.Value)
    $tb.Size = New-Object System.Drawing.Size(150, 28)
    $tb.Font = New-Object System.Drawing.Font('Segoe UI', 11)
    $tb.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
    $Panel.Controls.Add($tb)

    if (-not [string]::IsNullOrWhiteSpace($Suffix)) {
        $sfx = New-Object System.Windows.Forms.Label
        $sfx.Text = $Suffix
        $sfx.Location = New-Object System.Drawing.Point(162, ($Y.Value + 4))
        $sfx.Size = New-Object System.Drawing.Size(300, 22)
        $sfx.Font = New-Object System.Drawing.Font('Segoe UI', 10)
        $sfx.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
        $Panel.Controls.Add($sfx)
    }

    $Y.Value += 52
    return $tb
}

function Parse-PositiveNumber {
    param([string]$Text, [double]$Fallback)
    $clean = ($Text -replace '[^0-9.]', '')
    $value = 0.0
    if ([double]::TryParse($clean, [ref]$value) -and $value -gt 0) { return $value }
    return $Fallback
}

# =====================================================================
# MAIN
# =====================================================================
try {
    Clear-Host
    Write-Host 'LINEAR ALGEBRA QUIZ - ADJUST TIMERS' -ForegroundColor Magenta
    Write-Host 'VERSION 2 - TYPED TIMER EDITOR' -ForegroundColor DarkCyan
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

    Write-Step 'STEP 2 OF 3 - Reading current timers'
    $cur = Read-CurrentTimers -ProjectFolder $projectFolder
    Write-Ok ("Solo delay {0:n1}s | learning steps {1}/{2} min | 1v1 delay {3:n1}s" -f ($cur.SoloDelayMs/1000.0), $cur.StepAgain, $cur.StepGood, ($cur.GameDelayMs/1000.0))

    if ($cur.SoloCount -eq 0 -and $cur.GameCount -eq 0) {
        throw 'No solo or game pages were found in the project.'
    }

    # ---------- Build the window ----------
    $subtitle = "Type the values you want, then apply. Solo pages: $($cur.SoloCount)   1v1 pages: $($cur.GameCount)."
    $ui = New-AppWindow -Title 'Adjust timers' -Subtitle $subtitle
    $form = $ui.Form

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $panel.Padding = New-Object System.Windows.Forms.Padding(30, 18, 30, 18)
    $panel.AutoScroll = $true
    $form.Controls.Add($panel)
    $ui.Header.BringToFront()

    $y = 8
    $yref = [ref]$y

    $soloDelayBox = Add-NumberField -Panel $panel -Y $yref `
        -Title 'Auto-advance delay — Solo practice' `
        -Hint 'After you answer, how long the Again / Hard / Good / Easy panel stays before the card auto-advances with the suggested rating.' `
        -Value (("{0:n1}" -f ($cur.SoloDelayMs/1000.0)) -replace '\.0$','') `
        -Suffix 'seconds'

    $againBox = Add-NumberField -Panel $panel -Y $yref `
        -Title 'Learning step 1 — the "Again" interval' `
        -Hint 'When a card in the learning phase is rated Again, it comes back after this many minutes. This is the time shown on the Again button.' `
        -Value ([string]$cur.StepAgain) `
        -Suffix 'minutes'

    $goodBox = Add-NumberField -Panel $panel -Y $yref `
        -Title 'Learning step 2 — the "Good" interval' `
        -Hint 'The next learning step (in minutes) before a card graduates. This is the time shown on the Good button while a card is still being learned.' `
        -Value ([string]$cur.StepGood) `
        -Suffix 'minutes'

    $gameDelayBox = Add-NumberField -Panel $panel -Y $yref `
        -Title 'Auto-advance delay — 1v1 game' `
        -Hint 'On the head-to-head pages, how long the answer and explanation stay on screen before the next card. The countdown bar matches this automatically.' `
        -Value (("{0:n1}" -f ($cur.GameDelayMs/1000.0)) -replace '\.0$','') `
        -Suffix 'seconds'

    $applyBtn = New-UiButton -Text 'Apply to all pages' -Primary
    $applyBtn.Location = New-Object System.Drawing.Point(644, $y)
    $applyBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $panel.Controls.Add($applyBtn)

    $cancelBtn = New-UiButton -Text 'Cancel'
    $cancelBtn.Location = New-Object System.Drawing.Point(464, $y)
    $cancelBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $panel.Controls.Add($cancelBtn)

    $form.AcceptButton = $applyBtn
    $form.CancelButton = $cancelBtn

    $result = $form.ShowDialog()

    $soloDelayText = $soloDelayBox.Text
    $againText = $againBox.Text
    $goodText = $goodBox.Text
    $gameDelayText = $gameDelayBox.Text
    $form.Dispose()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Info 'Cancelled. Nothing was changed.'
        [void](Read-Host 'Press Enter to close')
        exit 0
    }

    # Parse and clamp to sensible values.
    $soloDelayMs = [int]([math]::Round((Parse-PositiveNumber -Text $soloDelayText -Fallback ($cur.SoloDelayMs/1000.0)) * 1000))
    $gameDelayMs = [int]([math]::Round((Parse-PositiveNumber -Text $gameDelayText -Fallback ($cur.GameDelayMs/1000.0)) * 1000))
    $stepAgain = [int][math]::Round((Parse-PositiveNumber -Text $againText -Fallback $cur.StepAgain))
    $stepGood = [int][math]::Round((Parse-PositiveNumber -Text $goodText -Fallback $cur.StepGood))

    if ($soloDelayMs -lt 200) { $soloDelayMs = 200 }
    if ($gameDelayMs -lt 200) { $gameDelayMs = 200 }
    if ($stepAgain -lt 1) { $stepAgain = 1 }
    if ($stepGood -lt 1) { $stepGood = 1 }

    Write-Step 'STEP 3 OF 3 - Applying changes'
    Write-Info ("Solo delay -> {0:n1}s | steps -> {1}/{2} min | 1v1 delay -> {3:n1}s" -f ($soloDelayMs/1000.0), $stepAgain, $stepGood, ($gameDelayMs/1000.0))

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $changed = 0

    foreach ($page in (Get-SoloPages -P $projectFolder)) {
        Backup-File -ProjectFolder $projectFolder -FilePath $page.FullName -Stamp $stamp
        if (Set-SoloTimers -FilePath $page.FullName -DelayMs $soloDelayMs -StepAgain $stepAgain -StepGood $stepGood) {
            $changed++; Write-Host "  Updated solo: $($page.Name)" -ForegroundColor DarkCyan
        }
    }

    foreach ($page in (Get-GamePages -P $projectFolder)) {
        Backup-File -ProjectFolder $projectFolder -FilePath $page.FullName -Stamp $stamp
        if (Set-GameTimer -FilePath $page.FullName -DelayMs $gameDelayMs) {
            $changed++; Write-Host "  Updated 1v1: $($page.Name)" -ForegroundColor DarkCyan
        }
    }

    Write-Ok "Applied to $changed page(s). Backups in backups\timing-editor\$stamp."

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Show-AppMessage -Title 'Timers updated' -Message "Updated $changed page(s).`r`n`r`nSolo auto-advance: $('{0:n1}' -f ($soloDelayMs/1000.0)) s`r`nLearning steps: $stepAgain min / $stepGood min`r`n1v1 auto-advance: $('{0:n1}' -f ($gameDelayMs/1000.0)) s`r`n`r`nA backup of each page was saved. Refresh the website to see the changes, then push with 'Update Entire Project to GitHub'." -Type 'Success'
}
catch {
    Write-Host ''
    Write-Host 'ADJUST TIMERS STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    try { Show-AppMessage -Title 'Adjust timers stopped' -Message $_.Exception.Message -Type 'Error' } catch { }
    [void](Read-Host 'Press Enter to close')
    exit 1
}

[void](Read-Host 'Press Enter to close')
