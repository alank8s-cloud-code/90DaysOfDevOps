# Git Commands Reference

## 1. Setup & Configuration

| Command | What it does | Example |
|---|---|---|
| `git --version` | Shows the installed Git version. | `git --version` |
| `git config --global user.name` | Sets your Git username globally. | `git config --global user.name "alank8s cloud"` |
| `git config --global user.email` | Sets your Git email globally. | `git config --global user.email "alank8s.cloud@example.com"` |
| `git config --global --list` | Displays your global Git configuration. | `git config --global --list` |

---

## 2. Basic Workflow

| Command | What it does | Example |
|---|---|---|
| `git init` | Initializes the current directory as a Git repository. | `git init` |
| `git status` | Shows the current state of the working directory and staging area. | `git status` |
| `git add` | Moves changes from the Working Directory to the Staging Area. | `git add git-commands.md` |
| `git add .` | Stages all changes in the current directory. | `git add .` |
| `git commit` | Saves staged changes as a new commit in the repository. | `git commit -m "Add Git commands reference"` |
| `git log` | Displays the commit history. | `git log` |

---

## 3. Viewing Changes

| Command | What it does | Example |
|---|---|---|
| `git diff` | Shows changes that have not been staged. | `git diff` |
| `git diff --staged` | Shows changes that are currently staged. | `git diff --staged` |
| `git log --oneline` | Shows commit history in a short and compact format. | `git log --oneline` |

---
