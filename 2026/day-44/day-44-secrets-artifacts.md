# Day 44 – Secrets, Artifacts & Running Real Tests in CI

## Objective

Today the GitHub Actions pipeline starts doing **real CI/CD work**.

The focus of Day 44 is:

* 🔐 GitHub Secrets
* 🌱 Environment Variables
* 📦 GitHub Actions Artifacts
* 🔄 Sharing Artifacts Between Jobs
* 🧪 Running Real Tests in CI
* 🔍 Security Scanning with Bandit
* ⚡ Dependency Caching

---

# Task 1 – GitHub Secrets

## What?

GitHub Secrets allow us to store sensitive information securely instead of putting it directly inside workflow files.

Examples:

```text
API keys
Passwords
Docker credentials
Access tokens
Cloud credentials
```

## Why?

Never hardcode sensitive information in a GitHub Actions workflow.

Bad:

```yaml
run: echo "my-password-123"
```

Better:

```yaml
env:
  MY_SECRET_MESSAGE: ${{ secrets.MY_SECRET_MESSAGE }}
```

## How?

Go to:

```text
Repository
   ↓
Settings
   ↓
Secrets and variables
   ↓
Actions
   ↓
New repository secret
```

Create:

```text
Name:
MY_SECRET_MESSAGE
```

Set any test value.

## Workflow

```yaml
name: Check Secret

on:
  workflow_dispatch:

jobs:
  check-secret:
    runs-on: ubuntu-latest

    steps:
      - name: Check if secret is set
        env:
          MY_SECRET_MESSAGE: ${{ secrets.MY_SECRET_MESSAGE }}
        run: |
          if [ -n "$MY_SECRET_MESSAGE" ]; then
            echo "The secret is set: true"
          else
            echo "The secret is set: false"
          fi
```

Expected output:

```text
The secret is set: true
```

The actual secret value should never be printed.

## Why should secrets never be printed?

CI logs can be viewed by people who have access to the repository/workflow.

Secrets may accidentally appear in:

```text
Logs
Error messages
Debug output
Artifacts
Screenshots
Pull request output
```

Therefore:

```text
Secret
  ↓
Use internally
  ↓
Never print actual value
```

---

# Task 2 – Use Secrets as Environment Variables

Secrets can be passed to a workflow step as environment variables.

Example:

```yaml
- name: Use secret
  env:
    MY_SECRET_MESSAGE: ${{ secrets.MY_SECRET_MESSAGE }}
  run: |
    if [ -n "$MY_SECRET_MESSAGE" ]; then
      echo "Secret is available"
    fi
```

The secret is available to the process without hardcoding it in the workflow.

## Docker Secrets

For future Docker work, create:

```text
DOCKER_USERNAME
DOCKER_TOKEN
```

under:

```text
Settings → Secrets and variables → Actions
```

These can be used later for authentication when pushing Docker images.

---

# Task 3 – Upload Artifacts

## What?

An artifact is a file or collection of files produced by a workflow that we want to keep after the job finishes.

Examples:

```text
Test reports
Log files
Build files
Coverage reports
Screenshots
Compiled applications
```

## How?

Generate a log:

```yaml
- name: Generate log
  run: |
    mkdir Download-output
    echo "Workflow started" > Download-output/output.log
    echo "Tests completed" >> Download-output/output.log
```

Upload it:

```yaml
- name: Upload artifact
  uses: actions/upload-artifact@v4
  with:
    name: workflow-logs
    path: Download-output
```

Here:

```yaml
name: workflow-logs
```

is the artifact name.

And:

```yaml
path: Download-output
```

is the folder being uploaded.

## Verify

After the workflow finishes:

```text
GitHub
  ↓
Actions
  ↓
Workflow run
  ↓
Artifacts
  ↓
workflow-logs
```

Download the artifact and verify that `output.log` exists.

---

# Task 4 – Download Artifacts Between Jobs

Different GitHub Actions jobs normally run on separate runners.

Therefore:

```text
Job 1 filesystem
        ≠
Job 2 filesystem
```

A file created in Job 1 is not automatically available in Job 2.

Artifacts provide the bridge.

## Workflow

```yaml
name: Download Artifacts Between Jobs

on:
  workflow_dispatch:

jobs:

  generate-file:
    runs-on: ubuntu-latest

    steps:
      - name: Generate file
        run: |
          mkdir Download-output
          echo "Hello from Job 1" > Download-output/output.log
          echo "This file was created in Job 1." >> Download-output/output.log

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: workflow-logs
          path: Download-output


  use-file:
    runs-on: ubuntu-latest
    needs: generate-file

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v5
        with:
          name: workflow-logs

      - name: Print file contents
        run: cat Download-output/output.log
```

## Flow

```text
Job 1
 │
 ├── Generate output.log
 │
 └── upload-artifact
          │
          ▼
     GitHub Artifact
          │
          ▼
Job 2
 │
 ├── download-artifact
 │
 └── cat output.log
```

## Why `needs`?

