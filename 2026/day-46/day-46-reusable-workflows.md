# Day 46 – Reusable Workflows & Composite Actions

## Objective

Learn how to avoid repeating GitHub Actions workflow logic by using:

* Reusable Workflows
* `workflow_call`
* Workflow inputs and secrets
* Workflow outputs
* Composite Actions
* Step outputs
* Job dependencies with `needs:`

---

# What is a Reusable Workflow?

A **reusable workflow** is a GitHub Actions workflow that can be called by another workflow.

It is similar to a function in programming:

```text
Caller Workflow
      |
      | calls
      v
Reusable Workflow
      |
      +---- Build
      +---- Test
      +---- Scan
```

Instead of copying the same jobs into multiple workflows, we can create the workflow once and reuse it.

### Why use reusable workflows?

* Avoid duplicate YAML
* Make CI/CD pipelines consistent
* Reuse workflows across repositories
* Make maintenance easier
* Pass inputs and secrets
* Return outputs to the caller workflow

---

# What is `workflow_call`?

`workflow_call` is the trigger that makes a workflow reusable.

```yaml
on:
  workflow_call:
```

It means:

> This workflow can be called by another workflow.

A reusable workflow must be located inside:

```text
.github/workflows/
```

Example:

```text
.github/
└── workflows/
    └── reusable-build.yml
```

---

#  Reusable Workflow vs Regular Action

A regular action is normally used inside a job's `steps:`:

```yaml
steps:
  - uses: actions/checkout@v4
```

A reusable workflow is called at the **job level**:

```yaml
jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
```

### Main difference

```text
Regular Action
     |
     v
Reusable Steps


Reusable Workflow
     |
     v
Reusable Jobs
```

---

# Task 2 – Create the Reusable Workflow

File:

```text
.github/workflows/reusable-build.yml
```

```yaml
name: Reusable Build

on:
  workflow_call:
    inputs:
      app_name:
        description: "Name of the application"
        required: true
        type: string

      environment:
        description: "Deployment environment"
        required: true
        type: string
        default: staging

    secrets:
      docker_token:
        description: "Docker authentication token"
        required: true

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build application
        run: |
          echo "Building ${{ inputs.app_name }} for ${{ inputs.environment }}"

      - name: Check Docker token
        run: |
          if [ -n "${{ secrets.docker_token }}" ]; then
            echo "Docker token is set: true"
          else
            echo "Docker token is set: false"
          fi
```

## Important concepts

### Inputs

```yaml
inputs:
  app_name:
    required: true
    type: string
```

The caller must provide `app_name`.

```yaml
environment:
  required: true
  type: string
  default: staging
```

The caller can provide an environment. If it does not, `staging` is used.

### Secret

```yaml
secrets:
  docker_token:
    required: true
```

The caller must provide a secret called `docker_token`.

The actual secret should **never be printed**.

---

# Task 3 – Create the Caller Workflow

File:

```text
.github/workflows/call-build.yml
```

```yaml
name: Call Reusable Build

on:
  push:
    branches:
      - main

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml

    with:
      app_name: "my-web-app"
      environment: "production"

    secrets:
      docker_token: ${{ secrets.DOCKER_TOKEN }}
```

## Flow

```text
Push to main
     |
     v
call-build.yml
     |
     | uses
     v
reusable-build.yml
     |
     +---- Checkout
     |
     +---- Build application
     |
     +---- Check Docker token
```

The caller provides:

```text
app_name    = my-web-app
environment = production
docker_token = GitHub Secret
```

The reusable workflow receives them through:

```yaml
${{ inputs.app_name }}
${{ inputs.environment }}
${{ secrets.docker_token }}
```

---

# Task 4 – Add Outputs

A reusable workflow can return a value to its caller.

The output flow is:

```text
Step Output
     |
     v
Job Output
     |
     v
Reusable Workflow Output
     |
     v
Caller Workflow
     |
     v
Another Job
```

---

## Updated `reusable-build.yml`

```yaml
name: Reusable Build

on:
  workflow_call:
    inputs:
      app_name:
        description: "Name of the application"
        required: true
        type: string

      environment:
        description: "Deployment environment"
        required: true
        type: string
        default: staging

    secrets:
      docker_token:
        description: "Docker authentication token"
        required: true

    outputs:
      build_version:
        description: "Generated build version"
        value: ${{ jobs.build.outputs.build_version }}

jobs:
  build:
    runs-on: ubuntu-latest

    outputs:
      build_version: ${{ steps.version.outputs.build_version }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build application
        run: |
          echo "Building ${{ inputs.app_name }} for ${{ inputs.environment }}"

      - name: Check Docker token
        run: |
          if [ -n "${{ secrets.docker_token }}" ]; then
            echo "Docker token is set: true"
          else
            echo "Docker token is set: false"
          fi

      - name: Generate build version
        id: version
        run: |
          SHORT_SHA=$(git rev-parse --short HEAD)
          VERSION="v1.0-${SHORT_SHA}"

          echo "Build version: $VERSION"
          echo "build_version=$VERSION" >> "$GITHUB_OUTPUT"
```

