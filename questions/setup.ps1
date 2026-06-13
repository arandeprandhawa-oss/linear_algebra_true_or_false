# ===========================================================================
# setup.ps1 - Linear Algebra True/False Flashcard Website Setup
#
# What this script does:
#   1. Installs Git on your computer (if not already installed)
#   2. Downloads your copy of this website to your Downloads folder
#   3. Connects it to your Firebase project (for 1v1 multiplayer)
#   4. Publishes your website to GitHub Pages
#
# HOW TO RUN:
#   1. Open PowerShell (search "PowerShell" in the Start menu)
#   2. Paste this line and press Enter:
#        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   3. Then paste this line and press Enter:
#        cd Downloads; .\setup.ps1
# ===========================================================================

# ---------------------------------------------------------------------------
# WELCOME
# ---------------------------------------------------------------------------
Clear-Host
Write-Host ""
Write-Host "  =================================================" -ForegroundColor Cyan
Write-Host "   Linear Algebra True/False - Website Setup"       -ForegroundColor Cyan
Write-Host "  =================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  This script will set up your own copy of the"
Write-Host "  flashcard website in about 5 minutes."
Write-Host ""
Write-Host "  You will need:"
Write-Host "    - A GitHub account  (github.com/signup)"
Write-Host "    - A Firebase account (firebase.google.com) -- for 1v1 mode"
Write-Host ""
$continue = Read-Host "  Press Enter to continue (or type Q to quit)"
if($continue -match '^[Qq]'){ Write-Host "Bye!" -ForegroundColor Yellow; return }

# ---------------------------------------------------------------------------
# STEP 1: Check / install Git
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "  [1/5] Checking for Git..." -ForegroundColor Cyan

if(-not(Get-Command git -ErrorAction SilentlyContinue)){
    Write-Host "  Git is not installed. Installing now..." -ForegroundColor Yellow
    if(-not(Get-Command winget -ErrorAction SilentlyContinue)){
        Write-Host ""
        Write-Host "  ERROR: winget not found." -ForegroundColor Red
        Write-Host "  Please install 'App Installer' from the Microsoft Store" -ForegroundColor Red
        Write-Host "  then run this script again." -ForegroundColor Red
        return
    }
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    Write-Host ""
    Write-Host "  Git installed! IMPORTANT: You must close this PowerShell" -ForegroundColor Green
    Write-Host "  window and open a NEW one, then run setup.ps1 again." -ForegroundColor Yellow
    return
}
Write-Host "  Git is installed. OK." -ForegroundColor Green

# ---------------------------------------------------------------------------
# STEP 2: Get their GitHub repo URL
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "  [2/5] Your GitHub Repository" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Before continuing, you need to fork this repo on GitHub."
Write-Host "  A fork is your own personal copy of this website."
Write-Host ""
Write-Host "  To fork:"
Write-Host "    1. Go to: https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false"
Write-Host "    2. Click the Fork button (top-right)"
Write-Host "    3. Click Create Fork"
Write-Host ""
Write-Host "  Opening that page now..."
Start-Process "https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false"
Write-Host ""
Write-Host "  After forking, come back here."
Write-Host "  Your fork URL will look like:"
Write-Host "    https://github.com/YOUR-USERNAME/linear_algebra_true_or_false.git"
Write-Host ""
$repoUrl = Read-Host "  Paste your fork URL here (the .git link from the green Code button)"
$repoUrl = $repoUrl.Trim()
if(-not $repoUrl){
    Write-Host "  No URL entered. Run the script again when ready." -ForegroundColor Yellow
    return
}

# Extract username from URL for the live site URL later
$username = ""
if($repoUrl -match "github\.com/([^/]+)/"){
    $username = $Matches[1]
}

# ---------------------------------------------------------------------------
# STEP 3: Clone repo to Downloads
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "  [3/5] Downloading your website files..." -ForegroundColor Cyan

$destDir = "$env:USERPROFILE\Downloads\linear_algebra_true_or_false"
if(Test-Path $destDir){
    Write-Host "  Folder already exists. Updating..." -ForegroundColor Yellow
    Set-Location $destDir
    git pull
} else {
    git clone $repoUrl $destDir
    Set-Location $destDir
}
Write-Host "  Downloaded to: $destDir" -ForegroundColor Green