```yaml
needs: generate-file
```

means:

```text
generate-file
      ↓
   finishes
      ↓
   use-file
```

Without `needs`, the jobs can run independently.

## Real Pipeline Example

```text
Build Job
    ↓
Create application package
    ↓
Upload artifact
    ↓
Test Job
    ↓
Download artifact
    ↓
Test application
```

Artifacts are commonly useful for:

```text
Test reports
Application builds
Logs
Coverage reports
Screenshots
Deployment packages
```

---

# Task 5 – Run Real Tests in CI

For this task, Python was used to create a real health-check script.

## Repository Structure

```text
github-actions-practice/
│
├── .github/
│   └── workflows/
│       └── python-test.yml
│
├── scripts/
│   ├── health_check.py
│   └── security_test.py
│
└── requirements.txt
```

---

## Python Health Check

Create:

```text
scripts/health_check.py
```

```python
import sys
import platform


def health_check():
    print("Running health check...")

    print(f"Python version: {platform.python_version()}")
    print(f"Platform: {platform.system()}")

    if sys.version_info >= (3, 8):
        print("Python version check: PASSED")
    else:
        print("Python version check: FAILED")
        return False

    print("Health check passed!")
    return True


if __name__ == "__main__":
    if health_check():
        sys.exit(0)
    else:
        sys.exit(1)
```

## Why `sys.exit()`?

The exit code tells CI whether the script succeeded.

```text
exit 0
   ↓
SUCCESS
```

```text
exit 1
   ↓
FAILURE
```

GitHub Actions uses the command's exit code to determine whether a step succeeds or fails.

---

# Python CI Workflow

```yaml
name: Python CI

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  test-python:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v6
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: |
          python3 -m pip install --upgrade pip
          pip install flake8

      - name: Lint Python code
        run: flake8 scripts/health_check.py

      - name: Run Python script
        run: python3 scripts/health_check.py
```

---

# Flake8

Flake8 is used for Python linting and static checks.

Run locally:

```bash
flake8 scripts/health_check.py
```

If the code contains invalid Python syntax, Flake8 can report:

```text
E999 SyntaxError: invalid syntax
```

For example, an accidental extra backtick:

```python
`
```

can cause:

```text
E999 SyntaxError
```

After fixing the syntax error:

```bash
flake8 scripts/health_check.py
```

should pass.

---

# Intentionally Break the CI

To verify that CI actually detects failures, intentionally change:

```python
sys.exit(0)
```

to:

```python
sys.exit(1)
```

Commit and push:

```bash
git add scripts/health_check.py
git commit -m "Intentionally break health check"
git push
```

Expected:

```text
Run Python script ❌
Workflow 🔴
```

Then fix it:

```python
sys.exit(0)
```

Commit:

```bash
git add scripts/health_check.py
git commit -m "Fix health check script"
git push
```

Expected:

```text
Run Python script ✅
Workflow 🟢
```

---

# Task 6 – Security Scanning & Caching

## Part A – Security Scanning with Bandit

### What?

Bandit is a Python security scanner.

It analyzes Python source code for potentially dangerous coding patterns.

Install:

```bash
python3 -m pip install bandit
```

Run:

```bash
bandit -r scripts/security_test.py
```

---

## SQL Injection Security Exercise

An intentionally vulnerable example was created:

```python
import sqlite3


def find_user(username):
    connection = sqlite3.connect("users.db")
    cursor = connection.cursor()

    query = f"SELECT * FROM users WHERE username = '{username}'"
    cursor.execute(query)

    return cursor.fetchall()
```

The vulnerable line is:

```python
query = f"SELECT * FROM users WHERE username = '{username}'"
```

The problem is that Python is directly building an SQL query using a variable.

---

## Bandit Detection

Running:

```bash
bandit -r scripts/security_test.py
```

produced:

```text
[B608:hardcoded_sql_expressions]
Possible SQL injection vector through string-based query construction.
```

Bandit reported:

```text
Severity: Medium
Confidence: Low
```

The important finding was:

```text
B608
```

Bandit identified a coding pattern that could potentially lead to SQL injection.

---

# Fixing the SQL Injection

Instead of:

```python
query = f"SELECT * FROM users WHERE username = '{username}'"
cursor.execute(query)
```

use a parameterized query:

```python
query = "SELECT * FROM users WHERE username = ?"
cursor.execute(query, (username,))
```

## Why?

The `?` is a parameter placeholder.

```text
SQL query
    ↓
SELECT ... WHERE username = ?
                         ↑
                    placeholder
                         ↑
                    username
```

The username is passed separately as data instead of being directly inserted into the SQL string.

---

## Verify the Fix

Run:

```bash
bandit -r scripts/security_test.py
```

The B608 finding should disappear.

---

# Add Bandit to CI

```yaml
- name: Install security scanner
  run: |
    python3 -m pip install --upgrade pip
    pip install bandit

- name: Run Bandit security scan
  run: bandit -r scripts/security_test.py