---

# Understanding the Output

The step creates the output:

```bash
echo "build_version=$VERSION" >> "$GITHUB_OUTPUT"
```

Because the step has:

```yaml
id: version
```

we can access it as:

```yaml
steps.version.outputs.build_version
```

The job then exposes that step output:

```yaml
jobs:
  build:
    outputs:
      build_version: ${{ steps.version.outputs.build_version }}
```

The reusable workflow exposes the job output:

```yaml
on:
  workflow_call:
    outputs:
      build_version:
        value: ${{ jobs.build.outputs.build_version }}
```

Therefore:

```text
Step
  |
  | steps.version.outputs.build_version
  v
Job
  |
  | jobs.build.outputs.build_version
  v
Reusable Workflow
  |
  | workflow_call.outputs.build_version
  v
Caller Workflow
```

---

# Caller Workflow with Second Job

```yaml
name: Call Reusable Build

on:
  push:
    branches:
      - main

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml

    with:
      app_name: "my-web-app"
      environment: "production"

    secrets:
      docker_token: ${{ secrets.DOCKER_TOKEN }}

  show-version:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Print build version
        run: |
          echo "Build Version: ${{ needs.build.outputs.build_version }}"
```

## What does `needs: build` mean?

```yaml
needs: build
```

means:

> Wait for the `build` job to finish before running `show-version`.

Then:

```yaml
${{ needs.build.outputs.build_version }}
```

means:

> Get the `build_version` output from the `build` job.

Expected output:

```text
Build Version: v1.0-a1b2c3d
```

The SHA will be different for each commit.

---

# Task 5 – Create a Composite Action

A **Composite Action** is a reusable collection of steps.

Create:

```text
.github/actions/setup-and-greet/action.yml
```

Directory structure:

```text
.github/
├── actions/
│   └── setup-and-greet/
│       └── action.yml
│
└── workflows/
    ├── reusable-build.yml
    ├── call-build.yml
    └── greet.yml
```

---

# Composite Action YAML

```yaml
name: Setup and Greet

description: Greet a user and show runner information

inputs:
  name:
    description: "Name of the person"
    required: true

  language:
    description: "Greeting language"
    required: false
    default: en

outputs:
  greeted:
    description: "Whether the greeting was completed"
    value: ${{ steps.greeting.outputs.greeted }}

runs:
  using: composite

  steps:
    - name: Print greeting
      id: greeting
      shell: bash
      run: |
        if [ "${{ inputs.language }}" = "en" ]; then
          echo "Hello, ${{ inputs.name }}!"
        elif [ "${{ inputs.language }}" = "fr" ]; then
          echo "Bonjour, ${{ inputs.name }}!"
        elif [ "${{ inputs.language }}" = "es" ]; then
          echo "Hola, ${{ inputs.name }}!"
        else
          echo "Hello, ${{ inputs.name }}!"
        fi

        echo "greeted=true" >> "$GITHUB_OUTPUT"

    - name: Show date and OS
      shell: bash
      run: |
        echo "Current date: $(date)"
        echo "Runner OS: $RUNNER_OS"
```

---

# How the Composite Action Works

The action accepts:

```text
name
language
```

For example:

```yaml
with:
  name: Alan
  language: en
```

The action receives these values through:

```yaml
${{ inputs.name }}
${{ inputs.language }}
```

The action then:

1. Prints a greeting
2. Prints the current date
3. Prints the runner operating system
4. Creates an output called `greeted`

---

# Creating the Caller Workflow for the Composite Action

Create:

```text
.github/workflows/greet.yml
```

```yaml
name: Greeting

on:
  workflow_dispatch:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Use setup-and-greet
        id: greet
        uses: ./.github/actions/setup-and-greet

        with:
          name: Alan
          language: en

      - name: Check output
        run: |
          echo "Greeted: ${{ steps.greet.outputs.greeted }}"
```

---

# Understanding `uses:`

This line:

```yaml
uses: ./.github/actions/setup-and-greet
```

tells GitHub:

> Use my custom Composite Action located at this path.

GitHub finds:

```text
.github/actions/setup-and-greet/action.yml
```

and executes its steps.

---

# Understanding the `greeted` Output

Inside the Composite Action:

```yaml
id: greeting
```

and:

```bash
echo "greeted=true" >> "$GITHUB_OUTPUT"
```

creates a step output.

The action exposes it:

```yaml
outputs:
  greeted:
    value: ${{ steps.greeting.outputs.greeted }}
```

The caller gives the action an ID:

```yaml
id: greet
```

Therefore the caller can access the action output using:

```yaml
${{ steps.greet.outputs.greeted }}
```

So:

```yaml
echo "Greeted: ${{ steps.greet.outputs.greeted }}"
```

prints:

```text
Greeted: true
```

### Output flow

