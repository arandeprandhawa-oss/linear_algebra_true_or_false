#requires -Version 5.1
<#
This script is designed for a fresh Windows computer.
It finds the current user's Downloads folder, installs portable tools when
needed, signs in through the browser, copies the template into a new repository,
and safely pushes without using force push.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TemplateRepository = 'https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false.git'
$ToolRootName = 'LAQuizTools'

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

function Get-DownloadsFolder {
    $knownFolderId = '{374DE290-123F-4565-9164-39C4925E467B}'
    $registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
    $downloads = $null

    try {
        $item = Get-ItemProperty -Path $registryPath -Name $knownFolderId -ErrorAction Stop
        $downloads = [Environment]::ExpandEnvironmentVariables($item.$knownFolderId)
    }
    catch {
        $profilePath = [Environment]::GetFolderPath('UserProfile')
        if ([string]::IsNullOrWhiteSpace($profilePath)) {
            $profilePath = $env:USERPROFILE
        }
        $downloads = Join-Path $profilePath 'Downloads'
    }

    if (-not (Test-Path -LiteralPath $downloads)) {
        New-Item -ItemType Directory -Path $downloads -Force | Out-Null
    }

    return $downloads
}

function Get-ToolRoot {
    $base = $env:LOCALAPPDATA
    if ([string]::IsNullOrWhiteSpace($base)) {
        $base = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'AppData\Local'
    }

    $folder = Join-Path $base $ToolRootName
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    return $folder
}

function Save-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}

function Invoke-WebDownload {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$OutFile
    )

    $headers = @{ 'User-Agent' = 'LA-Quiz-Friendly-Setup' }
    Invoke-WebRequest -Uri $Url -OutFile $OutFile -Headers $headers -UseBasicParsing
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

function Invoke-NativeCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$FailureMessage = 'A command failed.',
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
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$FailureMessage = 'A command failed.',
        [switch]$AllowFailure
    )

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $lines = & $FilePath @Arguments 2>&1
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
        Text = (($lines | ForEach-Object { "$_" }) -join [Environment]::NewLine).Trim()
    }
}