# ---------------------------------------------------------------------------
# STEP 4: Firebase config (for 1v1 multiplayer)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "  [4/5] Firebase Setup (for 1v1 multiplayer)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Firebase lets two people play against each other in real time."
Write-Host "  If you only want Solo mode, you can skip this step."
Write-Host ""
Write-Host "  To get your Firebase config:"
Write-Host "    1. Go to: https://console.firebase.google.com"
Write-Host "    2. Create a project (any name)"
Write-Host "    3. Add a Web App (the </> icon)"
Write-Host "    4. Copy the firebaseConfig values"
Write-Host "    5. Also enable Firestore Database (test mode)"
Write-Host ""
$doFirebase = Read-Host "  Do you have your Firebase config ready? (Y to enter it / N to skip)"

if($doFirebase -match '^[Yy]'){
    Write-Host ""
    Write-Host "  Paste each value and press Enter. Leave blank to skip that field."
    Write-Host ""
    $apiKey           = (Read-Host "  apiKey").Trim()
    $authDomain       = (Read-Host "  authDomain").Trim()
    $projectId        = (Read-Host "  projectId").Trim()
    $storageBucket    = (Read-Host "  storageBucket").Trim()
    $messagingSenderId= (Read-Host "  messagingSenderId").Trim()
    $appId            = (Read-Host "  appId").Trim()

    if($apiKey){
        $utf8 = [System.Text.UTF8Encoding]::new($false)
        Get-ChildItem "$destDir\*.html" | ForEach-Object {
            $c = Get-Content $_.FullName -Raw -Encoding UTF8
            if($c -notmatch 'firebaseConfig'){ return }
            if($apiKey)            { $c = $c -replace 'apiKey:\s*"[^"]*"',            "apiKey: `"$apiKey`"" }
            if($authDomain)        { $c = $c -replace 'authDomain:\s*"[^"]*"',        "authDomain: `"$authDomain`"" }
            if($projectId)         { $c = $c -replace 'projectId:\s*"[^"]*"',         "projectId: `"$projectId`"" }
            if($storageBucket)     { $c = $c -replace 'storageBucket:\s*"[^"]*"',     "storageBucket: `"$storageBucket`"" }
            if($messagingSenderId) { $c = $c -replace 'messagingSenderId:\s*"[^"]*"', "messagingSenderId: `"$messagingSenderId`"" }
            if($appId)             { $c = $c -replace 'appId:\s*"[^"]*"',             "appId: `"$appId`"" }
            [System.IO.File]::WriteAllText($_.FullName, $c, $utf8)
            Write-Host "    Updated Firebase in $($_.Name)" -ForegroundColor DarkCyan
        }
        Write-Host "  Firebase config saved." -ForegroundColor Green
    }
} else {
    Write-Host "  Skipped. You can run the Firebase section of this script later." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# STEP 5: Push to GitHub + open Pages settings
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "  [5/5] Publishing your website..." -ForegroundColor Cyan

Set-Location $destDir
git add -A
git commit -m "initial setup: my own flashcard website"
git push

Write-Host ""
Write-Host "  =================================================" -ForegroundColor Green
Write-Host "   Setup complete!" -ForegroundColor Green
Write-Host "  =================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  FINAL STEP: Enable GitHub Pages (30 seconds)"
Write-Host ""
Write-Host "  Opening your repo settings now..."
if($username){
    $pagesUrl = "https://github.com/$username/linear_algebra_true_or_false/settings/pages"
    Start-Process $pagesUrl
    Write-Host ""
    Write-Host "  In the browser:"
    Write-Host "    1. Under 'Source' select: Deploy from a branch"
    Write-Host "    2. Branch: main   Folder: / (root)"
    Write-Host "    3. Click Save"
    Write-Host ""
    Write-Host "  Your live site will be ready in ~1 minute at:"
    Write-Host "  https://$username.github.io/linear_algebra_true_or_false/" -ForegroundColor Cyan
} else {
    Write-Host "  Go to your repo Settings > Pages > Deploy from branch > main > Save"
}
Write-Host ""
Write-Host "  READ the README.md file in your Downloads folder"
Write-Host "  for how to add your own cards." -ForegroundColor Yellow
Write-Host ""
