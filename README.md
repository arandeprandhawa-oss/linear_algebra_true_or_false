# True/False Flashcard Website - Make Your Own

A ready-to-use template for making your own flashcard quiz website. Fork it, run one script, and you have a live website at `your-username.github.io/linear_algebra_true_or_false`.

**Live demo:** https://arandeprandhawa-oss.github.io/linear_algebra_true_or_false/

---

## What you get

- **1v1 multiplayer** - race a friend through cards using a room code
- **Solo mode** - spaced repetition (Again / Hard / Good / Easy rating)
- **4 topic tabs** - each tab is a separate set of cards
- **Category filter chips** - filter cards by topic within a tab
- **Explanations** - shown after every answer so you learn, not just memorize
- **Works on mobile and iPad**

---

## What you need (both are free)

| Account | What it is | Sign up |
|---|---|---|
| **GitHub** | Hosts your website for free | github.com/signup |
| **Firebase** | Powers the 1v1 multiplayer | firebase.google.com |

You only need Firebase if you want the 1v1 mode. Solo mode works without it.

---

## One-time setup (5 minutes)

### Step 1 - Fork this repo

"Forking" creates your own personal copy of this website on your GitHub account.

1. Make sure you are signed in to GitHub
2. Go to the top of this page and click **Fork** (top-right corner)
3. Click **Create fork**

You now have a copy at `github.com/YOUR-USERNAME/linear_algebra_true_or_false`.

### Step 2 - Download `setup.ps1`

In your fork, click on `setup.ps1`, then click the download button (the arrow icon).

Save it to your **Downloads** folder.

### Step 3 - Run the script

1. Open **PowerShell** (search for it in the Start menu)
2. Paste this line and press Enter:
   ```
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```
3. Paste this line and press Enter:
   ```
   cd Downloads; .\setup.ps1
   ```
4. Follow the prompts - the script will guide you through everything

### Step 4 - Enable GitHub Pages

The script opens this page automatically, but here are the steps:

1. Go to your repo on GitHub
2. Click **Settings** (top tab bar)
3. Click **Pages** (left sidebar)
4. Under Source: select **Deploy from a branch**
5. Branch: **main** | Folder: **/ (root)**
6. Click **Save**

Wait about 1 minute. Your site is live at:
```
https://YOUR-USERNAME.github.io/linear_algebra_true_or_false/
```

---

## Adding your own cards

Cards live in the `etapes/` folder. Each file (`etape1.js` through `etape4.js`) is one topic tab.

### Card format

```js
{
  en:          "Every square matrix is invertible.",   // the question shown
  fr:          "False",                                // answer: "True" or "False"
  alts:        ["False", "false"],                     // keep these as shown
  needsHyphen: false,                                  // always false for T/F
  needsAccent: false,                                  // always false for T/F
  gender:      "both",                                 // always "both" for T/F
  guessGender: true,                                   // always true for T/F
  explanation: "A matrix is only invertible when det(A) is not zero.",
  category:    "matrices"                              // must match a categoryLabels key
},
```

**Rules:**
- `en` - the statement shown to the student
- `fr` - must be exactly `"True"` or `"False"` (capital T or F)
- `alts` - copy exactly: `["True","true"]` or `["False","false"]`
- `explanation` - why the answer is True or False (shown after answering)
- `category` - must match one of the keys in `categoryLabels` at the bottom of the file

### How to add cards using PowerShell

```powershell
# Auto-find your repo
$repo = "$env:USERPROFILE\Downloads\linear_algebra_true_or_false"
Set-Location $repo

# Open the card file in Notepad
notepad etapes\etape1.js
```

Add your cards before the `],` line that closes the `vocab` array, then save. Then push:

```powershell
git add -A
git commit -m "add new cards"
git push
```

Wait ~1 minute and hard-refresh (`Ctrl + F5`) to see your changes live.

---

## Adding a new category (filter chip)

Each card belongs to a category. Categories appear as clickable filter chips above the cards. To add a new one, open the etape JS file in Notepad and add a line to `categoryLabels`:

```js
categoryLabels: {
    all:          "All Topics",
    matrices:     "Matrices",
    determinants: "Determinants",
    mynewcategory: "My New Category"   // add your category here
}
```

Then use that key in your card's `category` field.

---

## Changing the tab labels

Open `etapes/registry.js` and edit the `label`, `titleMulti`, and `sub` fields:

```js
{
    id: 'e1',
    label: 'Unit 1',                              // short tab label
    sublabel: '1st',                              // small badge on the tab
    titleMulti: 'My Subject - True or False',     // shown on the lobby page
    titleSolo:  'My Subject - Solo Practice',     // shown on the solo page
    sub: 'Topic description shown under title',   // subtitle
    file: 'etapes/etape1.js'                      // which card file to load
},
```

---

## Firebase setup for 1v1 mode

The 1v1 mode needs Firebase (free). The setup script walks you through this, but here are the manual steps:

### Create a Firebase project

