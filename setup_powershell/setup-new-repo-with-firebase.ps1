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
        $link = Read-Host 'After creating it, paste the new GitHub repository link here'
        $repo = Parse-GitHubRepositoryLink -Link $link

        if ($null -eq $repo) {
            Write-Warn 'That does not look like a GitHub repository link. Example: https://github.com/name/my-quiz'
            continue
        }

        $check = Invoke-NativeCommand `
            -FilePath $GhExe `
            -Arguments @('repo', 'view', "$($repo.Owner)/$($repo.Name)") `
            -AllowFailure `
            -Quiet

        if ($check -ne 0) {
            Write-Warn 'GitHub cannot find that repository yet. Finish creating it, then paste the link again.'
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
    Write-Host ''
    Write-Host 'In Firebase: Project settings > General > Your apps > SDK setup and configuration > Config' -ForegroundColor White
    Write-Host 'Paste the ENTIRE firebaseConfig block below.' -ForegroundColor White
    Write-Host 'After the final }; line, type END on a new line and press Enter.' -ForegroundColor Yellow
    Write-Host ''

    $lines = New-Object System.Collections.Generic.List[string]
    while ($true) {
        $line = Read-Host
        if ($line.Trim() -eq 'END') {
            break
        }
        $lines.Add($line)
    }

    $text = $lines -join [Environment]::NewLine
    if ([string]::IsNullOrWhiteSpace($text)) {
        throw 'No Firebase configuration was pasted.'
    }

    function Get-RequiredConfigValue {
        param(
            [string]$ConfigText,
            [string]$Name,
            [switch]$Optional
        )

        $pattern = '(?im)\b' + [regex]::Escape($Name) + '\s*:\s*"([^"]*)"'
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
    Write-Host 'LINEAR ALGEBRA QUIZ - CREATE NEW REPOSITORY' -ForegroundColor Magenta
    Write-Host 'MODE: GitHub + Firebase multiplayer' -ForegroundColor Magenta
    Write-Host 'This script starts from a completely fresh template copy.'

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
}
catch {
    Write-Host ''
    Write-Host 'SETUP STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ''
    Write-Host 'No force push was used. Existing local folders are backed up rather than deleted.' -ForegroundColor Yellow
    Wait-ForEnter 'Press Enter to close'
    exit 1
}

Wait-ForEnter 'Press Enter to close'
