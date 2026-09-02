# Day 24 – Git Merge, Rebase, Squash, Stash & Cherry-pick
---

# Task 1 – Git Merge

## What is Git Merge?

Git Merge is a command that combines the changes from one branch into another branch.

It takes the work done in a feature branch and brings it into the target branch (usually `main`).

Think of it like this:

```
main
 │
 ├── A
 ├── B
 │
feature-login
 │
 ├── C
 └── D

After Merge

main
 │
 ├── A
 ├── B
 ├── C
 └── D
```

---

## Why do we use Git Merge?

In a real project, every developer works on their own branch.

For example:

* Developer A works on Login
* Developer B works on Signup
* Developer C fixes Bugs

When the work is finished, all branches must be combined into the main project.

Git Merge combines those branches safely.

---

## Types of Merge

Git mainly performs two kinds of merges.

### 1. Fast-Forward Merge

Git simply moves the `main` pointer forward because nobody changed `main` after the branch was created.

Example

```
Before

main
A---B

feature
     \
      C---D

After

main
A---B---C---D
```

No extra merge commit is created.


---

### 2. Merge Commit

If both branches have new commits, Git cannot simply move the pointer.

It creates a new merge commit.

Example

```
Before

        C---D (feature)
       /
A---B
       \
        E (main)

After

        C---D
       /     \
A---B---E-----M
```

`M` is the merge commit.

---

---

## Observation

Git performed a **Fast-Forward Merge** because `main` had not changed.

---

## Observation

Git created a **Merge Commit** because both branches had different commits.

---

## Merge Conflict

A merge conflict happens when Git cannot decide which change should be kept.

Example

Branch A

```
Hello World
```

changes to

```
Hello Git
```

Branch B

changes same line to

```
Hello DevOps
```

When merging:

```
<<<<<<< HEAD
Hello Git
=======
Hello DevOps
>>>>>>> feature
```

Git asks the developer to manually choose the correct version.

---

# Answers

## What is a Fast-Forward Merge?

A Fast-Forward Merge happens when the target branch has no new commits. Git simply moves the branch pointer forward without creating a merge commit.

---

## When does Git create a Merge Commit?

Git creates a merge commit when both branches have new commits and their histories have diverged.

---

## What is a Merge Conflict?

A merge conflict occurs when the same part of a file has been modified differently in two branches, and Git cannot automatically decide which version to keep.

---

# Task 2 – Git Rebase

## What is Git Rebase?

Git Rebase moves your branch to start from the latest commit of another branch.

Instead of combining histories like merge, it rewrites your commits as if they were created after the latest commits.

---

## Why do we use Rebase?

Rebase keeps Git history clean and linear.

Instead of creating many merge commits, commits appear in one straight line.

---

## Example

Before

```
main

A---B---C

feature

     D---E
```

After Rebase

```
A---B---C---D'---E'
```

Notice that D and E become new commits.

---

## Commands

```bash
git checkout -b feature-dashboard

echo Dashboard > dashboard.txt

git add .

git commit -m "Dashboard UI"

echo API >> dashboard.txt

git add .

git commit -m "Dashboard API"

git checkout main

echo Home > home.txt

git add .

git commit -m "Home update"

git checkout feature-dashboard

git rebase main
```

---

## Observation

`git log --oneline --graph --all`

shows a straight history with no merge commit.

---

# Answers

## What does Rebase actually do?

It replays your commits on top of another branch and creates new commit IDs.

---

## How is history different from Merge?

Merge keeps branch history and creates merge commits.

Rebase creates a clean, linear history without merge commits.

---

## Why should you never Rebase shared commits?

Rebase changes commit IDs. If other developers already have those commits, it causes history conflicts and makes collaboration difficult.

---

## When would you use Rebase vs Merge?

Use Rebase:

* Before merging your own local branch.
* To keep history clean.

Use Merge:

* For shared branches.
* When preserving branch history is important.

---

# Task 3 – Squash Merge

## What is Squash Merge?

Squash Merge combines all commits from a branch into one single commit before adding it to the target branch.

---

## Why use Squash Merge?

Sometimes a feature contains many tiny commits like:

```
Fix typo

Update spacing

Rename variable

Remove blank line

Fix comment
```