function Install-PortableGit {
    param([string]$ToolsFolder)

    Write-Info 'Git was not found. Downloading the official portable Git for Windows...'
    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Friendly-Setup' }

    $asset = $release.assets |
        Where-Object { $_.name -match '^PortableGit-.*-64-bit\.7z\.exe$' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw 'Could not find the current 64-bit PortableGit download.'
    }

    $gitFolder = Join-Path $ToolsFolder 'PortableGit'
    $installer = Join-Path $ToolsFolder $asset.name

    if (Test-Path -LiteralPath $gitFolder) {
        Remove-Item -LiteralPath $gitFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $gitFolder -Force | Out-Null

    Invoke-WebDownload -Url $asset.browser_download_url -OutFile $installer
    $arguments = @("-o`"$gitFolder`"", '-y')
    $process = Start-Process -FilePath $installer -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "PortableGit extraction failed with exit code $($process.ExitCode)."
    }

    Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue
    $gitExe = Join-Path $gitFolder 'cmd\git.exe'
    if (-not (Test-Path -LiteralPath $gitExe)) {
        throw 'PortableGit downloaded, but git.exe could not be found.'
    }

    return $gitExe
}

function Install-PortableGitHubCli {
    param([string]$ToolsFolder)

    Write-Info 'GitHub CLI was not found. Downloading the official portable GitHub CLI...'
    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/cli/cli/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Friendly-Setup' }

    $asset = $release.assets |
        Where-Object { $_.name -match '^gh_.*_windows_amd64\.zip$' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw 'Could not find the current 64-bit GitHub CLI download.'
    }

    $ghFolder = Join-Path $ToolsFolder 'GitHubCLI'
    $zipFile = Join-Path $ToolsFolder $asset.name

    if (Test-Path -LiteralPath $ghFolder) {
        Remove-Item -LiteralPath $ghFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $ghFolder -Force | Out-Null

    Invoke-WebDownload -Url $asset.browser_download_url -OutFile $zipFile
    Expand-Archive -LiteralPath $zipFile -DestinationPath $ghFolder -Force
    Remove-Item -LiteralPath $zipFile -Force -ErrorAction SilentlyContinue

    $ghExe = Get-ChildItem -LiteralPath $ghFolder -Filter 'gh.exe' -File -Recurse |
        Select-Object -First 1 -ExpandProperty FullName

    if ([string]::IsNullOrWhiteSpace($ghExe)) {
        throw 'GitHub CLI downloaded, but gh.exe could not be found.'
    }

    return $ghExe
}

function Ensure-GitAndGitHubCli {
    param([string]$ToolsFolder)

    $gitExe = Get-CommandPath -Names @('git.exe', 'git')
    if ([string]::IsNullOrWhiteSpace($gitExe)) {
        $gitExe = Install-PortableGit -ToolsFolder $ToolsFolder
    }
    Write-Ok "Git ready: $gitExe"

    $ghExe = Get-CommandPath -Names @('gh.exe', 'gh')
    if ([string]::IsNullOrWhiteSpace($ghExe)) {
        $ghExe = Install-PortableGitHubCli -ToolsFolder $ToolsFolder
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

    $status = Invoke-NativeCommand `
        -FilePath $GhExe `
        -Arguments @('auth', 'status', '--hostname', 'github.com') `
        -AllowFailure `
        -Quiet

    if ($status -ne 0) {
        Write-Info 'GitHub needs a one-time browser login.'
        Wait-ForEnter 'Press Enter to show the GitHub login code and open the browser'
        [void](Invoke-NativeCommand `
            -FilePath $GhExe `
            -Arguments @('auth', 'login', '--hostname', 'github.com', '--git-protocol', 'https', '--web') `
            -FailureMessage 'GitHub sign-in was not completed.')
    }

    [void](Invoke-NativeCommand `
        -FilePath $GhExe `
        -Arguments @('auth', 'setup-git') `
        -FailureMessage 'GitHub authentication could not be connected to Git.')

    $userResult = Invoke-NativeCapture `
        -FilePath $GhExe `
        -Arguments @('api', 'user', '--jq', '.login') `
        -FailureMessage 'Could not read the signed-in GitHub username.'

    $userName = $userResult.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($userName)) {
        throw 'GitHub returned an empty username.'
    }

    Write-Ok "Signed in to GitHub as: $userName"
    return $userName
}

function Parse-GitHubRepositoryLink {
    param([string]$Link)

    $normalized = $Link.Trim().TrimEnd('/')
    $normalized = $normalized -replace '\.git$', ''

    if ($normalized -match '^https?://github\.com/([^/]+)/([^/]+)$') {
        return [pscustomobject]@{
            Owner = $matches[1]
            Name = $matches[2]
            WebUrl = "https://github.com/$($matches[1])/$($matches[2])"
            GitUrl = "https://github.com/$($matches[1])/$($matches[2]).git"
        }
    }

    if ($normalized -match '^git@github\.com:([^/]+)/([^/]+)$') {
        return [pscustomobject]@{
            Owner = $matches[1]
            Name = $matches[2]
            WebUrl = "https://github.com/$($matches[1])/$($matches[2])"
            GitUrl = "https://github.com/$($matches[1])/$($matches[2]).git"
        }
    }

    return $null
}

