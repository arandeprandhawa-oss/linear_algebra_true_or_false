#requires -Version 5.1
<#
.SYNOPSIS
    Signs in to Firebase, connects the current quiz folder to an existing
    Firebase project, and saves .firebaserc/firebase.json for future deploys.

.DESCRIPTION
    This tool does not need a Firebase Web API key to deploy Firestore rules.
    It uses the Firebase CLI login and a Firebase project ID. It can detect the
    project ID from the website's existing firebaseConfig, or let the user pick
    from projects available to the signed-in Google account.
#>

param(
    [string]$ProjectFolder,
    [switch]$CalledByDeploy
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Prevent the Firebase CLI from pausing for telemetry/update prompts during
# automatic checks. Interactive browser login still works normally.
$env:FIREBASE_CLI_DISABLE_TELEMETRY = '1'
$env:NO_UPDATE_NOTIFIER = '1'

function Initialize-Ui {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function Show-AppMessage {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error')][string]$Type = 'Info'
    )

    $icon = switch ($Type) {
        'Warning' { [System.Windows.Forms.MessageBoxIcon]::Warning }
        'Error'   { [System.Windows.Forms.MessageBoxIcon]::Error }
        default   { [System.Windows.Forms.MessageBoxIcon]::Information }
    }

    [void][System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        $icon
    )
}

function Write-Step {
    param([string]$Message)
    Write-Host ''
    Write-Host '====================================================================' -ForegroundColor DarkGray
    Write-Host $Message -ForegroundColor Cyan
    Write-Host '====================================================================' -ForegroundColor DarkGray
}

function Write-Ok { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Info { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Yellow }
function Write-Warn { param([string]$Message) Write-Host "[WARNING] $Message" -ForegroundColor DarkYellow }

function Save-Utf8NoBom {
    param([string]$Path, [AllowEmptyString()][string]$Text)
    [System.IO.File]::WriteAllText(
        $Path,
        $Text,
        (New-Object System.Text.UTF8Encoding($false))
    )
}

function Get-DownloadsFolder {
    try {
        $item = Get-ItemProperty `
            -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' `
            -Name '{374DE290-123F-4565-9164-39C4925E467B}' `
            -ErrorAction Stop

        return [Environment]::ExpandEnvironmentVariables(
            $item.'{374DE290-123F-4565-9164-39C4925E467B}'
        )
    }
    catch {
        $profile = [Environment]::GetFolderPath('UserProfile')
        if ([string]::IsNullOrWhiteSpace($profile)) { $profile = $env:USERPROFILE }
        if (-not [string]::IsNullOrWhiteSpace($profile)) {
            return [System.IO.Path]::Combine($profile, 'Downloads')
        }
        return $PSScriptRoot
    }
}

function Get-StateFolder {
    # Prefer the Windows known-folder API. Environment variables can be empty
    # in some stripped-down launch environments, so every fallback is checked
    # before it is passed to Join-Path.
    $root = [Environment]::GetFolderPath('LocalApplicationData')
    if ([string]::IsNullOrWhiteSpace($root)) { $root = $env:LOCALAPPDATA }

    if ([string]::IsNullOrWhiteSpace($root)) {
        $profile = [Environment]::GetFolderPath('UserProfile')
        if ([string]::IsNullOrWhiteSpace($profile)) { $profile = $env:USERPROFILE }
        if (-not [string]::IsNullOrWhiteSpace($profile)) {
            $root = [System.IO.Path]::Combine($profile, 'AppData', 'Local')
        }
    }

    if ([string]::IsNullOrWhiteSpace($root)) {
        throw 'Windows could not provide a Local AppData folder for the Firebase tools.'
    }

    $folder = [System.IO.Path]::Combine($root, 'LAQuizTools')
    [void][System.IO.Directory]::CreateDirectory($folder)
    return $folder
}

function Test-QuizProject {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or
        -not (Test-Path -LiteralPath $Path -PathType Container)) {
        return $false
    }

    return (Test-Path -LiteralPath (Join-Path $Path 'index.html') -PathType Leaf) -and
           (Test-Path -LiteralPath (Join-Path $Path 'firestore.rules') -PathType Leaf) -and
           (Test-Path -LiteralPath (Join-Path $Path 'etapes\registry.js') -PathType Leaf)
}

function Find-ProjectRootFromPath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }

    $candidate = if (Test-Path -LiteralPath $Path -PathType Leaf) {
        Split-Path -Parent $Path
    }
    else {
        $Path
    }

    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) { return $null }

    $directory = Get-Item -LiteralPath $candidate
    while ($null -ne $directory) {
        if (Test-QuizProject -Path $directory.FullName) { return $directory.FullName }
        $directory = $directory.Parent
    }

    $children = Get-ChildItem -LiteralPath $candidate -Directory -ErrorAction SilentlyContinue |
        Sort-Object `
            @{ Expression = { if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 } } },
            @{ Expression = { $_.LastWriteTime }; Descending = $true }

    foreach ($child in $children) {
        if (Test-QuizProject -Path $child.FullName) { return $child.FullName }
    }

    return $null
}

function Find-AutomaticProject {
    if (-not [string]::IsNullOrWhiteSpace($ProjectFolder)) {
        $provided = Find-ProjectRootFromPath -Path $ProjectFolder
        if (-not [string]::IsNullOrWhiteSpace($provided)) { return $provided }
    }

    foreach ($mode in @('firebase','javascript','local')) {
        $stateFile = Join-Path (Get-StateFolder) "last-$mode-project.txt"
        if (-not (Test-Path -LiteralPath $stateFile -PathType Leaf)) { continue }

        try {
            $saved = [System.IO.File]::ReadAllText(
                $stateFile,
                [System.Text.Encoding]::UTF8
            ).Trim()

            if (Test-QuizProject -Path $saved) { return $saved }
        }
        catch { }
    }

    $scriptFolder = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptFolder)) { $scriptFolder = (Get-Location).Path }

    foreach ($candidate in @($scriptFolder, (Get-Location).Path)) {
        $hit = Find-ProjectRootFromPath -Path $candidate
        if (-not [string]::IsNullOrWhiteSpace($hit)) { return $hit }
    }

    $profile = [Environment]::GetFolderPath('UserProfile')
    if ([string]::IsNullOrWhiteSpace($profile)) { $profile = $env:USERPROFILE }

    $roots = @(
        (Get-DownloadsFolder),
        [Environment]::GetFolderPath('MyDocuments'),
        [Environment]::GetFolderPath('Desktop')
    )
    if (-not [string]::IsNullOrWhiteSpace($profile)) {
        $roots += [System.IO.Path]::Combine($profile, 'OneDrive')
    }

    $skip = @(
        '.git','node_modules','backups','AppData','$RECYCLE.BIN',
        'System Volume Information','Windows','Program Files','Program Files (x86)'
    )

    foreach ($root in $roots) {
        if ([string]::IsNullOrWhiteSpace($root) -or
            -not (Test-Path -LiteralPath $root -PathType Container)) {
            continue
        }

        $queue = New-Object System.Collections.Queue
        $queue.Enqueue([pscustomobject]@{ Path = $root; Depth = 0 })
        $visited = 0

        while ($queue.Count -gt 0 -and $visited -lt 6000) {
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
                    @{ Expression = { if ($_.Name -match '(?i)linear.*algebra|true.*false') { 0 } else { 1 } } },
                    @{ Expression = { $_.LastWriteTime }; Descending = $true }

            foreach ($child in $children) {
                $queue.Enqueue([pscustomobject]@{
                    Path = $child.FullName
                    Depth = $entry.Depth + 1
                })
            }
        }
    }

    return $null
}

