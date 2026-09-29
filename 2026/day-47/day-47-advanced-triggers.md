# Day 47 – Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines

## Objective

Today I learned how to use advanced GitHub Actions triggers instead of only basic `push` and `pull_request` events.

I practiced:

* Pull Request lifecycle events
* Pull Request validation
* Scheduled workflows using cron
* Path and branch filters
* Chaining workflows with `workflow_run`
* External event triggers with `repository_dispatch`
* `workflow_run` vs `workflow_call`

---

# What I Learned

GitHub Actions can start workflows for many different events.

```text
                    GitHub Actions Triggers
                            │
       ┌────────────────────┼────────────────────┐
       │                    │                    │
       ▼                    ▼                    ▼
  Pull Request           Schedule           External Event
       │                    │                    │
 opened/closed          cron time        repository_dispatch
       │                    │                    │
       ▼                    ▼                    ▼
   PR Checks          Health Check          Deployment
```

---

# Project Structure

```text
.github/
└── workflows/
    ├── pr-lifecycle.yml
    ├── pr-checks.yml
    ├── scheduled-tasks.yml
    ├── smart-triggers.yml
    ├── docs-ignore.yml
    ├── tests.yml
    ├── deploy-after-tests.yml
    └── external-trigger.yml

day-47/
└── day-47-advanced-triggers.md
```

---

# Task 1: Pull Request Event Types

## What?

A Pull Request has different lifecycle events.

For this task I used:

```text
opened
synchronize
reopened
closed
```

## Why?

Different actions can require different automation.

For example:

```text
PR opened
   ↓
Run PR checks

New commit pushed
   ↓
Run checks again

PR merged
   ↓
Start deployment
```

## Workflow

File:

```text
.github/workflows/pr-lifecycle.yml
```

```yaml
name: Pull Request Lifecycle

on:
  pull_request:
    types: [opened, synchronize, reopened, closed]

jobs:
  pr-info:
    runs-on: ubuntu-latest

    steps:
      - name: Show PR event information
        run: |
          echo "Event type: ${{ github.event.action }}"
          echo "PR title: ${{ github.event.pull_request.title }}"
          echo "PR author: ${{ github.event.pull_request.user.login }}"
          echo "Source branch: ${{ github.event.pull_request.head.ref }}"
          echo "Target branch: ${{ github.event.pull_request.base.ref }}"

      - name: PR was merged
        if: github.event.action == 'closed' && github.event.pull_request.merged == true
        run: |
          echo "The Pull Request was merged successfully!"
          echo "PR: ${{ github.event.pull_request.title }}"
```

## Important Expressions

### Event type

```yaml
${{ github.event.action }}
```

Examples:

```text
opened
synchronize
reopened
closed
```

### PR title

```yaml
${{ github.event.pull_request.title }}
```

### PR author

```yaml
${{ github.event.pull_request.user.login }}
```

### Source branch

```yaml
${{ github.event.pull_request.head.ref }}
```

### Target branch

```yaml
${{ github.event.pull_request.base.ref }}
```

## PR Merge Check

A closed PR is not always merged.

```text
closed
   │
   ├── merged = true  → Merged
   │
   └── merged = false → Closed without merge
```

Therefore:

```yaml
if: github.event.action == 'closed' && github.event.pull_request.merged == true
```

means:

> Run this step only when the PR is closed and actually merged.

## Testing

I tested the workflow by:

1. Creating a PR from `feature-login` to `main`
2. Checking the `opened` event
3. Pushing another commit to the PR
4. Checking the `synchronize` event
5. Merging the PR
6. Checking the `closed` event
7. Verifying the merged step ran

---

# Task 2: Pull Request Validation Workflow

## What?

This workflow acts as a basic **PR quality gate**.

It checks:

```text
File size
Branch name
PR description
```

## Why?

Before allowing changes into `main`, we can automatically check whether the Pull Request follows project rules.

```text
Pull Request
     │
     ├── File size check
     ├── Branch name check
     └── PR body check
```

## Workflow

File:

```text
.github/workflows/pr-checks.yml
```

