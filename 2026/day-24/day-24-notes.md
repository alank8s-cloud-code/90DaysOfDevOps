# Git Branching, Merge, Rebase, Squash, Stash & Cherry-Pick – Hands-On Lab

## 📌 Objective

This lab demonstrates some of the most important Git workflows used in real-world software development.

You will learn:

- Creating and switching branches
- Fast-forward merge
- Merge commit
- Merge conflicts
- Git Rebase
- Squash Merge
- Git Stash
- Git Cherry-pick

---

# Task 1: Git Merge – Hands-On

## Objective

Learn how Git merges branches, understand the difference between fast-forward and merge commits, and intentionally create a merge conflict.

---

## Step 1: Create Repository (Skip if already created)

```bash
mkdir git-merge-lab
cd git-merge-lab

git init

echo "# Git Merge Lab" > README.md

git add .
git commit -m "Initial commit"
```

---

## Step 2: Create feature-login Branch

```bash
git checkout -b feature-login
```

---

## Step 3: Add Two Commits

```bash
echo "Login Page Created" > login.txt

git add .
git commit -m "Add login page"

echo "Login Validation Added" >> login.txt

git add .
git commit -m "Add login validation"
```

---

## Step 4: Merge into Main

```bash
git checkout main

git merge feature-login
```

Observe the output.

Git should display something similar to:

```
Updating xxxxx..xxxxx
Fast-forward
```

This is a **Fast-Forward Merge**.

---

## Step 5: Create feature-signup Branch

```bash
git checkout -b feature-signup
```

---

## Step 6: Add Commits

```bash
echo "Signup Page" > signup.txt

git add .
git commit -m "Add signup page"

echo "Signup Validation" >> signup.txt

git add .
git commit -m "Add signup validation"
```

---

## Step 7: Move Main Ahead

Switch back:

```bash
git checkout main
```

Create another commit.

```bash
echo "Homepage Updated" > home.txt

git add .
git commit -m "Update homepage"
```

Now both branches have different histories.

---

## Step 8: Merge feature-signup

```bash
git merge feature-signup
```

Git creates a **Merge Commit** because both branches have new commits.

---

# Create Merge Conflict

Create a file:

```bash
echo "Version 1" > app.txt

git add .
git commit -m "Add app file"
```

Create branch:

```bash
git checkout -b conflict-branch
```

Modify:

```bash
echo "Feature Branch Version" > app.txt

git add .
git commit -m "Update app in feature branch"
```

Return to main:

```bash
git checkout main
```

Modify the same line:

```bash
echo "Main Branch Version" > app.txt

git add .
git commit -m "Update app in main"
```

Merge:

```bash
git merge conflict-branch
```

Git shows:

```
CONFLICT (content): Merge conflict in app.txt
```

Open file:

```
<<<<<<< HEAD
Main Branch Version
=======
Feature Branch Version
>>>>>>> conflict-branch
```

Resolve manually.

After resolving:

```bash
git add app.txt
git commit
```

---

# Task 1 Questions & Answers

## 1. What is a Fast-Forward Merge?

A Fast-Forward Merge happens when the target branch has not moved ahead since the feature branch was created. Git simply moves the branch pointer forward without creating a new merge commit.

Example:

```
A---B (main)
     \
      C---D (feature)
```

After merge:

```
A---B---C---D (main)
```

No merge commit is created.

---

## 2. When does Git create a Merge Commit?

Git creates a merge commit when both branches have independent commits after they diverged.

Example:

```
      C---D
     /
A---B
     \
      E
```

After merge:

```
      C---D
     /     \
A---B-------M
     \
      E
```

Here **M** is the merge commit.

---

## 3. What is a Merge Conflict?

A merge conflict occurs when Git cannot automatically determine which changes should be kept because the same part of a file was modified in different branches.

The developer must manually resolve the conflict before completing the merge.

---

---

# Task 2: Git Rebase – Hands-On

