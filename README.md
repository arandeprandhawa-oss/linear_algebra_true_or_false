# french-quiz — Maintenance Guide

Live site: <https://arandeprandhawa-oss.github.io/french-quiz/>

Everything below is **copy-paste PowerShell**. No local server, no manual file hunting, and **nothing to fill in for your username** — every script finds your repo folder automatically and works on any computer.

After every change: push → wait ~1 min → **Ctrl + F5** to see it live.

---

---

## Using this as a template (forking)

This repo is fully shareable. Everything here pushes to **whatever repo you cloned from** — the scripts read your git remote automatically, they are not tied to the original author's account. To make it your own:

### Step 1 — Fork it (one click)

On the GitHub page of this repo, click **Fork** (top-right). That creates your own copy at `github.com/YOUR-USERNAME/french-quiz`. You now own it and can push to it freely.

### Step 2 — Clone YOUR fork

In **Script 1**, change the `$repoUrl` line to your fork's URL (green **Code** button → HTTPS → copy), then run it. Everything else in Script 1 is automatic.

### Step 3 — Enable GitHub Pages on your fork

Your fork → **Settings → Pages** → Source: **Deploy from a branch** → Branch: **main** → **/ (root)** → **Save**. After ~1 min your live site is at `https://YOUR-USERNAME.github.io/french-quiz/`.

### Step 4 — (Audio) get your own Google key

Audio needs your own free Google Cloud Text-to-Speech key — see **Script 5**. The original author's key is not in the repo (it's private), so this is a required one-time step if you want audio.

### Step 5 — (Multiplayer only) use your own Firebase

The 1v1 mode points at a Firebase project. If you only use **Solo mode**, skip this. For your own multiplayer, create a free Firebase project and swap the config — see **"Swap in your own Firebase"** below.

> **What's portable vs. account-specific**
>
> | Works for anyone immediately | Needs your own account |
> |---|---|
> | Clone, edit cards, add étapes, Solo mode | Pushing (fork first — Step 1) |
> | All Scripts 1–4 (auto-detect everything) | Audio generation (your Google key — Step 4) |
> | The site itself, hosted on your Pages | Multiplayer (your Firebase — Step 5) |

### Swap in your own Firebase (multiplayer only)

1. Create a project at <https://console.firebase.google.com/> → add a **Web app** → copy its `firebaseConfig` object.
2. Run this to replace the config across all lobby pages at once:

```powershell
# auto-find repo
$try=@("$env:USERPROFILE\Downloads\french-quiz-repo","$env:USERPROFILE\Downloads\french-quiz-main","$env:USERPROFILE\Desktop\french-quiz-repo","$env:USERPROFILE\Documents\french-quiz-repo","$env:USERPROFILE\french-quiz-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1
if(-not $repo){Write-Host "Repo not found. Run Script 1 first." -ForegroundColor Red;return}
Set-Location $repo

# ── PASTE YOUR firebaseConfig VALUES HERE ──────────────────────────────────
$apiKey         = "YOUR_API_KEY"
$authDomain     = "YOUR_PROJECT.firebaseapp.com"
$projectId      = "YOUR_PROJECT"
$storageBucket  = "YOUR_PROJECT.firebasestorage.app"
$messagingSenderId = "YOUR_SENDER_ID"
$appId          = "YOUR_APP_ID"
# ── DO NOT EDIT BELOW THIS LINE ────────────────────────────────────────────
$utf8=[System.Text.UTF8Encoding]::new($false)
foreach($f in (Get-ChildItem -Filter "*.html")){
  $c=Get-Content $f.FullName -Raw -Encoding UTF8
  if($c -notmatch 'firebaseConfig'){ continue }
  $c=$c -replace 'apiKey:\s*"[^"]*"',            "apiKey: `"$apiKey`""
  $c=$c -replace 'authDomain:\s*"[^"]*"',        "authDomain: `"$authDomain`""
  $c=$c -replace 'projectId:\s*"[^"]*"',         "projectId: `"$projectId`""
  $c=$c -replace 'storageBucket:\s*"[^"]*"',     "storageBucket: `"$storageBucket`""
  $c=$c -replace 'messagingSenderId:\s*"[^"]*"', "messagingSenderId: `"$messagingSenderId`""
  $c=$c -replace 'appId:\s*"[^"]*"',             "appId: `"$appId`""
  [System.IO.File]::WriteAllText($f.FullName,$c,$utf8)
  Write-Host "Updated Firebase config in $($f.Name)" -ForegroundColor Green
}
git add -A; git commit -m "use my own Firebase project"; git push
```