function Choose-ProjectFolder {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose the quiz folder containing index.html and firestore.rules'
    $dialog.ShowNewFolderButton = $false

    $result = $dialog.ShowDialog()
    $selected = if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $dialog.SelectedPath
    }
    else {
        $null
    }

    $dialog.Dispose()

    if ([string]::IsNullOrWhiteSpace($selected)) { return $null }
    return Find-ProjectRootFromPath -Path $selected
}

function Find-NpmCommand {
    foreach ($name in @('npm.cmd','npm.exe','npm')) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $command) { return $command.Source }
    }
    return $null
}

function Find-NodeCommand {
    foreach ($name in @('node.exe','node')) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $command) { return $command.Source }
    }
    return $null
}

function Test-FirebaseCliBasic {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or
        -not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = (& $Path --version 2>&1 | Out-String).Trim()
        $code = $LASTEXITCODE
    }
    catch {
        return $false
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }

    if ($code -ne 0) { return $false }
    if ($output -match '(?i)SyntaxError|Unexpected end of JSON|welcome\.js|firepit') { return $false }
    return ($output -match '\d+\.\d+')
}

function Get-LocalNpmFirebaseCliPath {
    $installRoot = Join-Path (Get-StateFolder) 'FirebaseCLI-NPM'
    return Join-Path $installRoot 'node_modules\.bin\firebase.cmd'
}

function Find-FirebaseCli {
    # Prefer the npm-installed CLI. The old standalone Windows firebase.exe
    # can fail inside firepit/welcome.js before login even starts.
    $localNpmCli = Get-LocalNpmFirebaseCliPath
    if (Test-FirebaseCliBasic -Path $localNpmCli) { return $localNpmCli }

    # A normal npm global install exposes firebase.cmd on Windows.
    $globalCmd = Get-Command 'firebase.cmd' -ErrorAction SilentlyContinue
    if ($null -ne $globalCmd -and (Test-FirebaseCliBasic -Path $globalCmd.Source)) {
        return $globalCmd.Source
    }

    return $null
}

