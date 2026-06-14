#requires -Version 5.1
<#
LOCAL-ONLY installer for the Linear Algebra True/False website.

What it does:
- Uses the current Windows user's real Documents/Desktop folders.
- Downloads a fresh public copy of the website.
- Removes audio, Firebase, and multiplayer features.
- Saves the complete website locally on the computer.
- Creates an easy desktop shortcut and opens the website.

It does NOT require GitHub login, a GitHub repository link, Git, Python,
Node.js, npm, or Firebase.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TemplateZipUrl = 'https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false/archive/refs/heads/main.zip'

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

function Wait-ForEnter {
    param([string]$Message)
    [void](Read-Host $Message)
}

function Initialize-PopupSupport {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function New-SetupButton {
    param(
        [string]$Text,
        [switch]$Primary
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Size = New-Object System.Drawing.Size(118, 38)
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

function New-SetupWindow {
    param(
        [string]$WindowTitle,
        [string]$Heading,
        [string]$Description,
        [int]$Width = 760,
        [int]$Height = 420,
        [switch]$Resizable
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $WindowTitle
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size($Width, $Height)
    $form.MinimumSize = New-Object System.Drawing.Size([Math]::Min($Width, 660), [Math]::Min($Height, 390))
    $form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
    $form.TopMost = $true
    $form.ShowIcon = $false
    $form.MaximizeBox = $Resizable.IsPresent
    $form.MinimizeBox = $false

    if ($Resizable) {
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
    }
    else {
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    }

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = [System.Windows.Forms.DockStyle]::Top
    $header.Height = 112
    $header.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $form.Controls.Add($header)

    $accent = New-Object System.Windows.Forms.Panel
    $accent.Dock = [System.Windows.Forms.DockStyle]::Left
    $accent.Width = 7
    $accent.BackColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
    $header.Controls.Add($accent)

    $brand = New-Object System.Windows.Forms.Label
    $brand.Text = 'LINEAR ALGEBRA QUIZ SETUP'
    $brand.AutoSize = $true
    $brand.Location = New-Object System.Drawing.Point(28, 17)
    $brand.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 8.5)
    $brand.ForeColor = [System.Drawing.Color]::FromArgb(125, 211, 252)
    $header.Controls.Add($brand)

    $headingLabel = New-Object System.Windows.Forms.Label
    $headingLabel.Text = $Heading
    $headingLabel.AutoSize = $false
    $headingLabel.Location = New-Object System.Drawing.Point(25, 40)
    $headingLabel.Size = [System.Drawing.Size]::new(($Width - 70), 31)
    $headingLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $headingLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 16)
    $headingLabel.ForeColor = [System.Drawing.Color]::White
    $header.Controls.Add($headingLabel)

    $descriptionLabel = New-Object System.Windows.Forms.Label
    $descriptionLabel.Text = $Description
    $descriptionLabel.AutoSize = $false
    $descriptionLabel.Location = New-Object System.Drawing.Point(28, 75)
    $descriptionLabel.Size = [System.Drawing.Size]::new(($Width - 75), 28)
    $descriptionLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $descriptionLabel.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
    $descriptionLabel.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $header.Controls.Add($descriptionLabel)

    $content = New-Object System.Windows.Forms.Panel
    $content.Dock = [System.Windows.Forms.DockStyle]::Fill
    $content.Padding = New-Object System.Windows.Forms.Padding(26, 22, 26, 18)
    $content.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $form.Controls.Add($content)
    $header.BringToFront()

    return [pscustomobject]@{
        Form = $form
        Header = $header
        Content = $content
    }
}

function Show-TextPopup {
    param(
        [string]$Title,
        [string]$Prompt,
        [string]$DefaultValue = ''
    )

    $ui = New-SetupWindow `
        -WindowTitle $Title `
        -Heading $Title `
        -Description 'Type or paste the requested information below.' `
        -Width 760 `
        -Height 405

    $form = $ui.Form
    $content = $ui.Content

    $promptLabel = New-Object System.Windows.Forms.Label
    $promptLabel.Text = $Prompt
    $promptLabel.AutoSize = $false
    $promptLabel.Location = New-Object System.Drawing.Point(26, 22)
    $promptLabel.Size = New-Object System.Drawing.Size(690, 55)
    $promptLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $promptLabel.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
    $content.Controls.Add($promptLabel)

    $inputBox = New-Object System.Windows.Forms.TextBox
    $inputBox.Text = $DefaultValue
    $inputBox.Location = New-Object System.Drawing.Point(26, 88)
    $inputBox.Size = New-Object System.Drawing.Size(690, 32)
    $inputBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $inputBox.Font = New-Object System.Drawing.Font('Segoe UI', 11)
    $content.Controls.Add($inputBox)

    $hint = New-Object System.Windows.Forms.Label
    $hint.Text = 'Click inside the box and press Ctrl+V to paste.'
    $hint.AutoSize = $false
    $hint.Location = New-Object System.Drawing.Point(27, 130)
    $hint.Size = New-Object System.Drawing.Size(690, 24)
    $hint.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $hint.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $hint.Font = New-Object System.Drawing.Font('Segoe UI', 8.7)
    $content.Controls.Add($hint)

    $divider = New-Object System.Windows.Forms.Panel
    $divider.Location = New-Object System.Drawing.Point(26, 168)
    $divider.Size = New-Object System.Drawing.Size(690, 1)
    $divider.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $divider.BackColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
    $content.Controls.Add($divider)

    $cancelButton = New-SetupButton -Text 'Cancel'
    $cancelButton.Location = New-Object System.Drawing.Point(466, 191)
    $cancelButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $content.Controls.Add($cancelButton)

    $continueButton = New-SetupButton -Text 'Continue' -Primary
    $continueButton.Location = New-Object System.Drawing.Point(598, 191)
    $continueButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $continueButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $content.Controls.Add($continueButton)

    $form.AcceptButton = $continueButton
    $form.CancelButton = $cancelButton
    $form.ActiveControl = $inputBox

    $result = $form.ShowDialog()
    $value = $inputBox.Text.Trim()
    $form.Dispose()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        return $null
    }

    if ([string]::IsNullOrWhiteSpace($value)) {
        [System.Windows.Forms.MessageBox]::Show(
            'Please enter a value before continuing.',
            $Title,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null

        return $null
    }

    return $value
}

function Show-MultilinePopup {
    param(
        [string]$Title,
        [string]$Prompt
    )

    $ui = New-SetupWindow `
        -WindowTitle $Title `
        -Heading $Title `
        -Description 'Paste the complete configuration block below.' `
        -Width 900 `
        -Height 760 `
        -Resizable

    $form = $ui.Form
    $content = $ui.Content

    $promptLabel = New-Object System.Windows.Forms.Label
    $promptLabel.Text = $Prompt
    $promptLabel.AutoSize = $false
    $promptLabel.Location = New-Object System.Drawing.Point(26, 18)
    $promptLabel.Size = New-Object System.Drawing.Size(830, 72)
    $promptLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $promptLabel.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
    $content.Controls.Add($promptLabel)

    $hint = New-Object System.Windows.Forms.Label
    $hint.Text = 'Click inside the large box and press Ctrl+V to paste the Firebase config.'
    $hint.AutoSize = $false
    $hint.Location = New-Object System.Drawing.Point(26, 94)
    $hint.Size = New-Object System.Drawing.Size(830, 26)
    $hint.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $hint.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $content.Controls.Add($hint)

    $configBox = New-Object System.Windows.Forms.TextBox
    $configBox.Multiline = $true
    $configBox.AcceptsReturn = $true
    $configBox.AcceptsTab = $true
    $configBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
    $configBox.WordWrap = $false
    $configBox.Font = New-Object System.Drawing.Font('Consolas', 10.5)
    $configBox.Location = New-Object System.Drawing.Point(26, 128)
    $configBox.Size = New-Object System.Drawing.Size(830, 430)
    $configBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $configBox.BackColor = [System.Drawing.Color]::White
    $content.Controls.Add($configBox)

    $cancelButton = New-SetupButton -Text 'Cancel'
    $cancelButton.Location = New-Object System.Drawing.Point(606, 577)
    $cancelButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $content.Controls.Add($cancelButton)

    $continueButton = New-SetupButton -Text 'Use this config' -Primary
    $continueButton.Location = New-Object System.Drawing.Point(738, 577)
    $continueButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $continueButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $content.Controls.Add($continueButton)

    $form.AcceptButton = $continueButton
    $form.CancelButton = $cancelButton
    $form.ActiveControl = $configBox

    $result = $form.ShowDialog()
    $value = $configBox.Text
    $form.Dispose()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        return $null
    }

    return $value
}

function Show-FolderPopup {
    param(
        [string]$Title,
        [string]$InitialFolder
    )

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $Title
    $dialog.ShowNewFolderButton = $true

    if (-not [string]::IsNullOrWhiteSpace($InitialFolder) -and
        (Test-Path -LiteralPath $InitialFolder -PathType Container)) {
        $dialog.SelectedPath = $InitialFolder
    }

    $result = $dialog.ShowDialog()
    $selectedPath = $null

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $dialog.SelectedPath
    }

    $dialog.Dispose()
    return $selectedPath
}

function Show-NoticePopup {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )

    $accentColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
    $statusText = 'INFORMATION'

    switch ($Type) {
        'Success' {
            $accentColor = [System.Drawing.Color]::FromArgb(22, 163, 74)
            $statusText = 'SUCCESS'
        }
        'Warning' {
            $accentColor = [System.Drawing.Color]::FromArgb(217, 119, 6)
            $statusText = 'PLEASE CHECK'
        }
        'Error' {
            $accentColor = [System.Drawing.Color]::FromArgb(220, 38, 38)
            $statusText = 'SETUP STOPPED'
        }
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size(640, 330)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    $form.ShowIcon = $false
    $form.BackColor = [System.Drawing.Color]::White
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)

    $bar = New-Object System.Windows.Forms.Panel
    $bar.Dock = [System.Windows.Forms.DockStyle]::Top
    $bar.Height = 7
    $bar.BackColor = $accentColor
    $form.Controls.Add($bar)

    $status = New-Object System.Windows.Forms.Label
    $status.Text = $statusText
    $status.AutoSize = $true
    $status.Location = New-Object System.Drawing.Point(28, 28)
    $status.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 8.5)
    $status.ForeColor = $accentColor
    $form.Controls.Add($status)

    $heading = New-Object System.Windows.Forms.Label
    $heading.Text = $Title
    $heading.AutoSize = $false
    $heading.Location = New-Object System.Drawing.Point(25, 53)
    $heading.Size = New-Object System.Drawing.Size(580, 34)
    $heading.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 15)
    $heading.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
    $form.Controls.Add($heading)

    $messageLabel = New-Object System.Windows.Forms.Label
    $messageLabel.Text = $Message
    $messageLabel.AutoSize = $false
    $messageLabel.Location = New-Object System.Drawing.Point(29, 101)
    $messageLabel.Size = New-Object System.Drawing.Size(574, 100)
    $messageLabel.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
    $form.Controls.Add($messageLabel)

    $okButton = New-SetupButton -Text 'OK' -Primary
    $okButton.Location = New-Object System.Drawing.Point(486, 226)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($okButton)

    $form.AcceptButton = $okButton
    $form.CancelButton = $okButton
    [void]$form.ShowDialog()
    $form.Dispose()
}

function Save-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}

function Backup-ExistingFolder {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = "$Path-backup-$timestamp"
        Write-Info "A folder already exists. Moving it safely to:`n$backup"
        Move-Item -LiteralPath $Path -Destination $backup
        Write-Ok 'The old local folder was backed up.'
    }
}

function Remove-AudioFromHtml {
    param([string]$Path)

    $content = [System.IO.File]::ReadAllText($Path)
    $original = $content

    $audioScriptPattern = @'
(?is)<script\b[^>]*\bsrc\s*=\s*["'][^"']*(?:pronunciation-google|generate-audio|audio-manifest)[^"']*["'][^>]*>\s*</script>\s*
'@
    $content = [regex]::Replace($content, $audioScriptPattern.Trim(), '')

    $audioButtonPattern = @'
(?is)<button\b(?=[^>]*(?:class|id|title|aria-label)\s*=\s*["'][^"']*(?:pronoun|speaker|mute|audio)[^"']*["'])[^>]*>.*?</button>\s*
'@
    $content = [regex]::Replace($content, $audioButtonPattern.Trim(), '')

    $content = $content.Replace(
        'Audio pronunciation added! Hear every card read aloud in Solo and 1v1 modes.',
        ''
    )

    $audioCallPatterns = @(
        '(?<!function )(?:(?:[A-Za-z_$][\w$]*)\.)*\b_playRaw\s*\([^;]*?\)\s*;',
        '(?<!function )(?:(?:[A-Za-z_$][\w$]*)\.)*\bplayAudio\s*\([^;]*?\)\s*;',
        '(?<!function )(?:(?:[A-Za-z_$][\w$]*)\.)*\bplayFrenchAudio\s*\([^;]*?\)\s*;',
        '(?<!function )(?:(?:[A-Za-z_$][\w$]*)\.)*\baddFrenchAudioButton\s*\([^;]*?\)\s*;'
    )

    foreach ($pattern in $audioCallPatterns) {
        $content = [regex]::Replace(
            $content,
            $pattern,
            '',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    }

    if ($content -ne $original) {
        Save-Utf8NoBom -Path $Path -Text $content
        return $true
    }

    return $false
}

function Remove-AudioFeatures {
    param([string]$WebsiteFolder)

    $items = @(
        'audio',
        'audio-manifest.json',
        'generate-audio.js',
        'pronunciation-google.js',
        'package.json',
        'package-lock.json'
    )

    $removed = 0
    foreach ($relative in $items) {
        $full = Join-Path $WebsiteFolder $relative
        if (Test-Path -LiteralPath $full) {
            Remove-Item -LiteralPath $full -Recurse -Force
            Write-Host "Removed: $relative" -ForegroundColor DarkCyan
            $removed++
        }
    }

    $cleaned = 0
    $htmlFiles = Get-ChildItem -LiteralPath $WebsiteFolder -Filter '*.html' -File -Recurse

    foreach ($htmlFile in $htmlFiles) {
        if (Remove-AudioFromHtml -Path $htmlFile.FullName) {
            $cleaned++
            Write-Host "Cleaned: $($htmlFile.FullName.Substring($WebsiteFolder.Length + 1))" -ForegroundColor DarkCyan
        }
    }

    Write-Ok "Audio cleanup finished. Removed $removed items and cleaned $cleaned HTML files."
}

function Convert-ToSoloOnly {
    param([string]$WebsiteFolder)

    $multiplayerFiles = @(
        'etape1.html',
        'etape3.html',
        'etape4.html',
        'firestore.rules',
        'firebase.json',
        '.firebaserc'
    )

    foreach ($relative in $multiplayerFiles) {
        $full = Join-Path $WebsiteFolder $relative
        if (Test-Path -LiteralPath $full) {
            Remove-Item -LiteralPath $full -Recurse -Force
            Write-Host "Removed Firebase/multiplayer file: $relative" -ForegroundColor DarkCyan
        }
    }

    $landingPage = @'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Linear Algebra True or False</title>
  <style>
    :root { font-family: Inter, system-ui, Arial, sans-serif; color: #172033; background: #f5f7fb; }
    * { box-sizing: border-box; }
    body { margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 24px; }
    main { width: min(900px, 100%); }
    h1 { margin-bottom: 8px; font-size: clamp(2rem, 6vw, 3.4rem); }
    p { color: #536079; font-size: 1.05rem; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 16px; margin-top: 28px; }
    a { display: block; padding: 24px; border-radius: 18px; background: white; color: #172033; text-decoration: none;
        box-shadow: 0 8px 28px rgba(20,35,70,.09); border: 1px solid #e2e7f0; }
    a:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(20,35,70,.14); }
    strong { display: block; font-size: 1.25rem; margin-bottom: 6px; }
    span { color: #65718a; }
    .note { margin-top: 24px; padding: 14px 16px; border-radius: 12px; background: #eaf7ee; color: #245b34; }
  </style>
</head>
<body>
  <main>
    <h1>Linear Algebra: True or False</h1>
    <p>Choose a unit and practise using local solo flashcards.</p>
    <section class="grid">
      <a href="solo.html"><strong>Unit 1</strong><span>Start solo practice</span></a>
      <a href="solo1.html"><strong>Unit 2</strong><span>Start solo practice</span></a>
      <a href="solo3.html"><strong>Unit 3</strong><span>Start solo practice</span></a>
      <a href="solo4.html"><strong>Unit 4</strong><span>Start solo practice</span></a>
    </section>
    <div class="note">This website is installed locally on this computer. No GitHub or Firebase account is required.</div>
  </main>
</body>
</html>
'@

    Save-Utf8NoBom -Path (Join-Path $WebsiteFolder 'index.html') -Text $landingPage

    $readmePath = Join-Path $WebsiteFolder 'README.md'
    $notice = @'
# Local solo-only installation

This copy is installed locally on the computer.

- No GitHub login is required.
- No GitHub repository link is required.
- No Firebase account is required.
- Multiplayer is disabled.
- Open `index.html` or use the desktop shortcut to start.

'@

    if (Test-Path -LiteralPath $readmePath) {
        $existing = [System.IO.File]::ReadAllText($readmePath)
        Save-Utf8NoBom -Path $readmePath -Text ($notice + "`r`n---`r`n`r`n" + $existing)
    }
    else {
        Save-Utf8NoBom -Path $readmePath -Text $notice
    }

    Write-Ok 'Firebase and multiplayer were removed. The homepage is now local and solo-only.'
}

function Download-FreshWebsite {
    param([string]$Destination)

    Backup-ExistingFolder -Path $Destination

    $temporaryRoot = Join-Path $env:TEMP ("LAQuizLocalInstall-" + [Guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $temporaryRoot 'website.zip'
    $extractPath = Join-Path $temporaryRoot 'extracted'

    New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null

    try {
        Write-Info 'Downloading a fresh copy of the website...'
        Invoke-WebRequest `
            -Uri $TemplateZipUrl `
            -OutFile $zipPath `
            -Headers @{ 'User-Agent' = 'LA-Quiz-Local-Installer' } `
            -UseBasicParsing

        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

        $sourceFolder = Get-ChildItem -LiteralPath $extractPath -Directory |
            Select-Object -First 1

        if ($null -eq $sourceFolder) {
            throw 'The downloaded website archive did not contain the expected folder.'
        }

        New-Item -ItemType Directory -Path $Destination -Force | Out-Null

        Get-ChildItem -LiteralPath $sourceFolder.FullName -Force | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $Destination -Recurse -Force
        }

        Write-Ok "Fresh website downloaded to: $Destination"
    }
    finally {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Create-LocalLaunchers {
    param([string]$WebsiteFolder)

    $indexPath = Join-Path $WebsiteFolder 'index.html'
    if (-not (Test-Path -LiteralPath $indexPath)) {
        throw 'index.html was not found after installation.'
    }

    $cmdPath = Join-Path $WebsiteFolder 'Open Linear Algebra Quiz.cmd'
    $cmdText = @'
@echo off
start "" "%~dp0index.html"
'@
    [System.IO.File]::WriteAllText(
        $cmdPath,
        $cmdText,
        [System.Text.Encoding]::ASCII
    )

    $desktop = [Environment]::GetFolderPath('Desktop')
    if (-not [string]::IsNullOrWhiteSpace($desktop)) {
        $shortcutPath = Join-Path $desktop 'Linear Algebra True or False.lnk'
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $indexPath
        $shortcut.WorkingDirectory = $WebsiteFolder
        $shortcut.Description = 'Open the local Linear Algebra True or False website'
        $shortcut.Save()
        Write-Ok "Desktop shortcut created: $shortcutPath"
    }

    return $indexPath
}

try {
    Clear-Host
    Write-Host 'LINEAR ALGEBRA QUIZ - LOCAL INSTALLER' -ForegroundColor Magenta
    Write-Host 'UI VERSION 6 - PARSER FIX' -ForegroundColor DarkCyan
    Write-Host 'MODE: Local computer only - no GitHub and no Firebase' -ForegroundColor Magenta
    Write-Host 'Nothing needs to be installed except the website files themselves.'

    Initialize-PopupSupport

    $documents = [Environment]::GetFolderPath('MyDocuments')
    if ([string]::IsNullOrWhiteSpace($documents)) {
        $documents = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Documents'
    }

    Write-Step 'STEP 1 OF 5 - Choosing where to install the local website'
    $parentFolder = Show-FolderPopup `
        -Title 'Choose the local installation folder' `
        -InitialFolder $documents

    if ([string]::IsNullOrWhiteSpace($parentFolder)) {
        throw 'Installation was cancelled before a folder was selected.'
    }

    $folderName = Show-TextPopup `
        -Title 'Name your local quiz folder' `
        -Prompt 'Enter the folder name that will appear on this computer:' `
        -DefaultValue 'Linear Algebra True or False'

    if ([string]::IsNullOrWhiteSpace($folderName)) {
        throw 'Installation was cancelled before a folder name was entered.'
    }

    foreach ($character in [System.IO.Path]::GetInvalidFileNameChars()) {
        $folderName = $folderName.Replace([string]$character, '-')
    }
    $folderName = $folderName.Trim().TrimEnd('.')

    if ([string]::IsNullOrWhiteSpace($folderName)) {
        throw 'The selected folder name is not valid.'
    }

    $websiteFolder = Join-Path $parentFolder $folderName
    Write-Ok "The website will be installed at: $websiteFolder"

    Write-Step 'STEP 2 OF 5 - Downloading a completely fresh website copy'
    Download-FreshWebsite -Destination $websiteFolder

    Write-Step 'STEP 3 OF 5 - Removing audio, Firebase, and multiplayer'
    Remove-AudioFeatures -WebsiteFolder $websiteFolder
    Convert-ToSoloOnly -WebsiteFolder $websiteFolder

    Write-Step 'STEP 4 OF 5 - Creating an easy desktop shortcut'
    $indexPath = Create-LocalLaunchers -WebsiteFolder $websiteFolder

    Write-Step 'STEP 5 OF 5 - Opening the local website'
    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Write-Host "Local website folder: $websiteFolder" -ForegroundColor Cyan
    Write-Host "Start page:           $indexPath" -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'No GitHub link, GitHub login, Firebase login, Python, Node.js, or npm is required.' -ForegroundColor Yellow
    Write-Host 'Use the desktop shortcut whenever you want to open the quiz.' -ForegroundColor Yellow

    Start-Process -FilePath $indexPath -ErrorAction SilentlyContinue
    Start-Process -FilePath $websiteFolder -ErrorAction SilentlyContinue

    Show-NoticePopup `
        -Title 'Your local quiz is ready' `
        -Message "The website was installed at:`r`n$websiteFolder`r`n`r`nA desktop shortcut was also created." `
        -Type 'Success'
}
catch {
    Write-Host ''
    Write-Host 'INSTALLATION STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ''
    Write-Host 'Existing website folders are backed up instead of being deleted.' -ForegroundColor Yellow
    try {
        Show-NoticePopup `
            -Title 'Installation Stopped' `
            -Message 'The local installation could not finish. The PowerShell window contains the detailed reason. Existing folders were backed up rather than deleted.' `
            -Type 'Error'
    }
    catch {
        # Keep the console error visible even if Windows dialogs are unavailable.
    }
    Wait-ForEnter 'Press Enter to close'
    exit 1
}

Wait-ForEnter 'Press Enter to close'