function Get-NewRepositoryDetails {
    param(
        [string]$GhExe,
        [string]$SignedInUser
    )

    Write-Host ''
    Write-Host 'Create a NEW EMPTY public repository:' -ForegroundColor White
    Write-Host '  - Do not add a README' -ForegroundColor Gray
    Write-Host '  - Do not add a .gitignore' -ForegroundColor Gray
    Write-Host '  - Do not add a license' -ForegroundColor Gray
    Write-Host "  - Owner should normally be $SignedInUser" -ForegroundColor Gray

    Wait-ForEnter 'Press Enter to open the GitHub new-repository page'
    Start-Process 'https://github.com/new' -ErrorAction SilentlyContinue

    while ($true) {
        $link = Show-TextPopup `
            -Title 'Connect the new GitHub repository' `
            -Prompt 'After creating the empty repository in your browser, paste its full link here. Example: https://github.com/your-name/my-quiz'

        if ([string]::IsNullOrWhiteSpace($link)) {
            throw 'Repository setup was cancelled before a GitHub link was entered.'
        }

        $repo = Parse-GitHubRepositoryLink -Link $link

        if ($null -eq $repo) {
            Show-NoticePopup `
                -Title 'Invalid repository link' `
                -Message 'That does not look like a GitHub repository link. Paste the full link shown in the browser address bar.' `
                -Type 'Warning'
            continue
        }

        $check = Invoke-NativeCommand `
            -FilePath $GhExe `
            -Arguments @('repo', 'view', "$($repo.Owner)/$($repo.Name)") `
            -AllowFailure `
            -Quiet

        if ($check -ne 0) {
            Show-NoticePopup `
                -Title 'Repository not found' `
                -Message 'GitHub cannot find that repository yet. Finish creating it in the browser, then return here and paste the link again.' `
                -Type 'Warning'
            continue
        }

        return $repo
    }
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
    param([string]$RepositoryFolder)

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
        $full = Join-Path $RepositoryFolder $relative
        if (Test-Path -LiteralPath $full) {
            Remove-Item -LiteralPath $full -Recurse -Force
            Write-Host "Removed: $relative" -ForegroundColor DarkCyan
            $removed++
        }
    }

    $cleaned = 0
    $htmlFiles = Get-ChildItem -LiteralPath $RepositoryFolder -Filter '*.html' -File -Recurse |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }

    foreach ($htmlFile in $htmlFiles) {
        if (Remove-AudioFromHtml -Path $htmlFile.FullName) {
            $cleaned++
            Write-Host "Cleaned: $($htmlFile.FullName.Substring($RepositoryFolder.Length + 1))" -ForegroundColor DarkCyan
        }
    }

    Write-Ok "Audio cleanup finished. Removed $removed file/folder items and cleaned $cleaned HTML files."
}

function Initialize-And-PushRepository {
    param(
        [string]$GitExe,
        [string]$RepositoryFolder,
        [pscustomobject]$Repository,
        [string]$GitHubUser,
        [string]$CommitMessage
    )

    $oldGitFolder = Join-Path $RepositoryFolder '.git'
    if (Test-Path -LiteralPath $oldGitFolder) {
        Remove-Item -LiteralPath $oldGitFolder -Recurse -Force
    }

    $noJekyll = Join-Path $RepositoryFolder '.nojekyll'
    if (-not (Test-Path -LiteralPath $noJekyll)) {
        Save-Utf8NoBom -Path $noJekyll -Text ''
    }

    Set-Location -LiteralPath $RepositoryFolder

    [void](Invoke-NativeCommand -FilePath $GitExe -Arguments @('init') -FailureMessage 'Git could not initialize the new local repository.')
    [void](Invoke-NativeCommand -FilePath $GitExe -Arguments @('checkout', '-B', 'main') -FailureMessage 'Git could not create the main branch.')
    [void](Invoke-NativeCommand -FilePath $GitExe -Arguments @('config', 'user.name', $GitHubUser) -FailureMessage 'Git could not set the commit username.')
    [void](Invoke-NativeCommand -FilePath $GitExe -Arguments @('config', 'user.email', "$GitHubUser@users.noreply.github.com") -FailureMessage 'Git could not set the commit email.')
    [void](Invoke-NativeCommand -FilePath $GitExe -Arguments @('remote', 'add', 'origin', $Repository.GitUrl) -FailureMessage 'Git could not add the new GitHub repository as origin.')
    [void](Invoke-NativeCommand -FilePath $GitExe -Arguments @('add', '-A') -FailureMessage 'Git could not stage the website files.')
    [void](Invoke-NativeCommand -FilePath $GitExe -Arguments @('commit', '-m', $CommitMessage) -FailureMessage 'Git could not create the first commit.')
    [void](Invoke-NativeCommand -FilePath $GitExe -Arguments @('push', '-u', 'origin', 'main') -FailureMessage 'GitHub rejected the push. The new repository must be empty.')

    Write-Ok 'The new website files were pushed to GitHub.'
}

