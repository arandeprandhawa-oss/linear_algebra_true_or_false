# french-quiz — Maintenance & Local Setup Guide

Practical how-to for the [french-quiz](https://arandeprandhawa-oss.github.io/french-quiz/) app.

---

## File map (what touches what)

```
index.html        ← Étape 2 (default landing) · 1v1 lobby
etape1.html       ← Étape 1 · 1v1 lobby
etape3.html       ← Étape 3 · 1v1 lobby
solo.html         ← Étape 2 · Solo (spaced repetition)
solo1.html        ← Étape 1 · Solo
solo3.html        ← Étape 3 · Solo
etapes/
  registry.js     ← single source of truth: which étapes exist
  etape1.js        ← Étape 1 vocab + category labels
  etape2.js        ← Étape 2 vocab + category labels
  etape3.js        ← Étape 3 vocab + category labels
  etape4.js        ← Étape 4 vocab (not yet wired into registry)
```

Each étape has **three** moving parts: a vocab file (`etapes/etapeN.js`), a registry entry
(`registry.js`), and a pair of HTML shells (`etapeN.html` + `soloN.html`).

---

## 1a. Adding new cards to an existing étape

Open the relevant `etapes/etapeN.js` and add an object to the `vocab` array. The shape:

```js
{
  en: "a book",            // English prompt
  fr: "un livre",          // canonical French answer (shown when revealed)
  alts: ["un livre"],      // every accepted answer (add punctuation/no-punctuation variants)
  needsHyphen: false,      // true if the answer contains a required hyphen (e.g. Levez-vous.)
  needsAccent: false,      // true if the answer contains a required accent (é, ç, etc.)
  gender: "m",             // "m", "f", or "both"
  guessGender: true,       // optional — prompts the learner to supply the article's gender
  category: "classroom"    // MUST match a key in categoryLabels (see 1b)
}
```

Tips:

- **`alts` should include every reasonable form** the learner might type — with and without
  trailing punctuation, with/without spaces before `!` or `?`. Look at existing command
  entries (`Écoutez !`) for the pattern: `alts:["Écoutez","Écoutez !","Écoutez!"]`.
- Group new entries under the matching `// ===== CATEGORY =====` comment block to keep the
  file readable.
- That's it — the lobby, solo page, and category chips read the vocab automatically. No HTML
  edit needed for new cards in an existing étape.

## 1b. Adding a new category to an étape

Categories drive the filter chips. If a card uses a `category` value that isn't yet known,
add it to the `categoryLabels` map at the bottom of the same `etapeN.js`:

```js
categoryLabels: {
  all: "Random", classroom: "Classroom", commands: "Commands", people: "People",
  // add your new one:
  weather: "Weather"
}
```

The key (`weather`) must exactly match the `category:` string on the cards. The value is the
display label. `all` is special (the "Random" chip) — leave it in.

---

## 2. Updating the registry (adding a whole new étape)

`etapes/registry.js` is the single source of truth for which étapes exist. To wire up a new
one (e.g. Étape 4):

1. **Create the vocab file** `etapes/etape4.js` with the same shape as the others:
   ```js
   window.ETAPE_DATA = {
     vocab: [ /* ...cards... */ ],
     categoryLabels: { all: "Random", /* ... */ }
   };
   ```

2. **Add an entry** to the `window.ETAPES` array in `registry.js`:
   ```js
   {
     id: 'e4',
     label: 'Étape 4',
     sublabel: '4ᵉ',
     titleMulti: 'French Flashcards · 1v1 MODL-1101 Étape 4',
     titleSolo:  'French Flashcards · Solo · MODL-1101 Étape 4',
     sub: 'Race a friend, or practice solo',
     file: 'etapes/etape4.js'
   }
   ```

3. **Create the two HTML shells.** Copy an existing pair (e.g. `etape3.html` → `etape4.html`
   and `solo3.html` → `solo4.html`). In each new shell change the one identifying line:
   - In `etape4.html`: `window.CURRENT_ETAPE_ID = 'e4';`
   - Load the right vocab file: `<script src="etapes/etape4.js"></script>`

4. **Register the new pages in the page maps.** Every shell contains these two objects — add
   the `e4` key to **all** of them (in `index.html`, `etape1.html`, `etape3.html`, and the
   new `etape4.html`, plus the solo shells):
   ```js
   window.ETAPE_PAGE_MAP = { e1:'etape1.html', e2:'index.html', e3:'etape3.html', e4:'etape4.html' };
   window.ETAPE_SOLO_MAP = { e1:'solo1.html', e2:'solo.html', e3:'solo3.html', e4:'solo4.html' };
   ```

5. **(Optional) change the default landing tab** with `window.DEFAULT_ETAPE = 'e4';` in
   `registry.js`.

After this the tab bar renders the new étape automatically from the registry.

---

## 3. Updating Firestore security rules

The 1v1 mode writes game/lobby documents to Cloud Firestore (project `french-quiz-79a0d`).
The Firebase config lives inline in the `<script type="module">` block of each lobby HTML.

When you add étapes or change which collections/fields the client writes, the Firestore
**rules** must allow it, or writes will be silently rejected.

1. In the **Firebase console** → Firestore Database → **Rules** tab, edit the ruleset. A
   minimal pattern for this app (game rooms keyed by a short room code) looks like:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // game/lobby rooms — open read/write so two anonymous players can sync
       match /rooms/{roomId} {
         allow read, write: if true;
       }
     }
   }
   ```
   Adjust the collection name (`rooms`) to match what the client actually writes — check the
   `setDoc`/`doc(db, "...")` calls in the module script of the lobby pages.

2. If any étape introduces a **new category id or new collection** that the rules whitelist by
   name, add it to the rules before relying on it.

3. **Deploy the rules.** Either click **Publish** in the console, or from the CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase deploy --only firestore:rules
   ```
   (CLI deploy requires a `firestore.rules` file and a `firebase.json` in the project root.)