## Objective

Learn how Git Rebase moves commits onto another branch and creates a cleaner project history.

---

## Step 1: Create feature-dashboard

```bash
git checkout main

git checkout -b feature-dashboard
```

---

## Step 2: Add 3 Commits

```bash
echo "Dashboard UI" > dashboard.txt

git add .
git commit -m "Dashboard UI"

echo "Charts Added" >> dashboard.txt

git add .
git commit -m "Add charts"

echo "Dashboard Styling" >> dashboard.txt

git add .
git commit -m "Dashboard styling"
```

---

## Step 3: Move Main Ahead

```bash
git checkout main
```

```bash
echo "Footer Added" > footer.txt

git add .
git commit -m "Add footer"
```

---

## Step 4: Rebase

```bash
git checkout feature-dashboard

git rebase main
```

Git reapplies dashboard commits on top of main.

---

## Step 5: View History

```bash
git log --oneline --graph --all
```

The history becomes linear.

---

# Task 2 Questions & Answers

## 1. What does rebase actually do to your commits?

Rebase removes your local commits temporarily, moves your branch to the latest commit of the target branch, and then reapplies your commits one by one on top of it.

It rewrites commit history by creating new commit IDs.

---

## 2. How is the history different from a merge?

Merge history:

```
A---B-------M
     \     /
      C---D
```

Rebase history:

```
A---B---C'---D'
```

The history becomes linear and easier to read.

---

## 3. Why should you never rebase commits that have been pushed and shared with others?

Rebase changes commit hashes.

If other developers already have those commits, rewriting them causes history mismatches, duplicate commits, and merge problems.

Therefore, only rebase local commits that have not been shared.

---

## 4. When would you use rebase vs merge?

### Use Rebase

- Before opening a Pull Request
- To maintain a clean history
- For local feature branches
- Before pushing your work

### Use Merge

- For shared branches
- When preserving complete project history
- When working with multiple developers
- When history should show exactly how work was integrated

---

---

# Task 3: Squash Commit vs Merge Commit

## Objective

Understand the difference between Squash Merge and Regular Merge.

---

## Step 1: Create feature-profile

```bash
git checkout main

git checkout -b feature-profile
```

---

## Step 2: Make Multiple Commits

```bash
echo "Profile Page" > profile.txt

git add .
git commit -m "Profile page"

echo "Formatting Fix" >> profile.txt

git add .
git commit -m "Formatting"

echo "Typo Fix" >> profile.txt

git add .
git commit -m "Typo"

echo "Image Added" >> profile.txt

git add .
git commit -m "Image"

echo "CSS Updated" >> profile.txt

git add .
git commit -m "CSS update"
```

---

## Step 3: Squash Merge

```bash
git checkout main

git merge --squash feature-profile

git commit -m "Add profile feature"
```

---

## Step 4: View Log

```bash
git log --oneline
```

Only **one commit** appears on main.

---

## Step 5: Regular Merge

Create another branch.

```bash
git checkout -b feature-settings
```

Make several commits.

```bash
echo "Settings" > settings.txt

git add .
git commit -m "Settings page"

echo "Theme" >> settings.txt

git add .
git commit -m "Theme"

echo "Language" >> settings.txt

git add .
git commit -m "Language support"
```

Merge normally.

```bash
git checkout main

git merge feature-settings
```

View history.

```bash
git log --oneline --graph --all
```

All commits remain.

---

# Task 3 Questions & Answers

## 1. What does squash merging do?

Squash merge combines all commits from a feature branch into a single new commit before merging into the target branch.

---

## 2. When would you use squash merge vs regular merge?

### Squash Merge

- Small features
- Bug fixes
- Cleaning commit history
- Removing unnecessary intermediate commits

### Regular Merge

- Preserve all development history
- Team collaboration
- Large features
- When each commit has value

---

## 3. What is the trade-off of squashing?

Advantages:

