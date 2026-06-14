# Linear Algebra True or False — Setup Toolkit

This folder contains beginner-friendly Windows PowerShell tools for installing, configuring, and editing the Linear Algebra True or False website.


## Table of contents

- [Double-click launchers](#double-click-launchers)
- [Files in this folder](#files-in-this-folder)
- [Requirements](#requirements)
- [Choose a setup command](#choose-a-setup-command)
  - [Local version — no Firebase](#local-version-no-firebase)
  - [Online version — with Firebase](#online-version-with-firebase)
- [Option 1: Install a local version without Firebase](#option-1-local-installation)
  - [What the local version does](#what-the-local-version-does)
  - [Run the local installer](#run-the-local-installer)
- [Option 2: Create an online GitHub and Firebase version](#option-2-online-installation)
  - [What the online version does](#what-the-online-version-does)
  - [Run the Firebase installer](#run-the-firebase-installer)
  - [GitHub repository step](#github-repository-step)
  - [Firebase configuration step](#firebase-configuration-step)
- [Edit JavaScript using the visual editor](#edit-javascript)
  - [Start the editor](#start-the-editor)
  - [Use the editor](#use-the-editor)
  - [When no JavaScript files appear](#when-no-javascript-files-appear)
  - [Backups](#backups)
  - [Important editing note](#important-editing-note)
- [Change the multiplayer player count](#change-player-count)
- [Edit flashcards and publish to GitHub](#edit-flashcards-and-publish)
  - [Double-click the launcher](#double-click-the-launcher)
  - [Choose and edit a flashcard file](#choose-and-edit-a-flashcard-file)
  - [Publish the change](#publish-the-change)
- [Safety features](#safety-features)
- [Troubleshooting](#troubleshooting)
  - [PowerShell says scripts are disabled](#powershell-scripts-disabled)
  - [GitHub login does not open](#github-login-does-not-open)
  - [The editor cannot find the project](#editor-cannot-find-project)
  - [The editor shows no files](#editor-shows-no-files)
  - [The online website does not update immediately](#website-does-not-update)
  - [Null-valued popup error](#null-valued-popup-error)
  - [`System.Object[]` or `op_Subtraction` error](#object-array-popup-error)
  - [An update script stops](#update-script-stops)

---


<a id="double-click-launchers"></a>
## Double-click launchers

Every PowerShell tool now has a matching `.cmd` launcher. Beginners can double-click the `.cmd` file instead of opening PowerShell and typing a command.

Keep each `.cmd` file in the same folder as its matching `.ps1` file.

| Double-click this file | Runs this PowerShell file | Purpose |
|---|---|---|
| `Setup Launcher.cmd` | `setup.ps1` | Finds the installers and lets you choose a setup version. |
| `Install Local Quiz.cmd` | `setup-new-repo-no-firebase.ps1` | Installs the local, no-Firebase version. |
| `Install Firebase Quiz.cmd` | `setup-new-repo-with-firebase.ps1` | Installs the GitHub and Firebase version. |
| `Edit Quiz JavaScript.cmd` | `edit-quiz-javascript.ps1` | Opens the visual JavaScript and HTML editor. |
| `Change Player Count.cmd` | `change-player-count.ps1` | Opens a visual editor for choosing 2–6 multiplayer players and updates configuration plus Firestore rules. |
| `Edit Flashcards and Publish.cmd` | `edit-flashcards-and-publish.ps1` | Edits a flashcard file and optionally publishes it to GitHub. |
| `Update GitHub Setup Toolkit.cmd` | `update-github-setup-scripts.ps1` | Updates the repository's setup toolkit and main README. |

Windows may show a security prompt the first time a downloaded file is opened. Confirm only when the file came from this toolkit.

---

<a id="files-in-this-folder"></a>
## Files in this folder

| File | Purpose |
|---|---|
| `Setup Launcher.cmd` | Double-click launcher for `setup.ps1`. |
| `setup.ps1` | Optional launcher that can choose between the two installers when both are present. |
| `Install Local Quiz.cmd` | Double-click launcher for the local installer. |
| `setup-new-repo-no-firebase.ps1` | Installs a local, solo-only copy of the website on the computer. No GitHub or Firebase account is required. |
| `Install Firebase Quiz.cmd` | Double-click launcher for the Firebase installer. |
| `setup-new-repo-with-firebase.ps1` | Creates a local copy, connects it to a new GitHub repository, guides the Firebase setup, deploys Firestore rules, and prepares GitHub Pages. |
| `Edit Quiz JavaScript.cmd` | Double-click launcher for the visual JavaScript editor. |
| `Change Player Count.cmd` | Double-click launcher for the 2–6 player configuration editor. |
| `change-player-count.ps1` | Visual tool that updates `multiplayer-config.js`, checks every multiplayer page, and rebuilds `firestore.rules`. |
| `edit-quiz-javascript.ps1` | Opens a visual editor that lets you choose a JavaScript file from a drop-down menu and open it in Notepad. |
| `Edit Flashcards and Publish.cmd` | Double-click launcher for editing a flashcard file and publishing the saved change to GitHub. |
| `edit-flashcards-and-publish.ps1` | Companion PowerShell program used by the double-click launcher. It prepares Git, opens Notepad, creates a backup, and asks before pushing. |
| `Update GitHub Setup Toolkit.cmd` | Double-click launcher for the repository updater. |
| `update-github-setup-scripts.ps1` | Updates the repository setup toolkit and the main README. |
| `README.md` | The guide you are reading. |

<a id="requirements"></a>
## Requirements

- Windows 10 or Windows 11
- An internet connection for either installer
- A web browser
- A GitHub account only for the Firebase/GitHub version
- A Google account only for the Firebase version

You do **not** need to install Python, Node.js, npm, Git, GitHub CLI, or Firebase CLI manually. The setup scripts download only the tools they require.

---


<a id="choose-a-setup-command"></a>
## Step 3 — Choose one setup command

The easiest method is to double-click the matching `.cmd` file. PowerShell commands are also provided as a fallback.

<a id="local-version-no-firebase"></a>
### Local version — no Firebase

Double-click:

```text
Install Local Quiz.cmd
```

Use this when the website should stay on the computer and does not need Firebase or online multiplayer.

PowerShell fallback:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\setup-new-repo-no-firebase.ps1"
```

<a id="online-version-with-firebase"></a>
### Online version — with Firebase

Double-click:

```text
Install Firebase Quiz.cmd
```

Use this when the website needs GitHub, Firebase, Firestore, or multiplayer features.

PowerShell fallback:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\setup-new-repo-with-firebase.ps1"
```

Both commands automatically use the current Windows user's profile through `$env:USERPROFILE`, so the username does not need to be typed manually.

---

<a id="option-1-local-installation"></a>
## Option 1: Install a local version without Firebase

Use this option when the website should stay on the computer and does not need online multiplayer.

<a id="what-the-local-version-does"></a>
### What this version does

- Finds the current Windows user automatically.
- Asks where the website should be stored.
- Downloads a fresh copy of the website.
- Removes Firebase, multiplayer, and audio features.
- Creates a desktop shortcut.
- Opens the website locally.
- Does not ask for a GitHub link.
- Does not require GitHub or Firebase login.

<a id="run-the-local-installer"></a>
### Run it

Place `setup-new-repo-no-firebase.ps1` in Downloads and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\setup-new-repo-no-firebase.ps1"
```

Follow the popup windows. Choose the parent folder where the local website should be installed.

The complete website remains on the computer. The desktop shortcut opens `index.html`.

---

<a id="option-2-online-installation"></a>
## Option 2: Create an online GitHub and Firebase version

Use this option when the website needs a GitHub repository, GitHub Pages, Firestore, or multiplayer features.

<a id="what-the-online-version-does"></a>
### What this version does

- Downloads portable Git when Git is missing.
- Downloads portable GitHub CLI when it is missing.
- Downloads the standalone Firebase CLI when it is missing.
- Opens the GitHub browser login.
- Opens the page for creating a new GitHub repository.
- Shows a popup where the new repository link is pasted.
- Downloads a fresh website copy.
- Opens the Firebase browser login.
- Opens Firebase Console.
- Shows a large popup where the Firebase web configuration is pasted.
- Updates the website configuration.
- Deploys Firestore rules.
- Pushes the website to GitHub.
- Attempts to enable GitHub Pages.
- Keeps a complete local copy in Downloads.

<a id="run-the-firebase-installer"></a>
### Run it

Place `setup-new-repo-with-firebase.ps1` in Downloads and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\setup-new-repo-with-firebase.ps1"
```

<a id="github-repository-step"></a>
### GitHub repository step

When the script opens GitHub:

1. Create a new **empty** public repository.
2. Do not add a README, `.gitignore`, or license on the GitHub creation page.
3. Copy the full repository link from the browser.
4. Paste it into the setup popup.
5. Click **Continue**.

Example:

```text
https://github.com/your-name/linear-algebra-quiz
```

<a id="firebase-configuration-step"></a>
### Firebase configuration step

In Firebase Console:

1. Open **Project settings**.
2. Stay on the **General** tab.
3. Scroll to **Your apps**.
4. Select or create the web app.
5. Under **SDK setup and configuration**, select **Config**.
6. Copy the entire `firebaseConfig` block.
7. Paste it into the large setup popup.
8. Click **Use this config**.

Paste only the normal Firebase web configuration. Never paste a service-account private key into the website or upload one to GitHub.

---

<a id="change-player-count"></a>
## Change the multiplayer player count

1. Double-click `Change Player Count.cmd`.
2. Confirm the automatically detected project folder.
3. Choose 2, 3, 4, 5, or 6 players.
4. Click **Apply player count**.
5. Run `Deploy Firestore Rules.cmd`, then `Update Entire Project to GitHub.cmd`.

The command saves backups, writes the shared `multiplayer-config.js` setting, verifies the multiplayer pages, and regenerates rules for Player 1 through Player 6. Every required player must join and press **I am ready** before the match starts.

---

<a id="edit-javascript"></a>
## Edit JavaScript using the visual editor

The `edit-quiz-javascript.ps1` file is designed for beginners.

<a id="start-the-editor"></a>
### Start the editor

When the editor is inside the project's `setup_powershell` folder, it usually detects the main project folder automatically.

Right-click `edit-quiz-javascript.ps1` and choose **Run with PowerShell**, or run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\edit-quiz-javascript.ps1"
```

<a id="use-the-editor"></a>
### Use the editor

1. Choose the project folder, or drag and drop the project folder onto the blue drop area.
2. Select a JavaScript file from the drop-down menu.
3. Leave **Create a timestamped backup** checked.
4. Click **Open in Notepad**.
5. Make the change in Notepad.
6. Press **Ctrl+S** to save.
7. Refresh the website in the browser to see the change.

You can also drag and drop a `.js` file directly onto the editor.

<a id="when-no-javascript-files-appear"></a>
### When no JavaScript files appear

Some versions of the website keep JavaScript inside HTML pages instead of separate `.js` files.

Turn on:

```text
Also show HTML files
```

The drop-down will then include `.html` files as well.

<a id="backups"></a>
### Backups

Before opening a file, the editor creates a backup under:

```text
backups\javascript-editor\<date-and-time>\
```

The original folder structure is preserved inside the backup.

The backup feature can be turned off, but keeping it enabled is recommended.

<a id="important-editing-note"></a>
### Important

The editor changes the **local files on the computer**. It does not automatically upload those edits to GitHub.

To update an online website after editing, commit and push the changed files using Git, GitHub Desktop, or GitHub's website.

---


<a id="edit-flashcards-and-publish"></a>
## Edit flashcards and publish to GitHub

Use these two files together:

```text
Edit Flashcards and Publish.cmd
edit-flashcards-and-publish.ps1
```

The `.cmd` file is the one to double-click. It opens PowerShell and runs the companion `.ps1` file automatically.

The tool is preconfigured for:

```text
https://github.com/arandeprandhawa-oss/linear_algebra_true_or_false
```

It downloads portable Git and GitHub CLI when needed, guides the GitHub browser login, downloads or reuses a local repository copy, creates a backup, opens the selected flashcard file in Notepad, and asks before committing and pushing.

<a id="double-click-the-launcher"></a>
### Double-click the launcher

Keep both files in the same folder, then double-click:

```text
Edit Flashcards and Publish.cmd
```

Do not move the `.cmd` file away from its companion `.ps1` file.

<a id="choose-and-edit-a-flashcard-file"></a>
### Choose and edit a flashcard file

1. Sign into GitHub in the browser when requested.
2. Choose an HTML, JavaScript, or JSON file from the file window.
3. In Notepad, press **Ctrl+F** to find the question you want to change.
4. Edit the flashcard.
5. Press **Ctrl+S** to save.
6. Return to the PowerShell helper and click **OK**.

A timestamped backup is created under:

```text
backups\flashcard-editor\<date-and-time>\
```

The backup is not staged for the GitHub commit.

<a id="publish-the-change"></a>
### Publish the change

After Notepad is saved, the tool checks the selected file.

- Choose **Yes** when asked to upload it.
- Enter a short GitHub commit message, or keep the suggested message.
- The tool stages only the selected flashcard file.
- It pulls the newest GitHub changes safely.
- It commits and pushes to `main`.
- It opens the changed file on GitHub when finished.

The tool never force-pushes. Choosing **No** keeps the saved edit only on the computer.

---

<a id="safety-features"></a>
## Safety features

- Existing local folders are moved to timestamped backup folders instead of being deleted.
- Setup scripts do not use force push.
- The editor backs up files before opening them.
- Firebase web configuration is placed in browser code, but Firestore access must still be protected with Firestore Security Rules.
- Service-account keys must never be placed in browser files or committed to GitHub.

---

<a id="troubleshooting"></a>
## Troubleshooting

<a id="powershell-scripts-disabled"></a>
### PowerShell says scripts are disabled

Run the script using the provided command with:

```powershell
-ExecutionPolicy Bypass
```

This applies only to that PowerShell process.

<a id="github-login-does-not-open"></a>
### GitHub login does not open

Run the setup script again and press Enter when it asks to open the browser login. Complete the GitHub authorization in the browser, then return to PowerShell.

<a id="editor-cannot-find-project"></a>
### The editor cannot find the project

Use **Choose project folder** and select the main folder containing `index.html`.

Do not select only the `setup_powershell` folder.

<a id="editor-shows-no-files"></a>
### The editor shows no files

Turn on **Also show HTML files**. The website may use inline JavaScript inside its HTML pages.

<a id="website-does-not-update"></a>
### The online website does not update immediately

GitHub Pages deployment can take a short time. Refresh the page after the deployment finishes.




### A setup popup still reports a null-valued expression

Older polished popup versions used Windows event handlers that could lose their textbox reference in Windows PowerShell 5.1.

The current installers no longer use those event handlers for setup input windows. Confirm the installer displays:

```text
UI VERSION 5 - STABLE POPUPS WITHOUT EVENT HANDLERS
```

The new input windows use normal text boxes and standard **Continue** and **Cancel** buttons. Paste with **Ctrl+V**.

<a id="null-valued-popup-error"></a>
### A popup says `You cannot call a method on a null-valued expression`

This was caused by an older Windows PowerShell 5.1 popup handler losing its reference to a textbox or button when the window opened.

Replace the old scripts with the newest versions. The corrected updater displays:

```text
UI VERSION 6 - WINDOWS EVENT HANDLER FIX
```

This is a popup-code compatibility issue. It is not caused by the GitHub repository link or the user's GitHub account.

<a id="object-array-popup-error"></a>
### A popup reports `System.Object[]` or `op_Subtraction`

This means an older copy of the polished-dialog scripts is still being run.

Replace the old files with the newest versions and confirm the updater shows:

```text
UI VERSION 5 - POWERSHELL 5.1 SIZE FIX
```

The corrected scripts use a Windows PowerShell 5.1-safe method for calculating popup sizes.

<a id="update-script-stops"></a>
### An update script stops

The updater saves an error log named:

```text
la-quiz-update-error.txt
```

in Downloads. Use the popup's **Copy details** or **Open error log** button when asking for help.

## Firebase login/project repair

Run **Login and Connect Firebase.cmd** when a copied/downloaded project is missing
`.firebaserc`, when the Firebase CLI is not installed, or when the saved Firebase
login has expired. The command:

- finds the quiz folder automatically;
- downloads the official Firebase CLI when needed;
- opens the Google/Firebase browser login when needed;
- detects the project ID from the website's existing `firebaseConfig`;
- lets you choose from your Firebase projects only when automatic detection is
  not possible;
- saves `.firebaserc` and `firebase.json` for future deployments.

**Deploy Firestore Rules.cmd** now launches the same connection check
automatically before every deployment.