```yaml
name: PR Validation Checks

on:
  pull_request:
    branches:
      - main

jobs:

  file-size-check:
    name: Check File Sizes
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Check for files larger than 1 MB
        run: |
          echo "Checking files larger than 1 MB..."

          large_files=$(find . -type f \
            -not -path './.git/*' \
            -size +1M)

          if [ -n "$large_files" ]; then
            echo "❌ Files larger than 1 MB found:"
            echo "$large_files"
            exit 1
          fi

          echo "✅ All files are within the 1 MB limit."


  branch-name-check:
    name: Check Branch Name
    runs-on: ubuntu-latest

    steps:
      - name: Check branch name
        env:
          BRANCH_NAME: ${{ github.head_ref }}
        run: |
          echo "Checking branch: $BRANCH_NAME"

          if [[ "$BRANCH_NAME" =~ ^(feature|fix|docs)/.+ ]]; then
            echo "✅ Branch name is valid."
          else
            echo "❌ Invalid branch name: $BRANCH_NAME"
            echo "Branch must start with:"
            echo "  feature/"
            echo "  fix/"
            echo "  docs/"
            exit 1
          fi


  pr-body-check:
    name: Check PR Description
    runs-on: ubuntu-latest

    steps:
      - name: Check PR body
        env:
          PR_BODY: ${{ github.event.pull_request.body }}
        run: |
          if [ -z "$PR_BODY" ]; then
            echo "::warning::PR description is empty. Please add a description."
          else
            echo "✅ PR description is present."
          fi
```

## Branch Name Rule

Allowed branch names:

```text
feature/login
feature/payment
fix/login
fix/header
docs/readme
docs/github-actions
```

The regular expression is:

```regex
^(feature|fix|docs)/.+
```

### Example

```text
fix/login
   │
   └── valid
```

The branch must start with:

```text
feature/
fix/
docs/
```

and must have a name after `/`.

## PR Body Check

The workflow reads:

```yaml
${{ github.event.pull_request.body }}
```

If the PR description is empty, it produces a warning:

```text
⚠️ PR description is empty.
```

It does **not** fail the job because this is only a warning.

## Testing

I tested the branch validation using a badly named branch.

Example:

```text
login-work → main
```

Result:

```text
❌ Invalid branch name
```

A valid branch such as:

```text
fix/login → main
```

passes the check.

---

# Task 3: Scheduled Workflows

## What?

A scheduled workflow runs automatically according to a **cron expression**.

## Why?

Scheduled workflows are useful for tasks that need to happen regularly without a developer pushing code.

Examples:

```text
Every 6 hours
    ↓
Health check

Every Monday
    ↓
Security scan

Every month
    ↓
Maintenance task
```

## Workflow

File:

```text
.github/workflows/scheduled-tasks.yml
```

```yaml
name: Scheduled Tasks

on:
  schedule:
    # Every Monday at 2:30 AM UTC
    - cron: '30 2 * * 1'

    # Every 6 hours
    - cron: '0 */6 * * *'

  workflow_dispatch:

jobs:
  scheduled-health-check:
    name: Scheduled Health Check
    runs-on: ubuntu-latest

    steps:
      - name: Show triggered schedule
        run: |
          echo "Workflow triggered by schedule:"
          echo "${{ github.event.schedule }}"

      - name: Health check
        run: |
          echo "Checking website health..."

          response=$(curl -s -o /dev/null -w "%{http_code}" https://example.com)

          echo "HTTP response code: $response"

          if [ "$response" -ne 200 ]; then
            echo "❌ Health check failed!"
            exit 1
          fi

          echo "✅ Health check passed!"
```

## Cron Syntax

Cron has five fields:

```text
minute hour day-of-month month day-of-week
```

Example:

```text
30 2 * * 1
│  │ │ │ │
│  │ │ │ └── Monday
│  │ │ └──── Every month
│  │ └────── Every day
│  └──────── 2 AM
└─────────── 30 minutes
```

Therefore:

```text
30 2 * * 1
```

means:

> Every Monday at 2:30 AM UTC.

---

## Cron: Every 6 Hours

```text
0 */6 * * *
```

Runs at:

```text
00:00 UTC
06:00 UTC
12:00 UTC
18:00 UTC
```

---

# Cron Notes

## Every weekday at 9 AM IST

IST is UTC + 5:30.

```text
09:00 IST
-05:30
────────
03:30 UTC
```

Cron:

```text
30 3 * * 1-5
```