function Try-EnableGitHubPages {
    param(
        [string]$GhExe,
        [pscustomobject]$Repository
    )

    $endpoint = "repos/$($Repository.Owner)/$($Repository.Name)/pages"
    $existing = Invoke-NativeCommand `
        -FilePath $GhExe `
        -Arguments @('api', $endpoint) `
        -AllowFailure `
        -Quiet

    if ($existing -eq 0) {
        Write-Ok 'GitHub Pages was already enabled.'
        return $true
    }

    $created = Invoke-NativeCommand `
        -FilePath $GhExe `
        -Arguments @(
            'api',
            '--method', 'POST',
            $endpoint,
            '-f', 'source[branch]=main',
            '-f', 'source[path]=/'
        ) `
        -AllowFailure `
        -Quiet

    if ($created -eq 0) {
        Write-Ok 'GitHub Pages was enabled from the main branch.'
        return $true
    }

    Write-Warn 'GitHub Pages could not be enabled automatically.'
    Start-Process "$($Repository.WebUrl)/settings/pages" -ErrorAction SilentlyContinue
    Write-Info 'The Pages settings page was opened. Choose: Deploy from a branch > main > /(root).'
    return $false
}

function Clone-Template {
    param(
        [string]$GitExe,
        [string]$Destination
    )

    Backup-ExistingFolder -Path $Destination
    [void](Invoke-NativeCommand `
        -FilePath $GitExe `
        -Arguments @('clone', '--depth', '1', '--branch', 'main', '--single-branch', $TemplateRepository, $Destination) `
        -FailureMessage 'The template repository could not be downloaded.')

    Write-Ok "Template downloaded to: $Destination"
}


function Install-PortableFirebaseCli {
    param([string]$ToolsFolder)

    Write-Info 'Firebase CLI was not found. Downloading the official standalone Windows binary...'
    $firebaseFolder = Join-Path $ToolsFolder 'FirebaseCLI'
    New-Item -ItemType Directory -Path $firebaseFolder -Force | Out-Null

    $firebaseExe = Join-Path $firebaseFolder 'firebase.exe'
    Invoke-WebDownload `
        -Url 'https://firebase.tools/bin/win/instant/latest' `
        -OutFile $firebaseExe

    Unblock-File -LiteralPath $firebaseExe -ErrorAction SilentlyContinue

    if (-not (Test-Path -LiteralPath $firebaseExe)) {
        throw 'Firebase CLI downloaded, but firebase.exe could not be found.'
    }

    return $firebaseExe
}

function Ensure-FirebaseCli {
    param([string]$ToolsFolder)

    $firebaseExe = Get-CommandPath -Names @('firebase.exe', 'firebase.cmd', 'firebase')
    if ([string]::IsNullOrWhiteSpace($firebaseExe)) {
        $firebaseExe = Install-PortableFirebaseCli -ToolsFolder $ToolsFolder
    }

    Write-Ok "Firebase CLI ready: $firebaseExe"
    $env:PATH = "$(Split-Path -Parent $firebaseExe);$env:PATH"
    return $firebaseExe
}

function Ensure-FirebaseLogin {
    param([string]$FirebaseExe)

    $check = Invoke-NativeCommand `
        -FilePath $FirebaseExe `
        -Arguments @('projects:list', '--json') `
        -AllowFailure `
        -Quiet

    if ($check -ne 0) {
        Write-Info 'Firebase needs a one-time Google browser login.'
        Wait-ForEnter 'Press Enter to open the Firebase/Google login page'
        [void](Invoke-NativeCommand `
            -FilePath $FirebaseExe `
            -Arguments @('login') `
            -FailureMessage 'Firebase sign-in was not completed.')
    }

    [void](Invoke-NativeCommand `
        -FilePath $FirebaseExe `
        -Arguments @('projects:list', '--json') `
        -FailureMessage 'Firebase is installed, but the account login could not be verified.' `
        -Quiet)

    Write-Ok 'Firebase sign-in is ready.'
}

