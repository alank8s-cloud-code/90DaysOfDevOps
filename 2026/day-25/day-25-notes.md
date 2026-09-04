# Day 25 – Git Reset vs Revert & Branching Strategies

Notes and hands-on results for undoing mistakes safely in Git, plus a look at
branching strategies used by real engineering teams.

---

## Task 1: Git Reset — Hands-On

**What:** Make three commits, then practice undoing the last one using the
three reset modes — `--soft`, `--mixed`, `--hard`.

**Why:** Reset is one of the most misunderstood git commands because all
three flags "undo a commit," but they behave very differently with your
staged and working-directory changes. Doing it hands-on is the only way the
difference actually sticks — reading about it isn't enough to build the
muscle memory of "which flag do I want right now."

**Setup:**
```bash
git init devops-git-practice && cd devops-git-practice
echo "line 1" > file.txt && git add . && git commit -m "Commit A"
echo "line 2" >> file.txt && git add . && git commit -m "Commit B"
echo "line 3" >> file.txt && git add . && git commit -m "Commit C"
```

### `git reset --soft HEAD~1`
```bash
git reset --soft HEAD~1
```
- HEAD moves back to Commit B.
- Commit C's changes stay **staged** (in the index), ready to re-commit immediately.
- Working directory is untouched.
- `git status` shows the changes as "Changes to be committed."

### `git reset --mixed HEAD~1` (re-commit C first, then run this)
```bash
git commit -m "Commit C"
git reset --mixed HEAD~1
```
- HEAD moves back to Commit B.
- Commit C's changes are **unstaged** but still present in the working directory.
- `git status` shows them as "Changes not staged for commit."
- This is the **default** mode if you just type `git reset HEAD~1`.

