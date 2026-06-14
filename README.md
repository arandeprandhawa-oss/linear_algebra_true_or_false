# Linear Algebra: True or False

A web-based flashcard quiz for **MATH 2210 Applied Linear Algebra**. Practise the true/false concept checks for each unit, either **solo** (with spaced repetition) or in a configurable **2-to-6-player multiplayer race** using a shared match code.

**Live website:** <https://arandeprandhawa-oss.github.io/linear_algebra_true_or_false/>

> Everything in this repository is plain HTML/CSS/JavaScript with **no build step**. To install, edit, configure, or publish it you only ever **double-click a tool** in the `setup_powershell` folder — you never have to type a command.

---

## Table of contents

- [What this is](#what-this-is)
- [Features at a glance](#features-at-a-glance)
- [How the site is organised](#how-the-site-is-organised)
- [How a quiz round plays](#how-a-quiz-round-plays)
- [The setup toolkit (double-click tools)](#the-setup-toolkit)
- [Tutorial 1 — Install a local copy (no internet needed)](#tutorial-1-local)
- [Tutorial 2 — Create your own online copy (GitHub + Firebase)](#tutorial-2-online)
- [Tutorial 3 — Log in and connect Firebase](#tutorial-3-firebase-login)
- [Tutorial 4 — Deploy the Firestore (multiplayer) rules](#tutorial-4-deploy-rules)
- [Tutorial 5 — Edit the quiz questions](#tutorial-5-edit-questions)
- [Tutorial 6 — Edit the flashcard data](#tutorial-6-edit-flashcards)
- [Tutorial 7 — Add a new unit](#tutorial-7-add-unit)
- [Tutorial 8 — Choose 2–6 multiplayer players](#tutorial-8-player-count)
- [Tutorial 9 — Adjust the timers](#tutorial-9-timing)
- [Tutorial 10 — Push your changes to GitHub](#tutorial-10-push)
- [Tutorial 11 — Update the toolkit itself](#tutorial-11-update-toolkit)
- [The interactive script simulator](#script-simulator)
- [Project file layout](#project-file-layout)
- [Data formats (reference)](#data-formats)
- [Safety features](#safety-features)
- [Troubleshooting](#troubleshooting)
- [Requirements](#requirements)

---

<a id="what-this-is"></a>
## What this is

This repository holds two things:

1. **The website** — plain HTML/CSS/JavaScript flashcard pages. No build step, no framework. Open `index.html` in a browser and it works.
2. **A setup toolkit** — a folder of friendly double-click tools (in `setup_powershell/`) for installing, editing, configuring, and publishing the site on Windows. You never have to type a single command.

The online version uses **Firebase / Firestore** for configurable 2-to-6-player multiplayer matches. The local version strips that out and runs entirely offline as solo-only.

---

<a id="features-at-a-glance"></a>
## Features at a glance

| Feature | Details |
|---|---|
| **Solo practice** | Spaced repetition so the cards you miss come back sooner. |
| **Configurable multiplayer** | A **2-to-6-player** race over a shared match code — lobby, per-player ready states, live scoring, finish, and resign. |
| **Four course units** | Span/independence, matrix algebra/inverses/LU, determinants/transformations, subspaces/eigenvalues/Markov. |
| **True/False only** | Tap a button or press `T` / `F` — no typing answers. |
| **Instant feedback** | Each card shows ✓ / ✗ plus a short *why*, then auto-advances. |
| **End-of-round review** | Final score plus a replay of every card you missed, with explanations. |
| **No-typing toolkit** | 12 double-click tools cover install, Firebase login, rule deploy, editing, configuration, and publishing. |
| **Safe edits** | Tools make timestamped backups before changing any file. |
| **Script simulator** | A live, click-through demo of every toolkit tool (`script-simulations.html`). |

**Newly added since the first release** (all documented below): a standalone **Login and Connect Firebase** tool, a standalone **Deploy Firestore Rules** tool, **Add New Unit**, **Change Player Count (2–6)**, and **Adjust Timing and Length**. Multiplayer also grew from strict 1‑v‑1 to a configurable **2-to-6-player** race.

---

<a id="how-the-site-is-organised"></a>
## How the site is organised

The quiz is split into four **units**, matching the course:

| Unit | Topic |
|---|---|
| Unit 1 | Systems, Span & Independence |
| Unit 2 | Matrix Algebra, Inverses & LU |
| Unit 3 | Determinants & Linear Transformations |
| Unit 4 | Subspaces, Eigenvalues & Markov |

Each unit has two pages:

- A **multiplayer lobby** page (`index.html`, `etape1.html`, `etape3.html`, `etape4.html`) — create or join a match, or jump to solo.
- A **solo** page (`solo.html`, `solo1.html`, `solo3.html`, `solo4.html`) — practise on your own with spaced repetition.

A tab bar at the top of every page lets you switch units. The tabs are generated automatically from `etapes/registry.js`, and the question/answer content for each unit lives in `etapes/etape1.js` … `etape4.js`.

> **Page-to-unit mapping (worth knowing):** `index.html` = Unit 2's multiplayer page, `solo.html` = Unit 2's solo page. `solo1.html` = Unit 1, `solo3.html` = Unit 3, `solo4.html` = Unit 4. The `1` / `3` / `4` in the filename is the unit number; the unnumbered files are Unit 2.

---

<a id="how-a-quiz-round-plays"></a>
## How a quiz round plays

- A statement appears (for example, *"Every square matrix is invertible."*).
- Answer with the **True / False buttons**, or use the keyboard: `T` = True, `F` = False, `Space` / `Enter` = Next.
- The card immediately shows **✓ correct** or **✗ wrong**, plus a one-line explanation of *why*, then auto-advances after a short pause you can tune (see Tutorial 9).
- **Solo mode** uses spaced repetition: cards you rate *Again* / *Hard* return sooner; *Good* / *Easy* space them out.
- **Multiplayer mode** runs the same cards for everyone in the match at once. The waiting room shows who has joined and who has pressed **I am ready** (e.g. *Player 1 is ready*, *Player 3 joined — not ready*), and the match starts only when every required player is ready.
- At the end you get your **score** and a **review** of every card you missed, with its explanation.

You can also **filter by category** (e.g. only *determinants* or only *eigenvalues*) or mix **all topics** together.

---

<a id="the-setup-toolkit"></a>
## The setup toolkit

Everything lives in the **`setup_powershell`** folder. Each tool is a `.cmd` file you **double-click** — it runs the matching PowerShell script for you and handles the security prompts automatically. Keep each `.cmd` next to its matching `.ps1`.

| Double-click this | What it does |
|---|---|
| **Setup Launcher** | The front door. If both installers are present, lets you pick local vs. online. |
| **Install Local Quiz** | Installs an offline, solo-only copy on this computer. No accounts needed. |
| **Install Firebase Quiz** | Creates a full online copy with GitHub Pages + Firebase multiplayer. |
| **Login and Connect Firebase** | Signs in to Firebase, links this folder to your Firebase project, and saves `.firebaserc` / `firebase.json` for future deploys. No Web API key needed. |
| **Deploy Firestore Rules** | Rebuilds `firestore.rules` to match your current units and settings, then publishes them to Firebase. |
| **Edit Quiz JavaScript** | Visual editor to open and edit the quiz logic / question files. |
| **Edit Flashcards** | Visual editor for the flashcard question data. |
| **Add New Unit** | Creates a brand-new unit and wires it into the registry, pages, and tabs automatically. |
| **Change Player Count** | Visual editor to choose 2, 3, 4, 5, or 6 players; updates the site configuration and Firestore rules. |
| **Adjust Timing and Length** | Type in the auto-advance delays and learning-step times; applies to all pages. |
| **Update Entire Project to GitHub** | Commits **every** change in the project and pushes it to GitHub. |
| **Update GitHub Setup Toolkit** | Pushes only the `setup_powershell` toolkit files to GitHub. |

**Requirements:** Windows 10/11, a web browser, and an internet connection for the online installer. A GitHub account is needed only for the online/GitHub tools, and a Google account only for Firebase. You do **not** need to install Git, Node.js, Python, or any CLI yourself — the scripts fetch what they need.

---

<a id="tutorial-1-local"></a>
## Tutorial 1 — Install a local copy (no internet needed)

Use this when you just want the quiz on your own machine, offline, solo-only.

1. Open the `setup_powershell` folder.
2. Double-click **Install Local Quiz**.
3. When the folder picker appears, choose where to put the site (Documents is fine).
4. Give the folder a name, or accept the default.
5. Wait for it to finish. It will open the quiz in your browser and drop a **desktop shortcut**.

**What you get:** a fully offline copy. The homepage opens straight into Unit 1 solo practice, the unit tabs switch between all four units, and the **← Home** link returns you to the start. Firebase, multiplayer, and audio are removed since they need the internet.

> If you ran an older version of this installer before, re-run it — the local homepage and the "back" link were fixed so they no longer land on a blank or broken page.

---

<a id="tutorial-2-online"></a>
## Tutorial 2 — Create your own online copy (GitHub + Firebase)

Use this to publish the full site, with working 2-to-6-player multiplayer, on the web.

1. Double-click **Install Firebase Quiz** in `setup_powershell`.
2. **GitHub step** — when the browser opens:
   - Create a new **empty, public** repository.
   - Do **not** add a README, `.gitignore`, or license.
   - Copy the repository URL (e.g. `https://github.com/your-name/your-repo`).
   - Paste it into the setup popup and click **Continue**.
3. **Firebase step** — in the Firebase Console:
   - Open **Project settings → General → Your apps**.
   - Select or create a **web** app.
   - Under **SDK setup and configuration**, choose **Config**.
   - Copy the entire `firebaseConfig` block.
   - Paste it into the large setup popup and click **Use this config**.
4. The script applies your config, deploys the Firestore rules, pushes to GitHub, and tries to enable GitHub Pages.

Your site goes live at `https://your-name.github.io/your-repo/` (Pages can take a couple of minutes the first time).

> **Security:** only ever paste the normal Firebase **web** config. Never paste a service-account private key into the site or commit one to GitHub. The `.gitignore` already excludes key files, `.env`, and logs.
>
> If multiplayer doesn't work after this, run **Login and Connect Firebase** (Tutorial 3) then **Deploy Firestore Rules** (Tutorial 4) once.

---

<a id="tutorial-3-firebase-login"></a>
## Tutorial 3 — Log in and connect Firebase

This one-time step signs you in to Firebase and links your project so rule deploys work later. **It does not need a Firebase Web API key** — it uses the Firebase CLI login plus a project ID.

1. Double-click **Login and Connect Firebase** in `setup_powershell`.
2. The tool installs the official `firebase-tools` (via npm) if it isn't already present.
3. A browser window opens — **sign in with the Google account** that owns your Firebase project and approve access.
4. Pick (or confirm) your **Firebase project**. The tool can detect the project ID from the website's existing `firebaseConfig`, or let you choose from the projects on your account.
5. It saves `.firebaserc` and `firebase.json` so future deploys reuse this login — **you only log in once**.

> This tool replaced the old portable `firebase.exe` flow, which could crash with *"Unexpected end of JSON input"* or *"Cannot bind argument to parameter 'Path'"*. If you saw those errors before, just run this tool.

---

<a id="tutorial-4-deploy-rules"></a>
## Tutorial 4 — Deploy the Firestore (multiplayer) rules

`firestore.rules` controls who may read and write match data. It must be re-published whenever it changes.

1. Double-click **Deploy Firestore Rules** in `setup_powershell`.
2. The tool reads your `firestore.rules`, refreshes it to match the current units and page settings, then deploys it to Firebase (reusing the login from Tutorial 3).
3. Wait for the success message — multiplayer now uses the updated rules.

Run this after any of:

- Adding a new unit with **Add New Unit** (Tutorial 7).
- Changing the player count with **Change Player Count** (Tutorial 8).
- Changing match lengths with **Adjust Timing and Length** (Tutorial 9).
- Editing `firestore.rules` by hand.

---

<a id="tutorial-5-edit-questions"></a>
## Tutorial 5 — Edit the quiz questions

1. Double-click **Edit Quiz JavaScript**.
2. Choose your project folder (the one containing `index.html`), or drag-and-drop it onto the blue area.
3. Pick a file from the drop-down — the unit data lives in `etapes/etape1.js` … `etape4.js`.
4. Leave **Create a timestamped backup** checked.
5. Click **Open in Notepad**, make your edit, then **Ctrl+S** to save.
6. Refresh the website to see the change.

If the drop-down looks empty, turn on **Also show HTML files** — some logic lives inline in the HTML pages.

---

<a id="tutorial-6-edit-flashcards"></a>
## Tutorial 6 — Edit the flashcard data

1. Double-click **Edit Flashcards**.
2. Point it at your project folder.
3. Edit the question entries through the editor. Each card is one object — see [Data formats](#data-formats) for the exact shape.
4. Save. A timestamped backup is created automatically before any change.

---

<a id="tutorial-7-add-unit"></a>
## Tutorial 7 — Add a new unit

This builds a whole new unit and connects it everywhere for you — no hand-editing of HTML or the registry.

1. Double-click **Add New Unit**.
2. The project is detected automatically. Fill in:
   - **Unit label** (e.g. "Unit 5").
   - **Topic / subtitle** (e.g. "Orthogonality & Least Squares").
   - **Tab badge** (the small number on the tab).
   - Optionally, pick an existing unit to **copy its questions** as a starting point.
3. Click **Create unit**.

It creates the unit's data file (`etapes/etapeN.js`), adds it to `registry.js`, creates the solo page (and the multiplayer page too, if you're on the online layout), and refreshes the unit tabs and navigation on every page. Then use **Edit Quiz JavaScript** to fill in the real questions, and **Deploy Firestore Rules** (Tutorial 4) so multiplayer knows about the new unit.

> It detects your layout automatically: a local (solo-only) install gets just a solo page; an online install gets both the multiplayer and solo pages.

---

<a id="tutorial-8-player-count"></a>
## Tutorial 8 — Choose 2–6 multiplayer players

Use the visual tool to change the number of players for every multiplayer unit at once.

1. Open `setup_powershell`.
2. Double-click **Change Player Count**.
3. The project folder is detected automatically. If needed, use **Choose a different folder**.
4. Choose **2, 3, 4, 5, or 6 players** from the drop-down.
5. Leave **Create timestamped backups** checked, then click **Apply player count**.
6. Double-click **Deploy Firestore Rules** (Tutorial 4), followed by **Update Entire Project to GitHub** (Tutorial 10).

The tool updates `multiplayer-config.js`, verifies every multiplayer page loads it, and rebuilds `firestore.rules` for Player 1 through Player 6. In the waiting room, each joined player gets their own ready state, such as **Player 1 is ready** and **Player 3 joined — not ready**. The match begins only when every required player has joined and pressed **I am ready**.

> Existing match codes keep the player count that was stored when each match was created. Create a new match after changing the setting.

---

<a id="tutorial-9-timing"></a>
## Tutorial 9 — Adjust the timers

This tool lets you **type** the timing values for the quiz. The project is detected automatically.

1. Double-click **Adjust Timing and Length**.
2. Type the values you want:
   - **Auto-advance delay — Solo practice**: after you answer, how long the Again / Hard / Good / Easy panel stays before the card auto-advances with the suggested rating (seconds).
   - **Learning step 1 — the "Again" interval**: when a learning card is rated Again, how soon it returns (minutes). This is the time shown on the Again button.
   - **Learning step 2 — the "Good" interval**: the next learning step before a card graduates (minutes). This is the time shown on the Good button.
   - **Auto-advance delay — multiplayer game**: on the head-to-head pages, how long the answer/explanation stays before the next card (seconds). The countdown bar stays in sync automatically.
3. Click **Apply to all pages**.

It writes the solo values to every `solo*.html` page and the multiplayer value to every game page, saving a backup of each under `backups\timing-editor` first. Refresh the site to see the effect.

> A local (solo-only) install has the solo timing controls; an online install has both the solo and the multiplayer controls. The tool fills the boxes with the current values so you can see what they are before changing them.

---

<a id="tutorial-10-push"></a>
## Tutorial 10 — Push your changes to GitHub

After editing anything locally, the changes are only on your computer until you push them.

1. Double-click **Update Entire Project to GitHub**.
2. Review the list of changed files it shows you.
3. Confirm. It runs `git add -A`, makes one commit, and pushes to `main`.

That single action publishes everything — edited questions, flashcards, new units, timing changes, and any toolkit fixes. GitHub Pages redeploys automatically a moment later.

> This tool does a normal push (no force-push), so it's safe to run any time you've made changes. If the folder isn't connected to GitHub yet (for example a fresh copy from the ZIP), it detects the project by its files and connects it for you automatically.

---

<a id="tutorial-11-update-toolkit"></a>
## Tutorial 11 — Update the toolkit itself

If you only changed files inside `setup_powershell` and want to publish just those:

1. Double-click **Update GitHub Setup Toolkit**.
2. It stages, commits, and pushes only the toolkit folder to `main`.

For most cases, **Update Entire Project to GitHub** (Tutorial 10) already covers this too.

---

<a id="script-simulator"></a>
## The interactive script simulator

`script-simulations.html` is a self-contained, click-through demo of the whole toolkit. It mimics what each tool's window looks like — the folder pickers, the Notepad pop-ups, the progress bars, the success and error messages — without changing any real files. It's handy for learning the workflow before running the real tools, or for showing someone else how a tool behaves.

Open it locally by double-clicking the file, or visit it on the live site at `…/script-simulations.html`.

---

<a id="project-file-layout"></a>
## Project file layout

```
linear_algebra_true_or_false/
├── index.html              Multiplayer lobby — Unit 2 (site entry point)
├── etape1.html             Multiplayer lobby — Unit 1
├── etape3.html             Multiplayer lobby — Unit 3
├── etape4.html             Multiplayer lobby — Unit 4
├── solo.html               Solo practice — Unit 2
├── solo1.html              Solo practice — Unit 1
├── solo3.html              Solo practice — Unit 3
├── solo4.html              Solo practice — Unit 4
├── script-simulations.html Interactive toolkit simulator (no real files touched)
├── multiplayer-config.js   Shared 2–6 player setting (edit with Change Player Count)
├── firestore.rules         Firestore security rules (online version)
├── firebase.json           Firebase deploy config (written by Login and Connect Firebase)
├── .firebaserc             Firebase project link (written by Login and Connect Firebase)
├── etapes/
│   ├── registry.js         The list of units (drives the tab bar)
│   ├── etape1.js           Unit 1 questions
│   ├── etape2.js           Unit 2 questions
│   ├── etape3.js           Unit 3 questions
│   └── etape4.js           Unit 4 questions
├── backups/                Timestamped backups made by the editor tools
└── setup_powershell/       The double-click setup toolkit (12 tools + this folder's README)
```

---

<a id="data-formats"></a>
## Data formats (reference)

### A flashcard

Each card is one object in the `vocab` array of a `etapes/etapeN.js` file:

```js
{
  en:          "Every square matrix is invertible.",   // the statement shown
  fr:          "False",                                // must be "True" or "False"
  alts:        ["False", "false"],                     // accepted values (both cases)
  explanation: "A matrix is invertible only when its determinant is nonzero.",
  category:    "matrices"                              // must match a categoryLabels key
},
```

- `en` — the statement shown to the student.
- `fr` — exactly `"True"` or `"False"` (capital first letter).
- `alts` — always `["True","true"]` or `["False","false"]`.
- `explanation` — shown after answering; briefly say *why*.
- `category` — must match a key in the `categoryLabels` block at the bottom of the same file.

### A registry entry

Each unit is one object in `window.ETAPES` inside `etapes/registry.js` (this is what **Add New Unit** writes):

```js
{
  id:         'e5',
  label:      'Unit 5',
  sublabel:   '5ᵗʰ',
  titleMulti: 'Linear Algebra · True or False · Unit 5',
  titleSolo:  'Linear Algebra · Solo · Unit 5',
  sub:        'Orthogonality & Least Squares',
  file:       'etapes/etape5.js'
}
```

### Player count

`multiplayer-config.js` is a single frozen setting every multiplayer page reads (edit it with **Change Player Count**, not by hand):

```js
window.MULTIPLAYER_CONFIG = Object.freeze({
  playerCount: 2   // supported: 2, 3, 4, 5, or 6
});
```

---

<a id="safety-features"></a>
## Safety features

- Existing local folders are moved to timestamped **backup** folders, never deleted.
- The editor and configuration tools back up files before changing them (e.g. `backups\timing-editor`, `backups\player-count-editor`, `backups\firebase-connection`).
- "Update Entire Project to GitHub" never force-pushes.
- **Login and Connect Firebase** never needs (and never stores) a service-account key — it uses the standard Firebase CLI browser login.
- Service-account keys, `.env` files, and logs are excluded by `.gitignore`.

---

<a id="troubleshooting"></a>
## Troubleshooting

**PowerShell says scripts are disabled.**
Use the `.cmd` launchers (double-click) rather than running the `.ps1` files directly — they already pass `-ExecutionPolicy Bypass` for that one process.

**The GitHub login doesn't open.**
Run the installer again and complete the GitHub authorization in the browser when prompted, then return to the window.

**Firebase login crashes or won't connect.**
Run **Login and Connect Firebase**. The current version ignores the broken portable executable, installs the official `firebase-tools` via npm, safely handles a timed-out check, and then opens the browser login.

**Multiplayer won't start after changing the player count or adding a unit.**
You changed `firestore.rules`, so re-publish it: run **Deploy Firestore Rules**, then **Update Entire Project to GitHub**.

**The local homepage opens to a blank/odd page, or "back" goes nowhere.**
You're on an old install. Re-run **Install Local Quiz** — the newest version shows `UI VERSION 7 - LOCAL INDEX + BACK-LINK FIX` and fixes the homepage redirect and the **← Home** link.

**The editor can't find the project.**
Choose the **main** folder (the one containing `index.html`), not the `setup_powershell` subfolder.

**The editor shows no files.**
Turn on **Also show HTML files** — some units keep their logic inline in the HTML.

**The online site didn't update right away.**
GitHub Pages takes a short while to redeploy. Refresh after a minute or two with **Ctrl + F5**.

**An update tool stops with an error.**
It saves a log named `la-quiz-update-error.txt` in Downloads. Use the popup's **Copy details** / **Open error log** button when asking for help.

---

<a id="requirements"></a>
## Requirements

- **Windows 10 or 11** for the double-click toolkit.
- A **web browser** (any modern one).
- **Internet** for the online installer and multiplayer.
- A **GitHub account** — only for the online/GitHub tools.
- A **Google account** — only for Firebase multiplayer.

You do **not** need to install Git, Node.js, or Python yourself; the scripts handle that.