Meaning:

> Monday to Friday at 9:00 AM IST.

---

## First day of every month at midnight UTC

Cron:

```text
0 0 1 * *
```

Meaning:

> At midnight UTC on the first day of every month.

In IST:

```text
5:30 AM IST
```

---

## Why can scheduled workflows be delayed?

GitHub scheduled workflows are not guaranteed to start at the exact scheduled time.

They can be delayed when GitHub Actions has high load, especially around the beginning of an hour.

Scheduled workflows can also be automatically disabled for repositories that remain inactive for a prolonged period.

Therefore, cron scheduling should not be treated as an exact real-time scheduler.

---

## Why use `workflow_dispatch`?

Without:

```yaml
workflow_dispatch:
```

I would have to wait for the scheduled time.

With it, I can manually test the workflow immediately from:

```text
GitHub
  ↓
Actions
  ↓
Scheduled Tasks
  ↓
Run workflow
```

---

# Task 4: Path & Branch Filters

## What?

Path and branch filters allow GitHub Actions to run only when relevant branches or files change.

## Why?

They prevent unnecessary workflow runs and save CI resources.

For example:

```text
README.md changed
      ↓
No application CI needed
```

But:

```text
src/app.js changed
      ↓
Run application CI
```

## Workflow

File:

```text
.github/workflows/smart-triggers.yml
```

```yaml
name: Smart Push Triggers

on:
  push:
    branches:
      - main
      - 'release/*'

    paths:
      - 'src/**'
      - 'app/**'

jobs:
  smart-build:
    runs-on: ubuntu-latest

    steps:
      - name: Show trigger information
        run: |
          echo "Workflow triggered because src/ or app/ changed."
          echo "Branch: ${{ github.ref_name }}"

      - name: Run build
        run: |
          echo "Running application build..."
```

## `paths`

```yaml
paths:
  - 'src/**'
  - 'app/**'
```

means:

> Run the workflow only when files inside `src/` or `app/` change.

Examples:

```text
src/login.js       → Run
src/utils/api.js   → Run
app/index.js       → Run
README.md          → Skip
docs/setup.md      → Skip
```

---

# `paths-ignore`

A second workflow can ignore documentation changes.

File:

```text
.github/workflows/docs-ignore.yml
```

```yaml
name: Ignore Documentation Changes

on:
  push:
    branches:
      - main
      - 'release/*'

    paths-ignore:
      - '*.md'
      - 'docs/**'

jobs:
  application-check:
    runs-on: ubuntu-latest

    steps:
      - name: Run application checks
        run: |
          echo "Application-related files changed."
          echo "Running application checks..."
```

## `paths` vs `paths-ignore`

### `paths`

Use when:

> The workflow should run **ONLY** when specific files or directories change.

```text
paths
  ↓
"Run ONLY for these paths"
```

### `paths-ignore`

Use when:

> The workflow should normally run, but documentation or other unimportant changes should be ignored.

```text
paths-ignore
  ↓
"Run for everything EXCEPT these paths"
```

---

# Task 5: `workflow_run` — Chain Workflows

## What?

`workflow_run` allows one workflow to react after another workflow completes.

Example:

```text
Run Tests
    │
    │ completed
    ▼
Deploy After Tests
```

## Why?

This is useful for CI/CD.

We don't want:

```text
Tests fail
   ↓
Deploy anyway ❌
```

We want:

```text
Tests pass
   ↓
Deploy ✅
```

---

## Workflow 1: Tests

File:

```text
.github/workflows/tests.yml
```

```yaml
name: Run Tests

on:
  push:

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      - name: Run tests
        run: |
          echo "Running tests..."
          echo "Tests passed!"
```

---

## Workflow 2: Deploy After Tests

File:

```text
.github/workflows/deploy-after-tests.yml
```

```yaml
name: Deploy After Tests

on:
  workflow_run:
    workflows: ["Run Tests"]
    types:
      - completed

jobs:

  check-tests:
    runs-on: ubuntu-latest

    steps:
      - name: Check test result
        run: |
          if [ "${{ github.event.workflow_run.conclusion }}" != "success" ]; then
            echo "::warning::Tests failed. Deployment will not continue."
            exit 1
          fi

          echo "✅ Tests succeeded."
          echo "Deployment can continue."

  deploy:
    needs: check-tests
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest

    steps:
      - name: Deploy
        run: |
          echo "🚀 Deploying application..."
```

