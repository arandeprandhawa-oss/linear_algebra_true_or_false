# linear-algebra-true-false — Maintenance Guide

Live site: <https://arandeprandhawa-oss.github.io/linear_algebra_true_or_false/>

Everything below is **copy-paste PowerShell**. No Node.js, no npm, no Google keys — this site is plain HTML/JS with zero build step.

After every change: push → wait ~1 min → **Ctrl + F5** to see it live.

---

## File map

```
index.html              ← the entire quiz (one file — no per-unit HTML needed)
etapes/
  registry.js           ← single source of truth: which units exist + their metadata
  etape1.js             ← Unit 1 card bank (vocab + categoryLabels)
  etape2.js, …          ← additional units (add with Script 3)
README.md               ← this file
```

Units are selected via URL parameter: `index.html?unit=e2`  
The tab bar is auto-generated from `registry.js`.

---

## Card format

Each card is one object in the `vocab` array of a `etapeN.js` file:

```js
{
  en:          "Every square matrix is invertible.",   // ← the statement shown
  fr:          "False",                                // ← must be "True" or "False"
  alts:        ["False", "false"],                     // ← accepted values (always both cases)
  explanation: "A matrix is invertible only when its determinant is nonzero.",
  category:    "matrices"                              // ← must match a key in categoryLabels
},
```

**Rules:**
- `en` — the statement shown to the student
- `fr` — must be exactly `"True"` or `"False"` (capital first letter)
- `alts` — always `["True","true"]` or `["False","false"]`
- `explanation` — shown after answering; explain WHY briefly
- `category` — must match a key in `categoryLabels` at the bottom of the same file

---

## Script 1 — Download & set up

Run this **once** on a new computer. Installs Git if missing, clones the repo.
No npm or Node needed.

