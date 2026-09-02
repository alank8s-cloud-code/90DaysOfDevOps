# Day 43 – Jobs, Steps, Env Vars & Conditionals

## What I Learned

Today I learned how GitHub Actions controls the flow of a CI/CD pipeline using:

* Multiple jobs
* Job dependencies
* Environment variables
* GitHub context variables
* Job outputs
* Conditions
* Error handling
* Parallel jobs

---

# Task 1: Multi-Job Workflow

## What?

A GitHub Actions workflow can contain multiple jobs.

For this task, I created three jobs:

* `build` → Builds the application
* `test` → Runs tests
* `deploy` → Deploys the application

The jobs are connected using `needs`.

```text
build
  ↓
test
  ↓
deploy
```

## Why?

In a real CI/CD pipeline, some tasks must happen in a specific order.

For example:

```text
Build application
       ↓
Run tests
       ↓
Deploy application
```

There is no reason to deploy if the tests fail.

## How?

The `needs` keyword creates a dependency between jobs.

```text
test needs build
deploy needs test
```

This means:

* `test` waits for `build`
* `deploy` waits for `test`
* If `build` fails, `test` does not run
* If `test` fails, `deploy` does not run

## Expected Result

The Actions workflow graph should show:

```text
┌─────────────┐
│    build    │
└──────┬──────┘
       ↓
┌─────────────┐
│    test     │
└──────┬──────┘
       ↓
┌─────────────┐
│   deploy    │
└─────────────┘
```

## Output Screenshot

After running the workflow:

1. Open GitHub
2. Go to **Actions**
3. Select the workflow
4. Open the workflow run
5. Capture the **workflow graph**
6. Save the screenshot in your repository, for example:

```text
images/day-43/task-1-multi-job.png
```

Then add it to the README:

```markdown
![Task 1 Output](images/day-43/task-1-multi-job.png)
```

---

# Task 2: Environment Variables

## What?

GitHub Actions allows environment variables to be defined at different levels.

I used three levels:

```text
Workflow level
    APP_NAME = myapp

Job level
    ENVIRONMENT = staging

Step level
    VERSION = 1.0.0
```

## Why?

Environment variables allow us to store values that can be reused by commands and steps.

They are especially useful for values such as:

* Application names
* Environments
* Versions
* Configuration values

Different levels provide different scopes.

## Three Levels

### 1. Workflow Level

```text
APP_NAME= myapp
```

Available to jobs and steps in the workflow.

### 2. Job Level

```text
ENVIRONMENT= staging
```

Available to steps inside that job.

### 3. Step Level

```text
VERSION= 1.0.0
```

Available only inside that step.

## GitHub Context Variables

GitHub Actions also provides information about the workflow run through contexts.

For example:

```text
github.sha
```

Gives the commit SHA.

```text
github.actor
```

Gives the GitHub user who triggered the workflow.

## Scope

```text
Workflow
│
├── APP_NAME
│
└── Job
    │
    ├── ENVIRONMENT
    │
    └── Step
        │
        └── VERSION
```

## Expected Output

The workflow should print something similar to:

```text
APP_NAME: myapp
ENVIRONMENT: staging
VERSION: 1.0.0
Commit SHA: <commit-sha>
Actor: <github-username>
```

## Output Screenshot

After running the workflow:

1. Open the workflow run
2. Open the step that prints the variables
3. Capture the output
4. Save it as:

```text
images/day-43/task-2-environment-variables.png
```

Then add:

```markdown
![Task 2 Output](images/day-43/task-2-environment-variables.png)
```

---

# Task 3: Job Outputs

## What?

A job can create an output and another job can use that output.

For this task, the first job generates today's date.

The second job receives that date and prints it.

The flow is:

```text
Step
  ↓
Step Output
  ↓
Job Output
  ↓
needs.<job>.outputs.<name>
  ↓
Another Job
```

## Why?

Jobs normally run in separate environments.

If one job generates some information that another job needs, we can pass that information using **job outputs**.

For example, a build job could generate:

```text
VERSION=1.2.0
```

Then a deployment job could use that version.

Other examples include:

* Build version
* Image tag
* Release number
* Generated date
* File name
* Deployment information

## How?

First, a step creates an output using:

```text
$GITHUB_OUTPUT
```

The job then exposes that step output through:

```text
outputs:
```

The next job accesses it using:

```text
needs.<job>.outputs.<name>
```

For example:

```text
needs.create-output.outputs.date_value
```

## Important Concept

There are two different levels of outputs:

### Step Output

```text
steps.date.outputs.date
```

### Job Output

```text
needs.create-output.outputs.date_value
```

The complete flow is:

```text
Generate date
     ↓
steps.date.outputs.date
     ↓
create-output job
     ↓
date_value
     ↓
needs.create-output.outputs.date_value
     ↓
use-output job
```

## Expected Output

The second job should print something similar to:

```text
Date from previous job: Wed Sep 2 08:00:00 IST 2026
```

## Why Pass Outputs Between Jobs?

I would pass outputs between jobs when one job produces information that another job needs.

For example:

```text
Build Job
   ↓
Generate Docker image tag
   ↓
Job Output
   ↓
Deploy Job
   ↓
Deploy that image tag
```

This allows jobs to communicate without hardcoding values.

## Output Screenshot

After running the workflow:

1. Open the workflow run
2. Open the second job
3. Open the step that prints the date
4. Capture the output
5. Save it as:

```text
images/day-43/task-3-job-output.png
```

Then add:

```markdown
![Task 3 Output](images/day-43/task-3-job-output.png)
```

---

# Task 4: Conditionals

## What?

GitHub Actions allows steps and jobs to run only when specific conditions are true.

