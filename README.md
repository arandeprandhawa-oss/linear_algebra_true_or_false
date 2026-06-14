# Linear Algebra: True or False

A web-based flashcard quiz for **MATH 2210 Applied Linear Algebra**. Practise the true/false concept checks for each unit, either **solo** (with spaced repetition) or **head-to-head 1v1** against a friend using a shared match code.

**Live website:** <https://arandeprandhawa-oss.github.io/linear_algebra_true_or_false/>

---

## Table of contents

- [What this is](#what-this-is)
- [How the site is organised](#how-the-site-is-organised)
- [The setup toolkit (double-click tools)](#the-setup-toolkit)
- [Tutorial 1 — Install a local copy (no internet needed)](#tutorial-1-local)
- [Tutorial 2 — Create your own online copy (GitHub + Firebase)](#tutorial-2-online)
- [Tutorial 3 — Edit the quiz questions](#tutorial-3-edit-questions)
- [Tutorial 4 — Edit the flashcard data](#tutorial-4-edit-flashcards)
- [Tutorial 5 — Add a new unit](#tutorial-5-add-unit)
- [Tutorial 6 — Adjust the timers](#tutorial-6-timing)
- [Tutorial 7 — Push your changes to GitHub](#tutorial-7-push)
- [Tutorial 8 — Update the toolkit itself](#tutorial-8-update-toolkit)
- [Project file layout](#project-file-layout)
- [Safety features](#safety-features)
- [Troubleshooting](#troubleshooting)

---

<a id="what-this-is"></a>
## What this is

This repository holds two things:

1. **The website** — plain HTML/CSS/JavaScript flashcard pages. No build step, no framework. Open `index.html` in a browser and it works.
2. **A setup toolkit** — a folder of friendly double-click tools (in `setup_powershell/`) for installing, editing, and publishing the site on Windows. You never have to type a single command.

The online version uses **Firebase / Firestore** for the 1v1 multiplayer matches. The local version strips that out and runs entirely offline as solo-only.

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

- A **1v1 lobby** page (`index.html`, `etape1.html`, `etape3.html`, `etape4.html`) — create or join a match, or jump to solo.
- A **solo** page (`solo.html`, `solo1.html`, `solo3.html`, `solo4.html`) — practise on your own with spaced repetition.

A tab bar at the top of every page lets you switch units. The question/answer content for each unit lives in `etapes/etape1.js` … `etape4.js`, and the unit list itself is defined in `etapes/registry.js`.

> **Page-to-unit mapping (worth knowing):** `index.html` = Unit 2's 1v1 page, `solo.html` = Unit 2's solo page. `solo1.html` = Unit 1, `solo3.html` = Unit 3, `solo4.html` = Unit 4. The `1` / `3` / `4` in the filename is the unit number; the unnumbered files are Unit 2.

---

<a id="the-setup-toolkit"></a>
## The setup toolkit

Everything lives in the **`setup_powershell`** folder. Each tool is a `.cmd` file you **double-click** — it runs the matching PowerShell script for you and handles the security prompts automatically.

| Double-click this | What it does |
|---|---|
| **Install Local Quiz** | Installs an offline, solo-only copy on this computer. No accounts needed. |
| **Install Firebase Quiz** | Creates a full online copy with GitHub Pages + Firebase multiplayer. |
| **Setup Launcher** | If both installers are present, lets you pick local vs. online. |
| **Edit Quiz JavaScript** | Visual editor to open and edit the quiz logic / question files. |
| **Edit Flashcards** | Visual editor for the flashcard vocabulary data. |
| **Add New Unit** | Creates a brand-new unit and wires it into the registry, pages, and tabs automatically. |
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

Use this to publish the full site, with working 1v1 multiplayer, on the web.

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

---

<a id="tutorial-3-edit-questions"></a>
## Tutorial 3 — Edit the quiz questions

1. Double-click **Edit Quiz JavaScript**.
2. Choose your project folder (the one containing `index.html`), or drag-and-drop it onto the blue area.
3. Pick a file from the drop-down — the unit data lives in `etapes/etape1.js` … `etape4.js`.
4. Leave **Create a timestamped backup** checked.
5. Click **Open in Notepad**, make your edit, then **Ctrl+S** to save.
6. Refresh the website to see the change.

If the drop-down looks empty, turn on **Also show HTML files** — some logic lives inline in the HTML pages.

---

<a id="tutorial-4-edit-flashcards"></a>
## Tutorial 4 — Edit the flashcard data

1. Double-click **Edit Flashcards**.
2. Point it at your project folder.
3. Edit the vocabulary/question entries through the editor.
4. Save. A timestamped backup is created automatically before any change.

---

<a id="tutorial-5-add-unit"></a>
## Tutorial 5 — Add a new unit

This builds a whole new unit and connects it everywhere for you — no hand-editing of HTML or the registry.

1. Double-click **Add New Unit**.
2. The project is detected automatically. Fill in:
   - **Unit label** (e.g. "Unit 5").
   - **Topic / subtitle** (e.g. "Orthogonality & Least Squares").
   - **Tab badge** (the small number on the tab).
   - Optionally, pick an existing unit to **copy its questions** as a starting point.
3. Click **Create unit**.

It creates the unit's data file (`etapes/etapeN.js`), adds it to `registry.js`, creates the solo page (and the 1v1 page too, if you're on the online layout), and refreshes the unit tabs and navigation on every page. Then use **Edit Quiz JavaScript** to fill in the real questions.

> It detects your layout automatically: a local (solo-only) install gets just a solo page; an online install gets both the 1v1 and solo pages.

---

<a id="tutorial-6-timing"></a>
## Tutorial 6 — Adjust the timers

This tool lets you **type** the timing values for the quiz. The project is detected automatically.

1. Double-click **Adjust Timing and Length**.
2. Type the values you want:
   - **Auto-advance delay — Solo practice**: after you answer, how long the Again / Hard / Good / Easy panel stays before the card auto-advances with the suggested rating (seconds).
   - **Learning step 1 — the "Again" interval**: when a learning card is rated Again, how soon it returns (minutes). This is the time shown on the Again button.
   - **Learning step 2 — the "Good" interval**: the next learning step before a card graduates (minutes). This is the time shown on the Good button.
   - **Auto-advance delay — 1v1 game**: on the head-to-head pages, how long the answer/explanation stays before the next card (seconds). The countdown bar stays in sync automatically.
3. Click **Apply to all pages**.

It writes the solo values to every `solo*.html` page and the 1v1 value to every game page, saving a backup of each under `backups\timing-editor` first. Refresh the site to see the effect.

> A local (solo-only) install has the solo timing controls; an online install has both the solo and the 1v1 controls. The tool fills the boxes with the current values so you can see what they are before changing them.

---

<a id="tutorial-7-push"></a>
## Tutorial 7 — Push your changes to GitHub

After editing anything locally, the changes are only on your computer until you push them.

1. Double-click **Update Entire Project to GitHub**.
2. Review the list of changed files it shows you.
3. Confirm. It runs `git add -A`, makes one commit, and pushes to `main`.

That single action publishes everything — edited questions, flashcards, new units, timing changes, and any toolkit fixes. GitHub Pages redeploys automatically a moment later.

> This tool does a normal push (no force-push), so it's safe to run any time you've made changes. If the folder isn't connected to GitHub yet (for example a fresh copy from the ZIP), it detects the project by its files and connects it for you automatically.

---

<a id="tutorial-8-update-toolkit"></a>
## Tutorial 8 — Update the toolkit itself

If you only changed files inside `setup_powershell` and want to publish just those:

1. Double-click **Update GitHub Setup Toolkit**.
2. It stages, commits, and pushes only the toolkit folder to `main`.

For most cases, **Update Entire Project to GitHub** (Tutorial 7) already covers this too.

---

<a id="project-file-layout"></a>
## Project file layout

```
linear_algebra_true_or_false/
├── index.html              1v1 lobby — Unit 2 (and the site entry point)
├── etape1.html             1v1 lobby — Unit 1
├── etape3.html             1v1 lobby — Unit 3
├── etape4.html             1v1 lobby — Unit 4
├── solo.html               Solo practice — Unit 2
├── solo1.html              Solo practice — Unit 1
├── solo3.html              Solo practice — Unit 3
├── solo4.html              Solo practice — Unit 4
├── script-simulations.html Interactive terminal simulator
├── firestore.rules         Firestore security rules (online version)
├── etapes/
│   ├── registry.js         The list of units
│   ├── etape1.js           Unit 1 questions
│   ├── etape2.js           Unit 2 questions
│   ├── etape3.js           Unit 3 questions
│   └── etape4.js           Unit 4 questions
└── setup_powershell/       The double-click setup toolkit
```

---

<a id="safety-features"></a>
## Safety features

- Existing local folders are moved to timestamped **backup** folders, never deleted.
- The editors back up files before opening them.
- "Update Entire Project to GitHub" never force-pushes.
- Service-account keys, `.env` files, and logs are excluded by `.gitignore`.

---

<a id="troubleshooting"></a>
## Troubleshooting

**PowerShell says scripts are disabled.**
Use the `.cmd` launchers (double-click) rather than running the `.ps1` files directly — they already pass `-ExecutionPolicy Bypass` for that one process.

**The GitHub login doesn't open.**
Run the installer again and complete the GitHub authorization in the browser when prompted, then return to the window.

**The local homepage opens to a blank/odd page, or "back" goes nowhere.**
You're on an old install. Re-run **Install Local Quiz** — the newest version shows `UI VERSION 7 - LOCAL INDEX + BACK-LINK FIX` and fixes the homepage redirect and the **← Home** link.

**The editor can't find the project.**
Choose the **main** folder (the one containing `index.html`), not the `setup_powershell` subfolder.

**The editor shows no files.**
Turn on **Also show HTML files** — some units keep their logic inline in the HTML.

**The online site didn't update right away.**
GitHub Pages takes a short while to redeploy. Refresh after a minute or two.

**An update tool stops with an error.**
It saves a log named `la-quiz-update-error.txt` in Downloads. Use the popup's **Copy details** / **Open error log** button when asking for help.
