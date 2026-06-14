# Linear Algebra True or False

A beginner-friendly true-or-false flashcard website for studying linear algebra.

**Live website:**  
https://arandeprandhawa-oss.github.io/linear_algebra_true_or_false/

This repository also includes Windows setup, editing, backup, Firebase, and GitHub update tools.

---

## Table of contents

- [Quick start](#quick-start)
- [Important rule: extract the ZIP first](#important-rule-extract-the-zip-first)
- [Files in `setup_powershell`](#files-in-setup_powershell)
- [Which file should I double-click?](#which-file-should-i-double-click)
- [Install the local version](#install-the-local-version)
- [Install the Firebase and GitHub version](#install-the-firebase-and-github-version)
- [Edit flashcards](#edit-flashcards)
- [Edit JavaScript files](#edit-javascript-files)
- [Update the entire project to GitHub](#update-the-entire-project-to-github)
- [Update only the setup toolkit](#update-only-the-setup-toolkit)
- [How the `.cmd` and `.ps1` files work](#how-the-cmd-and-ps1-files-work)
- [Backups](#backups)
- [Firebase configuration](#firebase-configuration)
- [GitHub Pages](#github-pages)
- [Safety features](#safety-features)
- [Troubleshooting](#troubleshooting)

---

## Quick start

### Use the live website

Open:

https://arandeprandhawa-oss.github.io/linear_algebra_true_or_false/

### Install or edit the project on Windows

1. Download the repository or toolkit ZIP.
2. Right-click the ZIP.
3. Choose **Extract All**.
4. Open the extracted folder.
5. Open the `setup_powershell` folder.
6. Double-click the `.cmd` file for the task you want to perform.

---

## Important rule: extract the ZIP first

Do **not** run a `.cmd` file while viewing files inside the ZIP preview.

Each `.cmd` launcher needs its matching `.ps1` file beside it.

Example:

```text
Edit Flashcards.cmd
edit-flashcards.ps1
```

Keep both files in the same folder.

If the `.ps1` file is missing, the launcher will show:

```text
The companion PowerShell file was not found
```

---

## Files in `setup_powershell`

| File | Purpose |
|---|---|
| `Setup Launcher.cmd` | Opens the main setup launcher. |
| `setup.ps1` | Lets the user choose between the local and Firebase installers. |
| `Install Local Quiz.cmd` | Double-click launcher for the local-only installer. |
| `setup-new-repo-no-firebase.ps1` | Installs a local copy that does not require GitHub or Firebase. |
| `Install Firebase Quiz.cmd` | Double-click launcher for the Firebase and GitHub installer. |
| `setup-new-repo-with-firebase.ps1` | Creates an online version connected to GitHub, Firebase, Firestore, and GitHub Pages. |
| `Edit Flashcards.cmd` | Double-click launcher for the beginner flashcard editor. |
| `edit-flashcards.ps1` | Finds the project automatically and edits only flashcard `.js` files. |
| `Edit Quiz JavaScript.cmd` | Double-click launcher for the general JavaScript editor. |
| `edit-quiz-javascript.ps1` | Opens JavaScript files through a visual file-selection interface. |
| `Update Entire Project to GitHub.cmd` | Double-click launcher that uploads every reviewed, non-ignored project change. |
| `update-entire-project-to-github.ps1` | Finds the Git repository, reviews all changes, commits, and pushes them to `main`. |
| `Update GitHub Setup Toolkit.cmd` | Double-click launcher that updates only the files inside `setup_powershell`. |
| `update-github-setup-scripts.ps1` | Validates and uploads the setup toolkit to GitHub. |
| `README.md` | This guide. |

---

## Which file should I double-click?

### Install a local version

```text
Install Local Quiz.cmd
```

### Install an online Firebase version

```text
Install Firebase Quiz.cmd
```

### Choose between local and Firebase setup

```text
Setup Launcher.cmd
```

### Edit flashcard questions and answers

```text
Edit Flashcards.cmd
```

### Edit general JavaScript files

```text
Edit Quiz JavaScript.cmd
```

### Upload every project change to GitHub

```text
Update Entire Project to GitHub.cmd
```

### Update only the setup and editor tools

```text
Update GitHub Setup Toolkit.cmd
```

---

## Install the local version

Use the local installer when the quiz should stay on the computer and does not need online multiplayer.

Double-click:

```text
Install Local Quiz.cmd
```

The installer:

- Finds the current Windows user automatically.
- Downloads the website.
- Asks where the local quiz should be stored.
- Removes Firebase and online multiplayer requirements.
- Creates a local website folder.
- Creates shortcuts when supported.
- Opens the website on the computer.
- Does not require a GitHub account.
- Does not require a Firebase account.

The local version opens from the computer using `index.html`.

---

## Install the Firebase and GitHub version

Use the Firebase installer when the quiz needs:

- GitHub hosting
- GitHub Pages
- Firebase
- Firestore
- Online multiplayer
- Shared online data

Double-click:

```text
Install Firebase Quiz.cmd
```

The installer can download the tools it needs, including:

- Portable Git
- GitHub CLI
- Firebase CLI

It then guides the user through:

1. GitHub login
2. GitHub repository creation
3. Repository link entry
4. Firebase login
5. Firebase project setup
6. Firebase web configuration entry
7. Firestore rule deployment
8. GitHub push
9. GitHub Pages setup

### GitHub repository step

Create a new empty public repository.

Do not add these items on the repository creation page:

- README
- `.gitignore`
- License

Copy the repository URL and paste it into the setup window.

Example:

```text
https://github.com/your-name/linear-algebra-quiz
```

---

## Edit flashcards

Double-click:

```text
Edit Flashcards.cmd
```

The flashcard editor has two modes:

### Local only

Use this mode when editing a local copy that is not connected to GitHub.

The editor:

- Finds the quiz project automatically.
- Shows only flashcard `.js` files.
- Creates a timestamped backup.
- Opens the selected file in Notepad.
- Saves the change on the computer.
- Can open the local website for testing.

### Firebase + GitHub

Use this mode when the project is connected to GitHub.

The editor:

- Finds the Git repository automatically.
- Shows only flashcard `.js` files.
- Creates a timestamped backup.
- Opens the selected file in Notepad.
- Checks whether the file changed.
- Asks before committing.
- Pushes only the selected flashcard file to GitHub.
- Never force-pushes.

### Flashcard files shown in the editor

The editor is intentionally limited to `.js` files.

Typical files include:

```text
etapes\etape1.js
etapes\etape2.js
etapes\etape3.js
etapes\etape4.js
etapes\registry.js
```

HTML files such as these are not shown:

```text
index.html
solo.html
solo1.html
solo3.html
solo4.html
```

### How to edit a flashcard

1. Open `Edit Flashcards.cmd`.
2. Choose **Local only** or **Firebase + GitHub**.
3. Wait for automatic project detection.
4. Select a `.js` file.
5. Confirm the selected-file details appear.
6. Click **Edit in Notepad**.
7. Press **Ctrl+F** in Notepad to find a question.
8. Make the change.
9. Press **Ctrl+S**.
10. Return to the editor.
11. Confirm the next step.

---

## Edit JavaScript files

Double-click:

```text
Edit Quiz JavaScript.cmd
```

This is the general JavaScript editor.

It includes:

- Automatic project detection
- Manual folder selection
- A JavaScript file drop-down
- File information
- Timestamped backups
- Notepad editing
- Project-folder access

Use this editor for broader JavaScript changes that are not limited to flashcard content.

---

## Update the entire project to GitHub

Double-click:

```text
Update Entire Project to GitHub.cmd
```

This tool is for uploading **all project changes**, not only the setup tools.

It:

- Finds the local Git repository automatically.
- Lets the user choose the repository folder when needed.
- Signs in to GitHub.
- Checks the current branch.
- Lists every changed file.
- Includes added files.
- Includes modified files.
- Includes deleted files.
- Includes renamed files.
- Warns about possible secret or private-key files.
- Requires the user to review the complete list.
- Uses `git add -A`.
- Creates one commit.
- Pulls safely before pushing.
- Pushes to the `main` branch.
- Never force-pushes.

Files excluded by `.gitignore` are not uploaded.

### Use this tool when

- Flashcards were changed.
- HTML was changed.
- JavaScript was changed.
- Images were added or removed.
- A file was renamed.
- Multiple project folders were changed.
- The whole repository should be synchronized with GitHub.

### Review before confirming

Before uploading, check that the list does not include:

- `.env`
- Private keys
- Service-account JSON files
- Password files
- Secret credentials
- Personal files

---

## Update only the setup toolkit

Double-click:

```text
Update GitHub Setup Toolkit.cmd
```

This updater changes only the tools inside:

```text
setup_powershell
```

It does not upload every project file.

It validates the PowerShell files, downloads a fresh repository copy, replaces the toolkit files, commits the changes, and pushes them to GitHub.

The repaired toolkit updater displays:

```text
VERSION 11 - SHARED FLASHCARD EDITOR STATE FIX
```

Use this updater when changing:

- Installers
- Editors
- `.cmd` launchers
- PowerShell scripts
- Setup tools

Use **Update Entire Project to GitHub.cmd** instead when the rest of the repository must also be uploaded.

---

## How the `.cmd` and `.ps1` files work

The `.cmd` file is the beginner-friendly launcher.

The `.ps1` file contains the actual PowerShell program.

Example:

```text
Edit Flashcards.cmd
edit-flashcards.ps1
```

The repaired `.cmd` launchers:

- Find their own folder.
- Find the matching `.ps1` file.
- Use Windows PowerShell.
- Use `-ExecutionPolicy Bypass`.
- Use `-STA` for Windows Forms interfaces.
- Keep the window open when an error occurs.
- Display a useful message when the companion file is missing.

Do not rename only one file in a pair.

---

## Backups

The editing tools create backups before opening files.

Typical backup folders include:

```text
backups\local-flashcard-editor\<date-and-time>\
```

```text
backups\firebase-flashcard-editor\<date-and-time>\
```

```text
backups\javascript-editor\<date-and-time>\
```

The original folder structure is preserved inside each backup.

Keep backup creation enabled unless there is a specific reason to turn it off.

---

## Firebase configuration

In Firebase Console:

1. Open **Project settings**.
2. Stay on the **General** tab.
3. Scroll to **Your apps**.
4. Select or create the web app.
5. Find **SDK setup and configuration**.
6. Select **Config**.
7. Copy the complete `firebaseConfig` object.
8. Paste it into the installer window.

Example format:

```javascript
const firebaseConfig = {
  apiKey: "...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "..."
};
```

The normal Firebase web configuration is designed for browser applications.

Never paste or upload:

- Firebase Admin SDK private keys
- Service-account credentials
- Private certificate files
- Passwords

Firestore access must still be protected with proper Firestore Security Rules.

---

## GitHub Pages

The public website is:

https://arandeprandhawa-oss.github.io/linear_algebra_true_or_false/

After pushing changes, GitHub Pages may take a short time to redeploy.

When a change is not visible immediately:

1. Open the repository on GitHub.
2. Open the **Actions** tab.
3. Wait for the Pages deployment to finish.
4. Refresh the website.
5. Use **Ctrl+F5** for a full browser refresh.

---

## Safety features

The toolkit includes these safeguards:

- No force push
- Review screen before uploading the entire project
- Automatic backups before editing
- PowerShell syntax checks before toolkit updates
- Secret-file warnings in the full-project updater
- Fresh repository copies during toolkit updates
- Timestamped backup folders instead of automatic deletion
- Git pull and rebase before full-project pushes
- Clear confirmation windows before publishing

---

## Troubleshooting

### A `.cmd` file does not open

Confirm that:

1. The ZIP was fully extracted.
2. The `.cmd` and matching `.ps1` are together.
3. The files were not renamed separately.
4. The file is being run from the extracted folder, not the ZIP preview.

Example required pair:

```text
Edit Flashcards.cmd
edit-flashcards.ps1
```

---

### The launcher says the companion PowerShell file was not found

The matching `.ps1` is missing or in another folder.

Move the two matching files into the same folder.

---

### PowerShell says scripts are disabled

Use the provided `.cmd` launcher.

The launchers already use:

```powershell
-ExecutionPolicy Bypass
```

This does not permanently change the computer's execution policy.

---

### The editor cannot find the project

Click:

```text
Choose a different folder
```

Select the main quiz folder containing:

```text
index.html
```

Do not select only:

```text
setup_powershell
```

---

### The editor finds the folder but shows no JavaScript files

Confirm the main folder contains JavaScript files such as:

```text
etapes\etape1.js
```

Then click:

```text
Refresh files
```

---

### The flashcard dropdown shows HTML files

Replace the editor with the newest version.

The current flashcard editor shows only `.js` files.

---

### The selected file appears, but Edit in Notepad does not activate

Use the current repaired editor.

The shared-state repair is identified by the setup-toolkit updater version:

```text
VERSION 11 - SHARED FLASHCARD EDITOR STATE FIX
```

Close the old editor completely before opening the new one.

---

### Notepad does not open

Confirm that a valid `.js` file is selected and the selected-file details are visible.

The editor uses Windows Notepad directly.

---

### GitHub login does not open

Run the tool again.

When PowerShell asks, press Enter to begin the browser login.

Complete the login in the browser, then return to PowerShell.

---

### The full-project updater says nothing changed

Git does not see any modified, added, deleted, or renamed non-ignored files.

The local repository already matches its current committed state.

---

### The full-project updater cannot find the repository

Choose the repository folder manually.

It must contain the hidden folder:

```text
.git
```

A normal ZIP download of a GitHub repository does not contain `.git`.

Use a cloned repository when pushing changes back to GitHub.

---

### A possible private file warning appears

Review the file list carefully.

Do not upload:

```text
.env
```

```text
service-account.json
```

```text
firebase-adminsdk-*.json
```

```text
*.pem
```

```text
*.p12
```

```text
*.pfx
```

Cancel the update when unsure.

---

### GitHub Pages does not update immediately

Wait for GitHub Actions to finish the deployment, then refresh the live website.

---

### An updater stops with a PowerShell syntax error

Use the newest complete toolkit ZIP and extract every file before running the updater.

The setup-toolkit updater checks all `.ps1` files before pushing them.

---

## Repository structure

A simplified view of the project:

```text
linear_algebra_true_or_false/
├── index.html
├── solo.html
├── solo1.html
├── solo3.html
├── solo4.html
├── etapes/
│   ├── etape1.js
│   ├── etape2.js
│   ├── etape3.js
│   ├── etape4.js
│   └── registry.js
├── setup_powershell/
│   ├── Setup Launcher.cmd
│   ├── setup.ps1
│   ├── Install Local Quiz.cmd
│   ├── setup-new-repo-no-firebase.ps1
│   ├── Install Firebase Quiz.cmd
│   ├── setup-new-repo-with-firebase.ps1
│   ├── Edit Flashcards.cmd
│   ├── edit-flashcards.ps1
│   ├── Edit Quiz JavaScript.cmd
│   ├── edit-quiz-javascript.ps1
│   ├── Update Entire Project to GitHub.cmd
│   ├── update-entire-project-to-github.ps1
│   ├── Update GitHub Setup Toolkit.cmd
│   ├── update-github-setup-scripts.ps1
│   └── README.md
└── firestore.rules
```

---

## Final reminder

Use:

```text
Edit Flashcards.cmd
```

to edit flashcard `.js` files.

Use:

```text
Update Entire Project to GitHub.cmd
```

to upload all reviewed project changes.

Use:

```text
Update GitHub Setup Toolkit.cmd
```

to update only the Windows setup and editor tools.
