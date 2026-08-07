# Day 41 – GitHub Actions: Triggers & Matrix Builds

## Objective

Today I learned how GitHub Actions workflows can be triggered in different ways and how to execute the same workflow across multiple environments using Matrix Builds.

---

# What are GitHub Actions Triggers?

A **trigger** is an event that tells GitHub Actions **when a workflow should start**.

Without a trigger, GitHub doesn't know when to execute your workflow.

Think of a trigger like a **doorbell**.

- Someone presses the bell → Event happens
- The bell rings → Workflow starts

GitHub supports many different events such as:

- push
- pull_request
- workflow_dispatch
- schedule
- release
- issues
- workflow_call

---

# Why are Triggers Important?

Different projects require workflows to run at different times.

Examples:

- Run tests whenever code is pushed.
- Verify code before merging a Pull Request.
- Run backups every night.
- Deploy only when a developer clicks a button.
- Scan security vulnerabilities every Sunday.

Triggers automate these tasks so developers don't have to remember them manually.

---

# Task 1 – Pull Request Trigger

## What?

A Pull Request trigger runs a workflow whenever someone creates or updates a Pull Request.

GitHub event:

```yaml
pull_request
```

---

## Why?

Before merging code into the main branch, we should automatically verify that everything is working.

Common checks include:

- Running tests
- Code formatting
- Security scanning
- Linting
- Build verification

This prevents broken code from reaching production.

---

## Workflow

File:

```
.github/workflows/pr-check.yml
```

```yaml
name: PR Check

on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize

jobs:
  pr-check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v5

      - name: Print PR Branch
        run: echo "PR check running for branch: ${{ github.head_ref }}"
```

---

## How it Works

Developer pushes code

↓

Creates Pull Request

↓

GitHub detects `pull_request`

↓

Workflow starts automatically

↓

PR page shows workflow status

---

## Verification

✔ Workflow appears inside the Pull Request page.

---

# Task 2 – Scheduled Trigger

## What?

A scheduled workflow runs automatically at a specific time using **Cron Expressions**.

GitHub uses **UTC timezone**.

---

## Why?

Some jobs should run even if nobody pushes code.

Examples:

- Database backups
- Cleanup old artifacts
- Generate reports
- Security scans
- Dependency updates

---

## Workflow Example

```yaml
on:
  schedule:
    - cron: "0 0 * * *"
```

Meaning:

```
Minute Hour Day Month Weekday

0      0    *    *      *
```

Runs every day at **12:00 AM UTC**.

---

## Cron Expression

Every Monday at 9 AM UTC

```text
0 9 * * 1
```

---

## Common Cron Examples

| Cron | Meaning |
|-------|----------|
| `0 0 * * *` | Every day at midnight |
| `0 9 * * 1` | Every Monday at 9 AM |
| `*/15 * * * *` | Every 15 minutes |
| `0 */6 * * *` | Every 6 hours |

---

# Task 3 – Manual Trigger

## What?

A Manual Trigger allows developers to start a workflow whenever they want.

GitHub event:

```yaml
workflow_dispatch
```

---

## Why?

Some workflows should only run when a developer decides.

Examples:

- Production deployment
- Database migration
- Rollback
- Manual testing

---

## Workflow

File:

```
.github/workflows/manual.yml
```

```yaml
name: Manual Workflow

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Choose environment"
        required: true
        default: staging
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Print Environment
        run: echo "Environment: ${{ inputs.environment }}"
```

---

## How it Works

Developer opens

Actions

↓

Selects workflow

↓

Clicks **Run Workflow**

↓

Chooses Environment

↓

Workflow starts immediately

---

## Verification

The workflow prints:

```
Environment: staging
```

or

```
Environment: production
```

---

# Task 4 – Matrix Builds

## What?

Matrix Strategy allows GitHub Actions to run the same workflow multiple times with different configurations automatically.

Instead of writing many similar jobs, GitHub generates them for you.

---

## Why?

Applications should work in multiple environments.

Example:

Python project should support

- Python 3.10
- Python 3.11
- Python 3.12

Instead of creating three jobs manually, Matrix creates them automatically.

---

## Workflow

File:

```
.github/workflows/matrix.yml
```