1. Go to [firebase.google.com](https://firebase.google.com) and sign in
2. Click **Add project** - name it anything
3. Click the **Web** icon (`</>`) to add a web app
4. Copy the `firebaseConfig` object - you will need these values

### Enable Firestore

1. In your Firebase project, click **Firestore Database** (left sidebar)
2. Click **Create database**
3. Choose **Start in test mode** for now
4. Pick any region and click **Done**

### Update the Firestore rules

In Firebase Console, go to **Firestore Database > Rules** and replace everything with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /matches/{matchId} {
      function validCode() { return matchId.matches('^[A-Z]{4}$'); }
      function validStatus(s) { return s in ['waiting','playing','done','resigned']; }
      function validEtape(e) { return e in ['e1','e2','e3','e4']; }
      function validCategory(c) {
        return c in [
          'all','systems','span','independence',
          'matrices','inverses','lu',
          'determinants','transformations',
          'subspaces','eigenvalues','markov'
        ];
      }
      allow read: if validCode();
      allow create: if validCode()
        && request.resource.data.status == 'waiting'
        && validEtape(request.resource.data.etape)
        && request.resource.data.length in [20,30,40,50,60,70,80]
        && validCategory(request.resource.data.category);
      allow update: if validCode();
      allow delete: if validCode() && resource.data.status == 'waiting';
    }
  }
}
```

Click **Publish**.

### Swap the Firebase config into your HTML files

Run this in PowerShell (fill in your own values):

```powershell
$repo = "$env:USERPROFILE\Downloads\linear_algebra_true_or_false"
Set-Location $repo

# Paste your Firebase values here
$apiKey            = "YOUR_API_KEY"
$authDomain        = "YOUR_PROJECT.firebaseapp.com"
$projectId         = "YOUR_PROJECT"
$storageBucket     = "YOUR_PROJECT.firebasestorage.app"
$messagingSenderId = "YOUR_SENDER_ID"
$appId             = "YOUR_APP_ID"

$utf8 = [System.Text.UTF8Encoding]::new($false)
Get-ChildItem "*.html" | ForEach-Object {
    $c = Get-Content $_.FullName -Raw -Encoding UTF8
    if($c -notmatch 'firebaseConfig'){ return }
    $c = $c -replace 'apiKey:\s*"[^"]*"',            "apiKey: `"$apiKey`""
    $c = $c -replace 'authDomain:\s*"[^"]*"',        "authDomain: `"$authDomain`""
    $c = $c -replace 'projectId:\s*"[^"]*"',         "projectId: `"$projectId`""
    $c = $c -replace 'storageBucket:\s*"[^"]*"',     "storageBucket: `"$storageBucket`""
    $c = $c -replace 'messagingSenderId:\s*"[^"]*"', "messagingSenderId: `"$messagingSenderId`""
    $c = $c -replace 'appId:\s*"[^"]*"',             "appId: `"$appId`""
    [System.IO.File]::WriteAllText($_.FullName, $c, $utf8)
    Write-Host "Updated $($_.Name)"
}
git add -A; git commit -m "my Firebase config"; git push
```

---

## Pushing changes to your live site

Any time you edit files locally, run these three lines to publish:

```powershell
cd "$env:USERPROFILE\Downloads\linear_algebra_true_or_false"
git add -A
git commit -m "describe what you changed"
git push
```

Then wait about 1 minute and hard-refresh (`Ctrl + F5`).

If you get a "push rejected" error:
```powershell
git push --force
```

---

## Troubleshooting

**"push-la-quiz.ps1 is not digitally signed"**
Run this first, then try again:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

**"not a git repository"**
You are in the wrong folder. Run:
```powershell
cd "$env:USERPROFILE\Downloads\linear_algebra_true_or_false"
```

**Cards not appearing on the live site**
- Wait 1 full minute after pushing
- Hold `Ctrl` and press `F5` to hard-refresh (clears the browser cache)
- Check the card format carefully - `fr` must be exactly `"True"` or `"False"`

**1v1 match not working**
- Make sure Firestore is enabled (test mode) in your Firebase project
- Make sure you updated the Firestore rules (see Firebase section above)
- Make sure you ran the Firebase config script above

**The site shows an old version**
Push rejected somewhere earlier. Run `git push --force` to fix it.

---

## Quick reference

| Task | Command |
|---|---|
| Edit cards | `notepad etapes\etape1.js` |
| Push changes | `git add -A; git commit -m "msg"; git push` |
| Push rejected | `git push --force` |
| See recent changes | `git log --oneline -10` |
| Undo unsaved file edit | `git checkout -- etapes\etape1.js` |

---

## File map

```
index.html          <- Unit 1 lobby (1v1 + solo link)
etape1.html         <- Unit 1 - same as index but different tab active
etape3.html         <- Unit 3 lobby
etape4.html         <- Unit 4 lobby
solo.html           <- Unit 1 solo (spaced repetition)
solo1.html          <- Unit 2 solo
solo3.html          <- Unit 3 solo
solo4.html          <- Unit 4 solo
etapes/
  registry.js       <- tab labels, titles, which file each tab loads
  etape1.js         <- Unit 1 cards and category labels
  etape2.js         <- Unit 2 cards and category labels
  etape3.js         <- Unit 3 cards and category labels
  etape4.js         <- Unit 4 cards and category labels
setup.ps1           <- beginner setup script (run this first)
firestore.rules     <- Firestore security rules (paste into Firebase Console)
```
