# Day 42 – GitHub Actions Runners

## Objective

Learn how GitHub Actions runners work, understand the difference between GitHub-hosted and self-hosted runners, use runners on different operating systems, configure a self-hosted runner, use labels, and compare both runner types.

---

# 1. Runners: GitHub-Hosted & Self-Hosted

## What is a Runner?

A **runner** is the machine that actually executes the commands inside a GitHub Actions workflow.

Example:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - run: echo "Hello"
```

The `ubuntu-latest` runner is the machine where the `echo` command executes.

### Basic Workflow

```text
Developer
    |
    | git push
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    v
Runner
    |
    +--> Execute commands
    +--> Run tests
    +--> Build application
    +--> Deploy
```

---

# 2. GitHub-Hosted Runner

## What?

A **GitHub-hosted runner** is a temporary virtual machine provided and managed by GitHub to execute GitHub Actions jobs.

Examples:

```yaml
runs-on: ubuntu-latest
```

```yaml
runs-on: windows-latest
```

```yaml
runs-on: macos-latest
```

## Who manages it?

**GitHub manages the runner.**

GitHub takes care of:

- Creating the machine
- Operating system
- Runner infrastructure
- Many pre-installed tools
- Maintenance and updates
- Cleaning up the temporary environment

### Architecture

```text
GitHub Repository
       |
       v
GitHub Actions
       |
       v
GitHub-Hosted Runner
       |
       +--> Checkout code
       +--> Run tests
       +--> Build
       +--> Deploy
       |
       v
Job completed
       |
       v
Runner cleaned up
```

---

# 3. Self-Hosted Runner

## What?

A **self-hosted runner** is a machine that I provide and manage to execute GitHub Actions jobs.

For this task, my self-hosted runner is running on my own Linux machine.

## Who manages it?

**I manage the machine.**

I am responsible for:

- Operating system
- Security
- Updates
- Installed software
- Disk space
- Network
- Runner process
- Machine availability

### My Runner

```text
My Machine
    |
    +--> Linux
    |
    +--> GitHub Actions Runner
    |
    +--> Runner Name: Matrix
```

---

# 4. Runner Name vs Labels

My self-hosted runner is named:

```text
Matrix
```

The runner has labels:

```text
self-hosted
Linux
X64
my-linux-runner
```

## Matrix

`Matrix` is the **name of my runner**.

## self-hosted

`self-hosted` is a built-in label that identifies the runner as self-hosted.

## Linux

`Linux` is a label identifying the operating system.

## X64

`X64` is a label identifying the CPU architecture.

## my-linux-runner

`my-linux-runner` is a **custom label** that I added.

### Visual Representation

```text
                    RUNNER
                    Matrix
                       |
          +------------+------------+
          |            |            |
     self-hosted     Linux         X64
          |
          +---- my-linux-runner
                Custom Label
```

### Important

This:

```yaml
runs-on: my-linux-runner
```

means:

> Find a runner that has the `my-linux-runner` label.

It does NOT mean:

> Find a runner whose name is `my-linux-runner`.

My actual runner name is:

```text
Matrix
```

---

# Task 1 – GitHub-Hosted Runners

## Objective

Create a workflow with three jobs, each using a different operating system:

- Ubuntu
- Windows
- macOS

Each job prints:

- OS name
- Runner hostname
- Current user

The three jobs should run in parallel.

## File

```text
.github/workflows/hosted-runners.yml
```

## Workflow

```yaml
name: GitHub Hosted Runners

on:
  workflow_dispatch:

jobs:

  ubuntu:
    runs-on: ubuntu-latest

    steps:
      - name: Show runner information
        run: |
          echo "OS name: $(uname -s)"
          echo "Hostname: $(hostname)"
          echo "Current user: $(whoami)"

  windows:
    runs-on: windows-latest

    steps:
      - name: Show runner information
        run: |
          Write-Host "OS name: $env:OS"
          Write-Host "Hostname: $env:COMPUTERNAME"
          Write-Host "Current user: $env:USERNAME"

  macos:
    runs-on: macos-latest

    steps:
      - name: Show runner information
        run: |
          echo "OS name: $(uname -s)"
          echo "Hostname: $(hostname)"
          echo "Current user: $(whoami)"
```

## Why do they run in parallel?

There is no `needs:` dependency between the jobs.

```text
Ubuntu  --------\
                 \
Windows ---------> Run independently
                 /
