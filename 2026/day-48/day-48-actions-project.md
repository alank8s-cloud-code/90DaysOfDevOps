# 🚀 Day 48 – GitHub Actions Project: End-to-End CI/CD Pipeline

## 📌 Project Overview

In this project, I will build a complete **CI/CD pipeline using GitHub Actions**.

The pipeline will automatically:

```text
Pull Request
     ↓
Build & Test
     ↓
Merge to main
     ↓
Docker Build & Push
     ↓
Deploy
     ↓
Health Check
```

The main purpose of this project is to combine the GitHub Actions concepts I learned from **Day 40 to Day 47** into one practical project.

---

# 🎯 Task 1 – Set Up the Project Repository

## What is this task?

First, I need a GitHub repository that contains my application, Dockerfile, tests, and GitHub Actions workflows.

For this project, I will use:

```text
github-actions-capstone
```

The application can be a simple Python Flask application with a health endpoint.

For example:

```text
GET /health
```

which returns:

```text
OK
```

## Why do we need this?

GitHub Actions needs an application to work with.

In a real DevOps project, developers write application code, and the CI/CD pipeline automatically tests, packages, and deploys that code.

## What will I add?

```text
github-actions-capstone/
│
├── app/
├── tests/
├── Dockerfile
├── README.md
└── .github/
    └── workflows/
```

I will also add a basic test to verify that the application works.

---

# 🔄 Task 2 – Reusable Workflow: Build & Test

## What is a reusable workflow?

A reusable workflow is a GitHub Actions workflow that can be called by another workflow.

Instead of writing the same build and test steps again and again, I create them once and reuse them.

The workflow will be:

```text
Checkout Code
      ↓
Setup Python
      ↓
Install Dependencies
      ↓
Run Tests
      ↓
Return Result
```

## Why do we need it?

Suppose I have multiple pipelines that need to run tests.

Without a reusable workflow:

```text
Pipeline 1 → Write test steps
Pipeline 2 → Write test steps again
Pipeline 3 → Write test steps again
```

With a reusable workflow:

```text
              ┌→ PR Pipeline
Reusable      │
Build/Test ───┼→ Main Pipeline
              │
              └→ Other Pipeline
```

This reduces duplication and makes the pipeline easier to maintain.

## What will I create?

File:

```text
.github/workflows/reusable-build-test.yml
```

It will use:

```yaml
on:
  workflow_call:
```

It will accept:

```text
python_version
run_tests
```

The `run_tests` input will control whether tests should run.

## Expected result

The workflow should return:

```text
test_result = passed
```

when the tests succeed.

---

# 🐳 Task 3 – Reusable Workflow: Docker Build & Push

## What is this task?

After the application passes the tests, I need to package it into a Docker image.

The Docker workflow will:

```text
Checkout Code
      ↓
Login to Docker Hub
      ↓
Build Docker Image
      ↓
Push Docker Image
      ↓
Return Image URL
```

## Why do we need it?

Docker packages the application and its required environment into an image.

This allows the same image to be used in different environments.

For example:

```text
Developer Machine
       ↓
Docker Image
       ↓
Testing
       ↓
Production
```

## What will I create?

File:

```text
.github/workflows/reusable-docker.yml
```

The workflow will accept:

```text
image_name
tag
```

It will also use Docker Hub secrets:

```text
docker_username
docker_token
```

## Why use secrets?

I should never write my Docker Hub username/password or access token directly inside the workflow.

Instead:

```text
GitHub Secrets
      ↓
Docker Login
```

## Expected result

The workflow will return an image URL such as:

```text
myusername/myapp:latest
```

or:

```text
myusername/myapp:sha-a1b2c3d
```

---

# 🔀 Task 4 – Pull Request Pipeline

## What is this task?

This workflow runs when someone creates or updates a Pull Request targeting the `main` branch.

The trigger will be:

```text
pull_request
```

for:

```text
opened
synchronize
```

## Why do we need it?

Before merging code into `main`, we should verify that the code works.

The PR pipeline should **only test the code**.

It should NOT push a Docker image.

## Pipeline flow

```text
Developer creates PR
        ↓
Build & Test
        ↓
Tests Pass
        ↓
PR Checks Passed
```

## What will I create?

File:

```text
.github/workflows/pr-pipeline.yml
```

It will call:

```text
reusable-build-test.yml
```

with:

```text
run_tests: true
```

Then it will run a `pr-comment` job.

## Important point

There will be **no Docker build or Docker push** in this pipeline.

Why?

Because the code has not been merged into `main` yet.

## Expected result

When I open a PR, GitHub Actions should show:

```text
Build & Test       ✅
PR Comment         ✅
```

and there should be:

```text
Docker Push        ❌
```

---

# 🚀 Task 5 – Main Branch CI/CD Pipeline

## What is this task?

This is the main CI/CD pipeline.

It runs when code is pushed to the `main` branch.

Usually this happens after a Pull Request is merged.

## Why do we need it?

Once code is merged into `main`, we want to automatically:

```text
Test
 ↓
Build Docker Image
 ↓
Push Docker Image
 ↓
Deploy
```

This is the main purpose of **Continuous Integration and Continuous Deployment**.

## Pipeline flow

```text
Push to main
     ↓
Build & Test
     ↓
Docker Build & Push
     ↓
Deploy
```

## Job 1 – Build & Test

The first job calls:

```text
reusable-build-test.yml
```

If tests fail:

```text
Build & Test ❌
```

the next jobs should not run.

---

## Job 2 – Docker Build & Push

This job depends on Job 1.

Therefore:

```yaml
needs: build_test
```

It will create two Docker tags:

```text
latest
```

and:

```text
sha-<short-commit-hash>
```

Example:

```text
myusername/myapp:latest
myusername/myapp:sha-a1b2c3d
```

## Why use SHA tags?

The SHA tag tells me exactly which Git commit created the Docker image.

This is useful for:

* Version tracking
* Debugging
* Rollback
* Identifying deployments

---

## Job 3 – Deploy

The deploy job depends on the Docker job.

```text
Build & Test
      ↓
Docker Build & Push
      ↓
Deploy
```

It will print:

```text
Deploying image: myusername/myapp:latest to production
```

The job will use:

```text
environment: production
```

## Why use a production environment?

GitHub Environments can protect production deployments.

For example, I can configure:

```text
Required reviewers
```

Then someone must approve the deployment before it continues.

---

# ❤️ Task 6 – Scheduled Health Check

## What is a health check?

A health check verifies whether the application is actually working.

A successful Docker deployment does not always mean the application is healthy.

For example:

```text
Docker Container Running ✅
Application Responding ❌
```

A health check helps detect this problem.

## Why do we need it?

We want to continuously verify that the application is available.

The workflow will run:

```text
Every 12 hours
```

It can also be started manually using:

```text
workflow_dispatch
```

## Pipeline flow

```text
Pull Latest Image
       ↓
Run Container
       ↓
Wait 5 Seconds
       ↓
Curl /health
       ↓
PASS / FAIL
       ↓
Stop Container
```

## What will I create?

File:

```text
.github/workflows/health-check.yml
```

The schedule will use:

```yaml
cron: '0 */12 * * *'
```

## GitHub Step Summary

The workflow will create a summary using:

```text
$GITHUB_STEP_SUMMARY
```

Example:

```text
## Health Check Report

- Image: myapp:latest
- Status: PASSED
- Time: current time
```

This makes the result easy to see on the GitHub Actions run page.

---

# 📚 Task 7 – Add Badges & Documentation

## What is this task?

The final step is to document the project.

Documentation explains:

* What the project does
* How the pipeline works
* What workflows are used
* What happens during a PR
* What happens after merging
* How the health check works

## Why do we need documentation?

Documentation is important in real DevOps projects because other developers and engineers need to understand the automation.

It is also useful when explaining the project during an interview.

---

# 🏗️ Pipeline Architecture

The complete pipeline looks like this:

```text
                 ┌─────────────────────┐
                 │    Pull Request     │
                 └──────────┬──────────┘
                            ↓
                    ┌───────────────┐
                    │ Build & Test  │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │  PR Checks    │
                    └───────────────┘


                 PR Merged to main
                            ↓
                    ┌───────────────┐
                    │ Build & Test  │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Docker Build  │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │ Docker Push   │
                    └───────┬───────┘
                            ↓
                    ┌───────────────┐
                    │    Deploy     │
                    └───────────────┘


                  Every 12 Hours
                         ↓
                  ┌───────────────┐
                  │ Health Check  │
                  └───────────────┘
```

---

# 🔐 Brownie Points – DevSecOps with Trivy

## What is Trivy?

Trivy is a security scanner that can scan Docker images for known vulnerabilities.

## Why do we need it?

Security should be part of the CI/CD pipeline.

Instead of deploying an image first and checking security later, I can scan the image before deployment.

The flow becomes:

```text
Build Docker Image
        ↓
Trivy Security Scan
        ↓
No Critical CVE
        ↓
Push Image
        ↓
Deploy
```

If a **CRITICAL** vulnerability is found:

```text
Pipeline ❌
```