3. Update `firestore.rules` for your project and deploy (see **Script 6**). In `firebase deploy`, the CLI uses whichever project you `firebase use` — run `firebase use YOUR_PROJECT` first.

---

## How the auto-detect works

Every script below starts by locating your repo automatically. It looks for the `french-quiz` repo in the common places (Downloads, Desktop, Documents, your user folder) and `cd`s into it. You never type your username. If it can't find it, it tells you to run **Script 1** first.

---

## Script simulations (interactive preview)

Not sure what a script does before you run it? Open the interactive simulator — it walks through every script step-by-step in a fake terminal, including the Notepad save-check, with no risk to your files.

**Live version (easiest):**
<https://arandeprandhawa-oss.github.io/french-quiz/script-simulations.html>

**Or run it locally:**
```powershell
# from inside the repo folder
Start-Process "script-simulations.html"
```

It has a tab for each script (Setup, Verify, Add cards, New étape, Audio, Firestore). Pick a tab, press **Run**, then **Continue** to step through. For the Notepad-based scripts you can try both "Save" and "Close without saving" to see how the save-check reacts.

> GitHub READMEs can't run JavaScript (GitHub strips scripts for security), so the simulator only works via the live link above or by opening the file locally — not inline on the GitHub page.

---

## File map

```
index.html          <- Etape 2 (default landing) · 1v1 lobby
etape1.html         <- Etape 1 · 1v1 lobby
etape3.html         <- Etape 3 · 1v1 lobby
etape4.html         <- Etape 4 · 1v1 lobby
solo.html           <- Etape 2 · Solo (spaced repetition + audio)
solo1.html          <- Etape 1 · Solo
solo3.html          <- Etape 3 · Solo
solo4.html          <- Etape 4 · Solo
etapes/
  registry.js       <- single source of truth: which etapes exist
  etape1.js ... etape4.js   <- vocab + category labels per etape
audio/              <- pre-generated mp3 files (one per French card)
audio-manifest.json <- maps French text to audio filename
generate-audio.js   <- Node script to regenerate mp3s via Google TTS
```

---

# Script 1 — Download & set up everything

Run this **first**, on a fresh computer or after losing your local copy. It installs Git and Node.js if missing, clones the repo into your Downloads folder, and installs dependencies. No username needed — it uses `$env:USERPROFILE`.

