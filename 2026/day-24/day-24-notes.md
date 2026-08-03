# Day 24 – Advanced Git Workflows

## Objective

Learn advanced Git workflows including:

- Git Merge
- Git Rebase
- Squash Merge
- Git Stash
- Git Cherry-Pick

---

# Task 1 – Git Merge

## What I Did

- Created `feature-login` from `main`
- Added multiple commits
- Merged into `main`
- Observed a **Fast-Forward Merge**
- Created `feature-signup`
- Added commits
- Added another commit on `main`
- Merged `feature-signup`
- Observed a **Merge Commit**
- Created a merge conflict intentionally and resolved it

---

## Answers

### What is a Fast-Forward Merge?

A Fast-Forward merge happens when the target branch (`main`) has no new commits after the feature branch was created. Git simply moves the branch pointer forward without creating a new merge commit.

### When does Git create a Merge Commit?

Git creates a merge commit when both branches have different commits. Git combines both histories into a new merge commit.

### What is a Merge Conflict?

A merge conflict occurs when Git cannot automatically combine changes because the same lines of a file were modified differently in two branches. The conflict must be resolved manually.

---

# Task 2 – Git Rebase

## What I Did

- Created `feature-dashboard`
- Added multiple commits
- Added a new commit on `main`
- Rebased `feature-dashboard` onto `main`
- Compared the history with merge

---

## Answers

### What does rebase actually do?

Rebase takes my commits and replays them on top of another branch's latest commit.

### How is rebase different from merge?

Merge preserves both branch histories by creating a merge commit.

Rebase creates a linear history by replaying commits without creating a merge commit.

### Why should you never rebase shared commits?

Rebasing changes commit hashes. If commits have already been pushed and shared, rewriting history can create confusion and conflicts for other developers.

### When would you use rebase vs merge?

**Use Rebase**

- Clean project history
- Before opening a Pull Request
- Updating a feature branch with the latest `main`

**Use Merge**

- Preserve complete branch history
- Team collaboration
- Shared branches

---

# Task 3 – Squash Merge vs Regular Merge

## What I Did

Created `feature-profile`

Added multiple small commits

Merged using:

```bash
git merge --squash feature-profile
```

Created `feature-settings`

Merged normally using:

```bash
git merge feature-settings
```

Compared both histories.

---

## Answers

### What does squash merge do?

Squash merge combines all commits from a feature branch into one single commit before merging.

### When would you use squash merge?

- Small features
- Many temporary commits
- Cleaner project history

### When would you use a regular merge?

- When individual commit history is important
- Team projects
- Open source contributions

### Trade-off of squashing

Advantages

- Clean history
- One meaningful commit

Disadvantages

- Original commit history is lost.

---

# Task 4 – Git Stash

## What I Did

- Modified files without committing
- Tried switching branches
- Used stash
- Switched branches
- Restored work
- Created multiple stashes
- Listed all stashes
- Applied a specific stash

---

## Answers

### Difference between git stash pop and git stash apply

| git stash pop | git stash apply |
|---------------|-----------------|
| Restores changes | Restores changes |
| Removes stash | Keeps stash |

### When would you use Git Stash?

- Urgent bug fixes
- Switching branches quickly
- Saving unfinished work temporarily
- Keeping the working directory clean

---

# Task 5 – Git Cherry-Pick

## What I Did

Created `feature-hotfix`

Added three commits

Switched to `main`

Cherry-picked only one commit

Verified the history

---

## Answers

### What does cherry-pick do?

Cherry-pick copies a specific commit from one branch and creates a new commit with the same changes on the current branch.

### When would you use cherry-pick?

- Copy a hotfix to another branch
- Apply one bug fix without merging the entire feature branch
- Selectively reuse commits

### What can go wrong?

- Merge conflicts
- Missing dependent commits
- Duplicate changes
- Commit dependencies causing conflicts

---

# Commands Used

```bash
git branch
git switch
git checkout
git merge
git merge --squash
git rebase
git stash
git stash list
git stash apply
git stash pop
git stash show
git cherry-pick
git log --oneline --graph --all --decorate
git status
git add
git commit
git push
```

---

# Challenges Faced

During this day's practice, I encountered several real Git scenarios:

- Initially confused about the difference between **Fast-Forward Merge** and **Merge Commit**.
- Needed time to understand how **Git Rebase** rewrites commit history and why it should not be used on shared commits.
- Learned that **Squash Merge** combines multiple commits into a single commit, which removes the detailed commit history.
- Discovered that `git stash` does **not** save untracked files by default, which explained why my newly created `login.html` file was not stashed.
- Learned that `git stash apply` restores **only one selected stash**, not the entire stash list.
- Faced **Cherry-Pick conflicts** because the selected commit depended on previous commits that had not been applied to the target branch.
- Understood that cherry-picking copies the **changes (patch)** from a commit, not the commit itself, so dependent commits may require earlier commits or manual conflict resolution.

---

# What I Learned

- Understood the difference between **Merge**, **Rebase**, **Squash Merge**, **Stash**, and **Cherry-Pick**.
- Learned when to use **Merge** versus **Rebase** in real-world development.
- Learned how Git preserves history with merge and rewrites history with rebase.
- Learned how squash merge creates a cleaner commit history by combining multiple commits.
- Learned how to temporarily save unfinished work using Git Stash and restore it later.
- Learned the difference between `git stash pop` and `git stash apply`.
- Understood that cherry-pick creates a **new commit with a new commit hash**, not the original commit.
- Learned that successful cherry-picking works best with **independent commits**, while dependent commits may lead to merge conflicts.
- Gained practical experience resolving merge conflicts and understanding why Git reports them.

---

# Conclusion

This day provided hands-on experience with advanced Git workflows used in professional software development. By practicing merges, rebases, squash merges, stashing, and cherry-picking, I developed a stronger understanding of how Git manages commit history, branch integration, temporary work, and selective commit sharing. These concepts are essential for effective collaboration in real-world development teams.
