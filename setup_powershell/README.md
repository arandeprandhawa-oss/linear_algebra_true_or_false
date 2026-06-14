# Linear Algebra True or False — Setup Toolkit

This folder contains beginner-friendly Windows PowerShell tools for installing, configuring, and editing the Linear Algebra True or False website.


## Table of contents

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

<a id="files-in-this-folder"></a>
## Files in this folder

| File | Purpose |
|---|---|
| `setup.ps1` | Optional launcher that can choose between the two installers when both are present. |
| `setup-new-repo-no-firebase.ps1` | Installs a local, solo-only copy of the website on the computer. No GitHub or Firebase account is required. |
| `setup-new-repo-with-firebase.ps1` | Creates a local copy, connects it to a new GitHub repository, guides the Firebase setup, deploys Firestore rules, and prepares GitHub Pages. |
| `edit-quiz-javascript.ps1` | Opens a visual editor that lets you choose a JavaScript file from a drop-down menu and open it in Notepad. |
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

Open PowerShell, then copy and run **one** of the following commands.

<a id="local-version-no-firebase"></a>
### Local version — no Firebase

Use this when the website should stay on the computer and does not need Firebase or online multiplayer.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\setup-new-repo-no-firebase.ps1"
```

<a id="online-version-with-firebase"></a>
### Online version — with Firebase

Use this when the website needs GitHub, Firebase, Firestore, or multiplayer features.

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