```

If Bandit finds a security issue, it returns a non-zero exit code.

Therefore:

```text
Bandit
   ↓
Security issue
   ↓
Non-zero exit code
   ↓
GitHub Actions fails
   ↓
🔴 Pipeline
```

After fixing:

```text
Bandit
   ↓
No issue
   ↓
Exit code 0
   ↓
GitHub Actions passes
   ↓
🟢 Pipeline
```

---

# Part B – Dependency Caching

## What?

Caching allows GitHub Actions to reuse previously downloaded dependencies.

Without caching:

```text
Workflow
   ↓
Download dependencies
   ↓
Install
   ↓
Run tests
```

With caching:

```text
Workflow
   ↓
Restore cache
   ↓
Install dependencies
   ↓
Run tests
```

This can reduce dependency download time.

---

## Create `requirements.txt`

```text
flake8
bandit
```

Install:

```yaml
- name: Install dependencies
  run: |
    python3 -m pip install --upgrade pip
    pip install -r requirements.txt
```

---

## Add `actions/cache`

```yaml
- name: Get pip cache directory
  id: pip-cache
  run: echo "dir=$(python -m pip cache dir)" >> "$GITHUB_OUTPUT"

- name: Cache pip dependencies
  uses: actions/cache@v4
  with:
    path: ${{ steps.pip-cache.outputs.dir }}
    key: ${{ runner.os }}-python-3.12-pip-${{ hashFiles('**/requirements.txt') }}
    restore-keys: |
      ${{ runner.os }}-python-3.12-pip-
```

---

## Cache Flow

First workflow run:

```text
Workflow
   ↓
Cache not found
   ↓
Download dependencies
   ↓
Run CI
   ↓
Save cache
```

Next workflow run:

```text
Workflow
   ↓
Restore cache ⚡
   ↓
Install dependencies
   ↓
Run CI
```

---

## Why `hashFiles()`?

The cache key contains:

```yaml
${{ hashFiles('**/requirements.txt') }}
```

If `requirements.txt` changes, its hash changes.

Therefore a new cache can be created.

```text
requirements.txt
       │
       ▼
  hashFiles()
       │
       ▼
   Cache key
       │
       ├── Same dependencies → reuse cache
       │
       └── Changed dependencies → new cache
```

---

# Complete Day 44 CI Flow

```text
                    GitHub Push
                         │
                         ▼
                  Checkout Code
                         │
                         ▼
                   Setup Python
                         │
                         ▼
                  Restore Cache
                         │
                         ▼
              Install Dependencies
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
          Flake8                 Bandit
       Code Quality            Security Scan
              │                     │
              └──────────┬──────────┘
                         ▼
                  Run Python Test
                         │
                  ┌──────┴──────┐
                  ▼             ▼
               Success       Failure
                  │             │
                  ▼             ▼
                 🟢            🔴
```

---

# Key Commands

### Run Python script

```bash
python3 scripts/health_check.py
```

### Check exit code

```bash
echo $?
```

### Run Flake8

```bash
flake8 scripts/health_check.py
```

### Run Bandit

```bash
bandit -r scripts/security_test.py
```

### Install dependencies

```bash
pip install -r requirements.txt
```

### Git workflow

```bash
git status
git add .
git commit -m "Add Python CI security checks"
git push
```

---

# What I Learned Today

## 1. Secrets

Secrets should never be hardcoded or intentionally printed in CI logs.

```text
secrets.MY_SECRET_MESSAGE
        ↓
Environment variable
        ↓
Use securely
```

## 2. Artifacts

Artifacts allow files produced by CI to be stored and downloaded later.

```text
Job
 ↓
Generate file
 ↓
Upload artifact
 ↓
GitHub
 ↓
Download artifact
```

## 3. Jobs

Jobs normally run on separate runners.

Artifacts can be used to transfer files between them.

## 4. Exit Codes

```text
0     → Success
non-0 → Failure
```

GitHub Actions uses the exit code to determine whether a step passed or failed.

## 5. Flake8

Flake8 helps detect Python syntax and code-quality problems.

## 6. Bandit

Bandit performs static security analysis of Python code.

## 7. SQL Injection

Unsafe:

```python
query = f"SELECT * FROM users WHERE username = '{username}'"
```

Safe:

```python
query = "SELECT * FROM users WHERE username = ?"
cursor.execute(query, (username,))
```

## 8. Caching

`actions/cache` can store dependency-related files and restore them in later workflow runs.

---

# Key Takeaway

Day 44 was about moving from a basic GitHub Actions workflow to a more realistic **CI/DevSecOps pipeline**.

The pipeline can now:

```text
🔐 Protect secrets
      ↓
📦 Store artifacts
      ↓
🔄 Share files between jobs
      ↓
🧪 Run real Python code
      ↓
🔍 Check code quality
      ↓
🛡️ Scan for security issues
      ↓
⚡ Cache dependencies
      ↓
🟢 Pass / 🔴 Fail automatically
```

This is an important step toward building production-style CI/CD pipelines.