function Disable-LegacyStandaloneFirebase {
    $legacyFolder = Join-Path (Get-StateFolder) 'FirebaseCLI'
    $legacyExe = Join-Path $legacyFolder 'firebase.exe'
    if (-not (Test-Path -LiteralPath $legacyExe -PathType Leaf)) { return }

    $disabled = Join-Path $legacyFolder 'firebase-standalone-disabled.exe'
    try {
        if (Test-Path -LiteralPath $disabled -PathType Leaf) {
            Remove-Item -LiteralPath $disabled -Force -ErrorAction SilentlyContinue
        }
        Move-Item -LiteralPath $legacyExe -Destination $disabled -Force
        Write-Warn 'Disabled the older standalone Firebase executable that caused the welcome.js JSON error.'
    }
    catch {
        # Ignoring it is enough because this script no longer selects firebase.exe.
    }
}

function Install-FirebaseCli {
    $node = Find-NodeCommand
    $npm = Find-NpmCommand

    if ([string]::IsNullOrWhiteSpace($node) -or [string]::IsNullOrWhiteSpace($npm)) {
        throw "Node.js and npm are required for the reliable Firebase CLI installation.`r`n`r`nInstall the current Node.js LTS release, reopen this command, and run it again."
    }

    $nodeVersionText = (& $node --version 2>&1 | Out-String).Trim()
    $nodeVersionMatch = [regex]::Match($nodeVersionText, 'v?(\d+)')
    if (-not $nodeVersionMatch.Success -or [int]$nodeVersionMatch.Groups[1].Value -lt 18) {
        throw "Firebase CLI requires Node.js 18 or newer. Detected: $nodeVersionText"
    }

    $installRoot = Join-Path (Get-StateFolder) 'FirebaseCLI-NPM'
    [void][System.IO.Directory]::CreateDirectory($installRoot)

    Write-Info "Installing the official npm Firebase CLI into:`r`n       $installRoot"
    Write-Info 'The first installation can take a few minutes. npm progress will appear below.'

    $oldAudit = $env:npm_config_audit
    $oldFund = $env:npm_config_fund
    $oldNotifier = $env:npm_config_update_notifier
    try {
        $env:npm_config_audit = 'false'
        $env:npm_config_fund = 'false'
        $env:npm_config_update_notifier = 'false'

        # Consume npm's success-stream output so this function returns only
        # the final firebase.cmd path instead of an array of log lines.
        & $npm install --prefix $installRoot firebase-tools@latest --no-audit --no-fund 2>&1 |
            ForEach-Object { Write-Host $_ }
        $npmExitCode = $LASTEXITCODE
    }
    finally {
        if ($null -eq $oldAudit) { Remove-Item Env:\npm_config_audit -ErrorAction SilentlyContinue } else { $env:npm_config_audit = $oldAudit }
        if ($null -eq $oldFund) { Remove-Item Env:\npm_config_fund -ErrorAction SilentlyContinue } else { $env:npm_config_fund = $oldFund }
        if ($null -eq $oldNotifier) { Remove-Item Env:\npm_config_update_notifier -ErrorAction SilentlyContinue } else { $env:npm_config_update_notifier = $oldNotifier }
    }

    if ($npmExitCode -ne 0) {
        throw "npm could not install firebase-tools. Exit code: $npmExitCode`r`n`r`nCheck the internet connection and run this command again."
    }

    $firebaseCmd = Get-LocalNpmFirebaseCliPath
    if (-not (Test-FirebaseCliBasic -Path $firebaseCmd)) {
        throw "firebase-tools finished installing, but the Firebase command did not pass its startup test.`r`n`r`nExpected file:`r`n$firebaseCmd"
    }

    Disable-LegacyStandaloneFirebase
    Write-Ok "Firebase CLI installed with npm: $firebaseCmd"
    return $firebaseCmd
}

function Ensure-FirebaseCli {
    Disable-LegacyStandaloneFirebase

    $firebaseExe = Find-FirebaseCli
    if ([string]::IsNullOrWhiteSpace($firebaseExe)) {
        $firebaseExe = Install-FirebaseCli
    }

    if ([string]::IsNullOrWhiteSpace([string]$firebaseExe)) {
        throw 'The Firebase CLI installer returned an empty command path.'
    }

    $firebaseExe = [string]$firebaseExe
    $firebaseDirectory = [System.IO.Path]::GetDirectoryName($firebaseExe)
    if (-not [string]::IsNullOrWhiteSpace($firebaseDirectory) -and
        $env:PATH -notlike "*$firebaseDirectory*") {
        $env:PATH = "$firebaseDirectory;$env:PATH"
    }

    Write-Ok "Firebase CLI ready: $firebaseExe"
    return $firebaseExe
}

function ConvertTo-NativeArgument {
    param([AllowEmptyString()][string]$Value)

    if ($null -eq $Value) { return '""' }
    if ($Value -notmatch '[\s"]') { return $Value }

    # Firebase arguments in this tool are simple switches/IDs. Escaping quotes
    # is still included so paths or future values containing spaces are safe.
    return '"' + ($Value.Replace('"', '\"')) + '"'
}