```powershell
# ── CONFIG ──────────────────────────────────────────────────────────────────
$repoUrl = "https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false.git"
$destDir = "$env:USERPROFILE\Downloads\la-true-false-repo"
# ── DO NOT EDIT BELOW ────────────────────────────────────────────────────────
Write-Host "=== Linear Algebra True/False setup ===" -ForegroundColor Cyan
if(-not(Get-Command winget -ErrorAction SilentlyContinue)){
  Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then rerun." -ForegroundColor Red; return}
if(-not(Get-Command git -ErrorAction SilentlyContinue)){
  Write-Host "Installing Git..." -ForegroundColor Yellow
  winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
  Write-Host "Done. CLOSE and REOPEN PowerShell, then rerun." -ForegroundColor Green; return
} else { Write-Host "Git: OK" -ForegroundColor Green }
if(Test-Path $destDir){
  Write-Host "Repo already exists — pulling latest." -ForegroundColor Yellow
  Set-Location $destDir; git pull
} else {
  Write-Host "Cloning to $destDir ..." -ForegroundColor Yellow
  git clone $repoUrl $destDir; Set-Location $destDir
}
Write-Host "`n=== Done. You are in: $(Get-Location) ===" -ForegroundColor Cyan
Write-Host "Next: run Script 2 to verify." -ForegroundColor White
```

---

## Script 2 — Verify your setup

Auto-finds your repo and checks that everything required is present.

```powershell
# auto-find repo
$try=@("$env:USERPROFILE\Downloads\la-true-false-repo","$env:USERPROFILE\Desktop\la-true-false-repo","$env:USERPROFILE\Documents\la-true-false-repo","$env:USERPROFILE\la-true-false-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1
if(-not $repo){
  $found=Get-ChildItem $env:USERPROFILE -Recurse -Filter "index.html" -ErrorAction SilentlyContinue|
         Where-Object{Test-Path (Join-Path $_.DirectoryName "etapes\registry.js")}|Select-Object -First 1
  if($found){$repo=$found.DirectoryName}
}
if(-not $repo){Write-Host "Repo not found. Run Script 1 first." -ForegroundColor Red;return}
Set-Location $repo; Write-Host "Repo: $repo`n" -ForegroundColor Cyan

$ok=$true
function Chk($lbl,$cond,$hint){
  if($cond){Write-Host "  [OK]   $lbl" -ForegroundColor Green}
  else{Write-Host "  [MISS] $lbl  ->  $hint" -ForegroundColor Red;$script:ok=$false}
}
Chk "Git installed"       (Get-Command git -ErrorAction SilentlyContinue) "Run Script 1"
Chk "Inside a git repo"   (Test-Path ".git")            "Reclone with Script 1"
Chk "index.html present"  (Test-Path "index.html")      "Repo incomplete — re-clone"
Chk "registry.js present" (Test-Path "etapes\registry.js") "Repo incomplete — re-clone"
Chk "etape1.js present"   (Test-Path "etapes\etape1.js") "Repo incomplete — re-clone"
Write-Host ""
if($ok){Write-Host "All good — ready to work." -ForegroundColor Green}
else{Write-Host "Fix the [MISS] items above." -ForegroundColor Yellow}
```

---

## Script 3 — ADD cards to an existing unit

> Use this when the unit already exists and you want to **add more cards** to it.  
> To create a brand-new tab/unit, use **Script 4** instead.

Opens Notepad with a card template. Paste your cards, save, and the script validates every card before inserting them — if anything is wrong it tells you exactly what and changes nothing.

```powershell
# ── CHANGE THIS ──────────────────────────────────────────────────────────────
$unit = "etape1"   # which existing unit: etape1 / etape2 / etc.
# ── DO NOT EDIT BELOW ────────────────────────────────────────────────────────

# auto-find repo
$try=@("$env:USERPROFILE\Downloads\la-true-false-repo","$env:USERPROFILE\Desktop\la-true-false-repo","$env:USERPROFILE\Documents\la-true-false-repo","$env:USERPROFILE\la-true-false-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1
if(-not $repo){Write-Host "Repo not found. Run Script 1 first." -ForegroundColor Red;return}
Set-Location $repo
$file="etapes\$unit.js"
if(-not(Test-Path $file)){Write-Host "No such file: $file" -ForegroundColor Red;return}

# Open Notepad with template
$tmp="$env:TEMP\la-new-cards.txt"
@'
ADD YOUR NEW CARDS BELOW. One card per line. Delete these instruction lines.

Template (copy and edit this):
{en:"Statement goes here.", fr:"True", alts:["True","true"], explanation:"Because...", category:"determinants"},
{en:"Another statement.", fr:"False", alts:["False","false"], explanation:"Because...", category:"matrices"},

Field guide:
  en          — the statement shown on the card
  fr          — must be exactly "True" or "False"
  alts        — always ["True","true"] or ["False","false"]
  explanation — shown after answering; keep it brief
  category    — must match a key in categoryLabels at the bottom of the etapeN.js file

Available categories in etape1.js:
  systems | span | independence | matrices | inverses | lu
  determinants | transformations | subspaces | eigenvalues | markov
---------------------------------------------------------------------------
'@ | Set-Content $tmp -Encoding UTF8

$before=(Get-Item $tmp).LastWriteTime
Write-Host "Opening Notepad. Paste your cards, then SAVE (Ctrl+S) and CLOSE." -ForegroundColor Yellow
Start-Process notepad $tmp -Wait

# Confirm save
while((Get-Item $tmp).LastWriteTime -eq $before){
  $ans=Read-Host "Looks like you didn't SAVE. Save now (Ctrl+S), then type Y to continue (or N to cancel)"
  if($ans -match '^[Nn]'){Write-Host "Cancelled. Nothing changed." -ForegroundColor Yellow;return}
}

# Extract card lines
$lines=Get-Content $tmp -Encoding UTF8|Where-Object{$_ -match '^\s*\{.*\}\s*,?\s*$'}
if(-not $lines){Write-Host "No valid card lines found. Nothing changed." -ForegroundColor Red;return}

# Validate
$bad=@();$i=0
foreach($ln in $lines){
  $i++
  foreach($k in 'en','fr','alts','explanation','category'){
    if($ln -notmatch "(^|[\{\s,])$k\s*:"){$bad+="Card $i missing '$k': $ln"}
  }
  if($ln -notmatch 'fr\s*:\s*"(True|False)"'){$bad+="Card $i — fr must be `"True`" or `"False`": $ln"}
  if($ln -notmatch 'category\s*:\s*"[^"]+"'){$bad+="Card $i — invalid category: $ln"}
}
if($bad){Write-Host "VALIDATION FAILED — nothing changed:" -ForegroundColor Red;$bad|ForEach-Object{Write-Host "  $_" -ForegroundColor Red};return}

# Warn on unknown categories
$fileText=Get-Content $file -Raw -Encoding UTF8
foreach($ln in $lines){
  if($ln -match 'category\s*:\s*"([^"]+)"'){$cat=$Matches[1]
    if($cat -ne 'all' -and $fileText -notmatch "$cat\s*:"){
      Write-Host "WARNING: category '$cat' not found in categoryLabels of $file — add it or the filter chip won't show." -ForegroundColor Yellow
    }
  }
}

# Insert before categoryLabels
$utf8=[System.Text.UTF8Encoding]::new($false)
$block=($lines|ForEach-Object{"    "+$_.Trim()}) -join "`n"
$anchor="`n  ],`n  categoryLabels:"
if($fileText -notmatch [regex]::Escape($anchor.Trim())){Write-Host "Insert point not found in $file. Is the file intact?" -ForegroundColor Red;return}
$fileText=$fileText.Replace($anchor,"`n$block$anchor")
[System.IO.File]::WriteAllText((Resolve-Path $file),$fileText,$utf8)
Write-Host "Added $($lines.Count) card(s) to $file" -ForegroundColor Green

git add -A; git commit -m "${unit}: add $($lines.Count) card(s)"; git push --force
Write-Host "Pushed. Live in ~1 min — hard refresh with Ctrl+F5." -ForegroundColor Cyan
```

### 3b. Adding a new category (chip)

If a card uses a category key that doesn't yet exist in `categoryLabels`, run this:

```powershell
$unit="etape1"; $catKey="vectors"; $catLabel="Vectors"   # <- change these
$try=@("$env:USERPROFILE\Downloads\la-true-false-repo","$env:USERPROFILE\Desktop\la-true-false-repo","$env:USERPROFILE\Documents\la-true-false-repo","$env:USERPROFILE\la-true-false-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1; Set-Location $repo
$file="etapes\$unit.js"
$utf8=[System.Text.UTF8Encoding]::new($false)
$c=Get-Content $file -Raw -Encoding UTF8
$c=$c -replace 'all:\s*"All Topics"', "all: `"All Topics`", $catKey`: `"$catLabel`""
[System.IO.File]::WriteAllText((Resolve-Path $file),$c,$utf8)
git add -A; git commit -m "${unit}: add category $catKey"; git push --force
Write-Host "Added category '$catKey' ($catLabel). Push done." -ForegroundColor Green
```

---

## Script 4 — CREATE a brand-new unit (new tab)

> Use this to add a whole new topic unit — a new tab in the nav bar with its own card set.

What this script does:
1. Opens Notepad pre-filled with a unit template. You edit the cards and save.
2. Validates the file structure.
3. Registers the new unit in `registry.js`.
4. Pushes to GitHub.

```powershell
# ── CHANGE THESE ─────────────────────────────────────────────────────────────
$N     = "2"                                           # new unit number (2, 3, 4, …)
$label = "Midterm 2"                                   # tab label shown to user
$title = "MATH 2210 · Midterm 2 — True or False"      # full title shown in lobby
$sub   = "Eigenvalues, diagonalization, and more."     # subtitle/description
# ── DO NOT EDIT BELOW ─────────────────────────────────────────────────────────

# auto-find repo
$try=@("$env:USERPROFILE\Downloads\la-true-false-repo","$env:USERPROFILE\Desktop\la-true-false-repo","$env:USERPROFILE\Documents\la-true-false-repo","$env:USERPROFILE\la-true-false-repo")
$repo=$try|Where-Object{Test-Path "$_\index.html"}|Select-Object -First 1
if(-not $repo){Write-Host "Repo not found. Run Script 1 first." -ForegroundColor Red;return}
Set-Location $repo

$id="e$N"
$vocabFile="etapes\etape$N.js"
if(Test-Path $vocabFile){Write-Host "etapes\etape$N.js already exists. Aborting." -ForegroundColor Red;return}
$utf8=[System.Text.UTF8Encoding]::new($false)

# 1. Pre-fill template
@"
// =====================================================================
// MATH 2210 — $label
// =====================================================================
window.ETAPE_DATA = {
  vocab: [

    // ===== CATEGORY NAME =====
    {en:"Statement goes here.", fr:"True", alts:["True","true"], explanation:"Because...", category:"sample"},
    {en:"Another statement.", fr:"False", alts:["False","false"], explanation:"Because...", category:"sample"},

  ],
  categoryLabels: {
    all:    "All Topics",
    sample: "Sample — rename this"
  }
};
"@ | Set-Content $vocabFile -Encoding UTF8

$before=(Get-Item $vocabFile).LastWriteTime
Write-Host "Opening Notepad with your new unit file. Edit the cards, SAVE (Ctrl+S), and CLOSE." -ForegroundColor Yellow
Start-Process notepad $vocabFile -Wait

# Confirm save
while((Get-Item $vocabFile).LastWriteTime -eq $before){
  $ans=Read-Host "Didn't detect a save. Save now (Ctrl+S), then type Y to continue (or N to cancel)"
  if($ans -match '^[Nn]'){Remove-Item $vocabFile -Force;Write-Host "Cancelled." -ForegroundColor Yellow;return}
}

# Validate structure
$vt=Get-Content $vocabFile -Raw -Encoding UTF8
if($vt -notmatch 'window\.ETAPE_DATA' -or $vt -notmatch 'vocab\s*:\s*\[' -or $vt -notmatch 'categoryLabels\s*:'){
  Write-Host "File is missing required structure (window.ETAPE_DATA / vocab / categoryLabels). Fix it and rerun." -ForegroundColor Red;return
}
Write-Host "File structure looks valid." -ForegroundColor Green

# 2. Register in registry.js
$regEntry = @"

  {
    id: '$id',
    label: '$label',
    sublabel: 'Unit $N',
    titleMulti: '$title',
    titleSolo:  '$title',
    sub: '$sub',
    file: 'etapes/etape$N.js'
  }
"@
$reg=Get-Content "etapes\registry.js" -Raw -Encoding UTF8
$reg=$reg.Replace("`n];","$regEntry`n];")
[System.IO.File]::WriteAllText((Resolve-Path "etapes\registry.js"),$reg,$utf8)
Write-Host "Registered unit $label in registry.js" -ForegroundColor Green

# 3. Push
git add -A; git commit -m "add unit $label (etape$N)"; git push --force
Write-Host "`nDone. New tab '$label' is live in ~1 min. Hard-refresh with Ctrl+F5." -ForegroundColor Cyan
Write-Host "URL for this unit: index.html?unit=$id" -ForegroundColor White
```

---

## Troubleshooting

### Push rejected — "fetch first"

You have local changes that conflict. Since your local files are what you want to keep:

```powershell
git push --force
```

> Never `git pull` if your local files are newer — that overwrites your work with the old remote version.

### Files reverted after a pull

Re-copy the correct files, then:

```powershell
git add -A; git commit -m "re-apply local changes"; git push --force
```

### "nothing to commit" but you expected changes

The files weren't actually inside the repo folder. Confirm you're in the right directory (`pwd`) and that the `.js` or `.html` files are listed by `ls etapes`.

### Card shows wrong answer

The `fr` field must be exactly `"True"` or `"False"` (capital first letter, rest lowercase). The `alts` array should always be `["True","true"]` or `["False","false"]`.

---

## Quick reference

| Task | Script |
|---|---|
| First-time setup | **Script 1** |
| Verify everything works | **Script 2** |
| Add cards to an existing unit | **Script 3** |
| Create a brand-new unit/tab | **Script 4** |
| Push a manual change | `git add -A; git commit -m "msg"; git push --force` |
| Undo an unsaved file edit | `git checkout -- etapes\etape1.js` |
| See recent commits | `git log --oneline -10` |

---

## GitHub Pages setup (one-time, if not already done)

1. Go to your repo on GitHub → **Settings → Pages**
2. Source: **Deploy from a branch** → Branch: **main** → **/ (root)** → **Save**
3. Wait ~1 min. Your site will be at `https://arandeprandhawa-oss.github.io/linear_algebra_true_or_false/`
