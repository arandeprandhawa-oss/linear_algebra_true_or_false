#requires -Version 5.1
<#
Beginner-friendly editor for the Linear Algebra True/False website.

This script:
- Opens a polished Windows popup.
- Detects the project folder automatically when possible.
- Lets the user browse for or drag and drop a project folder or code file.
- Lists JavaScript files in a drop-down menu.
- Can also show HTML files when JavaScript is embedded in the page.
- Creates a timestamped backup before opening the selected file.
- Opens the file in Windows Notepad.

It does not install anything and does not upload changes to GitHub.
#>

$ErrorActionPreference = 'Stop'

function Initialize-EditorUi {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function New-EditorButton {
    param(
        [string]$Text,
        [switch]$Primary,
        [int]$Width = 132
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Size = New-Object System.Drawing.Size($Width, 39)
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
        $button.ForeColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
        $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    }

    return $button
}

function Show-EditorMessage {
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

    return $downloads
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

function Get-EditorStateFolder {
    $root = $env:LOCALAPPDATA

    if ([string]::IsNullOrWhiteSpace($root)) {
        $root = Join-Path `
            ([Environment]::GetFolderPath('UserProfile')) `
            'AppData\Local'
    }

    $stateFolder = Join-Path $root 'LAQuizTools'
    New-Item -ItemType Directory -Path $stateFolder -Force | Out-Null

    return $stateFolder
}

function Save-RememberedProject {
    param(
        [ValidateSet('local', 'firebase', 'javascript')]
        [string]$Mode,
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path) -or
        (-not (Test-Path -LiteralPath $Path -PathType Container))) {
        return
    }

    $stateFile = Join-Path (Get-EditorStateFolder) "last-$Mode-project.txt"

    [System.IO.File]::WriteAllText(
        $stateFile,
        $Path,
        (New-Object System.Text.UTF8Encoding($false))
    )
}

function Get-RememberedProject {
    param(
        [ValidateSet('local', 'firebase', 'javascript')]
        [string]$Mode
    )

    $stateFile = Join-Path (Get-EditorStateFolder) "last-$Mode-project.txt"

    if (-not (Test-Path -LiteralPath $stateFile -PathType Leaf)) {
        return $null
    }

    try {
        $savedPath = [System.IO.File]::ReadAllText($stateFile, [System.Text.Encoding]::UTF8).Trim()

        if (Test-QuizProject -Path $savedPath) {
            return $savedPath
        }
    }
    catch {
        return $null
    }

    return $null
}

function Test-QuizProject {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or
        (-not (Test-Path -LiteralPath $Path -PathType Container))) {
        return $false
    }

    $indexPath = Join-Path $Path 'index.html'

    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
        return $false
    }

    $rootHtmlFiles = @(
        Get-ChildItem `
            -LiteralPath $Path `
            -Filter '*.html' `
            -File `
            -ErrorAction SilentlyContinue
    )

    $hasKnownQuizPage = $false

    foreach ($htmlFile in $rootHtmlFiles) {
        if ($htmlFile.Name -match '(?i)^(solo\d*|etape\d*|quiz|flashcards?)\.html$') {
            $hasKnownQuizPage = $true
            break
        }
    }

    $hasSetupFolder =
        Test-Path `
            -LiteralPath (Join-Path $Path 'setup_powershell') `
            -PathType Container

    $folderName = Split-Path -Leaf $Path
    $nameLooksCorrect =
        $folderName -match '(?i)linear.*algebra|true.*false|algebra.*quiz'

    return (
        $hasKnownQuizPage -or
        $hasSetupFolder -or
        $nameLooksCorrect -or
        $rootHtmlFiles.Count -ge 3
    )
}

function Find-ProjectRootFromPath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $candidate = $Path

    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $candidate = Split-Path -Parent $candidate
    }

    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) {
        return $null
    }

    $directory = Get-Item -LiteralPath $candidate

    while ($null -ne $directory) {
        if (Test-QuizProject -Path $directory.FullName) {
            return $directory.FullName
        }

        $directory = $directory.Parent
    }

    return $null
}

