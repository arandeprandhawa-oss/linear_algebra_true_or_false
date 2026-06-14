#requires -Version 5.1
<#
Polished automatic flashcard editor for the Linear Algebra True or False quiz.

- Automatically searches Documents, Desktop, Downloads, remembered locations,
  and the folder containing this script.
- Supports local-only editing.
- Supports Firebase + GitHub editing and publishing.
- Creates a timestamped backup before opening a file.
- Opens the selected file in Notepad.
- Never force-pushes.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepositoryOwner = 'arandeprandhawa-oss'
$RepositoryName = 'linear_algebra_true_or_false'
$RepositoryWebUrl = "https://github.com/$RepositoryOwner/$RepositoryName"
$RepositoryGitUrl = "$RepositoryWebUrl.git"

function Initialize-EditorUi {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName Microsoft.VisualBasic
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function New-EditorButton {
    param(
        [string]$Text,
        [switch]$Primary,
        [int]$Width = 145
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Size = New-Object System.Drawing.Size($Width, 40)
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

function Ask-YesNo {
    param(
        [string]$Title,
        [string]$Message
    )

    $result = [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    return $result -eq [System.Windows.Forms.DialogResult]::Yes
}

function Ask-OkCancel {
    param(
        [string]$Title,
        [string]$Message
    )

    $result = [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    return $result -eq [System.Windows.Forms.DialogResult]::OK
}

function Get-DownloadsFolder {
    $knownFolderId = '{374DE290-123F-4565-9164-39C4925E467B}'
    $registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

    try {
        $item = Get-ItemProperty `
            -Path $registryPath `
            -Name $knownFolderId `
            -ErrorAction Stop

        return [Environment]::ExpandEnvironmentVariables(
            $item.$knownFolderId
        )
    }
    catch {
        $profilePath = [Environment]::GetFolderPath('UserProfile')

        if ([string]::IsNullOrWhiteSpace($profilePath)) {
            $profilePath = $env:USERPROFILE
        }

        return Join-Path $profilePath 'Downloads'
    }
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
        $savedPath = [System.IO.File]::ReadAllText($stateFile).Trim()

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

function Get-FlashcardFiles {
    param([string]$ProjectFolder)

    if (-not (Test-QuizProject -Path $ProjectFolder)) {
        return @()
    }

    $files = Get-ChildItem `
        -LiteralPath $ProjectFolder `
        -File `
        -Recurse `
        -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension.ToLowerInvariant() -in @('.html', '.js', '.json') -and
            $_.FullName -notmatch '[\\/]\.git[\\/]' -and
            $_.FullName -notmatch '[\\/]node_modules[\\/]' -and
            $_.FullName -notmatch '[\\/]backups[\\/]' -and
            $_.FullName -notmatch '[\\/]setup_powershell[\\/]'
        }

    $results = @()

    foreach ($file in $files) {
        $relative = Get-RelativePathSafe `
            -BasePath $ProjectFolder `
            -FullPath $file.FullName

        $priority = 100

        if ($file.Name -match '(?i)^solo\d*\.html$') {
            $priority = 1
        }
        elseif ($file.Name -match '(?i)^etape\d*\.html$') {
            $priority = 10
        }
        elseif ($file.Name -match '(?i)flash|card|question|quiz') {
            $priority = 20
        }
        elseif ($file.Name -ieq 'index.html') {
            $priority = 80
        }

        $results += [pscustomobject]@{
            Display = $relative
            RelativePath = $relative
            FullPath = $file.FullName
            Extension = $file.Extension
            SizeBytes = $file.Length
            LastWriteTime = $file.LastWriteTime
            Priority = $priority
        }
    }

    return @(
        $results |
            Sort-Object Priority, RelativePath
    )
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
        [pscustomobject]$SelectedFile,
        [string]$Mode
    )

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $category = if ($Mode -eq 'Firebase + GitHub') {
        'firebase-flashcard-editor'
    }
    else {
        'local-flashcard-editor'
    }

    $backupRoot = Join-Path `
        $ProjectFolder `
        (Join-Path 'backups' (Join-Path $category $timestamp))

    $backupFile = Join-Path $backupRoot $SelectedFile.RelativePath
    $backupDirectory = Split-Path -Parent $backupFile

    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    Copy-Item -LiteralPath $SelectedFile.FullPath -Destination $backupFile -Force

    return $backupFile
}

function Show-ProjectFolderDialog {
    param([string]$InitialFolder)

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose the main Linear Algebra quiz folder'
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

function Invoke-WebDownload {
    param(
        [string]$Url,
        [string]$OutFile
    )

    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $OutFile `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Flashcard-Editor' } `
        -UseBasicParsing
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

function Invoke-Native {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [string]$FailureMessage,
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
        [string]$FilePath,
        [string[]]$Arguments,
        [string]$FailureMessage,
        [switch]$AllowFailure
    )

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    try {
        $output = & $FilePath @Arguments 2>&1
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
        Text = (($output | ForEach-Object { "$_" }) -join [Environment]::NewLine).Trim()
    }
}

function Install-PortableGit {
    param([string]$ToolRoot)

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Flashcard-Editor' }

    $asset = $release.assets |
        Where-Object { $_.name -match '^PortableGit-.*-64-bit\.7z\.exe$' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw 'Could not find the current 64-bit PortableGit download.'
    }

    $gitFolder = Join-Path $ToolRoot 'PortableGit'
    $installer = Join-Path $ToolRoot $asset.name

    if (Test-Path -LiteralPath $gitFolder) {
        Remove-Item -LiteralPath $gitFolder -Recurse -Force
    }

    New-Item -ItemType Directory -Path $gitFolder -Force | Out-Null
    Invoke-WebDownload -Url $asset.browser_download_url -OutFile $installer

    $process = Start-Process `
        -FilePath $installer `
        -ArgumentList @("-o`"$gitFolder`"", '-y') `
        -Wait `
        -PassThru

    if ($process.ExitCode -ne 0) {
        throw "PortableGit extraction failed with exit code $($process.ExitCode)."
    }

    Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue

    $gitExe = Join-Path $gitFolder 'cmd\git.exe'

    if (-not (Test-Path -LiteralPath $gitExe)) {
        throw 'PortableGit downloaded, but git.exe was not found.'
    }

    return $gitExe
}

function Install-PortableGitHubCli {
    param([string]$ToolRoot)

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/cli/cli/releases/latest' `
        -Headers @{ 'User-Agent' = 'LA-Quiz-Flashcard-Editor' }

    $asset = $release.assets |
        Where-Object { $_.name -match '^gh_.*_windows_amd64\.zip$' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        throw 'Could not find the current 64-bit GitHub CLI download.'
    }

    $ghFolder = Join-Path $ToolRoot 'GitHubCLI'
    $zipFile = Join-Path $ToolRoot $asset.name

    if (Test-Path -LiteralPath $ghFolder) {
        Remove-Item -LiteralPath $ghFolder -Recurse -Force
    }

    New-Item -ItemType Directory -Path $ghFolder -Force | Out-Null
    Invoke-WebDownload -Url $asset.browser_download_url -OutFile $zipFile
    Expand-Archive -LiteralPath $zipFile -DestinationPath $ghFolder -Force
    Remove-Item -LiteralPath $zipFile -Force -ErrorAction SilentlyContinue

    $ghExe = Get-ChildItem `
        -LiteralPath $ghFolder `
        -Filter 'gh.exe' `
        -File `
        -Recurse |
        Select-Object -First 1 -ExpandProperty FullName

    if ([string]::IsNullOrWhiteSpace($ghExe)) {
        throw 'GitHub CLI downloaded, but gh.exe was not found.'
    }

    return $ghExe
}

function Ensure-GitTools {
    $toolRoot = Get-EditorStateFolder
    $gitExe = Get-CommandPath -Names @('git.exe', 'git')

    if ([string]::IsNullOrWhiteSpace($gitExe)) {
        $portableGit = Join-Path $toolRoot 'PortableGit\cmd\git.exe'

        if (Test-Path -LiteralPath $portableGit) {
            $gitExe = $portableGit
        }
        else {
            $gitExe = Install-PortableGit -ToolRoot $toolRoot
        }
    }

    $ghExe = Get-CommandPath -Names @('gh.exe', 'gh')

    if ([string]::IsNullOrWhiteSpace($ghExe)) {
        $portableGh = Get-ChildItem `
            -LiteralPath (Join-Path $toolRoot 'GitHubCLI') `
            -Filter 'gh.exe' `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName

        if (-not [string]::IsNullOrWhiteSpace($portableGh)) {
            $ghExe = $portableGh
        }
        else {
            $ghExe = Install-PortableGitHubCli -ToolRoot $toolRoot
        }
    }

    $env:PATH = "$(Split-Path -Parent $gitExe);$(Split-Path -Parent $ghExe);$env:PATH"

    return [pscustomobject]@{
        Git = $gitExe
        Gh = $ghExe
    }
}

function Ensure-GitHubLogin {
    param([string]$GhExe)

    $status = Invoke-Native `
        -FilePath $GhExe `
        -Arguments @('auth', 'status', '--hostname', 'github.com') `
        -FailureMessage 'GitHub login check failed.' `
        -AllowFailure `
        -Quiet

    if ($status -ne 0) {
        Show-EditorMessage `
            -Title 'GitHub login required' `
            -Message 'A one-time code will appear in PowerShell and GitHub will open in your browser.'

        [void](Read-Host 'Press Enter to begin GitHub login')

        [void](Invoke-Native `
            -FilePath $GhExe `
            -Arguments @(
                'auth',
                'login',
                '--hostname', 'github.com',
                '--git-protocol', 'https',
                '--web'
            ) `
            -FailureMessage 'GitHub login was not completed.')
    }

    [void](Invoke-Native `
        -FilePath $GhExe `
        -Arguments @('auth', 'setup-git') `
        -FailureMessage 'GitHub authentication could not be connected to Git.')

    $userResult = Invoke-NativeCapture `
        -FilePath $GhExe `
        -Arguments @('api', 'user', '--jq', '.login') `
        -FailureMessage 'Could not read the signed-in GitHub username.'

    if ([string]::IsNullOrWhiteSpace($userResult.Text)) {
        throw 'GitHub returned an empty username.'
    }

    return $userResult.Text
}

function Test-CorrectRepository {
    param(
        [string]$GitExe,
        [string]$Folder
    )

    if (-not (Test-Path -LiteralPath (Join-Path $Folder '.git') -PathType Container)) {
        return $false
    }

    $remote = Invoke-NativeCapture `
        -FilePath $GitExe `
        -Arguments @('-C', $Folder, 'remote', 'get-url', 'origin') `
        -FailureMessage 'Could not inspect the repository remote.' `
        -AllowFailure

    if ($remote.ExitCode -ne 0) {
        return $false
    }

    return $remote.Text -match (
        [regex]::Escape("$RepositoryOwner/$RepositoryName")
    )
}

function Get-OrCloneFirebaseRepository {
    param(
        [string]$CurrentProject,
        [pscustomobject]$Tools
    )

    if (Test-CorrectRepository -GitExe $Tools.Git -Folder $CurrentProject) {
        Save-RememberedProject -Mode 'firebase' -Path $CurrentProject
        return $CurrentProject
    }

    $detected = Find-AutomaticQuizProject -Mode 'firebase'

    if (Test-CorrectRepository -GitExe $Tools.Git -Folder $detected) {
        Save-RememberedProject -Mode 'firebase' -Path $detected
        return $detected
    }

    $downloads = Get-DownloadsFolder
    $destination = Join-Path $downloads "$RepositoryName-editor"

    if (Test-Path -LiteralPath $destination) {
        if (Test-CorrectRepository -GitExe $Tools.Git -Folder $destination) {
            Save-RememberedProject -Mode 'firebase' -Path $destination
            return $destination
        }

        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        Move-Item `
            -LiteralPath $destination `
            -Destination "$destination-backup-$timestamp"
    }

    [void](Invoke-Native `
        -FilePath $Tools.Git `
        -Arguments @(
            'clone',
            '--branch', 'main',
            '--single-branch',
            $RepositoryGitUrl,
            $destination
        ) `
        -FailureMessage 'The GitHub repository could not be downloaded.')

    Save-RememberedProject -Mode 'firebase' -Path $destination
    return $destination
}

function Publish-SelectedFile {
    param(
        [pscustomobject]$Tools,
        [string]$RepositoryFolder,
        [pscustomobject]$SelectedFile,
        [string]$GitHubUser
    )

    $status = Invoke-NativeCapture `
        -FilePath $Tools.Git `
        -Arguments @(
            '-C', $RepositoryFolder,
            'status',
            '--porcelain',
            '--',
            $SelectedFile.RelativePath
        ) `
        -FailureMessage 'Git could not inspect the selected file.' `
        -AllowFailure

    if ([string]::IsNullOrWhiteSpace($status.Text)) {
        Show-EditorMessage `
            -Title 'No saved changes found' `
            -Message 'The selected file was not changed, so nothing needs to be uploaded.'

        return
    }

    $publish = Ask-YesNo `
        -Title 'Publish this flashcard change?' `
        -Message @"
A saved change was found in:

$($SelectedFile.RelativePath)

Choose Yes to commit and push only this file to GitHub.
Choose No to keep the saved change only on this computer.
"@

    if (-not $publish) {
        return
    }

    $defaultMessage = "Update flashcards in $([System.IO.Path]::GetFileName($SelectedFile.RelativePath))"

    $commitMessage = [Microsoft.VisualBasic.Interaction]::InputBox(
        'Enter a short description for the GitHub update:',
        'GitHub commit message',
        $defaultMessage
    )

    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = $defaultMessage
    }

    [void](Invoke-Native `
        -FilePath $Tools.Git `
        -Arguments @(
            '-C', $RepositoryFolder,
            'config',
            'user.name',
            $GitHubUser
        ) `
        -FailureMessage 'Git could not set the commit username.')

    [void](Invoke-Native `
        -FilePath $Tools.Git `
        -Arguments @(
            '-C', $RepositoryFolder,
            'config',
            'user.email',
            "$GitHubUser@users.noreply.github.com"
        ) `
        -FailureMessage 'Git could not set the commit email.')

    [void](Invoke-Native `
        -FilePath $Tools.Git `
        -Arguments @(
            '-C', $RepositoryFolder,
            'pull',
            '--rebase',
            '--autostash',
            'origin',
            'main'
        ) `
        -FailureMessage 'Git could not combine the newest GitHub changes safely.')

    [void](Invoke-Native `
        -FilePath $Tools.Git `
        -Arguments @(
            '-C', $RepositoryFolder,
            'add',
            '--',
            $SelectedFile.RelativePath
        ) `
        -FailureMessage 'Git could not stage the selected file.')

    [void](Invoke-Native `
        -FilePath $Tools.Git `
        -Arguments @(
            '-C', $RepositoryFolder,
            'commit',
            '-m',
            $commitMessage
        ) `
        -FailureMessage 'Git could not create the flashcard update commit.')

    [void](Invoke-Native `
        -FilePath $Tools.Git `
        -Arguments @(
            '-C', $RepositoryFolder,
            'push',
            'origin',
            'main'
        ) `
        -FailureMessage 'GitHub rejected the flashcard update.')

    Show-EditorMessage `
        -Title 'Flashcards published' `
        -Message 'The selected flashcard file was committed and pushed to GitHub.'

    Start-Process `
        -FilePath "$RepositoryWebUrl/blob/main/$($SelectedFile.RelativePath.Replace('\', '/'))" `
        -ErrorAction SilentlyContinue
}

function Start-FlashcardEditor {
    $script:Mode = 'Local only'
    $script:ProjectFolder = Find-AutomaticQuizProject -Mode 'local'
    $script:EditableFiles = @()
    $script:GitTools = $null
    $script:GitHubUser = $null

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Linear Algebra Quiz Flashcard Editor'
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size(1120, 760)
    $form.MinimumSize = New-Object System.Drawing.Size(1000, 700)
    $form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
    $form.AllowDrop = $true
    $form.ShowIcon = $false

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = [System.Windows.Forms.DockStyle]::Top
    $header.Height = 124
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
    $title.Text = 'Beginner flashcard editor'
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(28, 43)
    $title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 18)
    $title.ForeColor = [System.Drawing.Color]::White
    $header.Controls.Add($title)

    $subtitle = New-Object System.Windows.Forms.Label
    $subtitle.Text = 'The project is found automatically. Choose a flashcard page, edit it safely, and publish when using Firebase mode.'
    $subtitle.AutoSize = $true
    $subtitle.Location = New-Object System.Drawing.Point(31, 84)
    $subtitle.Font = New-Object System.Drawing.Font('Segoe UI', 9.8)
    $subtitle.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $header.Controls.Add($subtitle)

    $leftPanel = New-Object System.Windows.Forms.Panel
    $leftPanel.Dock = [System.Windows.Forms.DockStyle]::Left
    $leftPanel.Width = 330
    $leftPanel.Padding = New-Object System.Windows.Forms.Padding(22)
    $leftPanel.BackColor = [System.Drawing.Color]::White
    $form.Controls.Add($leftPanel)

    $rightPanel = New-Object System.Windows.Forms.Panel
    $rightPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $rightPanel.Padding = New-Object System.Windows.Forms.Padding(28, 22, 28, 22)
    $rightPanel.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $rightPanel.AutoScroll = $true
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
    $instructions.Text = "1. Choose Local or Firebase mode.`r`n`r`n2. The project is found automatically.`r`n`r`n3. Pick a flashcard file.`r`n`r`n4. Edit in Notepad and press Ctrl+S."
    $instructions.AutoSize = $false
    $instructions.Location = New-Object System.Drawing.Point(22, 59)
    $instructions.Size = New-Object System.Drawing.Size(282, 195)
    $instructions.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $instructions.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
    $leftPanel.Controls.Add($instructions)

    $foundPanel = New-Object System.Windows.Forms.Panel
    $foundPanel.Location = New-Object System.Drawing.Point(22, 265)
    $foundPanel.Size = New-Object System.Drawing.Size(282, 145)
    $foundPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $foundPanel.BackColor = [System.Drawing.Color]::FromArgb(239, 246, 255)
    $leftPanel.Controls.Add($foundPanel)

    $foundTitle = New-Object System.Windows.Forms.Label
    $foundTitle.Text = 'Automatic project detection'
    $foundTitle.AutoSize = $false
    $foundTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $foundTitle.Location = New-Object System.Drawing.Point(10, 24)
    $foundTitle.Size = New-Object System.Drawing.Size(260, 28)
    $foundTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10.5)
    $foundTitle.ForeColor = [System.Drawing.Color]::FromArgb(30, 64, 175)
    $foundPanel.Controls.Add($foundTitle)

    $foundText = New-Object System.Windows.Forms.Label
    $foundText.Text = 'Searching for the installed quiz...'
    $foundText.AutoSize = $false
    $foundText.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $foundText.Location = New-Object System.Drawing.Point(14, 58)
    $foundText.Size = New-Object System.Drawing.Size(252, 66)
    $foundText.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
    $foundPanel.Controls.Add($foundText)

    $autoButton = New-EditorButton -Text 'Find automatically' -Width 282
    $autoButton.Location = New-Object System.Drawing.Point(22, 430)
    $leftPanel.Controls.Add($autoButton)

    $browseButton = New-EditorButton -Text 'Choose a different folder' -Width 282
    $browseButton.Location = New-Object System.Drawing.Point(22, 480)
    $leftPanel.Controls.Add($browseButton)

    $openFolderButton = New-EditorButton -Text 'Open project folder' -Width 282
    $openFolderButton.Location = New-Object System.Drawing.Point(22, 530)
    $leftPanel.Controls.Add($openFolderButton)

    $backupBox = New-Object System.Windows.Forms.Panel
    $backupBox.Location = New-Object System.Drawing.Point(22, 588)
    $backupBox.Size = New-Object System.Drawing.Size(282, 74)
    $backupBox.BackColor = [System.Drawing.Color]::FromArgb(240, 253, 244)
    $leftPanel.Controls.Add($backupBox)

    $backupHelp = New-Object System.Windows.Forms.Label
    $backupHelp.Text = "Backups are created inside:`r`nbackups\local-flashcard-editor"
    $backupHelp.AutoSize = $false
    $backupHelp.Location = New-Object System.Drawing.Point(13, 12)
    $backupHelp.Size = New-Object System.Drawing.Size(256, 52)
    $backupHelp.ForeColor = [System.Drawing.Color]::FromArgb(22, 101, 52)
    $backupBox.Controls.Add($backupHelp)

    $modeLabel = New-Object System.Windows.Forms.Label
    $modeLabel.Text = 'Editing mode'
    $modeLabel.AutoSize = $true
    $modeLabel.Location = New-Object System.Drawing.Point(28, 24)
    $modeLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
    $rightPanel.Controls.Add($modeLabel)

    $modeCombo = New-Object System.Windows.Forms.ComboBox
    $modeCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $modeCombo.Location = New-Object System.Drawing.Point(28, 52)
    $modeCombo.Size = New-Object System.Drawing.Size(680, 32)
    $modeCombo.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    [void]$modeCombo.Items.Add('Local only')
    [void]$modeCombo.Items.Add('Firebase + GitHub')
    $modeCombo.SelectedIndex = 0
    $rightPanel.Controls.Add($modeCombo)

    $projectLabel = New-Object System.Windows.Forms.Label
    $projectLabel.Text = 'Automatically detected project folder'
    $projectLabel.AutoSize = $true
    $projectLabel.Location = New-Object System.Drawing.Point(28, 105)
    $projectLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
    $rightPanel.Controls.Add($projectLabel)

    $projectPathBox = New-Object System.Windows.Forms.TextBox
    $projectPathBox.ReadOnly = $true
    $projectPathBox.Location = New-Object System.Drawing.Point(28, 133)
    $projectPathBox.Size = New-Object System.Drawing.Size(680, 31)
    $projectPathBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $projectPathBox.BackColor = [System.Drawing.Color]::White
    $rightPanel.Controls.Add($projectPathBox)

    $fileLabel = New-Object System.Windows.Forms.Label
    $fileLabel.Text = 'Choose a flashcard file'
    $fileLabel.AutoSize = $true
    $fileLabel.Location = New-Object System.Drawing.Point(28, 184)
    $fileLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
    $rightPanel.Controls.Add($fileLabel)

    $fileCombo = New-Object System.Windows.Forms.ComboBox
    $fileCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $fileCombo.Location = New-Object System.Drawing.Point(28, 212)
    $fileCombo.Size = New-Object System.Drawing.Size(680, 32)
    $fileCombo.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $rightPanel.Controls.Add($fileCombo)

    $detailsPanel = New-Object System.Windows.Forms.Panel
    $detailsPanel.Location = New-Object System.Drawing.Point(28, 267)
    $detailsPanel.Size = New-Object System.Drawing.Size(680, 172)
    $detailsPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $detailsPanel.BackColor = [System.Drawing.Color]::White
    $detailsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $rightPanel.Controls.Add($detailsPanel)

    $detailsHeading = New-Object System.Windows.Forms.Label
    $detailsHeading.Text = 'Selected file details'
    $detailsHeading.AutoSize = $true
    $detailsHeading.Location = New-Object System.Drawing.Point(18, 17)
    $detailsHeading.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10.5)
    $detailsPanel.Controls.Add($detailsHeading)

    $detailsText = New-Object System.Windows.Forms.Label
    $detailsText.Text = 'The editor is finding your quiz project.'
    $detailsText.AutoSize = $false
    $detailsText.Location = New-Object System.Drawing.Point(18, 51)
    $detailsText.Size = New-Object System.Drawing.Size(640, 100)
    $detailsText.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $detailsText.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
    $detailsPanel.Controls.Add($detailsText)

    $backupCheck = New-Object System.Windows.Forms.CheckBox
    $backupCheck.Text = 'Create a timestamped backup before editing'
    $backupCheck.Checked = $true
    $backupCheck.AutoSize = $true
    $backupCheck.Location = New-Object System.Drawing.Point(30, 462)
    $rightPanel.Controls.Add($backupCheck)

    $refreshButton = New-EditorButton -Text 'Refresh files'
    $refreshButton.Location = New-Object System.Drawing.Point(28, 505)
    $rightPanel.Controls.Add($refreshButton)

    $editButton = New-EditorButton -Text 'Edit in Notepad' -Primary -Width 180
    $editButton.Location = New-Object System.Drawing.Point(528, 505)
    $editButton.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
    $editButton.Enabled = $false
    $rightPanel.Controls.Add($editButton)

    $statusPanel = New-Object System.Windows.Forms.Panel
    $statusPanel.Location = New-Object System.Drawing.Point(28, 565)
    $statusPanel.Size = New-Object System.Drawing.Size(680, 70)
    $statusPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $statusPanel.BackColor = [System.Drawing.Color]::FromArgb(241, 245, 249)
    $rightPanel.Controls.Add($statusPanel)

    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = 'Searching automatically...'
    $statusLabel.AutoSize = $false
    $statusLabel.Location = New-Object System.Drawing.Point(15, 13)
    $statusLabel.Size = New-Object System.Drawing.Size(646, 44)
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

    $updateFileDetails = {
        if ($fileCombo.SelectedIndex -lt 0 -or
            $fileCombo.SelectedIndex -ge $script:EditableFiles.Count) {
            $detailsText.Text = 'Choose a flashcard file.'
            $editButton.Enabled = $false
            return
        }

        $selected = $script:EditableFiles[$fileCombo.SelectedIndex]
        $detailsText.Text = "Path: $($selected.RelativePath)`r`nType: $($selected.Extension)`r`nSize: $(Format-FileSize -Bytes $selected.SizeBytes)`r`nLast changed: $($selected.LastWriteTime.ToString('yyyy-MM-dd h:mm tt'))"
        $editButton.Enabled = $true
    }.GetNewClosure()

    $loadFiles = {
        param([string]$PreferredFile)

        $fileCombo.Items.Clear()
        $script:EditableFiles = @()

        if (-not (Test-QuizProject -Path $script:ProjectFolder)) {
            $projectPathBox.Text = ''
            $foundText.Text = 'No project found yet.'
            $detailsText.Text = 'Use Find automatically or Choose a different folder.'
            $editButton.Enabled = $false
            & $setStatus 'No Linear Algebra quiz project is selected.' 'Warning'
            return
        }

        $projectPathBox.Text = $script:ProjectFolder
        $foundText.Text = "Found:`r`n$script:ProjectFolder"

        $rememberMode = if ($script:Mode -eq 'Firebase + GitHub') {
            'firebase'
        }
        else {
            'local'
        }

        Save-RememberedProject `
            -Mode $rememberMode `
            -Path $script:ProjectFolder

        $script:EditableFiles = @(Get-FlashcardFiles -ProjectFolder $script:ProjectFolder)

        foreach ($file in $script:EditableFiles) {
            [void]$fileCombo.Items.Add($file.Display)
        }

        if ($script:EditableFiles.Count -eq 0) {
            $detailsText.Text = 'No HTML, JavaScript, or JSON flashcard files were found.'
            $editButton.Enabled = $false
            & $setStatus 'The project was found, but it contains no editable flashcard files.' 'Warning'
            return
        }

        $selectedIndex = 0

        if (-not [string]::IsNullOrWhiteSpace($PreferredFile)) {
            for ($index = 0; $index -lt $script:EditableFiles.Count; $index++) {
                if ($script:EditableFiles[$index].FullPath -ieq $PreferredFile) {
                    $selectedIndex = $index
                    break
                }
            }
        }

        $fileCombo.SelectedIndex = $selectedIndex
        & $setStatus "Automatically loaded $($script:EditableFiles.Count) editable file(s)." 'Success'
    }.GetNewClosure()

    $findProject = {
        $form.UseWaitCursor = $true
        [System.Windows.Forms.Application]::DoEvents()

        try {
            & $setStatus 'Searching Documents, Desktop, Downloads, OneDrive, and remembered locations...' 'Normal'

            $modeKey = if ($script:Mode -eq 'Firebase + GitHub') {
                'firebase'
            }
            else {
                'local'
            }

            $detected = Find-AutomaticQuizProject -Mode $modeKey

            if ([string]::IsNullOrWhiteSpace($detected)) {
                $script:ProjectFolder = $null
                & $loadFiles $null

                Show-EditorMessage `
                    -Title 'Project not found automatically' `
                    -Message 'The editor checked Documents, Desktop, Downloads, OneDrive, its own folder, parent folders, and remembered installation locations. Use Choose a different folder as a fallback.' `
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
    }.GetNewClosure()

    $modeCombo.Add_SelectedIndexChanged({
        $script:Mode = [string]$modeCombo.SelectedItem
        $backupHelp.Text = if ($script:Mode -eq 'Firebase + GitHub') {
            "Backups are created inside:`r`nbackups\firebase-flashcard-editor"
        }
        else {
            "Backups are created inside:`r`nbackups\local-flashcard-editor"
        }

        & $findProject
    }.GetNewClosure())

    $autoButton.Add_Click({
        & $setStatus 'Searching Documents, Desktop, and Downloads...' 'Normal'
        & $findProject
    }.GetNewClosure())

    $browseButton.Add_Click({
        $selected = Show-ProjectFolderDialog -InitialFolder $script:ProjectFolder

        if (-not [string]::IsNullOrWhiteSpace($selected)) {
            $root = Find-ProjectRootFromPath -Path $selected

            if ([string]::IsNullOrWhiteSpace($root)) {
                Show-EditorMessage `
                    -Title 'Quiz project not found' `
                    -Message 'Choose the main folder containing index.html and the solo quiz pages.' `
                    -Type 'Warning'

                return
            }

            $script:ProjectFolder = $root
            & $loadFiles $null
        }
    }.GetNewClosure())

    $openFolderButton.Add_Click({
        if (Test-QuizProject -Path $script:ProjectFolder) {
            Start-Process `
                -FilePath 'explorer.exe' `
                -ArgumentList "`"$script:ProjectFolder`""
        }
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
        & $updateFileDetails
    }.GetNewClosure())

    $editButton.Add_Click({
        if ($fileCombo.SelectedIndex -lt 0 -or
            $fileCombo.SelectedIndex -ge $script:EditableFiles.Count) {
            return
        }

        $selected = $script:EditableFiles[$fileCombo.SelectedIndex]

        try {
            if ($script:Mode -eq 'Firebase + GitHub') {
                $form.UseWaitCursor = $true
                & $setStatus 'Preparing GitHub tools and repository...' 'Normal'
                [System.Windows.Forms.Application]::DoEvents()

                $script:GitTools = Ensure-GitTools
                $script:GitHubUser = Ensure-GitHubLogin -GhExe $script:GitTools.Gh

                $repository = Get-OrCloneFirebaseRepository `
                    -CurrentProject $script:ProjectFolder `
                    -Tools $script:GitTools

                if ($repository -ine $script:ProjectFolder) {
                    $script:ProjectFolder = $repository
                    & $loadFiles $null

                    $matchIndex = -1

                    for ($index = 0; $index -lt $script:EditableFiles.Count; $index++) {
                        if ($script:EditableFiles[$index].RelativePath -ieq $selected.RelativePath) {
                            $matchIndex = $index
                            break
                        }
                    }

                    if ($matchIndex -ge 0) {
                        $fileCombo.SelectedIndex = $matchIndex
                        $selected = $script:EditableFiles[$matchIndex]
                    }
                    else {
                        Show-EditorMessage `
                            -Title 'Choose the file again' `
                            -Message 'The Firebase repository was prepared. Choose the flashcard file again from the list.' `
                            -Type 'Information'

                        return
                    }
                }
            }

            $backupPath = $null

            if ($backupCheck.Checked) {
                $backupPath = Create-FileBackup `
                    -ProjectFolder $script:ProjectFolder `
                    -SelectedFile $selected `
                    -Mode $script:Mode
            }

            Start-Process `
                -FilePath 'notepad.exe' `
                -ArgumentList "`"$($selected.FullPath)`""

            $finished = Ask-OkCancel `
                -Title 'Finish editing in Notepad' `
                -Message @"
Make the flashcard changes in Notepad and press Ctrl+S.

After saving, return here and choose OK.
Choose Cancel to stop without publishing.
"@

            if (-not $finished) {
                & $setStatus 'Editing stopped. Any saved local changes were kept.' 'Warning'
                return
            }

            if ($script:Mode -eq 'Firebase + GitHub') {
                Publish-SelectedFile `
                    -Tools $script:GitTools `
                    -RepositoryFolder $script:ProjectFolder `
                    -SelectedFile $selected `
                    -GitHubUser $script:GitHubUser

                & $setStatus 'The Firebase/GitHub flashcard workflow finished.' 'Success'
            }
            else {
                & $setStatus "Local flashcards saved. Backup: $backupPath" 'Success'

                if (Ask-YesNo `
                    -Title 'Open the local quiz?' `
                    -Message 'Open index.html now to test the flashcard change?') {
                    Start-Process `
                        -FilePath (Join-Path $script:ProjectFolder 'index.html') `
                        -ErrorAction SilentlyContinue
                }
            }
        }
        catch {
            & $setStatus $_.Exception.Message 'Error'

            Show-EditorMessage `
                -Title 'Could not finish the flashcard edit' `
                -Message $_.Exception.Message `
                -Type 'Error'
        }
        finally {
            $form.UseWaitCursor = $false
        }
    }.GetNewClosure())

    $form.Add_Shown({
        & $findProject
    }.GetNewClosure())

    [void]$form.ShowDialog()
    $form.Dispose()
}

try {
    Initialize-EditorUi
    Start-FlashcardEditor
}
catch {
    try {
        Initialize-EditorUi

        Show-EditorMessage `
            -Title 'Flashcard editor could not start' `
            -Message $_.Exception.Message `
            -Type 'Error'
    }
    catch {
        Write-Host "Flashcard editor could not start: $($_.Exception.Message)" -ForegroundColor Red
        [void](Read-Host 'Press Enter to close')
    }

    exit 1
}