```text
Composite Action
      |
      v
Step: greeting
      |
      | greeted=true
      v
Action output
      |
      v
Caller workflow
      |
      | steps.greet.outputs.greeted
      v
Greeted: true
```

---

# Task 6 – Reusable Workflow vs Composite Action

| Feature                      | Reusable Workflow                         | Composite Action                                 |
| ---------------------------- | ----------------------------------------- | ------------------------------------------------ |
| Triggered by                 | `workflow_call`                           | `uses:` in a step                                |
| Can contain jobs?            | Yes                                       | No                                               |
| Can contain multiple steps?  | Yes                                       | Yes                                              |
| Lives where?                 | `.github/workflows/`                      | `.github/actions/<name>/action.yml`              |
| Can accept secrets directly? | Yes, through `workflow_call.secrets`      | No direct `workflow_call`-style secret interface |
| Best for                     | Reusing complete CI/CD workflows and jobs | Reusing a group of common steps                  |

---

# Reusable Workflow vs Composite Action – Simple Diagram

### Reusable Workflow

```text
Caller Workflow
      |
      | uses
      v
Reusable Workflow
      |
      +---- Job 1
      |       |
      |       +---- Step
      |       +---- Step
      |
      +---- Job 2
              |
              +---- Step
              +---- Step
```

### Composite Action

```text
Caller Workflow
      |
      v
     Job
      |
      v
Composite Action
      |
      +---- Step 1
      +---- Step 2
      +---- Step 3
```

---

# Important Syntax

## Reusable Workflow

```yaml
on:
  workflow_call:
```

## Calling a reusable workflow

```yaml
jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
```

## Passing inputs

```yaml
with:
  app_name: "my-web-app"
  environment: "production"
```

## Passing secrets

```yaml
secrets:
  docker_token: ${{ secrets.DOCKER_TOKEN }}
```

## Accessing inputs

```yaml
${{ inputs.app_name }}
${{ inputs.environment }}
```

## Accessing secrets

```yaml
${{ secrets.docker_token }}
```

## Job dependency

```yaml
needs: build
```

## Accessing job output

```yaml
${{ needs.build.outputs.build_version }}
```

---

# Composite Action Syntax

A Composite Action requires:

```yaml
runs:
  using: composite
```

Its location:

```text
.github/actions/action-name/action.yml
```

Use it in a workflow:

```yaml
steps:
  - uses: ./.github/actions/action-name
```

Pass inputs:

```yaml
with:
  name: Alan
  language: en
```

Access action inputs:

```yaml
${{ inputs.name }}
${{ inputs.language }}
```

---

# What I Learned

### Reusable Workflows

A reusable workflow allows complete jobs/workflows to be reused.

```text
workflow_call
     ↓
Reusable Workflow
     ↓
Jobs
```

### Composite Actions

A Composite Action allows multiple steps to be packaged and reused.

```text
uses:
   ↓
Composite Action
   ↓
Steps
```

### Outputs

I learned how an output can move through multiple levels:

```text
Step Output
     ↓
Job Output
     ↓
Reusable Workflow Output
     ↓
Caller Job
```

I also learned that a Composite Action can expose an output that the caller workflow can access using:

```yaml
${{ steps.<action-id>.outputs.<output-name> }}
```


## Challenges Faced

* Understanding the difference between a **reusable workflow** and a **composite action**.
* Understanding why `workflow_call` is required for reusable workflows.
* Understanding where `runs-on` is used when one workflow calls another workflow.
* Understanding how inputs and secrets are passed from the caller workflow to the reusable workflow.
* Understanding the flow of outputs:
  **step output → job output → reusable workflow output → caller workflow**.
* Understanding why `needs:` is required when the second job depends on the output of the build job.
* Understanding how `steps.<id>.outputs.<name>` works with Composite Actions.
* Understanding the difference between `uses:` at the **job level** for reusable workflows and at the **step level** for actions.
* Working with GitHub Actions YAML structure and keeping the correct indentation.

## What I Learned Today

* Learned what **Reusable Workflows** are and why they are useful for avoiding repeated CI/CD workflows.
* Learned how `workflow_call` makes a workflow reusable.
* Learned how to define and pass **inputs** and **secrets**.
* Learned how a caller workflow uses a reusable workflow with `uses:`.
* Learned how to create and use **workflow outputs**.
* Learned how to pass values from a step to a job and then from the reusable workflow back to the caller.
* Learned how `needs:` creates a dependency between jobs.
* Learned what **Composite Actions** are and how they help reuse multiple steps.
* Learned how to create a custom action using `action.yml` and `runs: using: composite`.
* Learned how to pass inputs to a Composite Action using `with:`.
* Learned how to create and access Composite Action outputs.
* Learned the key difference:

```text
Reusable Workflow → Reuse Jobs / Complete Workflows

Composite Action → Reuse Steps
```

### Key Takeaway

Today I learned how GitHub Actions can be made more **reusable, modular, and maintainable** instead of repeating the same workflow steps in every pipeline.

---