function Invoke-FirebaseCapture {
    param(
        [string]$FirebaseExe,
        [string[]]$Arguments,
        [int]$TimeoutSeconds = 45,
        [switch]$AllowFailure
    )

    if ([string]::IsNullOrWhiteSpace($FirebaseExe)) {
        throw 'The Firebase command path is empty.'
    }
    if (-not (Test-Path -LiteralPath $FirebaseExe -PathType Leaf)) {
        throw "The Firebase command was not found at: $FirebaseExe"
    }

    $argumentText = (($Arguments | ForEach-Object {
        ConvertTo-NativeArgument -Value ([string]$_)
    }) -join ' ')

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $extension = [System.IO.Path]::GetExtension($FirebaseExe)

    if ($extension -match '^(?i)\.(cmd|bat)$') {
        $commandProcessor = $env:ComSpec
        if ([string]::IsNullOrWhiteSpace($commandProcessor)) {
            $windowsRoot = $env:SystemRoot
            if ([string]::IsNullOrWhiteSpace($windowsRoot)) { $windowsRoot = $env:WINDIR }
            if (-not [string]::IsNullOrWhiteSpace($windowsRoot)) {
                $commandProcessor = [System.IO.Path]::Combine($windowsRoot, 'System32', 'cmd.exe')
            }
        }
        if ([string]::IsNullOrWhiteSpace($commandProcessor)) {
            $cmd = Get-Command 'cmd.exe' -ErrorAction SilentlyContinue
            if ($null -ne $cmd) { $commandProcessor = $cmd.Source }
        }
        if ([string]::IsNullOrWhiteSpace($commandProcessor)) {
            throw 'Windows Command Prompt (cmd.exe) could not be found.'
        }

        $startInfo.FileName = $commandProcessor
        $startInfo.Arguments = ('/d /s /c ""{0}" {1}"' -f $FirebaseExe, $argumentText)
    }
    else {
        $startInfo.FileName = $FirebaseExe
        $startInfo.Arguments = $argumentText
    }

    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.RedirectStandardInput = $true
    $startInfo.EnvironmentVariables['FIREBASE_CLI_DISABLE_TELEMETRY'] = '1'
    $startInfo.EnvironmentVariables['NO_UPDATE_NOTIFIER'] = '1'
    $startInfo.EnvironmentVariables['CI'] = '1'

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo

    try {
        if (-not $process.Start()) {
            throw 'The Firebase CLI process could not be started.'
        }

        # Closing stdin prevents a hidden yes/no prompt from waiting forever.
        $process.StandardInput.Close()
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        $finished = $process.WaitForExit($TimeoutSeconds * 1000)
        if (-not $finished) {
            # Never pass an empty SystemRoot/WINDIR value to Join-Path. Some
            # launchers omit those variables, which previously hid the real
            # timeout behind: "Cannot bind argument to parameter Path".
            $stopped = $false
            $windowsRoot = $env:SystemRoot
            if ([string]::IsNullOrWhiteSpace($windowsRoot)) { $windowsRoot = $env:WINDIR }

            if (-not [string]::IsNullOrWhiteSpace($windowsRoot)) {
                $taskKill = [System.IO.Path]::Combine($windowsRoot, 'System32', 'taskkill.exe')
                if (Test-Path -LiteralPath $taskKill -PathType Leaf) {
                    try {
                        & $taskKill /PID $process.Id /T /F *> $null
                        $stopped = $true
                    }
                    catch { }
                }
            }

            if (-not $stopped) {
                try {
                    Stop-Process -Id $process.Id -Force -ErrorAction Stop
                    $stopped = $true
                }
                catch {
                    try { $process.Kill() } catch { }
                }
            }

            try { $process.WaitForExit(5000) | Out-Null } catch { }
            $partialOut = try { $stdoutTask.Result } catch { '' }
            $partialErr = try { $stderrTask.Result } catch { '' }
            $partialText = (($partialOut, $partialErr) -join [Environment]::NewLine).Trim()

            return [pscustomobject]@{
                ExitCode = 124
                Text = $partialText
                TimedOut = $true
            }
        }

        # WaitForExit() without a timeout ensures asynchronous output has fully
        # flushed before the Result properties are read.
        $process.WaitForExit()
        $stdout = try { $stdoutTask.Result } catch { '' }
        $stderr = try { $stderrTask.Result } catch { '' }
        $text = (($stdout, $stderr) -join [Environment]::NewLine).Trim()
        $exitCode = [int]$process.ExitCode

        if (-not $AllowFailure -and $exitCode -ne 0) {
            if ([string]::IsNullOrWhiteSpace($text)) {
                $text = "Firebase command failed with exit code $exitCode."
            }
            throw $text
        }

        return [pscustomobject]@{
            ExitCode = $exitCode
            Text = $text
            TimedOut = $false
        }
    }
    finally {
        $process.Dispose()
    }
}