macOS   --------/
```

If a job uses:

```yaml
needs: ubuntu
```

then it will wait for the Ubuntu job to finish.

## Notes

### What is a GitHub-hosted runner?

A GitHub-hosted runner is a temporary virtual machine provided and managed by GitHub to execute GitHub Actions jobs.

### Who manages it?

GitHub manages the infrastructure and runner environment.

---

# Task 2 – Explore Pre-installed Software

## Objective

On the `ubuntu-latest` runner, print:

- Docker version
- Python version
- Node version
- Git version

## File

```text
.github/workflows/preinstalled-tools.yml
```

## Workflow

```yaml
name: Check Preinstalled Tools

on:
  workflow_dispatch:

jobs:
  tools:
    runs-on: ubuntu-latest

    steps:
      - name: Check tools
        run: |
          echo "Docker:"
          docker --version

          echo "Python:"
          python3 --version

          echo "Node:"
          node --version

          echo "Git:"
          git --version
```

## Why does it matter that runners come with tools pre-installed?

GitHub-hosted runners are temporary. If every runner started with no tools, every workflow would have to install everything first.

Without pre-installed tools:

```text
New Runner
    |
    +--> Install Git
    +--> Install Python
    +--> Install Node
    +--> Install Docker
    |
    v
Run application
```

With pre-installed tools:

```text
New Runner
    |
    +--> Git       ✅
    +--> Python    ✅
    +--> Node      ✅
    +--> Docker    ✅
    |
    v
Run workflow
```

### Benefits

- Faster workflow startup
- Less configuration
- Simpler workflow files
- Less installation overhead

### Important

Pre-installed does not mean every possible version is available.

If a project needs a specific version, configure it explicitly.

Example:

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 20
```

## Documentation

GitHub maintains documentation listing the software available on GitHub-hosted runners. Check the GitHub Actions documentation for the current `ubuntu-latest` software list because the installed software can change over time.

---

# Task 3 – Set Up a Self-Hosted Runner

## Steps

Go to:

```text
GitHub Repository
    |
    v
Settings
    |
    v
Actions
    |
    v
Runners
    |
    v
New self-hosted runner
```

Choose:

```text
Linux
X64
```

GitHub generates the runner setup commands.

Follow the generated instructions on:

- Your local machine, OR
- A cloud VM such as EC2/Utho/VPS

## Start the Runner

To run it manually:

```bash
./run.sh
```

To install it as a persistent service:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

## Verification

In GitHub:

```text
Settings
   |
   v
Actions
   |
   v
Runners
```

The runner should appear as:

```text
Matrix
● Idle
```

A green/online indicator means the runner is connected and available.

### What does Idle mean?

`Idle` means the self-hosted runner is connected to GitHub and currently has no job running.

---

# Task 4 – Use Your Self-Hosted Runner

## Objective

Run a workflow on my own machine.

Create:

```text
.github/workflows/self-hosted.yml
```

## Workflow

```yaml
name: Self Hosted Runner

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: self-hosted

    steps:
      - name: Show hostname
        run: |
          echo "Hostname:"
          hostname

      - name: Show working directory
        run: |
          echo "Working directory:"
          pwd

      - name: Create file
        run: |
          echo "Created by GitHub Actions" > runner-test.txt

      - name: Verify file
        run: |
          ls -l runner-test.txt
          cat runner-test.txt
```

## What happens?

Because:

```yaml
runs-on: self-hosted
```

the commands execute on my self-hosted runner.

The file:

```text
runner-test.txt
```

is created on my runner machine.

Verify it directly on the machine:

```bash
ls -l runner-test.txt
```

Expected:

```text
runner-test.txt
```

---

# Task 5 – Labels

## Objective

Add a custom label:

```text
my-linux-runner
```

to the self-hosted `Matrix` runner.

My labels are now:

```text
self-hosted
Linux
X64
my-linux-runner
```

## Workflow

Update:

```yaml
runs-on: self-hosted
```

to:

```yaml
runs-on: [self-hosted, my-linux-runner]
```

Complete example:

```yaml
name: Self Hosted Runner With Label

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: [self-hosted, my-linux-runner]

    steps:
      - name: Show runner information
        run: |
          echo "Runner name: $RUNNER_NAME"
          echo "OS: $RUNNER_OS"
          echo "Architecture: $RUNNER_ARCH"
          hostname
```

## Does it still pick up the job?

Yes.

The `Matrix` runner has both:

```text
self-hosted
my-linux-runner
```

Therefore GitHub can select it.

## Why are labels useful?

Labels are useful when there are multiple self-hosted runners.

Example:

```text
Runner 1
  Matrix
  Linux
  my-linux-runner

Runner 2
  Server01
  Linux
  docker-runner

Runner 3
  Server02
  Windows
  windows-runner
```

Then:

```yaml
runs-on: [self-hosted, docker-runner]
```

can target the runner with the `docker-runner` label.

Labels allow jobs to be routed to runners with the required characteristics.

---

# Task 6 – GitHub-Hosted vs Self-Hosted

| Comparison | GitHub-Hosted | Self-Hosted |
|---|---|---|
| **Who manages it?** | GitHub | You/your organization |
| **Cost** | Uses GitHub Actions included minutes/usage limits | You pay for your own machine/cloud infrastructure |
| **Pre-installed tools** | Many common tools are pre-installed | You install and maintain tools |
| **Good for** | Standard CI/CD workflows | Custom environments, private networks, special requirements |
| **Security concern** | Less control over the underlying machine | You are responsible for security, updates, access and isolation |

## Simple Comparison

```text
GitHub-Hosted

GitHub
  |
  +--> Provides machine
  +--> Maintains machine
  +--> Installs common tools
  +--> Manages runner infrastructure
```

```text
Self-Hosted

You
  |
  +--> Provide machine
  +--> Maintain machine
  +--> Install tools
  +--> Manage security
  +--> Manage runner
```

---

# Commands Used

## Git Commands

```bash
git status
git add .
git commit -m "Day 42 - GitHub runners"
git push
```

## Linux Runner Commands

```bash
uname -s
hostname
whoami
pwd
```

## Check Docker

```bash
docker --version
```

## Check Python

```bash
python3 --version
```

## Check Node.js

```bash
node --version
```

## Check Git

```bash
git --version
```

## Self-Hosted Runner

Start manually:

```bash
./run.sh
```

Install as a service:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

---

# Challenges Faced

## Challenge 1 – Understanding `actions/checkout`

Initially, I thought `actions/checkout` was required in every workflow.

I learned that checkout is required when the workflow needs files from the repository.

For example:

```yaml
- uses: actions/checkout@v4
```

is useful when the workflow needs:

```text
package.json
Dockerfile
Source code
Tests
```

But for a command such as:

```yaml
- run: docker --version
```

checkout is not required.

---

## Challenge 2 – Different Operating Systems

Ubuntu and macOS use Bash by default:

```bash
echo "Hostname: $(hostname)"
```

Windows uses PowerShell by default:

```powershell
Write-Host "Hostname: $env:COMPUTERNAME"
```

I learned that commands may need different syntax depending on the runner operating system.

---

## Challenge 3 – Runner Name vs Label

My runner is named:

```text
Matrix
```

My custom label is:

```text
my-linux-runner
```

I learned that:

```yaml
runs-on: my-linux-runner
```

selects a runner using the label.

It does not mean the runner's name is `my-linux-runner`.

---

## Challenge 4 – Git `commit -a`

I initially used:

```bash
git commit -am "added new file"
```

for a new file.

I learned that `-a` does not stage untracked files.

Correct:

```bash
git add workflow-self.yml
git commit -m "added new file"
```

---

# What I Learned

- A runner is the machine that executes GitHub Actions jobs.
- GitHub-hosted runners are managed by GitHub.
- Self-hosted runners are machines managed by me or my organization.
- `runs-on` determines which runner executes a job.
- `ubuntu-latest`, `windows-latest`, and `macos-latest` are GitHub-hosted runner labels.
- `self-hosted` identifies a self-hosted runner.
- `Matrix` is my runner name.
- `my-linux-runner` is my custom runner label.
- Labels help select the correct self-hosted runner.
- GitHub-hosted runners have many common tools pre-installed.
- Self-hosted runners provide more control but also require more maintenance and security responsibility.
- Jobs without `needs:` can run independently and in parallel.
- `actions/checkout` is needed when the workflow needs repository files.
- `git commit -am` does not stage new/untracked files.

---

# Final Runner Architecture

```text
                         GitHub Repository
                                |
                                v
                       GitHub Actions Workflow
                                |
                 +--------------+--------------+
                 |                             |
                 v                             v
        GitHub-Hosted Runner            Self-Hosted Runner
                 |                             |
        +--------+--------+                    |
        |        |        |                    |
      Ubuntu  Windows   macOS                Matrix
                                                |
                                      +---------+---------+
                                      |         |         |
                                self-hosted  Linux       X64
                                      |
                                      +--> my-linux-runner
```

## Final Key Concept

```text
Runner = Machine that executes the job

GitHub-Hosted = GitHub provides and manages the machine

Self-Hosted = I provide and manage the machine

Matrix = Name of my self-hosted runner

self-hosted = Built-in label

my-linux-runner = Custom label

runs-on = Tells GitHub which runner to use
```