### `git reset --hard HEAD~1` (re-commit C first, then run this)
```bash
git commit -m "Commit C"
git reset --hard HEAD~1
```
- HEAD moves back to Commit B.
- Commit C's changes are **gone from staging AND the working directory**.
- `git status` shows a clean tree — as if Commit C never happened.
- The only way back is `git reflog` (if the commit hasn't been garbage-collected yet).

### Answers

**Difference between `--soft`, `--mixed`, and `--hard`:**

| Mode | HEAD | Staging Area | Working Directory |
|---|---|---|---|
| `--soft` | Moved | Unchanged (keeps old commit's changes staged) | Unchanged |
| `--mixed` (default) | Moved | Reset to match new HEAD | Unchanged (changes appear as unstaged) |
| `--hard` | Moved | Reset to match new HEAD | Reset to match new HEAD (changes deleted) |

**Which one is destructive and why?**
`--hard` is destructive because it discards uncommitted work in the working
directory as well as the commit itself. `--soft` and `--mixed` only move
history and staging — your actual file changes are preserved on disk.

**When would you use each one?**
- `--soft`: You want to squash/redo a commit message or combine commits, but keep everything staged.
- `--mixed`: You want to "uncommit" but review/re-stage changes selectively before committing again.
- `--hard`: You are certain you want to throw away a commit and its changes completely (e.g., a broken experiment).

**Should you ever use `git reset` on commits that are already pushed?**
Generally **no**. Resetting rewrites history, so anyone who already pulled
those commits will have a diverging history and will hit conflicts or need a
force-push to reconcile. It's acceptable only on a private/feature branch
that no one else has pulled, and even then a force-push (`--force-with-lease`)
is required, which is risky on shared branches. `git revert` is the safer
choice for shared history.

---

## Task 2: Git Revert — Hands-On

**What:** Make three commits and then revert the middle one, then check
whether it disappears from history.

**Why:** Revert solves the same problem as reset (undo a bad commit) but
does it in a completely different, non-destructive way. The point of this
task is to see with your own eyes that the reverted commit *stays* in the
log — history only grows forward, it's never rewritten.

**Setup:**
```bash
echo "x" > file2.txt && git add . && git commit -m "Commit X"
echo "y" >> file2.txt && git add . && git commit -m "Commit Y"
echo "z" >> file2.txt && git add . && git commit -m "Commit Z"
```

### Revert commit Y
```bash
git log --oneline          # find Y's hash
git revert <hash-of-Y>
```
- Git opens a commit message editor for a **new commit** that undoes Y's changes.
- If Y's changes conflict with Z (since Z came after Y), Git may report a
  conflict that needs to be resolved manually before the revert commit completes.
- No existing commits are deleted or rewritten.

### Check `git log`
```bash
git log --oneline
```
- Commit Y is **still visible** in the log.
- A new commit (e.g., `Revert "Commit Y"`) appears after Z, effectively
  cancelling Y's changes while preserving the full history.

### Answers

**How is `git revert` different from `git reset`?**
`git reset` moves the branch pointer backward and can rewrite/erase history.
`git revert` moves history **forward** by adding a brand-new commit that
undoes the changes of a previous commit — the original commit stays intact
in the log.

**Why is revert considered safer than reset for shared branches?**
Because it never rewrites existing commits. Anyone who has already pulled
the branch can simply pull again and get the revert commit — no diverging
history, no force-push, no conflicts caused by history rewriting.

**When would you use revert vs reset?**
- Use **revert** on any branch that others have already pulled from (main,
  develop, release branches) — it's non-destructive and traceable.
- Use **reset** on local/private branches before pushing, when you want to
  clean up history (e.g., undo a bad local commit before anyone sees it).

---

## Task 3: Reset vs Revert — Summary

**What:** A side-by-side table comparing what each command does, whether
it deletes history, and whether it's safe on shared branches.

**Why:** Once you've felt the difference hands-on in Tasks 1–2, this forces
you to distill it into a decision rule you can recall instantly in real
work: "is this branch shared? Then revert. Is it private/local? Then reset
is fine."

| | `git reset` | `git revert` |
|---|---|---|
| **What it does** | Moves the branch/HEAD pointer to an earlier commit (optionally touching staging/working dir) | Creates a new commit that reverses the changes of a target commit |
| **Removes commit from history?** | Yes — commits after the reset point become unreachable (and can be garbage collected) | No — the original commit remains in history; a new "undo" commit is added |
| **Safe for shared/pushed branches?** | No — rewrites history, requires force-push, breaks collaborators' history | Yes — history stays linear and forward-moving, safe to push normally |
| **When to use** | Local/private branches, undoing recent uncommitted or unpushed work, cleaning up before push | Shared branches (main, develop, release), undoing a bug or bad change that's already public |

---

## Task 4: Branching Strategies

**What:** Research and document GitFlow, GitHub Flow, and Trunk-Based
Development — how each works, a diagram, and pros/cons.

**Why:** Reset/revert is about undoing individual commits; this task zooms
out to how a whole team organizes commits across branches over time.
Different orgs pick different strategies based on release cadence and team
size, so understanding the trade-offs is what lets you reason about *why*
a company's workflow looks the way it does — not just follow it blindly.

### GitFlow
**How it works:** Uses long-lived `develop` and `main` branches, plus
supporting branches: `feature/*` (branched from `develop`), `release/*`
(branched from `develop` when preparing a release), and `hotfix/*` (branched
from `main` for urgent production fixes). Features merge into `develop`;
releases merge into both `main` and `develop`; hotfixes merge into both
`main` and `develop`.

**Flow diagram:**
```
main      ----------------o----------------o------->  (tagged releases)
                            \              /
release/1.0                  o----o----o
                            /              \
develop   --o--o--o--o--o--o----------------o--o--->
             \      \
feature/a     o--o--o
                     \
feature/b             o--o
```

**When/where used:** Projects with scheduled, versioned releases —
enterprise software, desktop apps, libraries with formal version numbers.

**Pros:** Clear structure, isolates in-progress work from production,
supports multiple release versions in parallel, good for release trains.

**Cons:** Heavyweight — many long-lived branches, merge overhead, slower
to get code into production, overkill for continuous deployment.

---

### GitHub Flow
**How it works:** A single long-lived `main` branch that is always
deployable. All work happens on short-lived `feature/*` branches created
from `main`. When a feature is ready, open a pull request, review, then
merge straight back into `main` and deploy.

**Flow diagram:**
```
main      --o--o-----------o--------o------->  (always deployable)
              \            /        /
feature/a      o--o--o--o-         /
                                   /
feature/b            o--o--o--o--o
```

**When/where used:** Web apps and SaaS products with continuous deployment
— GitHub itself, most modern startups.

**Pros:** Simple, fast, minimal branch overhead, plays well with CI/CD.

**Cons:** No built-in support for maintaining multiple release versions at
once; requires strong CI/testing discipline since `main` must always be
deployable.

---

### Trunk-Based Development
**How it works:** Everyone commits directly to `main` ("trunk") or uses
very short-lived branches (hours, not days) that merge back quickly. Large
or risky changes are hidden behind feature flags rather than long-lived
branches.

**Flow diagram:**
```
main   --o-o-o-o-o-o-o-o-o-o-o-o-o------->
              \  /   \ /
short-lived    o      o   (merged back within hours)
```

**When/where used:** High-velocity teams with strong CI/CD and automated
testing — Google, Meta, many large-scale continuous-deployment shops.

**Pros:** Minimizes merge conflicts and integration pain, encourages small
frequent commits, pairs naturally with feature flags and CI/CD.

**Cons:** Requires excellent automated testing and CI discipline; risky
without feature flags since incomplete work can reach `main` easily.

### Answers

**Startup shipping fast:** **GitHub Flow.** It's lightweight, keeps `main`
deployable, and matches a small team shipping continuously without the
overhead of managing multiple release branches.

**Large team with scheduled releases:** **GitFlow.** The `develop` /
`release` / `hotfix` structure is built for coordinating many contributors
around versioned, scheduled releases.

**Favorite open-source project's strategy:** Checking the **Kubernetes**
repo on GitHub, it broadly follows a **trunk-based-style workflow**: most
contributions land on `main` via short-lived feature branches and pull
requests, with release branches cut only at release time rather than a
permanent `develop` branch. (Strategies vary by repo — check the
`CONTRIBUTING.md` of any project to confirm.)

---

## Task 5: Git Commands Reference (Days 22–25)

**What:** Consolidate everything learned across Days 22–25 (config, basic
workflow, branching, remotes, merge/rebase, stash/cherry-pick, reset/revert)
into one running reference file.

**Why:** This is your personal cheat sheet. The goal isn't to memorize
every flag — it's to have a single place you can grep through when you
forget a command mid-task, built up incrementally as you actually learn
each piece rather than copy-pasted from a tutorial.

This section was appended to `git-commands.md` in the `devops-git-practice`
repo.

### Setup & Config
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --list
git init
```

### Basic Workflow
```bash
git status
git add <file>          # stage a file
git add .                # stage everything
git commit -m "message"
git log
git log --oneline
git diff                 # unstaged changes
git diff --staged        # staged changes
```

### Branching
```bash
git branch                    # list branches
git branch <name>             # create branch
git checkout <name>           # switch branch (legacy)
git checkout -b <name>        # create + switch
git switch <name>             # switch branch (modern)
git switch -c <name>          # create + switch (modern)
git branch -d <name>          # delete merged branch
git branch -D <name>          # force delete branch
```

### Remote
```bash
git remote add origin <url>
git push origin <branch>
git push -u origin <branch>   # set upstream
git pull origin <branch>
git fetch origin
git clone <url>
# fork: done via GitHub UI, then clone your fork locally
```

### Merging & Rebasing
```bash
git merge <branch>            # merge branch into current
git rebase <branch>           # replay current branch commits onto <branch>
git rebase -i HEAD~3          # interactive rebase (squash/reorder/edit)
git rebase --continue
git rebase --abort
```

### Stash & Cherry Pick
```bash
git stash                     # save uncommitted changes
git stash list
git stash pop                 # reapply + remove from stash
git stash apply                # reapply, keep in stash
git stash drop
git cherry-pick <commit-hash> # apply a specific commit onto current branch
```

### Reset & Revert
```bash
git reset --soft HEAD~1       # move HEAD, keep changes staged
git reset --mixed HEAD~1      # move HEAD, unstage changes (default)
git reset --hard HEAD~1       # move HEAD, discard all changes
git revert <commit-hash>      # create a new commit undoing a past commit
git reflog                    # recover from a bad reset
```