function ConvertFrom-FirebaseJson {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }

    $firstBrace = $Text.IndexOf('{')
    $lastBrace = $Text.LastIndexOf('}')

    if ($firstBrace -lt 0 -or $lastBrace -le $firstBrace) { return $null }

    $json = $Text.Substring($firstBrace, ($lastBrace - $firstBrace + 1))

    try {
        return $json | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function Get-FirebaseLoginState {
    param([string]$FirebaseExe)

    Write-Info 'Checking the saved Firebase login (maximum 15 seconds)...'
    $result = Invoke-FirebaseCapture `
        -FirebaseExe $FirebaseExe `
        -Arguments @('login:list','--json','--non-interactive') `
        -TimeoutSeconds 15 `
        -AllowFailure

    if ($result.TimedOut) {
        return [pscustomobject]@{
            SignedIn = $false
            Reason = 'timeout'
            RawMessage = $result.Text
        }
    }

    if ($result.ExitCode -ne 0) {
        return [pscustomobject]@{
            SignedIn = $false
            Reason = 'not-signed-in'
            RawMessage = $result.Text
        }
    }

    $data = ConvertFrom-FirebaseJson -Text $result.Text
    $items = @()
    if ($null -ne $data) {
        if ($null -ne $data.result) { $items = @($data.result) }
        elseif ($null -ne $data.users) { $items = @($data.users) }
        elseif ($data -is [System.Array]) { $items = @($data) }
    }

    $signedIn = ($items.Count -gt 0)
    if (-not $signedIn -and $result.Text -match '(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}') {
        $signedIn = $true
    }

    $reason = if ($signedIn) { 'signed-in' } else { 'not-signed-in' }

    return [pscustomobject]@{
        SignedIn = $signedIn
        Reason = $reason
        RawMessage = $result.Text
    }
}

function Get-FirebaseProjects {
    param([string]$FirebaseExe)

    Write-Info 'Reading the Firebase projects available to this account (maximum 60 seconds)...'
    $result = Invoke-FirebaseCapture `
        -FirebaseExe $FirebaseExe `
        -Arguments @('projects:list','--json','--non-interactive') `
        -TimeoutSeconds 60 `
        -AllowFailure

    if ($result.TimedOut) {
        throw "The Firebase CLI did not respond within 60 seconds while reading your projects.`r`n`r`nThe command was stopped instead of being allowed to freeze. Check your internet connection, close any other Firebase command windows, and run this tool again."
    }

    if ($result.ExitCode -ne 0) {
        $details = $result.Text
        if ([string]::IsNullOrWhiteSpace($details)) {
            $details = "Firebase returned exit code $($result.ExitCode)."
        }
        throw "Firebase is signed in, but the project list could not be loaded.`r`n`r`n$details"
    }

    $data = ConvertFrom-FirebaseJson -Text $result.Text
    if ($null -eq $data) {
        throw 'Firebase responded, but its project list could not be read.'
    }

    $items = @()
    if ($null -ne $data.result) {
        $items = @($data.result)
    }
    elseif ($null -ne $data.projects) {
        $items = @($data.projects)
    }
    elseif ($data -is [System.Array]) {
        $items = @($data)
    }

    $projects = @()
    foreach ($item in $items) {
        $id = [string]$item.projectId
        if ([string]::IsNullOrWhiteSpace($id)) { $id = [string]$item.project_id }
        if ([string]::IsNullOrWhiteSpace($id)) { continue }

        $displayName = [string]$item.displayName
        if ([string]::IsNullOrWhiteSpace($displayName)) { $displayName = [string]$item.display_name }
        if ([string]::IsNullOrWhiteSpace($displayName)) { $displayName = $id }

        $projects += [pscustomobject]@{
            ProjectId = $id.Trim()
            DisplayName = $displayName.Trim()
            DisplayText = "$displayName  [$id]"
        }
    }

    return [pscustomobject]@{
        SignedIn = $true
        Projects = @($projects | Sort-Object DisplayName, ProjectId)
        RawMessage = $result.Text
    }
}

function Ensure-FirebaseLogin {
    param([string]$FirebaseExe)

    $loginState = Get-FirebaseLoginState -FirebaseExe $FirebaseExe
    if ($loginState.SignedIn) {
        Write-Ok 'Firebase login is already active.'
        return Get-FirebaseProjects -FirebaseExe $FirebaseExe
    }

    if ($loginState.Reason -eq 'timeout') {
        Write-Warn 'The automatic login check took too long, so it was stopped safely.'
    }
    else {
        Write-Info 'No active Firebase login was detected.'
    }

    Show-AppMessage `
        -Title 'Firebase login required' `
        -Message "The script will now open Google's sign-in page.`r`n`r`nChoose the Google account that owns your Firebase project and approve access. Return to this window after the browser says the login succeeded.`r`n`r`nYou do not need to type an API key." `
        -Type 'Info'

    Write-Info 'Opening Firebase sign-in in your browser. Finish the browser login to continue...'

    if ([string]::IsNullOrWhiteSpace($FirebaseExe) -or
        -not (Test-Path -LiteralPath $FirebaseExe -PathType Leaf)) {
        throw 'The Firebase login command could not be located.'
    }

    # Do not set CI for the interactive login command. Calling firebase.cmd
    # directly keeps the browser authorization flow attached to this console.
    $oldCi = $env:CI
    try {
        Remove-Item Env:\CI -ErrorAction SilentlyContinue
        & $FirebaseExe login
        $loginExitCode = $LASTEXITCODE

        if ($loginExitCode -ne 0) {
            Write-Warn 'Normal login did not finish. Trying a fresh reauthentication...'
            & $FirebaseExe login --reauth
            $loginExitCode = $LASTEXITCODE
        }
    }
    finally {
        if ($null -eq $oldCi) {
            Remove-Item Env:\CI -ErrorAction SilentlyContinue
        }
        else {
            $env:CI = $oldCi
        }
    }

    if ($loginExitCode -ne 0) {
        throw "Firebase sign-in was not completed. Exit code: $loginExitCode"
    }

    $loginState = Get-FirebaseLoginState -FirebaseExe $FirebaseExe
    if (-not $loginState.SignedIn) {
        throw "Firebase sign-in finished, but the saved login could not be verified.`r`n`r`nRun the command again and choose 'Allow' in the browser."
    }

    Write-Ok 'Firebase login completed.'
    return Get-FirebaseProjects -FirebaseExe $FirebaseExe
}

function Read-ProjectIdFromFirebaserc {
    param([string]$Root)

    $path = Join-Path $Root '.firebaserc'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }

    try {
        $object = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
        $id = [string]$object.projects.default
        if (-not [string]::IsNullOrWhiteSpace($id)) { return $id.Trim() }
    }
    catch { }

    return $null
}

function Read-ProjectIdFromWebsite {
    param([string]$Root)

    $htmlFiles = Get-ChildItem `
        -LiteralPath $Root `
        -Filter '*.html' `
        -File `
        -Recurse `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }

    $found = New-Object System.Collections.Generic.List[string]

    foreach ($file in $htmlFiles) {
        try {
            $text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
            $matches = [regex]::Matches(
                $text,
                '(?im)\bprojectId\s*:\s*["'']([^"'']+)["'']'
            )

            foreach ($match in $matches) {
                $id = $match.Groups[1].Value.Trim()
                if (-not [string]::IsNullOrWhiteSpace($id) -and
                    -not $found.Contains($id)) {
                    $found.Add($id)
                }
            }
        }
        catch { }
    }

    if ($found.Count -eq 1) { return $found[0] }
    return $null
}