function Read-FirebaseConfig {
    $prompt = @'
In Firebase, open:

Project settings > General > Your apps >
SDK setup and configuration > Config

Copy the ENTIRE firebaseConfig block and paste it into the large box below.
Then click Continue.
'@

    $text = Show-MultilinePopup `
        -Title 'Connect Firebase to the quiz' `
        -Prompt $prompt

    if ([string]::IsNullOrWhiteSpace($text)) {
        throw 'No Firebase configuration was pasted.'
    }

    function Get-RequiredConfigValue {
        param(
            [string]$ConfigText,
            [string]$Name,
            [switch]$Optional
        )

        $pattern = '(?im)\b' + [regex]::Escape($Name) + '\s*:\s*["'']([^"'']*)["'']'
        $match = [regex]::Match($ConfigText, $pattern)

        if (-not $match.Success) {
            if ($Optional) {
                return ''
            }
            throw "The pasted Firebase config is missing: $Name"
        }

        return $match.Groups[1].Value
    }

    $result = [ordered]@{
        apiKey = (Get-RequiredConfigValue -ConfigText $text -Name 'apiKey')
        authDomain = (Get-RequiredConfigValue -ConfigText $text -Name 'authDomain')
        projectId = (Get-RequiredConfigValue -ConfigText $text -Name 'projectId')
        storageBucket = (Get-RequiredConfigValue -ConfigText $text -Name 'storageBucket')
        messagingSenderId = (Get-RequiredConfigValue -ConfigText $text -Name 'messagingSenderId')
        appId = (Get-RequiredConfigValue -ConfigText $text -Name 'appId')
        measurementId = (Get-RequiredConfigValue -ConfigText $text -Name 'measurementId' -Optional)
    }

    Write-Ok "Firebase config accepted for project: $($result.projectId)"
    return $result
}