```yaml
name: Matrix Build

on:
  workflow_dispatch:

jobs:
  matrix-job:

    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version:
          - "3.10"
          - "3.11"
          - "3.12"

    steps:
      - uses: actions/checkout@v5

      - uses: actions/setup-python@v6
        with:
          python-version: ${{ matrix.python-version }}

      - run: python --version
```

---

## Result

GitHub automatically creates

```
Job 1 → Python 3.10

Job 2 → Python 3.11

Job 3 → Python 3.12
```

All run in parallel.

---

## Extend Matrix

```yaml
strategy:
  matrix:

    os:
      - ubuntu-latest
      - windows-latest

    python-version:
      - "3.10"
      - "3.11"
      - "3.12"

runs-on: ${{ matrix.os }}
```

Matrix combinations:

```
2 Operating Systems

×

3 Python Versions

=

6 Jobs
```

---

# Task 5 – Exclude & Fail-Fast

## What?

Sometimes one combination should never run.

Example:

```
Windows + Python 3.10
```

Matrix Exclude removes that combination.

---

## Why?

Maybe:

- Unsupported software
- Known bug
- Platform limitation

Running that job wastes CI time.

---

## Exclude Example

```yaml
strategy:

  matrix:

    os:
      - ubuntu-latest
      - windows-latest

    python-version:
      - "3.10"
      - "3.11"
      - "3.12"

    exclude:

      - os: windows-latest
        python-version: "3.10"
```

Now only **5 jobs** will run.

---

# Fail Fast

## What?

`fail-fast` controls what happens when one Matrix job fails.

Default:

```yaml
fail-fast: true
```

---

## Why?

Sometimes if one job fails, continuing the others wastes CI resources.

Other times, you want to know the status of every environment, even if one fails.

---

## Example

```yaml
strategy:

  fail-fast: false

  matrix:
```

---

## Difference

### fail-fast: true (Default)

- First failed Matrix job cancels the remaining running jobs.
- Saves CI time and resources.
- Useful when one failure is enough to stop testing.

---

### fail-fast: false

- All Matrix jobs continue running even if one job fails.
- Useful to see results from every operating system or language version.
- Helps identify all failing environments in a single run.

---

# Summary

Today I learned:

- Different ways to trigger GitHub Actions workflows.
- Pull Request workflows.
- Scheduled workflows using Cron.
- Manual workflows using workflow_dispatch.
- Matrix Strategy.
- Running workflows on multiple Python versions.
- Running workflows across multiple operating systems.
- Matrix Exclude.
- fail-fast behavior.

---

# Commands Used

```bash
git checkout -b feature/pr-trigger

git add .

git commit -m "Add GitHub Actions trigger workflows"

git push origin feature/pr-trigger

git checkout main

git pull origin main
```

---

# Challenges Faced

During today's GitHub Actions practice, I faced several practical challenges:

- Understanding the difference between various workflow triggers (`push`, `pull_request`, `workflow_dispatch`, and `schedule`) and when to use each one.
- Learning the correct GitHub event types for Pull Requests, especially the difference between `opened` and `synchronize`.
- Remembering that scheduled workflows use **UTC time**, which requires converting local time to UTC.
- Understanding how Matrix Builds automatically generate multiple jobs from combinations instead of writing separate jobs manually.
- Calculating the total number of matrix jobs and seeing how `exclude` removes only specific combinations.
- Initially making a typo in the matrix variable name (`python-verson` instead of `python-version`), which prevented the conditional failure step from running correctly.
- Learning the difference between `fail-fast: true` and `fail-fast: false`, and observing how remaining jobs behave when one matrix job fails.

---

# What I Learned

- A workflow starts only when one of its configured trigger events occurs.
- `pull_request` workflows help validate code before it is merged into the `main` branch.
- `workflow_dispatch` enables developers to run workflows manually with custom inputs.
- `schedule` uses cron expressions and always runs according to UTC time.
- Matrix Strategy creates multiple jobs automatically from different combinations of variables.
- Adding another matrix variable multiplies the total number of jobs (for example, 2 operating systems × 3 Python versions = 6 jobs).
- `exclude` removes only selected matrix combinations without affecting the rest.
- `fail-fast: true` cancels remaining matrix jobs after the first failure, while `fail-fast: false` allows every job to finish, making debugging across environments much easier.