## Important Expression

```yaml
${{ github.event.workflow_run.conclusion }}
```

can contain values such as:

```text
success
failure
cancelled
```

The deployment condition is:

```yaml
if: ${{ github.event.workflow_run.conclusion == 'success' }}
```

Therefore deployment happens only when the test workflow succeeds.

---

# Testing `workflow_run`

Push a commit:

```bash
git add .
git commit -m "Test workflow chaining"
git push
```

Expected sequence:

```text
Push
 │
 ▼
Run Tests
 │
 │ success
 ▼
Deploy After Tests
 │
 ▼
Deploy
```

If tests fail:

```text
Push
 │
 ▼
Run Tests
 │
 │ failure
 ▼
Deploy After Tests
 │
 ▼
⚠️ Deployment stopped
```

---

# `workflow_run` vs `workflow_call`

This is an important difference.

## `workflow_run`

Used when:

> One workflow should react to another workflow completing.

Example:

```text
Tests
  ↓
workflow_run
  ↓
Deploy
```

The second workflow starts **after the first workflow runs**.

---

## `workflow_call`

Used when:

> One workflow wants to directly call and reuse another workflow.

Example:

```text
Main CI
  │
  ├── Call frontend workflow
  │
  └── Call backend workflow
```

Example:

```yaml
jobs:
  frontend:
    uses: ./.github/workflows/frontend.yml
```

The called workflow must use:

```yaml
on:
  workflow_call:
```

### Easy comparison

| Feature      | `workflow_run`          | `workflow_call`             |
| ------------ | ----------------------- | --------------------------- |
| Purpose      | React after workflow    | Reuse workflow              |
| Relationship | Workflow A → Workflow B | Workflow A calls Workflow B |
| Trigger      | After completion        | Explicit call               |
| Common use   | CI → CD                 | Reusable CI jobs            |
| Example      | Tests → Deploy          | Main CI → Frontend CI       |

### Easy memory trick

```text
workflow_run
     ↓
"Run AFTER another workflow"

workflow_call
     ↓
"CALL another workflow"
```

---

# Task 6: `repository_dispatch`

## What?

`repository_dispatch` allows an **external system** to trigger GitHub Actions.

Normally:

```text
GitHub event
   ↓
GitHub Actions
```

With `repository_dispatch`:

```text
External system
      ↓
GitHub API
      ↓
GitHub Actions
```

## Why?

This is useful when something outside GitHub needs to start automation.

Examples:

* Slack bot
* Monitoring system
* External CI/CD platform
* Release management system
* Ticketing system
* Cloud automation system

---

## Workflow

File:

```text
.github/workflows/external-trigger.yml
```

```yaml
name: External Trigger

on:
  repository_dispatch:
    types:
      - deploy-request

jobs:
  external-deployment:
    runs-on: ubuntu-latest

    steps:
      - name: Show deployment request
        run: |
          echo "External deployment request received!"
          echo "Environment: ${{ github.event.client_payload.environment }}"
```

---

# Trigger Using GitHub CLI

I used:

```bash
gh api repos/alank8s-cloud-code/github-actions-practice/dispatches \
  -f event_type=deploy-request \
  -f 'client_payload[environment]=production'
```

This creates a payload equivalent to:

```json
{
  "event_type": "deploy-request",
  "client_payload": {
    "environment": "production"
  }
}
```

The workflow receives:

```text
environment = production
```

and prints:

```text
External deployment request received!
Environment: production
```

---

# Why the Original `client_payload` Command Failed

This command:

```bash
-F client_payload='{"environment":"production"}'
```

sent the JSON-looking value as a string rather than creating the nested object required by the API.

The working command:

```bash
-f 'client_payload[environment]=production'
```

uses GitHub CLI's nested field syntax.

It creates:

```json
"client_payload": {
  "environment": "production"
}
```

which is the correct structure.

---

# Checking the Workflow with `gh`

After triggering the event:

```bash
gh workflow list
```

Check the workflow runs:

```bash
gh run list --workflow=external-trigger.yml
```

View the latest run:

```bash
gh run view --log
```