These are not useful in the final history.

Squash Merge combines them into one meaningful commit.

---

## Commands

```bash
git checkout -b feature-profile

git commit -m "Commit 1"

git commit -m "Commit 2"

git commit -m "Commit 3"

git commit -m "Commit 4"

git checkout main

git merge --squash feature-profile

git commit -m "Add Profile Feature"
```

---

## Observation

Main received only one commit.

---

## Regular Merge

```bash
git checkout -b feature-settings

git commit -m "Settings 1"

git commit -m "Settings 2"

git commit -m "Settings 3"

git checkout main

git merge feature-settings
```

Main contains every commit.

---

# Answers

## What does Squash Merge do?

It combines multiple commits into one single commit before merging.

---

## When would you use Squash Merge?

* Small feature branches
* Cleanup commits
* Pull Requests
* Cleaner Git history

---

## Trade-off of Squashing

Advantages

* Clean history
* Easier to read
* One meaningful commit

Disadvantages

* Individual commit history is lost.
* Debugging small changes later becomes harder.

---

# Task 4 – Git Stash

## What is Git Stash?

Git Stash temporarily saves uncommitted changes without creating a commit.

---

## Why do we use Stash?

Imagine you are working on a feature.

Suddenly a production bug appears.

Instead of committing unfinished work, you stash it, fix the bug, then return to your original work.

---

## Commands

```bash
git stash

git stash list

git stash pop

git stash apply stash@{1}
```

---

## Observation

Changes disappeared after `git stash`.

After `git stash pop`, changes returned.

---

# Answers

## Difference between `git stash pop` and `git stash apply`

| git stash pop                                         | git stash apply                                   |
| ----------------------------------------------------- | ------------------------------------------------- |
| Applies the stash and removes it from the stash list. | Applies the stash but keeps it in the stash list. |

---

## When would you use Stash?

* Urgent bug fixes
* Switching branches
* Pulling latest changes
* Temporary work-in-progress

---

# Task 5 – Git Cherry-pick

## What is Cherry-pick?

Cherry-pick copies a specific commit from one branch and applies it to another branch.

Instead of merging the whole branch, only one selected commit is copied.

---

## Why use Cherry-pick?

Imagine a branch has five commits.

Only one commit fixes a production bug.

Instead of merging everything, copy only that fix.

---

## Commands

```bash
git checkout -b feature-hotfix

git commit -m "Commit 1"

git commit -m "Commit 2"

git commit -m "Commit 3"

git log --oneline

git checkout main

git cherry-pick <commit-id-of-second-commit>
```

---

## Observation

Only the selected commit appeared on `main`.

---

# Answers

## What does Cherry-pick do?

It copies a specific commit from one branch and applies it to another branch.

---

## When would you use Cherry-pick?

* Hotfixes
* Bug fixes
* Production patches
* Copying one useful commit without merging the entire branch

---

## What can go wrong?

* Merge conflicts
* Duplicate commits
* Confusing history if overused

---

# Commands Used

```bash
git checkout
git checkout -b
git branch
git add .
git commit -m
git merge
git merge --squash
git rebase
git stash
git stash list
git stash pop
git stash apply
git cherry-pick
git log --oneline --graph --all
```

---

# Challenges Faced

* Understanding the difference between Fast-Forward Merge and Merge Commit.
* Resolving merge conflicts when the same line was edited in multiple branches.
* Understanding how Rebase rewrites commit history.
* Learning when to use Squash Merge instead of a regular Merge.
* Remembering the difference between `git stash pop` and `git stash apply`.
* Identifying the correct commit hash for `git cherry-pick`.

---

# What I Learned

* Learned how Git Merge combines work from different branches.
* Understood the difference between Fast-Forward Merge and Merge Commit.
* Learned how to resolve merge conflicts manually.
* Understood how Git Rebase creates a clean, linear commit history.
* Learned why rebasing shared commits should be avoided.
* Learned how Squash Merge keeps project history clean.
* Understood how Git Stash saves temporary work without committing.
* Learned how Cherry-pick copies only selected commits to another branch.
* Improved understanding of Git history using `git log --oneline --graph --all`.
* Gained confidence in choosing the right Git workflow for different scenarios.
