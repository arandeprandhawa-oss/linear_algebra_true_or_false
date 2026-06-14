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
    Add-Type -AssemblyName Microsoft.VisualBasic
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function Show-TextPopup {
    param(
        [string]$Title,
        [string]$Prompt,
        [string]$DefaultValue = ''
    )

    return [Microsoft.VisualBasic.Interaction]::InputBox(
        $Prompt,
        $Title,
        $DefaultValue
    )
}

function Show-FolderPopup {
    param(
        [string]$Title,
        [string]$InitialFolder
    )

    $owner = New-Object System.Windows.Forms.Form
    $owner.TopMost = $true
    $owner.ShowInTaskbar = $false
    $owner.StartPosition = 'CenterScreen'
    $owner.Size = New-Object System.Drawing.Size(1, 1)
    $owner.Opacity = 0
    $owner.Show()

    try {
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = $Title
        $dialog.ShowNewFolderButton = $true

        if (-not [string]::IsNullOrWhiteSpace($InitialFolder) -and
            (Test-Path -LiteralPath $InitialFolder)) {
            $dialog.SelectedPath = $InitialFolder
        }

        $result = $dialog.ShowDialog($owner)
        if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
            return $null
        }

        return $dialog.SelectedPath
    }
    finally {
        $owner.Close()
        $owner.Dispose()
    }
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
    Write-Host 'MODE: Local computer only - no GitHub and no Firebase' -ForegroundColor Magenta
    Write-Host 'Nothing needs to be installed except the website files themselves.'

    Initialize-PopupSupport

    $documents = [Environment]::GetFolderPath('MyDocuments')
    if ([string]::IsNullOrWhiteSpace($documents)) {
        $documents = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Documents'
    }

    Write-Step 'STEP 1 OF 5 - Choosing where to install the local website'
    $parentFolder = Show-FolderPopup `
        -Title 'Choose the folder where the local website should be installed' `
        -InitialFolder $documents

    if ([string]::IsNullOrWhiteSpace($parentFolder)) {
        throw 'Installation was cancelled before a folder was selected.'
    }

    $folderName = Show-TextPopup `
        -Title 'Local website folder name' `
        -Prompt 'Enter a name for the website folder:' `
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
}
catch {
    Write-Host ''
    Write-Host 'INSTALLATION STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ''
    Write-Host 'Existing website folders are backed up instead of being deleted.' -ForegroundColor Yellow
    Wait-ForEnter 'Press Enter to close'
    exit 1
}

Wait-ForEnter 'Press Enter to close'
