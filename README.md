# french-quiz — Maintenance Guide

Live site: <https://arandeprandhawa-oss.github.io/french-quiz/>

Everything below is **copy-paste PowerShell**. No local server, no manual file hunting.
After every change: push → wait ~1 min → **Ctrl + F5** to see it live.

---

## Setup — run once

```powershell
cd C:\Users\User\Downloads\french-quiz-repo
```

> This is your repo folder. Run every command in this guide from here.

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
  etape1.js         <- Etape 1 vocab + category labels
  etape2.js         <- Etape 2 vocab + category labels
  etape3.js         <- Etape 3 vocab + category labels
  etape4.js         <- Etape 4 vocab + category labels
audio/              <- pre-generated mp3 files (one per French card)
audio-manifest.json <- maps French text to audio filename
generate-audio.js   <- Node script to regenerate mp3s via Google TTS
```

---

## 1. Adding new cards — full workflow

---

### Step 1 — open the vocab file in Notepad

```powershell
notepad etapes\etape2.js
```

Change `etape2` to `etape1`, `etape3`, or `etape4` depending on which midterm the card belongs to.

---

### Step 2 — find the right spot in the file

The file is organised into category blocks that look like this:

```
// ===== CLASSROOM OBJECTS — Étape 2 additions (Page 22, 32) =====
{en:"a notebook",  fr:"un cahier",  alts:["un cahier"],  needsHyphen:false, needsAccent:false, gender:"m", guessGender:true, category:"classroom"},
{en:"a pencil",    fr:"un crayon",  alts:["un crayon"],  needsHyphen:false, needsAccent:false, gender:"m", guessGender:true, category:"classroom"},
...

// ===== USEFUL EXPRESSIONS =====
{en:"There is/are a...", fr:"Il y a un...", ...},
...
```

**Scroll to the category your card belongs to** and paste your new card on a new line
directly below the last card in that block, before the next `// =====` comment.

The end of the entire vocab list looks like this — do **not** paste below this point:

```
    {en:"last existing card",  fr:"...",  ...},   ← paste above here, inside the list
  ],                                               ← this closes the vocab array — stop here
  categoryLabels: {
```

---

### Step 3 — format the card correctly

Every card is one line. Copy this template and fill in your values:

```js
{en:"ENGLISH PROMPT", fr:"FRENCH ANSWER", alts:["FRENCH ANSWER"], needsHyphen:false, needsAccent:false, gender:"m", guessGender:true, category:"classroom"},
```

**Field-by-field guide:**

| Field | What to put | Example |
|---|---|---|
| `en` | English prompt exactly as you want it shown | `"to study"` |
| `fr` | The canonical French answer shown on reveal | `"étudier"` |
| `alts` | All accepted spellings the checker should accept | `["étudier"]` |
| `needsHyphen` | `true` only if the answer contains a required hyphen | `true` → `quatre-vingts` |
| `needsAccent` | `true` only if the answer contains é ç ê î ô û etc. | `true` → `étudier` |
| `gender` | `"m"` masculine · `"f"` feminine · `"both"` same form | `"f"` |
| `guessGender` | `true` = learner must type the article (un/une/le/la) | `true` |
| `category` | Must exactly match a key in `categoryLabels` at the bottom of the file | `"classroom"` |

**`alts` tips — include every form a learner might reasonably type:**

```js
// Simple word — one alt is fine
alts:["étudier"]

// Sentence with optional trailing punctuation
alts:["Qu'est-ce que c'est", "Qu'est-ce que c'est ?", "Qu'est-ce que c'est?"]

// Sentence with exclamation space variants
alts:["Écoutez", "Écoutez !", "Écoutez!"]
```

**Real examples to copy from:**

```js
// Simple noun, masculine, learner guesses article
{en:"a book", fr:"un livre", alts:["un livre"], needsHyphen:false, needsAccent:false, gender:"m", guessGender:true, category:"classroom"},

// Accented word, feminine, learner guesses article
{en:"a student (f.)", fr:"une étudiante", alts:["une étudiante"], needsHyphen:false, needsAccent:true, gender:"f", guessGender:true, category:"classroom"},

// Number with required hyphen
{en:"eighty", fr:"quatre-vingts", alts:["quatre-vingts","quatre vingts"], needsHyphen:true, needsAccent:false, gender:"both", category:"numbers"},

// Question with punctuation variants
{en:"What is it?", fr:"Qu'est-ce que c'est ?", alts:["Qu'est-ce que c'est","Qu'est-ce que c'est ?","Qu'est-ce que c'est?"], needsHyphen:false, needsAccent:false, gender:"both", category:"identify"},
```

**Save the file** (Ctrl + S), then close Notepad.

---

### Step 4 — push to GitHub

```powershell
git add -A
git commit -m "etape2: add new cards"
git push
```

Cards appear on the live site automatically — no HTML changes needed.