```powershell
# ── CONFIG ─────────────────────────────────────────────────────────────────
# If you FORKED this repo, change this to YOUR fork's URL
# (on your fork's GitHub page: green "Code" button -> HTTPS -> copy).
$repoUrl = "https://github.com/arandeprandhawa-oss/french-quiz.git"
$destDir = "$env:USERPROFILE\Downloads\french-quiz-repo"
# ── DO NOT EDIT BELOW THIS LINE ────────────────────────────────────────────

Write-Host "=== french-quiz setup ===" -ForegroundColor Cyan

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then rerun." -ForegroundColor Red
    return
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    Write-Host "Git installed. CLOSE and REOPEN PowerShell, then rerun this script." -ForegroundColor Green
    return
} else { Write-Host "Git: OK" -ForegroundColor Green }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Node.js LTS..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
    Write-Host "Node installed. CLOSE and REOPEN PowerShell, then rerun this script." -ForegroundColor Green
    return
} else { Write-Host "Node: OK ($(node -v))" -ForegroundColor Green }

if (Test-Path $destDir) {
    Write-Host "Repo already exists at $destDir — pulling latest" -ForegroundColor Yellow
    Set-Location $destDir; git pull
} else {
    Write-Host "Cloning repo to $destDir ..." -ForegroundColor Yellow
    git clone $repoUrl $destDir; Set-Location $destDir
}
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install

Write-Host "`n=== Setup complete. You are in: $destDir ===" -ForegroundColor Cyan
Write-Host "Next: run Script 2 to verify." -ForegroundColor White
```

---

# Script 2 — Verify your setup

Auto-finds your repo, then checks Git, Node, dependencies, the Google API key, and all required files.

```powershell
# ── auto-find repo (no username needed) ────────────────────────────────────
$try = @(
  "$env:USERPROFILE\Downloads\french-quiz-repo",
  "$env:USERPROFILE\Downloads\french-quiz-main",
  "$env:USERPROFILE\Desktop\french-quiz-repo",
  "$env:USERPROFILE\Documents\french-quiz-repo",
  "$env:USERPROFILE\french-quiz-repo"
)
$repo = $try | Where-Object { Test-Path "$_\index.html" } | Select-Object -First 1
if (-not $repo) {
  $found = Get-ChildItem $env:USERPROFILE -Recurse -Filter "index.html" -ErrorAction SilentlyContinue |
           Where-Object { Test-Path (Join-Path $_.DirectoryName "etapes\registry.js") } |
           Select-Object -First 1
  if ($found) { $repo = $found.DirectoryName }
}
if (-not $repo) { Write-Host "Repo not found. Run Script 1 first." -ForegroundColor Red; return }
Set-Location $repo
Write-Host "Repo: $repo`n" -ForegroundColor Cyan
# ───────────────────────────────────────────────────────────────────────────

$ok = $true
function Check($label,$cond,$hint){
  if ($cond){ Write-Host "  [OK]   $label" -ForegroundColor Green }
  else      { Write-Host "  [MISS] $label  ->  $hint" -ForegroundColor Red; $script:ok=$false }
}
Check "Git installed"             (Get-Command git  -ErrorAction SilentlyContinue) "Run Script 1"
Check "Node installed"            (Get-Command node -ErrorAction SilentlyContinue) "Run Script 1"
Check "Inside a git repo"         (Test-Path ".git")               "Reclone with Script 1"
Check "index.html present"        (Test-Path "index.html")         "Repo incomplete"
Check "registry.js present"       (Test-Path "etapes\registry.js") "Repo incomplete"
Check "generate-audio.js present" (Test-Path "generate-audio.js")  "Repo incomplete"
Check "node_modules installed"    (Test-Path "node_modules")       "Run: npm install"
Check "audio folder present"      (Test-Path "audio")              "Run Script 5 to generate audio"
Check "Google API key set"        ($env:GOOGLE_APPLICATION_CREDENTIALS -and (Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS)) "See Script 5"

Write-Host ""
if ($ok){ Write-Host "All good — ready to work." -ForegroundColor Green }
else    { Write-Host "Fix the [MISS] lines above." -ForegroundColor Yellow }
```

---

# Script 3 — **ADD new flashcards to an EXISTING étape**

> **Use this when the étape already exists** (Étape 1–4) and you just want to **add more cards** to it. This does **NOT** create a new tab. To create a brand-new étape tab, use **Script 4** instead.

Paste the block. It opens Notepad with a template, waits while you paste your cards, confirms you saved, validates every card, then inserts and pushes. If a card is malformed it tells you exactly what's wrong and **changes nothing**.

```powershell
# ── CHANGE THIS ───────────────────────────────────────────────────────────
$etape = "etape2"   # which EXISTING etape to add to: etape1 / etape2 / etape3 / etape4
# ── DO NOT EDIT BELOW THIS LINE ────────────────────────────────────────────