function Select-FirebaseProject {
    param(
        [object[]]$Projects,
        [string]$SuggestedProjectId
    )

    if ($Projects.Count -eq 0) {
        throw 'No Firebase projects are available for this Google account.'
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Linear Algebra Quiz - Choose Firebase Project'
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size(760, 430)
    $form.MinimumSize = New-Object System.Drawing.Size(700, 390)
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
    $form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $form.MaximizeBox = $false

    $header = New-Object System.Windows.Forms.Panel
    $header.Dock = [System.Windows.Forms.DockStyle]::Top
    $header.Height = 125
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
    $brand.Location = New-Object System.Drawing.Point(28, 18)
    $brand.ForeColor = [System.Drawing.Color]::FromArgb(125, 211, 252)
    $brand.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
    $header.Controls.Add($brand)

    $heading = New-Object System.Windows.Forms.Label
    $heading.Text = 'Choose the Firebase project'
    $heading.AutoSize = $true
    $heading.Location = New-Object System.Drawing.Point(27, 48)
    $heading.ForeColor = [System.Drawing.Color]::White
    $heading.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 18)
    $header.Controls.Add($heading)

    $description = New-Object System.Windows.Forms.Label
    $description.Text = 'This choice is saved, so future Firestore rule updates can deploy automatically.'
    $description.AutoSize = $true
    $description.Location = New-Object System.Drawing.Point(29, 88)
    $description.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $description.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
    $header.Controls.Add($description)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = 'Firebase project connected to this website'
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(34, 158)
    $label.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
    $label.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
    $form.Controls.Add($label)

    $combo = New-Object System.Windows.Forms.ComboBox
    $combo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $combo.Location = New-Object System.Drawing.Point(35, 187)
    $combo.Size = New-Object System.Drawing.Size(670, 34)
    $combo.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor
                    [System.Windows.Forms.AnchorStyles]::Left -bor
                    [System.Windows.Forms.AnchorStyles]::Right
    $combo.DisplayMember = 'DisplayText'
    foreach ($project in $Projects) { [void]$combo.Items.Add($project) }
    $form.Controls.Add($combo)

    $selectedIndex = 0
    for ($i = 0; $i -lt $Projects.Count; $i++) {
        if ($Projects[$i].ProjectId -eq $SuggestedProjectId) {
            $selectedIndex = $i
            break
        }
    }
    $combo.SelectedIndex = $selectedIndex

    $hint = New-Object System.Windows.Forms.Label
    if (-not [string]::IsNullOrWhiteSpace($SuggestedProjectId)) {
        $hint.Text = "Website detection suggested: $SuggestedProjectId"
    }
    else {
        $hint.Text = "Choose the project that already contains this quiz's Firestore database."
    }
    $hint.AutoSize = $true
    $hint.Location = New-Object System.Drawing.Point(36, 232)
    $hint.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139)
    $hint.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    $form.Controls.Add($hint)

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = 'Cancel'
    $cancel.Size = New-Object System.Drawing.Size(145, 44)
    $cancel.Location = New-Object System.Drawing.Point(405, 295)
    $cancel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor
                     [System.Windows.Forms.AnchorStyles]::Right
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $cancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $cancel.BackColor = [System.Drawing.Color]::White
    $cancel.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
    $form.Controls.Add($cancel)

    $connect = New-Object System.Windows.Forms.Button
    $connect.Text = 'Connect this project'
    $connect.Size = New-Object System.Drawing.Size(165, 44)
    $connect.Location = New-Object System.Drawing.Point(565, 295)
    $connect.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor
                      [System.Windows.Forms.AnchorStyles]::Right
    $connect.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $connect.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $connect.BackColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
    $connect.ForeColor = [System.Drawing.Color]::White
    $connect.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
    $form.Controls.Add($connect)

    $form.AcceptButton = $connect
    $form.CancelButton = $cancel

    $result = $form.ShowDialog()
    $selected = $combo.SelectedItem
    $form.Dispose()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK -or $null -eq $selected) {
        return $null
    }

    return [string]$selected.ProjectId
}