Expected output:

```text
External deployment request received!
Environment: production
```

---

# When Would an External System Trigger a Pipeline?

An external system triggers a pipeline when an event happens **outside GitHub** and that event needs GitHub Actions to perform automation.

### Slack example

```text
Developer
    │
    │ /deploy production
    ▼
Slack Bot
    │
    │ GitHub API
    ▼
repository_dispatch
    │
    ▼
GitHub Actions
    │
    ▼
Production Deployment
```

### Monitoring example

```text
Monitoring Tool
      │
      │ Detects an event
      ▼
GitHub API
      │
      ▼
repository_dispatch
      │
      ▼
GitHub Actions
      │
      ▼
Health Check / Recovery
```

### Key point

> `repository_dispatch` is useful when an external application needs to tell GitHub Actions that something happened and a workflow should run.

---

# Final Trigger Comparison

After completing Day 47, I understand these triggers:

| Trigger               | Purpose                              |
| --------------------- | ------------------------------------ |
| `push`                | Run when code is pushed              |
| `pull_request`        | Run when PR activity occurs          |
| `schedule`            | Run automatically according to cron  |
| `workflow_dispatch`   | Manually run a workflow              |
| `workflow_run`        | Run after another workflow completes |
| `repository_dispatch` | Run from an external system          |

---

# Advanced Trigger Architecture

```text
                         GitHub Actions
                              │
       ┌──────────────────────┼──────────────────────┐
       │                      │                      │
       ▼                      ▼                      ▼
 Pull Request              Schedule             External API
       │                      │                      │
       ▼                      ▼                      ▼
 PR Lifecycle             Cron Jobs          repository_dispatch
       │                      │                      │
       ▼                      ▼                      ▼
 PR Validation             Health Check        External Deploy
       │
       ▼
     main
       │
       ▼
  Tests Workflow
       │
       │ workflow_run
       ▼
 Deploy Workflow
```

---

# Key Lessons

### 1. PR events

I learned how to respond to specific Pull Request activities:

```text
opened
synchronize
reopened
closed
```

### 2. PR validation

I learned how to enforce repository rules:

```text
File size
Branch naming
PR description
```

### 3. Cron

I learned that GitHub Actions cron uses:

```text
minute hour day-of-month month day-of-week
```

and scheduled workflows use UTC.

### 4. Path filters

I learned:

```text
paths
    ↓
Run ONLY for matching paths

paths-ignore
    ↓
Skip when changes are only in ignored paths
```

### 5. Workflow chaining

I learned:

```text
workflow_run
    ↓
React after another workflow completes
```

### 6. External triggers

I learned:

```text
repository_dispatch
    ↓
External system → GitHub Actions
```

---

# Interview Questions

### Q1. What is `workflow_dispatch`?

It allows a user to manually start a GitHub Actions workflow.

### Q2. What is `repository_dispatch`?

It allows an external system to trigger a GitHub Actions workflow through the GitHub API.

### Q3. What is `workflow_run`?

It triggers a workflow based on the completion of another workflow.

### Q4. What is the difference between `workflow_run` and `workflow_call`?

`workflow_run` reacts **after another workflow runs**, while `workflow_call` allows a workflow to **call and reuse another workflow**.

### Q5. What does `github.event.action` represent?

It represents the specific action that triggered the event, such as:

```text
opened
synchronize
reopened
closed
```

### Q6. What is `github.head_ref`?

For a Pull Request, it represents the **source branch**.

Example:

```text
feature/login → main
      ↑
github.head_ref
```

### Q7. What is `github.event.pull_request.base.ref`?

It represents the **target branch**.

```text
feature/login → main
                 ↑
              base.ref
```

### Q8. Why use path filters?

To prevent unnecessary workflow runs when unrelated files are changed.

---

# Day 47 Summary

Today I moved beyond basic GitHub Actions triggers and learned how to build more intelligent event-driven automation.

The most important concepts were:

```text
PR Events
    ↓
opened / synchronize / reopened / closed

Cron
    ↓
Scheduled automation

Path Filters
    ↓
Run only when relevant files change

workflow_run
    ↓
Chain workflows

repository_dispatch
    ↓
External systems trigger workflows
```

These concepts are important for building efficient and production-style CI/CD pipelines.