# auto-find repo
$try=@("$env:USERPROFILE\Downloads\french-quiz-repo","$env:USERPROFILE\Downloads\french-quiz-main","$env:USERPROFILE\Desktop\french-quiz-repo","$env:USERPROFILE\Documents\french-quiz-repo","$env:USERPROFILE\french-quiz-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1
if(-not $repo){Write-Host "Repo not found. Run Script 1 first." -ForegroundColor Red;return}
Set-Location $repo

$file = "etapes\$etape.js"
if (-not (Test-Path $file)) { Write-Host "No such file: $file" -ForegroundColor Red; return }

# 1. Template in Notepad
$tmp = "$env:TEMP\new-cards.txt"
@'
ADD YOUR NEW FLASHCARDS BELOW. One card per line. Delete these instruction lines.
Template:
{en:"ENGLISH", fr:"FRENCH", alts:["FRENCH"], needsHyphen:false, needsAccent:false, gender:"m", guessGender:true, category:"classroom"},

Field guide:
  en          English prompt
  fr          French answer shown on reveal
  alts        accepted spellings, e.g. ["un livre","un livre."]
  needsHyphen true if answer has a required hyphen (quatre-vingts)
  needsAccent true if answer has accents
  gender      "m" / "f" / "both"
  guessGender true if learner must type the article (un/une)
  category    must match a key in categoryLabels at the bottom of the file
------------------------------------------------------------------------------
'@ | Set-Content $tmp -Encoding UTF8

$before = (Get-Item $tmp).LastWriteTime
Write-Host "Opening Notepad. Paste your cards, then SAVE (Ctrl+S) and CLOSE." -ForegroundColor Yellow
Start-Process notepad $tmp -Wait

# 2. Confirm it was saved (loop until saved or cancelled)
while ((Get-Item $tmp).LastWriteTime -eq $before) {
  $ans = Read-Host "It looks like you didn't SAVE the file. Save it now (Ctrl+S), then type Y to continue (or N to cancel)"
  if ($ans -match '^[Nn]') { Write-Host "Cancelled. Nothing changed." -ForegroundColor Yellow; return }
}

# 3. Keep only card lines
$lines = Get-Content $tmp -Encoding UTF8 | Where-Object { $_ -match '^\s*\{.*\}\s*,?\s*$' }
if (-not $lines) { Write-Host "No valid card lines found. Nothing changed." -ForegroundColor Red; return }

# 4. Validate
$required='en','fr','alts','needsHyphen','needsAccent','gender','guessGender','category'
$bad=@(); $i=0
foreach($ln in $lines){
  $i++
  foreach($k in $required){
    if($ln -notmatch "(^|[\{\s,])$k\s*:"){
      if(-not($k -eq 'guessGender' -and $ln -match 'gender\s*:\s*"both"')){ $bad+="Card $i missing '$k':  $ln" }
    }
  }
  if($ln -notmatch 'category\s*:\s*"[^"]+"'){ $bad+="Card $i invalid category:  $ln" }
}
if($bad){ Write-Host "VALIDATION FAILED - nothing changed:" -ForegroundColor Red; $bad|ForEach-Object{Write-Host "  $_" -ForegroundColor Red}; return }

# 5. Warn on unknown categories
$fileText = Get-Content $file -Raw -Encoding UTF8
foreach($ln in $lines){
  if($ln -match 'category\s*:\s*"([^"]+)"'){ $cat=$Matches[1]
    if($cat -ne 'all' -and $fileText -notmatch "(^|[\{\s])$cat\s*:\s*`""){
      Write-Host "WARNING: category '$cat' not in categoryLabels — add it (section 1b) or the chip won't show." -ForegroundColor Yellow
    }
  }
}

# 6. Insert + save UTF-8 no BOM
$block = ($lines | ForEach-Object { "    " + $_.Trim() }) -join "`n"
$anchor = "`n  ],`n  categoryLabels:"
if($fileText -notlike "*$anchor*"){ Write-Host "Insert point not found in $file" -ForegroundColor Red; return }
$fileText = $fileText.Replace($anchor, "`n$block$anchor")
[System.IO.File]::WriteAllText((Resolve-Path $file), $fileText, [System.Text.UTF8Encoding]::new($false))
Write-Host "Added $($lines.Count) card(s) to $file" -ForegroundColor Green

# 7. Push
git add -A; git commit -m "${etape}: add $($lines.Count) card(s)"; git push
Write-Host "Pushed. Run Script 5 to generate audio for the new cards." -ForegroundColor Cyan
```

### 1b. Adding a new category (if a card uses a new one)

```powershell
$etape="etape2"; $catKey="weather"; $catLabel="Weather"   # <- change these
$try=@("$env:USERPROFILE\Downloads\french-quiz-repo","$env:USERPROFILE\Downloads\french-quiz-main","$env:USERPROFILE\Desktop\french-quiz-repo","$env:USERPROFILE\Documents\french-quiz-repo","$env:USERPROFILE\french-quiz-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1; Set-Location $repo
$file="etapes\$etape.js"
$c=Get-Content $file -Raw -Encoding UTF8
$c=$c -replace 'all:"Random"', "all:`"Random`", $catKey`:`"$catLabel`""
[System.IO.File]::WriteAllText((Resolve-Path $file),$c,[System.Text.UTF8Encoding]::new($false))
git add -A; git commit -m "${etape}: add $catKey category"; git push
```

---

# Script 4 — **MAKE a brand-new étape (new tab)**

> **Use this to create a whole new étape** — a new tab like "Étape 5" with its own vocab, lobby page, and solo page. This is different from **Script 3**, which only adds cards to an étape that already exists.

What this script does automatically:
1. Opens Notepad pre-filled with a ready-to-edit étape file (vocab + categoryLabels). You paste your flashcards and save.
2. **Confirms you actually saved** — if not, it asks you to save before continuing.
3. Creates the new `etapeN.js` vocab file.
4. Creates the two new HTML pages (`etapeN.html` lobby + `soloN.html` solo) from copies of an existing étape, with the correct étape id wired in.
5. **Updates every existing page** — `index.html`, all `etape*.html`, and all `solo*.html` — so the new tab appears and links work everywhere.
6. Registers the étape in `registry.js`.
7. Generates audio and pushes.

```powershell
# ── CHANGE THESE ──────────────────────────────────────────────────────────
$N          = "5"                                          # new etape number
$label      = "Étape 5"                                    # tab label
$titleMulti = "French Flashcards · 1v1 MODL-1101 Étape 5"
$titleSolo  = "French Flashcards · Solo · MODL-1101 Étape 5"
$copyFrom   = "4"                                          # existing etape to copy HTML shells from
# ── DO NOT EDIT BELOW THIS LINE ────────────────────────────────────────────

# auto-find repo
$try=@("$env:USERPROFILE\Downloads\french-quiz-repo","$env:USERPROFILE\Downloads\french-quiz-main","$env:USERPROFILE\Desktop\french-quiz-repo","$env:USERPROFILE\Documents\french-quiz-repo","$env:USERPROFILE\french-quiz-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1
if(-not $repo){Write-Host "Repo not found. Run Script 1 first." -ForegroundColor Red;return}
Set-Location $repo

$id   = "e$N"
$utf8 = [System.Text.UTF8Encoding]::new($false)
$vocabFile = "etapes\etape$N.js"

if (Test-Path $vocabFile) { Write-Host "etapes\etape$N.js already exists. Aborting so it isn't overwritten." -ForegroundColor Red; return }

# 1. Pre-fill a vocab template in Notepad
@"
// =====================================================================
// MODL-1101 — $label
// =====================================================================
window.ETAPE_DATA = {
  vocab: [
    // ===== CATEGORY NAME =====
    // Replace these examples with your real cards (one per line):
    {en:"a book", fr:"un livre", alts:["un livre"], needsHyphen:false, needsAccent:false, gender:"m", guessGender:true, category:"sample"},

  ],
  categoryLabels: {
    all:"Random",
    sample:"Sample category"
  }
};
"@ | Set-Content $vocabFile -Encoding UTF8

$before = (Get-Item $vocabFile).LastWriteTime
Write-Host "Opening Notepad with your new Étape $N file." -ForegroundColor Yellow
Write-Host "ADD YOUR NEW FLASHCARDS, update categoryLabels, then SAVE (Ctrl+S) and CLOSE." -ForegroundColor Yellow
Start-Process notepad $vocabFile -Wait

# 2. Confirm it was saved
while ((Get-Item $vocabFile).LastWriteTime -eq $before) {
  $ans = Read-Host "It looks like you didn't SAVE. Save the Notepad now (Ctrl+S), then type Y to continue (or N to cancel)"
  if ($ans -match '^[Nn]') { Remove-Item $vocabFile -Force; Write-Host "Cancelled. New etape removed." -ForegroundColor Yellow; return }
}

# 3. Quick sanity check that the vocab file still has the required structure
$vt = Get-Content $vocabFile -Raw -Encoding UTF8
if ($vt -notmatch 'window\.ETAPE_DATA' -or $vt -notmatch 'vocab\s*:\s*\[' -or $vt -notmatch 'categoryLabels\s*:') {
  Write-Host "The file is missing window.ETAPE_DATA / vocab / categoryLabels. Fix it and rerun." -ForegroundColor Red; return
}
Write-Host "Vocab file looks valid." -ForegroundColor Green

# 4. Create the two HTML shells from an existing etape
Copy-Item "etape$copyFrom.html" "etape$N.html"
Copy-Item "solo$copyFrom.html"  "solo$N.html"
$c = Get-Content "etape$N.html" -Raw -Encoding UTF8
$c = $c -replace "window\.CURRENT_ETAPE_ID\s*=\s*'e\d+'", "window.CURRENT_ETAPE_ID = '$id'"
$c = $c -replace "etapes/etape$copyFrom\.js", "etapes/etape$N.js"
[System.IO.File]::WriteAllText((Resolve-Path "etape$N.html"), $c, $utf8)
$c = Get-Content "solo$N.html" -Raw -Encoding UTF8
$c = $c -replace "etapes/etape$copyFrom\.js", "etapes/etape$N.js"
[System.IO.File]::WriteAllText((Resolve-Path "solo$N.html"), $c, $utf8)
Write-Host "Created etape$N.html and solo$N.html" -ForegroundColor Green

# 5. Update ETAPE_PAGE_MAP + ETAPE_SOLO_MAP in EVERY page (old + new)
$allShells = (Get-ChildItem -Filter "etape*.html").Name + (Get-ChildItem -Filter "solo*.html").Name + "index.html"
$allShells = $allShells | Sort-Object -Unique
foreach ($f in $allShells) {
  $c = Get-Content $f -Raw -Encoding UTF8
  if ($c -notmatch "$id`: 'etape$N.html'") {
    $c = $c -replace "(e$copyFrom\s*:\s*'etape$copyFrom\.html'\s*\r?\n\};)", "e$copyFrom`: 'etape$copyFrom.html',`n  $id`: 'etape$N.html'`n};"
  }
  if ($c -notmatch "$id`: 'solo$N.html'") {
    $c = $c -replace "(e$copyFrom\s*:\s*'solo$copyFrom\.html'\s*\r?\n\};)", "e$copyFrom`: 'solo$copyFrom.html',`n  $id`: 'solo$N.html'`n};"
  }
  [System.IO.File]::WriteAllText((Resolve-Path $f), $c, $utf8)
  Write-Host "  updated maps in $f" -ForegroundColor DarkCyan
}

# 6. Register the etape
$sublabel = "${N}ᵉ"
$regEntry = @"

  {
    id: '$id',
    label: '$label',
    sublabel: '$sublabel',
    titleMulti: '$titleMulti',
    titleSolo: '$titleSolo',
    sub: 'Race a friend, or practice solo',
    file: 'etapes/etape$N.js'
  }
"@
$reg = Get-Content "etapes\registry.js" -Raw -Encoding UTF8
$reg = $reg.Replace("`n];", "$regEntry`n];")
[System.IO.File]::WriteAllText((Resolve-Path "etapes\registry.js"), $reg, $utf8)
Write-Host "Registered Étape $N" -ForegroundColor Green

# 7. Audio + push
if ($env:GOOGLE_APPLICATION_CREDENTIALS -and (Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS)) {
  if (-not (Test-Path "node_modules")) { npm install }
  node generate-audio.js
} else {
  Write-Host "Skipping audio (Google key not set). Run Script 5 later to add it." -ForegroundColor Yellow
}
git add -A; git commit -m "add Étape $N (new tab, pages, registry, audio)"; git push
Write-Host "`nDone. Étape $N is live in ~1 min. Hard-refresh with Ctrl+F5." -ForegroundColor Cyan
```

---

# Script 5 — Google API key & audio generation

Audio uses **Google Cloud Text-to-Speech**. One-time key setup, then a single command makes audio for any new cards.

## One-time: get your Google API key (.json) — full walkthrough

You only do this once. It gives you a key file that lets the audio script talk to Google's voice service. Follow every step.

### A. Create a Google Cloud project
1. Go to <https://console.cloud.google.com/> and sign in with any Google account.
2. If it's your first time, accept the terms.
3. At the very top, click the **project dropdown** (says "Select a project") → **New Project**.
4. Name it `french-quiz` → **Create**. Wait a few seconds, then make sure that project is selected in the dropdown.

### B. Enable the Text-to-Speech API
5. In the top search bar, type **Cloud Text-to-Speech API** and click the result.
6. Click **Enable**.
7. If it asks you to **enable billing**, you must add a payment method to continue. **You will almost certainly pay nothing** — Google gives 1 million free characters/month for the Neural2 voices, and this whole app is well under that. A card is required only for verification.

### C. Create a service account (the identity the script uses)
8. Left menu (☰) → **APIs & Services → Credentials**.
9. Click **+ Create Credentials → Service account**.
10. Service account name: `tts` → **Create and continue**.
11. Role: click the dropdown → choose **Basic → Owner** (or search "Cloud Text-to-Speech User"). → **Continue** → **Done**.

### D. Download the JSON key
12. Back on the Credentials page, under **Service Accounts**, click the `tts@...` account you just made.
13. Open the **Keys** tab → **Add key → Create new key**.
14. Choose **JSON** → **Create**. A `.json` file downloads automatically — **this is your key.**

### E. Store it safely
15. Move the downloaded file somewhere outside the repo, e.g. `C:\Users\You\google-tts-key.json`.
16. **Never commit this file to GitHub.** Anyone with it can use your Google quota. It's already covered by `.gitignore`, but to be safe, confirm it is NOT inside your repo folder:

```powershell
# auto-find repo, then check the key isn't inside it
$try=@("$env:USERPROFILE\Downloads\french-quiz-repo","$env:USERPROFILE\Downloads\french-quiz-main","$env:USERPROFILE\Desktop\french-quiz-repo","$env:USERPROFILE\Documents\french-quiz-repo","$env:USERPROFILE\french-quiz-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1
$keys = Get-ChildItem $repo -Recurse -Filter "*.json" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin @('package.json','package-lock.json','audio-manifest.json') }
if($keys){ Write-Host "WARNING: possible key file inside repo — move it out:" -ForegroundColor Red; $keys.FullName }
else { Write-Host "Good — no stray key files in the repo." -ForegroundColor Green }
```

## Point PowerShell at the key

```powershell
# this session only:
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\Users\You\google-tts-key.json"
# OR permanently (run once, reopen PowerShell):
[Environment]::SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS","C:\Users\You\google-tts-key.json","User")
```

## Generate / update audio

```powershell
$try=@("$env:USERPROFILE\Downloads\french-quiz-repo","$env:USERPROFILE\Downloads\french-quiz-main","$env:USERPROFILE\Desktop\french-quiz-repo","$env:USERPROFILE\Documents\french-quiz-repo","$env:USERPROFILE\french-quiz-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1; Set-Location $repo
if(-not $env:GOOGLE_APPLICATION_CREDENTIALS -or -not (Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS)){
  Write-Host "API key not set. See setup steps above." -ForegroundColor Red; return
}
if(-not (Test-Path "node_modules")){ npm install }
node generate-audio.js
git add audio\ audio-manifest.json; git commit -m "generate audio"; git push
Write-Host "Audio generated and pushed." -ForegroundColor Green
```

### Re-record one word

```powershell
Remove-Item "audio\un_livre.mp3" -ErrorAction SilentlyContinue   # slug of the word
node generate-audio.js
git add audio\ audio-manifest.json; git commit -m "re-record audio"; git push
```

> Slug rule: lowercase, accents stripped, spaces/punctuation → `_`. `Qu'est-ce que c'est ?` → `qu_est_ce_que_c_est.mp3`.

### Common Google audio errors

| Error you see | Cause & fix |
|---|---|
| `Could not load the default credentials` | The key path isn't set. Re-run the `$env:GOOGLE_APPLICATION_CREDENTIALS = "..."` line, and confirm the `.json` path is correct. |
| `PERMISSION_DENIED` / `Cloud Text-to-Speech API has not been used` | The API isn't enabled on this project. Redo step B (Enable the API), then wait a minute. |
| `Billing has not been enabled` | Add a payment method (step B7). You stay within the free tier; you won't be charged for this volume. |
| `7 PERMISSION_DENIED: The caller does not have permission` | The service account role is too low. Redo step C11 and give it **Owner** or **Cloud Text-to-Speech User**. |
| `Cannot find module '@google-cloud/text-to-speech'` | Dependencies missing. Run `npm install` in the repo folder. |

---

## Other quick tasks

### Change auto-advance timer (solo, all pages)

```powershell
$ms=3000
$utf8=[System.Text.UTF8Encoding]::new($false)
foreach($f in @("solo.html","solo1.html","solo3.html","solo4.html")){
  $c=Get-Content $f -Raw -Encoding UTF8
  $c=$c -replace 'const autoDelay\s*=\s*\d+', "const autoDelay = $ms"
  [System.IO.File]::WriteAllText((Resolve-Path $f),$c,$utf8)
}
git add -A; git commit -m "timer ${ms}ms"; git push
```

### Change default landing tab

```powershell
$defaultEtape="e2"
$c=Get-Content "etapes\registry.js" -Raw -Encoding UTF8
$c=$c -replace "window\.DEFAULT_ETAPE\s*=\s*'e\d+'", "window.DEFAULT_ETAPE = '$defaultEtape'"
[System.IO.File]::WriteAllText((Resolve-Path "etapes\registry.js"),$c,[System.Text.UTF8Encoding]::new($false))
git add -A; git commit -m "default $defaultEtape"; git push
```

---

## Firestore security rules (1v1 mode)

Update when you add etapes or change what the client writes. (If you forked, this targets **your** Firebase project — see "Swap in your own Firebase" above.)

**Console:** [Firebase Console](https://console.firebase.google.com/) → select your project → **Firestore Database → Rules** → edit → **Publish**.

**CLI:**
```powershell
npm install -g firebase-tools
firebase login
firebase use YOUR_PROJECT_ID      # whichever project this site uses
firebase deploy --only firestore:rules
```

---

## Troubleshooting

### Push rejected: "Updates were rejected... fetch first"

This means GitHub has commits your local copy doesn't. Since your local files are the ones you want to keep (you just edited them), force your version up:

```powershell
git push --force
```

> **Do not run `git pull` or `git pull --rebase` here** — that pulls the old remote files back on top of your new ones and undoes your changes. `git push --force` makes GitHub match your local copy, which is what you want after editing files locally.
>
> (Force-push is safe for this project because you're the only one editing it. If someone else were also pushing, you'd coordinate first.)

### Files reverted after a pull

If a `git pull` brought back old versions of your files, just re-copy the fixed files over them and force-push again:

```powershell
git add -A
git commit -m "re-apply local changes"
git push --force
```

### "nothing to commit" when you expected changes

The files weren't actually copied into the repo folder. Check the source path with `ls $fixed` — you should see the html files listed. Make sure `$fixed` points to the folder that *directly* contains them.

---

## Quick reference

| Task | Script / command |
|---|---|
| First-time setup | **Script 1** |
| Verify everything works | **Script 2** |
| **Add cards to an existing étape** | **Script 3** |
| **Make a brand-new étape** | **Script 4** |
| Set up Google key / generate audio | **Script 5** |
| Push manually | `git add -A && git commit -m "msg" && git push` |
| Push rejected ("fetch first") | `git push --force` (keeps your local files) |
| See recent commits | `git log --oneline -10` |
| Undo unsaved edit | `git checkout -- filename.html` |
