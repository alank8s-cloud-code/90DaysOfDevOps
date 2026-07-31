# Day 40 – My First GitHub Actions Workflow

## Overview

Today we learned how to create a GitHub Actions workflow, understand its structure, add steps, and handle failures.
We also learned what happens when a workflow step fails and how to read errors.

---

# Task 1 – Set Up

Create a new public repository called `github-actions-practice`.

### Steps:

1. **Clone the repo locally**

```bash
git clone <repo-link>
```

2. **Add origin (if using SSH)**

```bash
git remote add origin <ssh-link>
```

3. **Create folder structure**

```bash
mkdir -p .github/workflows/
```

4. **Create workflow file**

```bash
touch .github/workflows/<filename>.yml
```

5. **Add, commit, and push file**

```bash
git add .github/workflows/<filename>.yml
git commit -m "Add workflow file"
git push -u origin main
```

---

# Task 2 – Hello Workflow

Create `.github/workflows/hello.yml` with:

* Trigger: on every push
* One job called `greet`
* Runs on `ubuntu-latest`
* Steps:

  1. Checkout code using `actions/checkout`
  2. Print `Hello from GitHub Actions!`

### hello.yml example:

```yaml
name: Hello-Second-Work-flow

on: push

jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      - name: checkout code
        uses: actions/checkout@v4

      - name: say hello to github
        run: echo "Hello github this is Suraj"
```

Push the workflow and watch it run in **Actions tab**.

---

# Task 3 – Understand the Anatomy

### Key explanations:

* **on:** triggers workflow start
  Example: `on: push` → workflow runs when code is pushed

* **jobs:** group of steps that perform a task
  Example: build → test → deploy

* **runs-on:** machine type where job runs
  Example: `runs-on: ubuntu-latest`

* **steps:** tasks inside a job

* **uses:** pre-built action
  Example: `uses: actions/checkout@v4` → checks out repo code

* **run:** run commands in runner terminal
  Example: `run: echo "Hello GitHub Actions"`

* **name:** description for a step

* **matrix:** run same job on multiple versions/environments

```yaml
strategy:
  matrix:
    python-version: [3.10, 3.11, 3.12]
```

---

# Task 4 – Add More Steps

Update `hello.yml` to also:

* Print current date and time
* Print branch name that triggered the run
* List files in repo
* Print runner OS
* Run shell script
* Print workflow trigger user and repo name

### Updated hello.yml:

```yaml
name: Hello-Second-Work-flow

on: workflow_dispatch

jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      - name: checkout code
        uses: actions/checkout@v4

      - name: say hello to github
        run: echo "Hello github this is Suraj"

      - name: display the date and time
        run: echo "Display the date and time: $(date)"

      - name: print the branch name
        run: echo "Branch name is ${{ github.ref_name }}"

      - name: list files
        run: ls

      - name: check runner OS version
        run: cat /etc/os-release

      - name: run shell script
        run: bash shell.sh

      - name: who triggered the workflow
        run: echo "Workflow triggered by ${{ github.actor }}"

      - name: print repo name
        run: echo "Repo name: ${{ github.repository }}"
```

Push and watch workflow run in **Actions tab**.

---

# Task 5 – Break It On Purpose

Add a step with a command that will fail, for example:

```yaml
      - name: fail this step on purpose
        run: exit 1
```

### What happens when a step fails:

1. Workflow stops automatically at the failing step
2. GitHub shows a **❌ red cross mark** next to the workflow run
3. If all steps succeed, you see a **✅ green check mark**

---

### How to read errors:

1. Click **Actions tab** in GitHub → shows workflow runs
2. Click the workflow run with ❌
3. Open the failed job → failed step is highlighted
4. Read the logs and **annotations** → shows exact line and error message

Example:

```
Annotations
1 error
Invalid workflow file: .github/workflows/hello2.yml#L21
```

* This means there is a YAML syntax error on line 21
* Fix the error, commit, and push again → workflow should pass ✅

---

### Key Points:

* Missing or wrong steps stop the pipeline automatically
* GitHub shows which step failed, so you can debug
* Always check logs and annotations to find the exact problem

---

# Result

After Day 40:

* Repo created and workflow set up
* First workflow ran and printed hello message
* Learned workflow structure (on, jobs, runs-on, steps, uses, run)
* Added more steps: date, branch, files, OS, shell script
* Tested workflow failure and learned how to read errors
