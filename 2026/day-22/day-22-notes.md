# Day 22 - Git Challenge

Name: Suraj
Topic: Git Basics

---

# Task 1: Install and Configure Git

## Objective

Install Git and configure your username and email.

---

### What?

Git is a Version Control System that tracks changes in a project.

### Why?

It helps save project history, work with other developers, and restore old versions.

### How?

Check Git version:

```bash
git --version
```

Set username:

```bash
git config --global user.name "Suraj"
```

Set email:

```bash
git config --global user.email "suraj@example.com"
```

Verify:

```bash
git config --list
```

---

## Screenshot 1

📷 Add screenshot of:

```bash
git --version
```

---

## Screenshot 2

📷 Add screenshot of:

```bash
git config --list
```

---

# Task 2: Create Your Git Project

## Objective

Create a new Git repository.

---

### What?

A Git repository is a folder where Git tracks project changes.

### Why?

Git needs a repository to save commits and project history.

### How?

Create folder:

```bash
mkdir devops-git-practice
```

Move inside:

```bash
cd devops-git-practice
```

Initialize Git:

```bash
git init
```

Check status:

```bash
git status
```

Explore .git folder:

```bash
ls -la
ls .git
```

---

## Screenshot 3

📷 Output of:

```bash
git init
```

---

## Screenshot 4

📷 Output of:

```bash
git status
```

---

## Screenshot 5

📷 Output of:

```bash
ls .git
```

---

# Task 3: Create Your Git Commands Reference

## What?

A Markdown file that stores Git commands.

### Why?

It helps me remember Git commands and use them later.

### How?

Create file:

```bash
touch git-commands.md
```

Add commands like:

## Setup & Config

### git init

What it does:

Creates a new Git repository.

Example

```bash
git init
```

### git config

What it does:

Sets Git username and email.

Example

```bash
git config --global user.name "Suraj"
```

### git status

What it does:

Shows current repository status.

Example

```bash
git status
```

### git add

What it does:

Moves files to the staging area.

Example

```bash
git add .
```

### git commit

What it does:

Saves staged changes.

Example

```bash
git commit -m "Initial commit"
```

### git log

What it does:

Shows commit history.

Example

```bash
git log
```

### git diff

What it does:

Shows changes before commit.

Example

```bash
git diff
```

---

## Screenshot 6

📷 Show your `git-commands.md` file.

---

# Task 4: Stage and Commit

## What?

Save project changes into Git.

### Why?

To create project history.

### How?

Stage:

```bash
git add .
```

Check:

```bash
git status
```

Commit:

```bash
git commit -m "Initial Git commands reference"
```

View history:

```bash
git log
```

---

## Screenshot 7

📷 Output of:

```bash
git status
```

---

## Screenshot 8

📷 Output of:

```bash
git commit
```

---

## Screenshot 9

📷 Output of:

```bash
git log
```

---

# Task 5: Make More Changes

## What?

Create multiple commits.

### Why?

Git works best when changes are saved in small commits.

### How?

Edit file.

Check:

```bash
git diff
```

Stage:

```bash
git add .
```

Commit:

```bash
git commit -m "Added more Git commands"
```

Repeat three times.

Compact history:

```bash
git log --oneline
```

---

## Screenshot 10

📷 Output of:

```bash
git diff
```

---

## Screenshot 11

📷 Output of:

```bash
git log --oneline
```

---

# Task 6: Understand Git Workflow

## 1. What is the difference between git add and git commit?

git add moves changed files to the staging area.

git commit saves the staged files in the Git repository.

---

## 2. What does the staging area do?

The staging area keeps files ready for commit.

Git does not commit directly because it lets me choose which files I want to save.

---

## 3. What information does git log show?

It shows:

- Commit ID
- Author
- Date
- Commit message

---

## 4. What is the .git folder?

The .git folder stores all Git information like commits, branches, configuration, and history.

If I delete it, Git stops tracking the project and the commit history is lost.

---

## 5. What is the difference between Working Directory, Staging Area, and Repository?

Working Directory

Where I create and edit files.

↓

git add

↓

Staging Area

Where Git keeps files ready to commit.

↓

git commit

↓

Repository

Where Git stores all committed versions of the project.

---

# What I Learned Today

- Installed Git
- Configured Git
- Created a Git repository
- Learned the Git workflow
- Used git status
- Used git add
- Used git commit
- Used git log
- Used git diff
- Learned about the .git folder
- Created multiple commits