- Clean history
- Easier to read
- One meaningful commit

Disadvantages:

- Individual commit history is lost
- Harder to track how the feature was developed

---

---

# Task 4: Git Stash – Hands-On

## Objective

Temporarily save unfinished work without committing it.

---

## Step 1: Modify a File

```bash
echo "Work in Progress" >> README.md
```

Do not commit.

---

## Step 2: Try Switching Branch

```bash
git checkout feature-login
```

Git may prevent switching if changes would be overwritten.

---

## Step 3: Stash Changes

```bash
git stash
```

Working directory becomes clean.

---

## Step 4: Switch Branch

```bash
git checkout feature-login
```

Make a commit.

```bash
echo "Login Updated" >> login.txt

git add .
git commit -m "Update login"
```

---

## Step 5: Return

```bash
git checkout main
```

---

## Step 6: Restore Work

```bash
git stash pop
```

Your saved changes return.

---

## Step 7: Multiple Stashes

```bash
git stash

git stash

git stash list
```

Output:

```
stash@{0}
stash@{1}
stash@{2}
```

---

## Step 8: Apply Specific Stash

```bash
git stash apply stash@{1}
```

---

# Task 4 Questions & Answers

## 1. What is the difference between `git stash pop` and `git stash apply`?

### git stash pop

- Restores the stash.
- Removes it from the stash list after applying.

### git stash apply

- Restores the stash.
- Keeps the stash in the stash list for future use.

---

## 2. When would you use stash in a real-world workflow?

Git Stash is useful when:

- You need to quickly switch branches.
- A production bug must be fixed immediately.
- Your current work is incomplete.
- You don't want to create temporary commits.
- You need to pull the latest changes before continuing.

---

---

# Task 5: Cherry Picking

## Objective

Copy a specific commit from one branch to another without merging the entire branch.

---

## Step 1: Create Branch

```bash
git checkout main

git checkout -b feature-hotfix
```

---

## Step 2: Create Three Commits

```bash
echo "Hotfix 1" > hotfix.txt

git add .
git commit -m "Hotfix 1"

echo "Hotfix 2" >> hotfix.txt

git add .
git commit -m "Hotfix 2"

echo "Hotfix 3" >> hotfix.txt

git add .
git commit -m "Hotfix 3"
```

---

## Step 3: View Commit IDs

```bash
git log --oneline
```

Example:

```
a1b2c3 Hotfix 3
d4e5f6 Hotfix 2
g7h8i9 Hotfix 1
```

---

## Step 4: Cherry-Pick Second Commit

```bash
git checkout main

git cherry-pick d4e5f6
```

Replace `d4e5f6` with your actual commit hash.

---

## Step 5: Verify

```bash
git log --oneline
```

Only **Hotfix 2** appears on main.

---

# Task 5 Questions & Answers

## 1. What does cherry-pick do?

Cherry-pick copies a specific commit from one branch and applies it to another branch without merging the complete branch.

---

## 2. When would you use cherry-pick in a real project?

Common use cases include:

- Applying an urgent bug fix to another branch
- Backporting fixes to older release branches
- Reusing a specific feature commit
- Applying only selected changes without merging unrelated work

---

## 3. What can go wrong with cherry-picking?

Possible issues include:

- Merge conflicts if the target branch has conflicting changes
- Duplicate commits if the same changes are merged later
- Loss of context because only one commit is copied
- Dependency problems if the selected commit relies on earlier commits that were not cherry-picked

---

# Conclusion

In this hands-on lab, you learned how to:

- Create and manage Git branches
- Perform Fast-Forward and Merge Commit merges
- Resolve merge conflicts
- Rebase branches for a clean linear history
- Compare Squash Merge and Regular Merge
- Temporarily save work using Git Stash
- Apply individual commits using Git Cherry-pick

These workflows are widely used in professional software development and DevOps environments, making them essential Git skills for collaborative projects.