---

### Optional — add audio for the new cards

```powershell
node generate-audio.js
git add audio\ audio-manifest.json
git commit -m "add audio for new cards"
git push
```

---

### Or — skip Notepad entirely and inject with PowerShell

If you don't want to open the file at all, paste this block and run it.
Edit only the top section.

```powershell
# ── CHANGE THESE TWO THINGS ──────────────────────────────────────────────
$etape = "etape2"   # etape1 / etape2 / etape3 / etape4

$newCards = @"
    {en:"a book", fr:"un livre", alts:["un livre"], needsHyphen:false, needsAccent:false, gender:"m", guessGender:true, category:"classroom"},
    {en:"a student (f.)", fr:"une etudiante", alts:["une etudiante"], needsHyphen:false, needsAccent:true, gender:"f", guessGender:true, category:"classroom"},
"@
# ── DO NOT EDIT BELOW THIS LINE ──────────────────────────────────────────

$file    = "etapes\$etape.js"
$content = Get-Content $file -Raw -Encoding UTF8
$anchor  = "`n  ],`n  categoryLabels:"
$content = $content.Replace($anchor, "`n$newCards$anchor")
[System.IO.File]::WriteAllText((Resolve-Path $file), $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Cards added to $file" -ForegroundColor Green

git add -A
git commit -m "${etape}: add new cards"
git push
```

> This inserts your cards at the **end of the vocab array**, just before `categoryLabels`.
> If you want cards under a specific category comment, use the Notepad method instead.


## 1b. Adding a new category

Run this if a card uses a `category` value that does not exist yet.

```powershell
# ── CHANGE THESE ─────────────────────────────────────────────────────────
$etape    = "etape2"
$catKey   = "weather"    # used in the card's category: field
$catLabel = "Weather"    # display name shown on the filter chip
# ── DO NOT EDIT BELOW THIS LINE ──────────────────────────────────────────

$file = "etapes\$etape.js"
$c    = Get-Content $file -Raw -Encoding UTF8
$c    = $c -replace 'all:"Random"', "all:`"Random`", $catKey`:`"$catLabel`""
[System.IO.File]::WriteAllText((Resolve-Path $file), $c, [System.Text.UTF8Encoding]::new($false))
Write-Host "Category '$catKey' added to $file" -ForegroundColor Green

git add -A
git commit -m "${etape}: add $catKey category"
git push
```

---

## 2. Adding audio for new cards

After adding cards, generate their mp3 files. Existing files are skipped automatically.

```powershell
node generate-audio.js

git add audio\ audio-manifest.json
git commit -m "add audio for new cards"
git push
```

> Requires Node.js and a Google Cloud TTS key configured in `generate-audio.js`.
> If you skip this step, new cards just show no audio — everything else still works.

---

## 3. Changing the auto-advance timer speed (solo mode)

Changes the timer speed across all four solo pages at once.

```powershell
# ── CHANGE THIS ───────────────────────────────────────────────────────────
$ms = 3000   # milliseconds: 3000 = 3 sec, 5000 = 5 sec, 1500 = 1.5 sec
# ── DO NOT EDIT BELOW THIS LINE ───────────────────────────────────────────

$utf8 = [System.Text.UTF8Encoding]::new($false)
foreach ($f in @("solo.html","solo1.html","solo3.html","solo4.html")) {
    $c = Get-Content $f -Raw -Encoding UTF8
    $c = $c -replace 'const autoDelay\s*=\s*\d+', "const autoDelay = $ms"
    [System.IO.File]::WriteAllText((Resolve-Path $f), $c, $utf8)
    Write-Host "Updated $f" -ForegroundColor Green
}

git add -A
git commit -m "set auto-advance timer to ${ms}ms"
git push
```

---

## 4. Changing the default landing tab

Sets which etape tab is active when someone first opens the site.

```powershell
# ── CHANGE THIS ───────────────────────────────────────────────────────────
$defaultEtape = "e2"   # e1 / e2 / e3 / e4
# ── DO NOT EDIT BELOW THIS LINE ───────────────────────────────────────────

$file = "etapes\registry.js"
$c = Get-Content $file -Raw -Encoding UTF8
$c = $c -replace "window\.DEFAULT_ETAPE\s*=\s*'e\d+'", "window.DEFAULT_ETAPE = '$defaultEtape'"
[System.IO.File]::WriteAllText((Resolve-Path $file), $c, [System.Text.UTF8Encoding]::new($false))
Write-Host "Default etape set to $defaultEtape" -ForegroundColor Green

git add -A
git commit -m "set default etape to $defaultEtape"
git push
```

---

## 5. Adding a whole new etape (end-to-end)

Change the variables at the top. The script creates all files and updates all maps automatically.

```powershell
# ── CHANGE THESE ─────────────────────────────────────────────────────────
$N          = "5"
$id         = "e5"
$label      = "Etape 5"
$sublabel   = "5e"
$titleMulti = "French Flashcards · 1v1 MODL-1101 Etape 5"
$titleSolo  = "French Flashcards · Solo · MODL-1101 Etape 5"
$copyFrom   = "4"       # etape number to copy the HTML shells from
# ── DO NOT EDIT BELOW THIS LINE ──────────────────────────────────────────

$utf8 = [System.Text.UTF8Encoding]::new($false)

# 1. Vocab file — opens in Notepad for you to fill in
Copy-Item "etapes\etape$copyFrom.js" "etapes\etape$N.js"
Write-Host "Created etapes\etape$N.js — replace the vocab then save and close Notepad" -ForegroundColor Yellow
notepad "etapes\etape$N.js"

# 2. HTML shells
Copy-Item "etape$copyFrom.html" "etape$N.html"
Copy-Item "solo$copyFrom.html"  "solo$N.html"

$c = Get-Content "etape$N.html" -Raw -Encoding UTF8
$c = $c -replace "window\.CURRENT_ETAPE_ID\s*=\s*'e\d+'", "window.CURRENT_ETAPE_ID = '$id'"
$c = $c -replace "etapes/etape$copyFrom\.js", "etapes/etape$N.js"
[System.IO.File]::WriteAllText((Resolve-Path "etape$N.html"), $c, $utf8)

$c = Get-Content "solo$N.html" -Raw -Encoding UTF8
$c = $c -replace "etapes/etape$copyFrom\.js", "etapes/etape$N.js"
[System.IO.File]::WriteAllText((Resolve-Path "solo$N.html"), $c, $utf8)

# 3. Update ETAPE_PAGE_MAP and ETAPE_SOLO_MAP in every shell
$allShells = @("index.html","etape1.html","etape3.html","etape4.html","etape$N.html",
               "solo.html","solo1.html","solo3.html","solo4.html","solo$N.html")
foreach ($f in $allShells) {
    $c = Get-Content $f -Raw -Encoding UTF8
    $c = $c -replace "(e$copyFrom\s*:\s*'etape$copyFrom\.html'`n\};)", "e$copyFrom`: 'etape$copyFrom.html',`n  $id`: 'etape$N.html'`n};"
    $c = $c -replace "(e$copyFrom\s*:\s*'solo$copyFrom\.html'`n\};)",  "e$copyFrom`: 'solo$copyFrom.html',`n  $id`: 'solo$N.html'`n};"
    [System.IO.File]::WriteAllText((Resolve-Path $f), $c, $utf8)
    Write-Host "Updated page maps in $f" -ForegroundColor Cyan
}

# 4. Add entry to registry.js
$regEntry = @"

  {
    id: '$id',
    label: '$label',
    sublabel: '${N}e',
    titleMulti: '$titleMulti',
    titleSolo: '$titleSolo',
    sub: 'Race a friend, or practice solo',
    file: 'etapes/etape$N.js'
  }
"@
$reg = Get-Content "etapes\registry.js" -Raw -Encoding UTF8
$reg = $reg.Replace("`n];", "$regEntry`n];")
[System.IO.File]::WriteAllText((Resolve-Path "etapes\registry.js"), $reg, $utf8)

Write-Host ""
Write-Host "Files created. After saving the vocab file, run:" -ForegroundColor Yellow
Write-Host "  node generate-audio.js" -ForegroundColor White
Write-Host "  git add -A && git commit -m 'add etape$N' && git push" -ForegroundColor White
```

After filling in the vocab in Notepad and saving:

```powershell
node generate-audio.js
git add -A
git commit -m "add etape$N with vocab, shells, audio"
git push
```

---

## 6. Updating Firestore security rules

The 1v1 mode writes to Cloud Firestore (project `french-quiz-79a0d`).
Update the rules whenever you add etapes or change what the client writes.

### Via the Firebase console (easiest)

1. [Firebase Console](https://console.firebase.google.com/) → `french-quiz-79a0d`
2. **Firestore Database → Rules** → edit → **Publish**

Current rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /rooms/{roomId} {
      allow read, write: if true;
    }
  }
}
```

### Via PowerShell (CLI)

```powershell
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
```

To check which collections the app writes to:

```powershell
Select-String -Path "*.html" -Pattern "setDoc|doc\(db," | Select-Object Line
```

---

## Quick reference

| Task | Command |
|---|---|
| Go to repo | `cd C:\Users\Gurda\Downloads\french-quiz-repo` |
| Push all changes | `git add -A && git commit -m "message" && git push` |
| Check what changed | `git status` |
| See recent commits | `git log --oneline -10` |
| Undo unsaved file edit | `git checkout -- filename.html` |
| Generate audio | `node generate-audio.js` |
| Search all files for text | `Select-String -Path "*" -Pattern "your text"` |