For this task, I practiced four conditional concepts:

1. Run a step only on `main`
2. Run a step when the previous step fails
3. Run a job only for push events
4. Continue the job even if a step fails

---

## 4.1 Step Only on Main

### What?

A step can check the current branch.

The condition is:

```text
github.ref_name == 'main'
```

### Why?

Some operations should only happen on the main branch.

For example:

```text
Feature branch
    ↓
Testing only

main branch
    ↓
Testing
    ↓
Production deployment
```

This prevents accidental production operations from feature branches.

---

## 4.2 Step Only When Previous Step Fails

### What?

GitHub Actions provides the:

```text
failure()
```

condition.

It allows a step to run when a previous step has failed.

### Why?

This is useful for failure handling.

For example:

```text
Test
 ↓
❌ Failed
 ↓
Collect logs
 ↓
Show error information
```

Instead of stopping immediately, we can run a troubleshooting step.

---

## 4.3 Job Only on Push Events

### What?

GitHub provides the event name through:

```text
github.event_name
```

For a push event:

```text
github.event_name == 'push'
```

### Why?

A workflow can be triggered by different events, such as:

```text
push
pull_request
workflow_dispatch
```

Sometimes a job should run only for pushes.

For example:

```text
Pull Request
     ↓
Run tests

Push
     ↓
Run tests
     ↓
Deploy
```

This allows us to control what happens for different GitHub events.

---

## 4.4 continue-on-error

### What?

```text
continue-on-error: true
```

means:

> If this step fails, continue running the next steps instead of stopping the job.

### Why?

It can be useful for optional checks.

For example:

```text
Optional security scan
       ↓
     ❌ fails
       ↓
Continue anyway
       ↓
Build application
```

Without `continue-on-error`, a failed step normally stops the remaining steps in the job.

## Expected Result

I verified that:

* The `main` condition runs only on `main`
* `failure()` runs after a failed step
* The push-only job does not run for pull requests
* `continue-on-error` allows later steps to continue

## Output Screenshot

After running the conditional workflows:

1. Open the workflow run
2. Open the relevant job/steps
3. Capture the result showing the conditional behavior
4. Save it as:

```text
images/day-43/task-4-conditionals.png
```

Then add:

```markdown
![Task 4 Output](images/day-43/task-4-conditionals.png)
```

---

# Task 5: Putting It Together

## What?

This task combines the concepts learned throughout Day 43.

The workflow contains:

```text
push to any branch
        ↓
   ┌────┴────┐
   ↓         ↓
 lint       test
   │         │
   └────┬────┘
        ↓
     summary
```

The `lint` and `test` jobs run independently, so they can run in parallel.

The `summary` job waits for both.

## Why?

This represents a more realistic CI pipeline.

We don't need to wait for linting to finish before starting tests.

Instead:

```text
             ┌── lint ──┐
             │           │
push ────────┤           ├── summary
             │           │
             └── test ──┘
```

This can make a CI pipeline faster.

The summary job then runs only after both checks finish.

## Branch Detection

The summary job checks whether the push was made to:

```text
main
```

or another branch.

For example:

```text
Push to main
     ↓
"This is a main branch push"
```

For another branch:

```text
Push to feature-login
     ↓
"This is a feature branch push"
```

## Commit Message

The summary also prints the commit message from the push event.

This is useful because the pipeline can report information about exactly what triggered the workflow.

The important GitHub context value is:

```text
github.event.head_commit.message
```

## Expected Output

For a main branch push:

```text
This is a main branch push
Commit message: Update application
```

For a feature branch:

```text
This is a feature branch push
Commit message: Add login feature
```

## Workflow Graph

The expected dependency structure is:

```text
                 ┌──────────┐
                 │   lint   │
                 └────┬─────┘
                      │
                      │
push ─────────────────┼──────→ summary
                      │
                 ┌────┴─────┐
                 │   test   │
                 └──────────┘
```

`lint` and `test` are independent and can run in parallel.

`summary` waits for both.

## Output Screenshot

After pushing to both `main` and a feature branch:

1. Open **GitHub → Actions**
2. Open the workflow run
3. Verify `lint` and `test` run in parallel
4. Verify `summary` runs after both
5. Open the summary output
6. Capture the branch and commit message
7. Save it as:

```text
images/day-43/task-5-smart-pipeline.png
```

Then add:

```markdown
![Task 5 Output](images/day-43/task-5-smart-pipeline.png)
```

---

# Day 43 Key Concepts

## 1. Job Dependency

```text
needs
```

Controls the order in which jobs run.

```text
build → test → deploy
```

---

## 2. Environment Variables

```text
Workflow level
Job level
Step level
```

Different levels provide different scopes.

---

## 3. GitHub Context

GitHub provides information about the workflow through contexts.

Examples:

```text
github.sha
github.actor
github.ref_name
github.event_name
github.event.head_commit.message
```

---

## 4. Job Outputs

A job can pass data to another job.

```text
Step output
     ↓
Job output
     ↓
needs.job.outputs.name
```

---

## 5. Conditions

Conditions control when jobs or steps execute.

Examples:

```text
if: main branch
if: failure()
if: push event
```

---

## 6. Error Handling

```text
continue-on-error: true
```

Allows a job to continue after a step fails.

---

# What I Learned Today

* How to create multiple jobs in GitHub Actions
* How `needs` creates job dependencies
* How jobs can run in parallel
* How environment variables work at workflow, job, and step levels
* How to use GitHub context variables
* How to create and pass job outputs
* How to use `if` conditions
* How `failure()` works
* How to detect push events
* How `continue-on-error` works
* How to combine these concepts into a CI pipeline