function Backup-IfPresent {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }

    $backupFolder = Join-Path (Split-Path -Parent $Path) 'backups\firebase-connection'
    [void][System.IO.Directory]::CreateDirectory($backupFolder)

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $name = [System.IO.Path]::GetFileName($Path)
    Copy-Item `
        -LiteralPath $Path `
        -Destination (Join-Path $backupFolder "$stamp-$name") `
        -Force
}

function Save-FirebaseConnectionFiles {
    param(
        [string]$Root,
        [string]$ProjectId
    )

    $rcPath = Join-Path $Root '.firebaserc'
    $jsonPath = Join-Path $Root 'firebase.json'

    Backup-IfPresent -Path $rcPath
    Backup-IfPresent -Path $jsonPath

    $rcObject = $null
    if (Test-Path -LiteralPath $rcPath -PathType Leaf) {
        try {
            $rcObject = Get-Content -LiteralPath $rcPath -Raw -Encoding UTF8 | ConvertFrom-Json
        }
        catch {
            $rcObject = $null
        }
    }

    if ($null -eq $rcObject) { $rcObject = New-Object psobject }
    if ($null -eq $rcObject.projects) {
        $rcObject | Add-Member -MemberType NoteProperty -Name projects -Value (New-Object psobject)
    }

    if ($null -eq $rcObject.projects.PSObject.Properties['default']) {
        $rcObject.projects | Add-Member -MemberType NoteProperty -Name default -Value $ProjectId
    }
    else {
        $rcObject.projects.default = $ProjectId
    }

    Save-Utf8NoBom `
        -Path $rcPath `
        -Text (($rcObject | ConvertTo-Json -Depth 30) + [Environment]::NewLine)

    $firebaseObject = $null
    if (Test-Path -LiteralPath $jsonPath -PathType Leaf) {
        try {
            $firebaseObject = Get-Content -LiteralPath $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        }
        catch {
            $firebaseObject = $null
        }
    }

    if ($null -eq $firebaseObject) { $firebaseObject = New-Object psobject }
    if ($null -eq $firebaseObject.firestore) {
        $firebaseObject | Add-Member `
            -MemberType NoteProperty `
            -Name firestore `
            -Value (New-Object psobject)
    }

    if ($null -eq $firebaseObject.firestore.PSObject.Properties['rules']) {
        $firebaseObject.firestore | Add-Member `
            -MemberType NoteProperty `
            -Name rules `
            -Value 'firestore.rules'
    }
    else {
        $firebaseObject.firestore.rules = 'firestore.rules'
    }

    Save-Utf8NoBom `
        -Path $jsonPath `
        -Text (($firebaseObject | ConvertTo-Json -Depth 30) + [Environment]::NewLine)

    $stateFile = Join-Path (Get-StateFolder) 'last-firebase-project.txt'
    Save-Utf8NoBom -Path $stateFile -Text $Root

    Write-Ok 'Saved .firebaserc and firebase.json.'
}

function Resolve-FirebaseProjectId {
    param(
        [string]$Root,
        [object[]]$AvailableProjects
    )

    $savedId = Read-ProjectIdFromFirebaserc -Root $Root
    $websiteId = Read-ProjectIdFromWebsite -Root $Root
    $availableIds = @($AvailableProjects | ForEach-Object { $_.ProjectId })

    if (-not [string]::IsNullOrWhiteSpace($savedId) -and
        $availableIds -contains $savedId) {
        Write-Ok "Using saved Firebase project: $savedId"
        return $savedId
    }

    if (-not [string]::IsNullOrWhiteSpace($websiteId) -and
        $availableIds -contains $websiteId) {
        Write-Ok "Detected Firebase project from the website: $websiteId"
        return $websiteId
    }

    if ($AvailableProjects.Count -eq 1) {
        $onlyId = [string]$AvailableProjects[0].ProjectId
        Write-Ok "Only one Firebase project is available: $onlyId"
        return $onlyId
    }

    if (-not [string]::IsNullOrWhiteSpace($websiteId) -and
        $availableIds -notcontains $websiteId) {
        Write-Warn "The website refers to '$websiteId', but the signed-in Google account cannot access it."
    }

    return Select-FirebaseProject `
        -Projects $AvailableProjects `
        -SuggestedProjectId $websiteId
}

try {
    Clear-Host
    Write-Host 'LINEAR ALGEBRA QUIZ - LOGIN AND CONNECT FIREBASE' -ForegroundColor Magenta
    Write-Host 'SAFE LOGIN, AUTOMATIC PROJECT DETECTION, AND SAVED DEPLOY SETTINGS' -ForegroundColor DarkCyan

    Initialize-Ui

    Write-Step 'STEP 1 OF 4 - Finding the online quiz project'
    $root = Find-AutomaticProject
    if ([string]::IsNullOrWhiteSpace($root)) {
        Show-AppMessage `
            -Title 'Choose the online quiz folder' `
            -Message "The online quiz was not found automatically.`r`n`r`nChoose the folder containing index.html, firestore.rules, and the etapes folder." `
            -Type 'Warning'

        $root = Choose-ProjectFolder
    }

    if ([string]::IsNullOrWhiteSpace($root)) {
        throw 'No valid online quiz folder was selected.'
    }
    Write-Ok "Project: $root"

    Write-Step 'STEP 2 OF 4 - Installing or finding the Firebase CLI'
    $firebaseExe = Ensure-FirebaseCli

    Write-Step 'STEP 3 OF 4 - Checking the Firebase login'
    $firebaseStatus = Ensure-FirebaseLogin -FirebaseExe $firebaseExe

    if ($firebaseStatus.Projects.Count -eq 0) {
        Start-Process 'https://console.firebase.google.com/' -ErrorAction SilentlyContinue
        throw "This Google account has no Firebase projects.`r`n`r`nThe Firebase Console was opened. Create a project or sign in with the account that owns your existing quiz project, then run this command again."
    }

    Write-Ok ("Available Firebase projects: " + $firebaseStatus.Projects.Count)

    Write-Step 'STEP 4 OF 4 - Detecting and saving the Firebase project'
    $projectId = Resolve-FirebaseProjectId `
        -Root $root `
        -AvailableProjects $firebaseStatus.Projects

    if ([string]::IsNullOrWhiteSpace($projectId)) {
        throw 'No Firebase project was selected.'
    }

    Save-FirebaseConnectionFiles -Root $root -ProjectId $projectId

    # Confirm that the selected project remains visible to this account.
    if (@($firebaseStatus.Projects | Where-Object { $_.ProjectId -eq $projectId }).Count -eq 0) {
        throw "The signed-in account cannot access Firebase project '$projectId'."
    }

    Write-Host ''
    Write-Host 'CONNECTED' -ForegroundColor Green
    Write-Host "Quiz folder:      $root" -ForegroundColor Cyan
    Write-Host "Firebase project: $projectId" -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Future Firestore deployments can now use the saved project automatically.' -ForegroundColor Yellow
    Write-Host 'Your Google password and Firebase Web API key were not saved by this script.' -ForegroundColor Yellow

    if (-not $CalledByDeploy) {
        Show-AppMessage `
            -Title 'Firebase connection saved' `
            -Message "Firebase login is ready and this quiz is connected to:`r`n`r`n$projectId`r`n`r`nThe project choice was saved in .firebaserc. You can now run 'Deploy Firestore Rules'." `
            -Type 'Success'
    }

    exit 0
}
catch {
    Write-Host ''
    Write-Host 'FIREBASE CONNECTION STOPPED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($null -ne $_.InvocationInfo -and $_.InvocationInfo.ScriptLineNumber -gt 0) {
        Write-Host ("Script line: {0}" -f $_.InvocationInfo.ScriptLineNumber) -ForegroundColor DarkRed
    }

    try {
        Show-AppMessage `
            -Title 'Firebase connection stopped' `
            -Message $_.Exception.Message `
            -Type 'Error'
    }
    catch { }

    if (-not $CalledByDeploy) {
        [void](Read-Host 'Press Enter to close')
    }

    exit 1
}