This is an example of **DevSecOps**.

---

# 🏷️ Workflow Files

My project will contain at least these five workflow files:

```text
.github/workflows/

├── reusable-build-test.yml
├── reusable-docker.yml
├── pr-pipeline.yml
├── main-pipeline.yml
└── health-check.yml
```

---

# 📊 Complete Workflow Summary

| Workflow                  | Trigger                 | Purpose                     |
| ------------------------- | ----------------------- | --------------------------- |
| `reusable-build-test.yml` | `workflow_call`         | Build and test              |
| `reusable-docker.yml`     | `workflow_call`         | Build and push Docker image |
| `pr-pipeline.yml`         | Pull Request            | Test PR code                |
| `main-pipeline.yml`       | Push to `main`          | Full CI/CD                  |
| `health-check.yml`        | Every 12 hours / Manual | Check application health    |

---

# 🔑 Important GitHub Actions Concepts Used

## `workflow_call`

Used to create reusable workflows.

```text
Main Pipeline
      ↓
workflow_call
      ↓
Reusable Workflow
```

## `needs`

Used to create job dependencies.

```text
Build
 ↓
Docker
 ↓
Deploy
```

## `secrets`

Used to safely store sensitive information.

```text
DOCKER_USERNAME
DOCKER_TOKEN
```

## `environment`

Used to protect environments such as:

```text
production
```

## `schedule`

Used to run workflows automatically at a specific time.

```text
Every 12 hours
```

## `workflow_dispatch`

Allows me to manually start a workflow.

---

# 🧠 What Did I Learn?

From this project, I learned how different GitHub Actions features work together.

### CI

Continuous Integration means automatically building and testing code.

```text
Code
 ↓
Build
 ↓
Test
```

### CD

Continuous Deployment means automatically deploying the application after the required checks pass.

```text
Build
 ↓
Test
 ↓
Docker
 ↓
Deploy
```

---

# 💡 What Would I Add Next?

After completing this project, I would improve the pipeline by adding:

### 1. 🔔 Slack Notifications

Send a message when the pipeline succeeds or fails.

### 2. 🌍 Multiple Environments

Create:

```text
Development
     ↓
Staging
     ↓
Production
```

### 3. 🔄 Rollback

If a deployment fails, deploy the previous working Docker image.

### 4. ☁️ AWS Deployment

Deploy the Docker container to an AWS EC2 instance.

### 5. 🔐 More Security

Add:

```text
Trivy
Secret Scanning
Dependency Scanning
Least-Privilege Permissions
```

---

# 📸 Screenshots

## PR Pipeline

Add a screenshot here showing:

```text
Build & Test ✅
PR Checks Passed ✅
```

---

## Main Pipeline

Add a screenshot here showing:

```text
Build & Test ✅
Docker Build & Push ✅
Deploy ✅
```

---

## Health Check

Add a screenshot showing:

```text
Health Check ✅
Status: PASSED
```

---

# 🐳 Docker Hub

Docker image:

```text
YOUR_DOCKER_HUB_LINK
```

Example:

```text
myusername/myapp:latest
```

---

# 📁 Final Project Structure

```text
github-actions-capstone/
│
├── .github/
│   └── workflows/
│       ├── reusable-build-test.yml
│       ├── reusable-docker.yml
│       ├── pr-pipeline.yml
│       ├── main-pipeline.yml
│       └── health-check.yml
│
├── app/
│   └── application files
│
├── tests/
│   └── test files
│
├── Dockerfile
├── README.md
└── day-48-actions-project.md
```

---

# 🎯 Final Result

After completing all tasks, my CI/CD pipeline will work like this:

```text
                    DEVELOPER
                        │
                        ↓
                  Pull Request
                        │
                        ↓
                 Build & Test
                        │
                        ↓
                  PR Approved
                        │
                        ↓
                  Merge to main
                        │
                        ↓
                 Build & Test
                        │
                        ↓
                 Docker Build
                        │
                        ↓
                  Security Scan
                        │
                        ↓
                 Docker Push
                        │
                        ↓
                    Deploy
                        │
                        ↓
                   Production
                        │
                        ↓
                Health Check
```

---

# 🏆 Day 48 Goal

The goal of Day 48 is not just to create YAML files.

The goal is to understand the **complete DevOps automation flow**:

```text
Code
 ↓
CI
 ↓
Testing
 ↓
Docker
 ↓
Security
 ↓
CD
 ↓
Deployment
 ↓
Monitoring / Health Check
```

By completing this project, I will have practical experience with an **end-to-end GitHub Actions CI/CD pipeline**.