> Note: the rules above are wide-open, which is fine for a casual classroom game but means
> anyone can read/write rooms. Tighten them (e.g. validate document shape, limit field sizes,
> add expiry) if you want stricter control.

---

## 4. Download and run it locally (Windows + PowerShell)

The app is plain static HTML/JS — no build step. You just need the files and a local web
server. Opening the HTML by double-clicking **won't work**, because the scripts use ES
modules, which browsers block over the `file://` protocol. You have to serve it over
`http://`.

### Prerequisites — install these first

You only need **one** of Git or Python, but installing both is easiest.

1. **Git for Windows** (to download the repo with one command):
   - Download from <https://git-scm.com/download/win> and run the installer (accept the
     defaults).
   - To verify, open PowerShell and run:
     ```powershell
     git --version
     ```
     You should see something like `git version 2.x.x`.

2. **Python 3** (to run the local web server — simplest option on Windows):
   - Install from the Microsoft Store (search "Python 3.12") or from
     <https://www.python.org/downloads/>. If you use the python.org installer, **check the box
     "Add Python to PATH"** on the first screen.
   - To verify:
     ```powershell
     python --version
     ```
     You should see `Python 3.x.x`. (If `python` does nothing, try `py --version`.)

> A modern web browser (Edge, Chrome, Firefox) is the only other thing you need.

### Step by step in PowerShell

Open PowerShell (Start menu → type "PowerShell" → Enter), then run these one at a time:

1. **Go to where you want the project to live** (e.g. your Documents folder):
   ```powershell
   cd $HOME\Documents
   ```

2. **Download the repo.**

   *Option A — with Git (recommended):*
   ```powershell
   git clone https://github.com/arandeprandhawa-oss/french-quiz.git
   ```

   *Option B — without Git (download the ZIP):* go to the repo page in your browser, click the
   green **Code** button → **Download ZIP**, then unzip it into `Documents`. The folder may be
   named `french-quiz-main`.

3. **Move into the project folder:**
   ```powershell
   cd french-quiz
   ```
   (If you used the ZIP, the folder is probably `french-quiz-main`, so run
   `cd french-quiz-main` instead.)

4. **Start a local web server in this folder:**
   ```powershell
   python -m http.server 8000
   ```
   If `python` isn't recognized, use:
   ```powershell
   py -m http.server 8000
   ```
   PowerShell will print something like `Serving HTTP on :: port 8000`. Leave this window
   **open** — it's running the server. (If Windows Firewall pops up asking for permission,
   "Allow access" on private networks is fine.)

5. **Open the app in your browser.** Go to:
   ```
   http://localhost:8000/
   ```
   The default landing page is Étape 2 (`index.html`). Use the tab bar to switch étapes, or go
   straight to a page like `http://localhost:8000/solo.html`.

6. **To stop the server**, click back into the PowerShell window and press **Ctrl + C**.

7. **To run it again later**, just reopen PowerShell and repeat steps 3–5 (no need to
   re-download). To get the latest updates first, run `git pull` inside the folder before
   starting the server.

### Notes for local use

- **Solo mode works fully offline** once the page is loaded — spaced repetition runs in the
  browser, no network needed.
- **1v1 multiplayer needs the internet** because it talks to the live Firebase project. It
  will work locally as long as `localhost` is allowed in Firebase. If multiplayer fails
  locally, add `localhost` under Firebase console → Authentication → Settings →
  **Authorized domains**.
- No API keys to set up — the Firebase web config is public by design and already embedded in
  the HTML.