function Replace-DoubleQuotedConfigValue {
    param(
        [string]$Content,
        [string]$Name,
        [string]$Value
    )

    $pattern = '(?im)(\b' + [regex]::Escape($Name) + '\s*:\s*)"[^"]*"'
    return [regex]::Replace(
        $Content,
        $pattern,
        {
            param($match)
            return $match.Groups[1].Value + '"' + $Value.Replace('\', '\\').Replace('"', '\"') + '"'
        }
    )
}

function Apply-FirebaseConfig {
    param(
        [string]$RepositoryFolder,
        [System.Collections.IDictionary]$Config
    )

    $updated = 0
    $htmlFiles = Get-ChildItem -LiteralPath $RepositoryFolder -Filter '*.html' -File -Recurse |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }

    foreach ($htmlFile in $htmlFiles) {
        $content = [System.IO.File]::ReadAllText($htmlFile.FullName)
        if ($content -notmatch '\bfirebaseConfig\b') {
            continue
        }

        $original = $content
        foreach ($name in @('apiKey', 'authDomain', 'projectId', 'storageBucket', 'messagingSenderId', 'appId')) {
            $content = Replace-DoubleQuotedConfigValue -Content $content -Name $name -Value ([string]$Config[$name])
        }

        if (-not [string]::IsNullOrWhiteSpace([string]$Config['measurementId'])) {
            $content = Replace-DoubleQuotedConfigValue `
                -Content $content `
                -Name 'measurementId' `
                -Value ([string]$Config['measurementId'])
        }

        if ($content -ne $original) {
            Save-Utf8NoBom -Path $htmlFile.FullName -Text $content
            $updated++
            Write-Host "Firebase updated: $($htmlFile.FullName.Substring($RepositoryFolder.Length + 1))" -ForegroundColor DarkCyan
        }
    }

    if ($updated -eq 0) {
        throw 'No HTML file containing firebaseConfig was updated. The template structure may have changed.'
    }

    Write-Ok "Firebase configuration was applied to $updated HTML files."
}

function Configure-FirebaseProjectFiles {
    param(
        [string]$RepositoryFolder,
        [string]$ProjectId
    )

    $firebasercObject = [ordered]@{
        projects = [ordered]@{
            default = $ProjectId
        }
    }

    $firebaseJsonObject = [ordered]@{
        firestore = [ordered]@{
            rules = 'firestore.rules'
        }
    }

    Save-Utf8NoBom `
        -Path (Join-Path $RepositoryFolder '.firebaserc') `
        -Text (($firebasercObject | ConvertTo-Json -Depth 5) + [Environment]::NewLine)

    Save-Utf8NoBom `
        -Path (Join-Path $RepositoryFolder 'firebase.json') `
        -Text (($firebaseJsonObject | ConvertTo-Json -Depth 5) + [Environment]::NewLine)

    Write-Ok 'Created .firebaserc and firebase.json.'
}

function Deploy-FirestoreRules {
    param(
        [string]$FirebaseExe,
        [string]$RepositoryFolder,
        [string]$ProjectId
    )

    $rulesPath = Join-Path $RepositoryFolder 'firestore.rules'
    if (-not (Test-Path -LiteralPath $rulesPath)) {
        throw 'The template does not contain firestore.rules.'
    }

    Write-Host ''
    Write-Host 'Firestore must exist before its rules can be deployed.' -ForegroundColor White
    Wait-ForEnter 'Press Enter to open Firestore in the Firebase Console'
    Start-Process "https://console.firebase.google.com/project/$ProjectId/firestore" -ErrorAction SilentlyContinue
    Wait-ForEnter 'Create the Firestore database if needed, then press Enter to continue'

    Set-Location -LiteralPath $RepositoryFolder
    [void](Invoke-NativeCommand `
        -FilePath $FirebaseExe `
        -Arguments @('deploy', '--only', 'firestore:rules', '--project', $ProjectId) `
        -FailureMessage 'Firestore rules could not be deployed. Confirm that Firestore Database was created in this Firebase project.')

    Write-Ok 'Firestore security rules were deployed.'
}

try {
    Clear-Host
    Write-Host 'LINEAR ALGEBRA QUIZ - ONLINE SETUP WITH FIREBASE' -ForegroundColor Magenta
    Write-Host 'UI VERSION 6 - PARSER FIX' -ForegroundColor DarkCyan
    Write-Host 'MODE: GitHub website + Firebase multiplayer (guided pop-ups)' -ForegroundColor Magenta
    Write-Host 'This script starts from a completely fresh template copy.'

    Initialize-PopupSupport

    $downloads = Get-DownloadsFolder
    $toolsFolder = Get-ToolRoot

    Write-Step 'STEP 1 OF 10 - Preparing Git, GitHub, and Firebase tools'
    $tools = Ensure-GitAndGitHubCli -ToolsFolder $toolsFolder
    $firebaseExe = Ensure-FirebaseCli -ToolsFolder $toolsFolder

    Write-Step 'STEP 2 OF 10 - Signing in to GitHub'
    $githubUser = Ensure-GitHubLogin -GhExe $tools.Gh

    Write-Step 'STEP 3 OF 10 - Creating or selecting the new GitHub repository'
    $newRepository = Get-NewRepositoryDetails -GhExe $tools.Gh -SignedInUser $githubUser

    Write-Step 'STEP 4 OF 10 - Downloading a completely fresh template copy'
    $repositoryFolder = Join-Path $downloads $newRepository.Name
    Clone-Template -GitExe $tools.Git -Destination $repositoryFolder

    Write-Step 'STEP 5 OF 10 - Removing all old audio features'
    Remove-AudioFeatures -RepositoryFolder $repositoryFolder

    Write-Step 'STEP 6 OF 10 - Signing in to Firebase'
    Ensure-FirebaseLogin -FirebaseExe $firebaseExe

    Write-Step 'STEP 7 OF 10 - Creating the Firebase project and reading its web config'
    Wait-ForEnter 'Press Enter to open the Firebase Console'
    Start-Process 'https://console.firebase.google.com/' -ErrorAction SilentlyContinue
    Write-Host 'Create/select a Firebase project and add a Web app if needed.' -ForegroundColor White
    Write-Host 'Then copy the Config snippet from Project settings.' -ForegroundColor White
    $firebaseConfig = Read-FirebaseConfig

    Apply-FirebaseConfig -RepositoryFolder $repositoryFolder -Config $firebaseConfig
    Configure-FirebaseProjectFiles `
        -RepositoryFolder $repositoryFolder `
        -ProjectId ([string]$firebaseConfig['projectId'])

    Write-Step 'STEP 8 OF 10 - Creating Firestore and deploying secure rules'
    Deploy-FirestoreRules `
        -FirebaseExe $firebaseExe `
        -RepositoryFolder $repositoryFolder `
        -ProjectId ([string]$firebaseConfig['projectId'])

    Write-Step 'STEP 9 OF 10 - Creating the new Git history and pushing to GitHub'
    Initialize-And-PushRepository `
        -GitExe $tools.Git `
        -RepositoryFolder $repositoryFolder `
        -Repository $newRepository `
        -GitHubUser $githubUser `
        -CommitMessage 'Create linear algebra true-or-false website with Firebase'

    Write-Step 'STEP 10 OF 10 - Turning on GitHub Pages'
    [void](Try-EnableGitHubPages -GhExe $tools.Gh -Repository $newRepository)

    $siteUrl = "https://$($newRepository.Owner).github.io/$($newRepository.Name)/"

    Write-Host ''
    Write-Host 'DONE' -ForegroundColor Green
    Write-Host "Local folder:    $repositoryFolder" -ForegroundColor Cyan
    Write-Host "Repository:      $($newRepository.WebUrl)" -ForegroundColor Cyan
    Write-Host "Website:         $siteUrl" -ForegroundColor Cyan
    Write-Host "Firebase project: $($firebaseConfig['projectId'])" -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'GitHub Pages may take a minute or two to become available.' -ForegroundColor Yellow
    Write-Host 'The Firebase web config is intentionally public in browser apps; Firestore rules protect the data.' -ForegroundColor Yellow

    Start-Process $newRepository.WebUrl -ErrorAction SilentlyContinue
    Start-Process $siteUrl -ErrorAction SilentlyContinue

    Show-NoticePopup `
        -Title 'Firebase setup is complete' `
        -Message "The website was downloaded locally, connected to Firebase, pushed to GitHub, and prepared for GitHub Pages." `
        -Type 'Success'
}
catch {
    Write-Host ''
    Write-Host 'SETUP STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ''
    Write-Host 'No force push was used. Existing local folders are backed up rather than deleted.' -ForegroundColor Yellow
    try {
        Show-NoticePopup `
            -Title 'Setup Stopped' `
            -Message 'The Firebase setup could not finish. The PowerShell window contains the detailed reason. No force push was used.' `
            -Type 'Error'
    }
    catch {
        # Keep the console error visible even if Windows dialogs are unavailable.
    }
    Wait-ForEnter 'Press Enter to close'
    exit 1
}

Wait-ForEnter 'Press Enter to close'