function Get-SearchRoots {
    $profile = [Environment]::GetFolderPath('UserProfile')
    $documents = [Environment]::GetFolderPath('MyDocuments')
    $desktop = [Environment]::GetFolderPath('Desktop')
    $downloads = Get-DownloadsFolder

    $roots = @(
        $downloads,
        $documents,
        $desktop,
        (Join-Path $profile 'OneDrive'),
        (Join-Path $profile 'OneDrive\Documents'),
        (Join-Path $profile 'OneDrive\Desktop')
    )

    return @(
        $roots |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_) -and
                (Test-Path -LiteralPath $_ -PathType Container)
            } |
            Select-Object -Unique
    )
}

function Get-PrioritizedChildDirectories {
    param([string]$Path)

    $skipNames = @(
        '.git',
        'node_modules',
        'backups',
        'AppData',
        '$RECYCLE.BIN',
        'System Volume Information',
        'Windows',
        'Program Files',
        'Program Files (x86)'
    )

    return @(
        Get-ChildItem `
            -LiteralPath $Path `
            -Directory `
            -Force `
            -ErrorAction SilentlyContinue |
            Where-Object {
                $skipNames -notcontains $_.Name -and
                -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
            } |
            Sort-Object `
                @{ Expression = {
                    if ($_.Name -match '(?i)linear.*algebra|true.*false|algebra.*quiz') {
                        0
                    }
                    else {
                        1
                    }
                } },
                @{ Expression = { $_.LastWriteTime }; Descending = $true }
    )
}

function Find-QuizProjectsUnderRoot {
    param(
        [string]$Root,
        [int]$MaximumDepth = 7,
        [int]$MaximumDirectories = 7000
    )

    $found = New-Object System.Collections.ArrayList

    if ([string]::IsNullOrWhiteSpace($Root) -or
        (-not (Test-Path -LiteralPath $Root -PathType Container))) {
        return @()
    }

    $queue = New-Object System.Collections.Queue
    $queue.Enqueue([pscustomobject]@{
        Path = $Root
        Depth = 0
    })

    $visited = 0

    while ($queue.Count -gt 0 -and $visited -lt $MaximumDirectories) {
        $entry = $queue.Dequeue()
        $visited++

        if (Test-QuizProject -Path $entry.Path) {
            [void]$found.Add($entry.Path)
        }

        if ($entry.Depth -ge $MaximumDepth) {
            continue
        }

        foreach ($child in Get-PrioritizedChildDirectories -Path $entry.Path) {
            $queue.Enqueue([pscustomobject]@{
                Path = $child.FullName
                Depth = $entry.Depth + 1
            })
        }
    }

    return @($found)
}

function Get-ProjectScore {
    param(
        [string]$Path,
        [string]$ScriptFolder,
        [string[]]$RememberedPaths,
        [switch]$PreferGit
    )

    $score = 0

    if ($RememberedPaths -contains $Path) {
        $score += 3000
    }

    if (-not [string]::IsNullOrWhiteSpace($ScriptFolder)) {
        try {
            $scriptFull = [System.IO.Path]::GetFullPath($ScriptFolder)
            $pathFull = [System.IO.Path]::GetFullPath($Path)

            if ($scriptFull.StartsWith(
                $pathFull.TrimEnd('\') + '\',
                [System.StringComparison]::OrdinalIgnoreCase
            )) {
                $score += 2200
            }
        }
        catch {
            # Ignore path normalization errors and continue scoring.
        }
    }

    $hasGit = Test-Path -LiteralPath (Join-Path $Path '.git') -PathType Container

    if ($PreferGit) {
        if ($hasGit) {
            $score += 1200
        }
        else {
            $score -= 600
        }
    }
    elseif (-not $hasGit) {
        $score += 350
    }

    if (Test-Path -LiteralPath (Join-Path $Path 'setup_powershell') -PathType Container) {
        $score += 250
    }

    $leaf = Split-Path -Leaf $Path

    if ($leaf -match '(?i)^linear_algebra_true_or_false') {
        $score += 500
    }
    elseif ($leaf -match '(?i)linear.*algebra|true.*false|algebra.*quiz') {
        $score += 350
    }

    $knownPages = 0

    foreach ($pageName in @(
        'solo.html',
        'solo1.html',
        'solo3.html',
        'solo4.html',
        'etape1.html',
        'etape3.html',
        'etape4.html'
    )) {
        if (Test-Path -LiteralPath (Join-Path $Path $pageName) -PathType Leaf) {
            $knownPages++
        }
    }

    $score += ($knownPages * 45)

    try {
        $indexFile = Get-Item -LiteralPath (Join-Path $Path 'index.html')
        $ageDays = ((Get-Date) - $indexFile.LastWriteTime).TotalDays

        if ($ageDays -lt 2) {
            $score += 180
        }
        elseif ($ageDays -lt 30) {
            $score += 90
        }
    }
    catch {
        # Test-QuizProject already checks index.html.
    }

    return $score
}

function Find-AutomaticQuizProject {
    param(
        [ValidateSet('local', 'firebase', 'javascript')]
        [string]$Mode = 'javascript'
    )

    $scriptFolder = $PSScriptRoot

    if ([string]::IsNullOrWhiteSpace($scriptFolder)) {
        $scriptFolder = (Get-Location).Path
    }

    $remembered = @()

    foreach ($rememberMode in @(
        $Mode,
        'local',
        'firebase',
        'javascript'
    ) | Select-Object -Unique) {
        $rememberedPath = Get-RememberedProject -Mode $rememberMode

        if (-not [string]::IsNullOrWhiteSpace($rememberedPath)) {
            $remembered += $rememberedPath
        }
    }

    if ($remembered.Count -gt 0) {
        if ($Mode -eq 'firebase') {
            foreach ($rememberedPath in $remembered) {
                if (Test-Path -LiteralPath (Join-Path $rememberedPath '.git') -PathType Container) {
                    return $rememberedPath
                }
            }
        }
        else {
            return $remembered[0]
        }
    }

    $ancestorProject = Find-ProjectRootFromPath -Path $scriptFolder

    if (-not [string]::IsNullOrWhiteSpace($ancestorProject)) {
        if ($Mode -ne 'firebase' -or
            (Test-Path -LiteralPath (Join-Path $ancestorProject '.git') -PathType Container)) {
            return $ancestorProject
        }
    }

    $currentProject = Find-ProjectRootFromPath -Path (Get-Location).Path

    if (-not [string]::IsNullOrWhiteSpace($currentProject)) {
        if ($Mode -ne 'firebase' -or
            (Test-Path -LiteralPath (Join-Path $currentProject '.git') -PathType Container)) {
            return $currentProject
        }
    }

    $candidatePaths = New-Object System.Collections.ArrayList

    foreach ($rememberedPath in $remembered) {
        [void]$candidatePaths.Add($rememberedPath)
    }

    if (-not [string]::IsNullOrWhiteSpace($ancestorProject)) {
        [void]$candidatePaths.Add($ancestorProject)
    }

    if (-not [string]::IsNullOrWhiteSpace($currentProject)) {
        [void]$candidatePaths.Add($currentProject)
    }

    foreach ($root in Get-SearchRoots) {
        foreach ($candidate in Find-QuizProjectsUnderRoot -Root $root) {
            [void]$candidatePaths.Add($candidate)
        }
    }

    $uniqueCandidates = @(
        $candidatePaths |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            } |
            Select-Object -Unique
    )

    if ($uniqueCandidates.Count -eq 0) {
        return $null
    }

    $preferGit = $Mode -eq 'firebase'
    $ranked = @()

    foreach ($candidate in $uniqueCandidates) {
        $ranked += [pscustomobject]@{
            Path = $candidate
            Score = Get-ProjectScore `
                -Path $candidate `
                -ScriptFolder $scriptFolder `
                -RememberedPaths $remembered `
                -PreferGit:$preferGit
        }
    }

    $best = $ranked |
        Sort-Object Score -Descending |
        Select-Object -First 1

    if ($null -eq $best) {
        return $null
    }

    Save-RememberedProject -Mode $Mode -Path $best.Path
    return $best.Path
}

function Get-AutomaticProjectFolder {
    return Find-AutomaticQuizProject -Mode 'javascript'
}

function Get-EditableFiles {
    param(
        [string]$ProjectFolder,
        [bool]$IncludeHtml
    )

    if (-not (Test-Path -LiteralPath $ProjectFolder -PathType Container)) {
        return @()
    }

    $extensions = @('.js', '.mjs', '.cjs')
    if ($IncludeHtml) {
        $extensions += '.html'
    }

    $files = Get-ChildItem -LiteralPath $ProjectFolder -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object {
            $extensionMatches = $extensions -contains $_.Extension.ToLowerInvariant()
            $excluded = $_.FullName -match '[\\/]\.git[\\/]' -or
                        $_.FullName -match '[\\/]node_modules[\\/]' -or
                        $_.FullName -match '[\\/]backups[\\/]' -or
                        $_.FullName -match '[\\/]setup_powershell[\\/]'

            $extensionMatches -and (-not $excluded)
        } |
        Sort-Object FullName

    $result = @()
    foreach ($file in $files) {
        $relative = Get-RelativePathSafe -BasePath $ProjectFolder -FullPath $file.FullName
        $result += [pscustomobject]@{
            Display = $relative
            RelativePath = $relative
            FullPath = $file.FullName
            Extension = $file.Extension
            SizeBytes = $file.Length
            LastWriteTime = $file.LastWriteTime
        }
    }

    return $result
}

function Format-FileSize {
    param([long]$Bytes)

    if ($Bytes -ge 1MB) {
        return ('{0:N2} MB' -f ($Bytes / 1MB))
    }

    if ($Bytes -ge 1KB) {
        return ('{0:N1} KB' -f ($Bytes / 1KB))
    }

    return "$Bytes bytes"
}

function Create-FileBackup {
    param(
        [string]$ProjectFolder,
        [pscustomobject]$SelectedFile
    )

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupRoot = Join-Path $ProjectFolder (Join-Path 'backups\javascript-editor' $timestamp)
    $backupFile = Join-Path $backupRoot $SelectedFile.RelativePath
    $backupDirectory = Split-Path -Parent $backupFile

    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    Copy-Item -LiteralPath $SelectedFile.FullPath -Destination $backupFile -Force

    return $backupFile
}

function Show-ProjectFolderDialog {
    param([string]$InitialFolder)

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose the main website project folder'
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

function Start-JavaScriptEditor {
    $script:ProjectFolder = Get-AutomaticProjectFolder
    $script:EditableFiles = @()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Linear Algebra Quiz Code Editor'
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size(1040, 720)
    $form.MinimumSize = New-Object System.Drawing.Size(900, 650)
    $form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
    $form.AllowDrop = $true
    $form.ShowIcon = $false

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = [System.Windows.Forms.DockStyle]::Top
    $header.Height = 118
    $header.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $form.Controls.Add($header)

    $accent = New-Object System.Windows.Forms.Panel
    $accent.Dock = [System.Windows.Forms.DockStyle]::Left
    $accent.Width = 8
    $accent.BackColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
    $header.Controls.Add($accent)

    $brand = New-Object System.Windows.Forms.Label
    $brand.Text = 'LINEAR ALGEBRA TRUE OR FALSE'
    $brand.AutoSize = $true
    $brand.Location = New-Object System.Drawing.Point(31, 18)
    $brand.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 8.5)
    $brand.ForeColor = [System.Drawing.Color]::FromArgb(125, 211, 252)
    $header.Controls.Add($brand)

    $title = New-Object System.Windows.Forms.Label
    $title.Text = 'Beginner JavaScript editor'
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(28, 42)
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 18)
    $title.ForeColor = [System.Drawing.Color]::White
    $header.Controls.Add($title)

    $subtitle = New-Object System.Windows.Forms.Label
    $subtitle.Text = 'Choose a file from the drop-down menu, create a safe backup, and open it in Notepad.'
    $subtitle.AutoSize = $true
    $subtitle.Location = New-Object System.Drawing.Point(31, 82)
    $subtitle.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $subtitle.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $header.Controls.Add($subtitle)

    $leftPanel = New-Object System.Windows.Forms.Panel
    $leftPanel.Dock = [System.Windows.Forms.DockStyle]::Left
    $leftPanel.Width = 315
    $leftPanel.Padding = New-Object System.Windows.Forms.Padding(22)
    $leftPanel.BackColor = [System.Drawing.Color]::White
    $form.Controls.Add($leftPanel)

    $rightPanel = New-Object System.Windows.Forms.Panel
    $rightPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $rightPanel.Padding = New-Object System.Windows.Forms.Padding(28, 24, 28, 22)
    $rightPanel.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $form.Controls.Add($rightPanel)

    $header.BringToFront()

    $instructionsTitle = New-Object System.Windows.Forms.Label
    $instructionsTitle.Text = 'How to use it'
    $instructionsTitle.AutoSize = $true
    $instructionsTitle.Location = New-Object System.Drawing.Point(22, 24)
    $instructionsTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 12)
    $instructionsTitle.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $leftPanel.Controls.Add($instructionsTitle)

    $instructions = New-Object System.Windows.Forms.Label
    $instructions.Text = "1. Choose or drop the project folder.`r`n`r`n2. Pick a file from the drop-down menu.`r`n`r`n3. Click Open in Notepad.`r`n`r`n4. Make your changes and press Ctrl+S."
    $instructions.AutoSize = $false
    $instructions.Location = New-Object System.Drawing.Point(22, 59)
    $instructions.Size = New-Object System.Drawing.Size(270, 190)
    $instructions.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $instructions.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
    $leftPanel.Controls.Add($instructions)

    $dropPanel = New-Object System.Windows.Forms.Panel
    $dropPanel.Location = New-Object System.Drawing.Point(22, 255)
    $dropPanel.Size = New-Object System.Drawing.Size(270, 142)
    $dropPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $dropPanel.BackColor = [System.Drawing.Color]::FromArgb(239, 246, 255)
    $dropPanel.AllowDrop = $true
    $dropPanel.Cursor = [System.Windows.Forms.Cursors]::Hand
    $leftPanel.Controls.Add($dropPanel)

    $dropTitle = New-Object System.Windows.Forms.Label
    $dropTitle.Text = 'Drag and drop here'
    $dropTitle.AutoSize = $false
    $dropTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $dropTitle.Location = New-Object System.Drawing.Point(10, 28)
    $dropTitle.Size = New-Object System.Drawing.Size(248, 28)
    $dropTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 11)
    $dropTitle.ForeColor = [System.Drawing.Color]::FromArgb(30, 64, 175)
    $dropPanel.Controls.Add($dropTitle)

    $dropText = New-Object System.Windows.Forms.Label
    $dropText.Text = "Drop a project folder or a .js file.`r`nThe project will be detected automatically."
    $dropText.AutoSize = $false
    $dropText.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $dropText.Location = New-Object System.Drawing.Point(14, 60)
    $dropText.Size = New-Object System.Drawing.Size(240, 58)
    $dropText.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
    $dropPanel.Controls.Add($dropText)

    $browseButton = New-EditorButton -Text 'Choose a different folder' -Width 270
    $browseButton.Location = New-Object System.Drawing.Point(22, 416)
    $leftPanel.Controls.Add($browseButton)

    $openFolderButton = New-EditorButton -Text 'Find project automatically' -Width 270
    $openFolderButton.Location = New-Object System.Drawing.Point(22, 465)
    $leftPanel.Controls.Add($openFolderButton)

    $helpBox = New-Object System.Windows.Forms.Panel
    $helpBox.Location = New-Object System.Drawing.Point(22, 526)
    $helpBox.Size = New-Object System.Drawing.Size(270, 86)
    $helpBox.BackColor = [System.Drawing.Color]::FromArgb(240, 253, 244)
    $leftPanel.Controls.Add($helpBox)

    $helpText = New-Object System.Windows.Forms.Label
    $helpText.Text = "Backups are stored inside:`r`nbackups\javascript-editor"
    $helpText.AutoSize = $false
    $helpText.Location = New-Object System.Drawing.Point(13, 15)
    $helpText.Size = New-Object System.Drawing.Size(244, 56)
    $helpText.ForeColor = [System.Drawing.Color]::FromArgb(22, 101, 52)
    $helpBox.Controls.Add($helpText)

    $projectLabel = New-Object System.Windows.Forms.Label
    $projectLabel.Text = 'Project folder'
    $projectLabel.AutoSize = $true
    $projectLabel.Location = New-Object System.Drawing.Point(28, 25)
    $projectLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
    $projectLabel.ForeColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
    $rightPanel.Controls.Add($projectLabel)

    $projectPathBox = New-Object System.Windows.Forms.TextBox
    $projectPathBox.ReadOnly = $true
    $projectPathBox.Location = New-Object System.Drawing.Point(28, 53)
    $projectPathBox.Size = New-Object System.Drawing.Size(625, 31)
    $projectPathBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $projectPathBox.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $projectPathBox.BackColor = [System.Drawing.Color]::White
    $rightPanel.Controls.Add($projectPathBox)

    $fileLabel = New-Object System.Windows.Forms.Label
    $fileLabel.Text = 'Choose a file'
    $fileLabel.AutoSize = $true
    $fileLabel.Location = New-Object System.Drawing.Point(28, 111)
    $fileLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
    $fileLabel.ForeColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
    $rightPanel.Controls.Add($fileLabel)

    $fileCombo = New-Object System.Windows.Forms.ComboBox
    $fileCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $fileCombo.Location = New-Object System.Drawing.Point(28, 140)
    $fileCombo.Size = New-Object System.Drawing.Size(625, 32)
    $fileCombo.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $fileCombo.Font = New-Object System.Drawing.Font('Segoe UI', 10.5)
    $rightPanel.Controls.Add($fileCombo)

    $includeHtmlCheck = New-Object System.Windows.Forms.CheckBox
    $includeHtmlCheck.Text = 'Also show HTML files (useful when JavaScript is inside the page)'
    $includeHtmlCheck.AutoSize = $true
    $includeHtmlCheck.Location = New-Object System.Drawing.Point(30, 187)
    $includeHtmlCheck.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
    $rightPanel.Controls.Add($includeHtmlCheck)

    $detailsPanel = New-Object System.Windows.Forms.Panel
    $detailsPanel.Location = New-Object System.Drawing.Point(28, 227)
    $detailsPanel.Size = New-Object System.Drawing.Size(625, 174)
    $detailsPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $detailsPanel.BackColor = [System.Drawing.Color]::White
    $detailsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $rightPanel.Controls.Add($detailsPanel)

    $detailsHeading = New-Object System.Windows.Forms.Label
    $detailsHeading.Text = 'Selected file details'
    $detailsHeading.AutoSize = $true
    $detailsHeading.Location = New-Object System.Drawing.Point(18, 17)
    $detailsHeading.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10.5)
    $detailsHeading.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $detailsPanel.Controls.Add($detailsHeading)

    $detailsText = New-Object System.Windows.Forms.Label
    $detailsText.Text = 'Choose a project folder to begin.'
    $detailsText.AutoSize = $false
    $detailsText.Location = New-Object System.Drawing.Point(18, 51)
    $detailsText.Size = New-Object System.Drawing.Size(585, 100)
    $detailsText.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $detailsText.Font = New-Object System.Drawing.Font('Segoe UI', 9.8)
    $detailsText.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
    $detailsPanel.Controls.Add($detailsText)

    $backupCheck = New-Object System.Windows.Forms.CheckBox
    $backupCheck.Text = 'Create a timestamped backup before opening the file'
    $backupCheck.Checked = $true
    $backupCheck.AutoSize = $true
    $backupCheck.Location = New-Object System.Drawing.Point(30, 425)
    $backupCheck.ForeColor = [System.Drawing.Color]::FromArgb(30, 64, 175)
    $rightPanel.Controls.Add($backupCheck)

    $refreshButton = New-EditorButton -Text 'Refresh files'
    $refreshButton.Location = New-Object System.Drawing.Point(28, 475)
    $rightPanel.Controls.Add($refreshButton)

    $openButton = New-EditorButton -Text 'Open in Notepad' -Primary -Width 165
    $openButton.Location = New-Object System.Drawing.Point(488, 475)
    $openButton.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $openButton.Enabled = $false
    $rightPanel.Controls.Add($openButton)

    $statusPanel = New-Object System.Windows.Forms.Panel
    $statusPanel.Location = New-Object System.Drawing.Point(28, 535)
    $statusPanel.Size = New-Object System.Drawing.Size(625, 65)
    $statusPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $statusPanel.BackColor = [System.Drawing.Color]::FromArgb(241, 245, 249)
    $rightPanel.Controls.Add($statusPanel)

    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = 'Ready.'
    $statusLabel.AutoSize = $false
    $statusLabel.Location = New-Object System.Drawing.Point(15, 12)
    $statusLabel.Size = New-Object System.Drawing.Size(590, 42)
    $statusLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
    $statusPanel.Controls.Add($statusLabel)

    $setStatus = {
        param(
            [string]$Message,
            [ValidateSet('Normal', 'Success', 'Warning', 'Error')]
            [string]$Kind = 'Normal'
        )

        $statusLabel.Text = $Message

        switch ($Kind) {
            'Success' { $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(22, 101, 52) }
            'Warning' { $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 83, 9) }
            'Error'   { $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(185, 28, 28) }
            default   { $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105) }
        }
    }.GetNewClosure()

    $updateSelectedDetails = {
        if ($fileCombo.SelectedIndex -lt 0 -or $fileCombo.SelectedIndex -ge $script:EditableFiles.Count) {
            $detailsText.Text = 'Choose a file from the drop-down menu.'
            $openButton.Enabled = $false
            return
        }

        $selected = $script:EditableFiles[$fileCombo.SelectedIndex]
        $detailsText.Text = "Path: $($selected.RelativePath)`r`nType: $($selected.Extension)`r`nSize: $(Format-FileSize -Bytes $selected.SizeBytes)`r`nLast changed: $($selected.LastWriteTime.ToString('yyyy-MM-dd h:mm tt'))"
        $openButton.Enabled = $true
    }.GetNewClosure()

    $loadFiles = {
        param(
            [string]$PreferredFullPath
        )

        $fileCombo.Items.Clear()
        $script:EditableFiles = @()

        if ([string]::IsNullOrWhiteSpace($script:ProjectFolder) -or
            (-not (Test-Path -LiteralPath $script:ProjectFolder -PathType Container))) {
            $projectPathBox.Text = ''
            $detailsText.Text = 'Choose or drag a project folder to begin.'
            $openButton.Enabled = $false
            & $setStatus 'No project folder is selected.' 'Warning'
            return
        }

        $projectPathBox.Text = $script:ProjectFolder
        Save-RememberedProject -Mode 'javascript' -Path $script:ProjectFolder
        $script:EditableFiles = @(Get-EditableFiles `
            -ProjectFolder $script:ProjectFolder `
            -IncludeHtml $includeHtmlCheck.Checked)

        foreach ($file in $script:EditableFiles) {
            [void]$fileCombo.Items.Add($file.Display)
        }

        if ($script:EditableFiles.Count -eq 0) {
            $detailsText.Text = 'No matching files were found.'
            $openButton.Enabled = $false
            & $setStatus 'No JavaScript files were found. Turn on “Also show HTML files” if this project keeps its JavaScript inside HTML pages.' 'Warning'
            return
        }

        $selectedIndex = 0
        if (-not [string]::IsNullOrWhiteSpace($PreferredFullPath)) {
            for ($index = 0; $index -lt $script:EditableFiles.Count; $index++) {
                if ($script:EditableFiles[$index].FullPath -ieq $PreferredFullPath) {
                    $selectedIndex = $index
                    break
                }
            }
        }

        $fileCombo.SelectedIndex = $selectedIndex
        & $setStatus "Found $($script:EditableFiles.Count) editable file(s)." 'Success'
    }.GetNewClosure()

    $useDroppedPath = {
        param([string]$DroppedPath)

        if ([string]::IsNullOrWhiteSpace($DroppedPath)) {
            return
        }

        $preferredFile = $null
        if (Test-Path -LiteralPath $DroppedPath -PathType Leaf) {
            $extension = [System.IO.Path]::GetExtension($DroppedPath).ToLowerInvariant()
            if ($extension -notin @('.js', '.mjs', '.cjs', '.html')) {
                Show-EditorMessage `
                    -Title 'Unsupported file type' `
                    -Message 'Drop a project folder, JavaScript file, or HTML file.' `
                    -Type 'Warning'
                return
            }

            $preferredFile = (Get-Item -LiteralPath $DroppedPath).FullName
        }

        $root = Find-ProjectRootFromPath -Path $DroppedPath
        if ($null -eq $root) {
            Show-EditorMessage `
                -Title 'Project folder not found' `
                -Message 'The dropped item could not be connected to a project folder.' `
                -Type 'Warning'
            return
        }

        $script:ProjectFolder = $root

        if ($null -ne $preferredFile -and
            [System.IO.Path]::GetExtension($preferredFile).ToLowerInvariant() -eq '.html') {
            $includeHtmlCheck.Checked = $true
        }

        & $loadFiles $preferredFile
    }.GetNewClosure()

    $dragEnterHandler = {
        param($sender, $eventArgs)

        if ($eventArgs.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
            $eventArgs.Effect = [System.Windows.Forms.DragDropEffects]::Copy
        }
        else {
            $eventArgs.Effect = [System.Windows.Forms.DragDropEffects]::None
        }
    }.GetNewClosure()

    $dragDropHandler = {
        param($sender, $eventArgs)

        $paths = $eventArgs.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
        if ($null -ne $paths -and $paths.Count -gt 0) {
            & $useDroppedPath $paths[0]
        }
    }.GetNewClosure()

    $form.Add_DragEnter($dragEnterHandler)
    $form.Add_DragDrop($dragDropHandler)
    $dropPanel.Add_DragEnter($dragEnterHandler)
    $dropPanel.Add_DragDrop($dragDropHandler)

    $browseButton.Add_Click({
        $selected = Show-ProjectFolderDialog -InitialFolder $script:ProjectFolder
        if (-not [string]::IsNullOrWhiteSpace($selected)) {
            $script:ProjectFolder = Find-ProjectRootFromPath -Path $selected
            & $loadFiles $null
        }
    }.GetNewClosure())

    $openFolderButton.Add_Click({
        & $setStatus 'Searching Documents, Desktop, Downloads, OneDrive, and remembered locations...' 'Normal'
        $form.UseWaitCursor = $true
        [System.Windows.Forms.Application]::DoEvents()

        try {
            $detected = Get-AutomaticProjectFolder

            if ([string]::IsNullOrWhiteSpace($detected)) {
                & $setStatus 'No quiz project was found automatically.' 'Warning'

                Show-EditorMessage `
                    -Title 'Project not found automatically' `
                    -Message 'The search checked Documents, Desktop, Downloads, OneDrive, the editor folder, and remembered installation locations. Use Choose a different folder as a fallback.' `
                    -Type 'Information'

                return
            }

            $script:ProjectFolder = $detected
            & $loadFiles $null
            & $setStatus "Automatically found: $detected" 'Success'
        }
        catch {
            & $setStatus $_.Exception.Message 'Error'

            Show-EditorMessage `
                -Title 'Automatic search could not finish' `
                -Message $_.Exception.Message `
                -Type 'Error'
        }
        finally {
            $form.UseWaitCursor = $false
        }
    }.GetNewClosure())

    $includeHtmlCheck.Add_CheckedChanged({
        & $loadFiles $null
    }.GetNewClosure())

    $refreshButton.Add_Click({
        $preferred = $null
        if ($fileCombo.SelectedIndex -ge 0 -and
            $fileCombo.SelectedIndex -lt $script:EditableFiles.Count) {
            $preferred = $script:EditableFiles[$fileCombo.SelectedIndex].FullPath
        }

        & $loadFiles $preferred
    }.GetNewClosure())

    $fileCombo.Add_SelectedIndexChanged({
        & $updateSelectedDetails
    }.GetNewClosure())

    $openButton.Add_Click({
        if ($fileCombo.SelectedIndex -lt 0 -or
            $fileCombo.SelectedIndex -ge $script:EditableFiles.Count) {
            return
        }

        $selected = $script:EditableFiles[$fileCombo.SelectedIndex]

        try {
            $backupPath = $null
            if ($backupCheck.Checked) {
                $backupPath = Create-FileBackup `
                    -ProjectFolder $script:ProjectFolder `
                    -SelectedFile $selected
            }

            Start-Process -FilePath 'notepad.exe' -ArgumentList "`"$($selected.FullPath)`""

            if ($null -ne $backupPath) {
                & $setStatus "Opened $($selected.RelativePath) in Notepad. Backup created at: $backupPath" 'Success'
            }
            else {
                & $setStatus "Opened $($selected.RelativePath) in Notepad. Remember to press Ctrl+S after editing." 'Success'
            }
        }
        catch {
            Show-EditorMessage `
                -Title 'Could not open the file' `
                -Message $_.Exception.Message `
                -Type 'Error'
        }
    }.GetNewClosure())

    $form.Add_Shown({
        if (-not [string]::IsNullOrWhiteSpace($script:ProjectFolder)) {
            & $loadFiles $null
            & $setStatus "Automatically found: $script:ProjectFolder" 'Success'
        }
        else {
            & $setStatus 'No project was found automatically. Use Choose a different folder.' 'Warning'
        }
    }.GetNewClosure())

    [void]$form.ShowDialog()
    $form.Dispose()
}

try {
    Initialize-EditorUi
    Start-JavaScriptEditor
}
catch {
    try {
        Initialize-EditorUi
        Show-EditorMessage `
            -Title 'Editor could not start' `
            -Message $_.Exception.Message `
            -Type 'Error'
    }
    catch {
        Write-Host "Editor could not start: $($_.Exception.Message)" -ForegroundColor Red
        [void](Read-Host 'Press Enter to close')
    }

    exit 1
}
