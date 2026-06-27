# Day 17 – Shell Scripting: Loops, Arguments & Error Handling

## Introduction

Shell scripting is the process of writing a series of Linux commands in a file so they can be executed automatically. Instead of running commands one by one in the terminal, we write them in a script and execute the script whenever needed.

Shell scripting is widely used in DevOps to automate repetitive tasks such as installing software, managing services, deploying applications, creating backups, monitoring servers, and configuring systems.

In this session, we learned how to use loops, command-line arguments, package installation, and basic error handling to write better Bash scripts.

---

# Learning Objectives

- Understand `for` and `while` loops
- Learn command-line arguments (`$1`, `$2`, `$#`, `$@`)
- Automate package installation
- Handle errors in Bash scripts
- Write reusable automation scripts

---

# Task 1 – For Loop

## What?

A **for loop** executes a block of code repeatedly for each item in a list or range.

## Why?

Instead of writing the same command multiple times, a for loop automates repetitive tasks.

### Example

Instead of:

```bash
echo Apple
echo Banana
echo Mango
echo Grapes
echo Orange
```

We can use a loop.

## How?

A for loop takes one item at a time from a list and executes the commands inside the loop.

### Syntax

```bash
for variable in list
do
    commands
done
```

## Script: `for_loop.sh`

```bash
#!/bin/bash

for fruit in Apple Banana Mango Grapes Orange
do
    echo "$fruit"
done
```

### Run

```bash
chmod +x for_loop.sh
./for_loop.sh
```

### Output

```text
Apple
Banana
Mango
Grapes
Orange
```

---

## Real DevOps Use Case

- Restart multiple services.
- Create multiple users.
- Process multiple log files.
- Deploy applications to multiple servers.

---

# Task 2 – Counting Numbers using For Loop

## What?

A for loop can also iterate over a sequence of numbers.

## Why?

Useful for counters, automation, and batch processing.

## Script

```bash
#!/bin/bash

for i in {1..10}
do
    echo "Number: $i"
done
```

### Run

```bash
chmod +x count.sh
./count.sh
```

### Output

```text
Number: 1
Number: 2
Number: 3
Number: 4
Number: 5
Number: 6
Number: 7
Number: 8
Number: 9
Number: 10
```

---

## Real DevOps Use Case

- Running health checks on multiple servers.
- Processing batches of files.
- Creating backups for multiple directories.

---

# Task 3 – While Loop

## What?

A while loop repeatedly executes commands as long as a condition is true.

## Why?

Used when the number of iterations depends on a condition.

## Syntax

```bash
while [ condition ]
do
    commands
done
```

## Script: `countdown.sh`

```bash
#!/bin/bash

count=5

while [ $count -gt 0 ]
do
    echo "$count"
    count=$((count-1))
done

echo "Countdown Complete!"
```

### Run

```bash
chmod +x countdown.sh
./countdown.sh
```

### Output

```text
5
4
3
2
1
Countdown Complete!
```

---

## Real DevOps Use Case

- Waiting for a service to become available.
- Monitoring CPU or memory usage continuously.
- Polling an API until deployment finishes.

---

# Task 4 – Command-Line Arguments

## What?

Command-line arguments allow values to be passed while executing a script.

## Why?

Makes scripts reusable without changing the code.

## Bash Special Variables

| Variable | Description |
|----------|-------------|
| `$0` | Script name |
| `$1` | First argument |
| `$2` | Second argument |
| `$#` | Total number of arguments |
| `$@` | All arguments |

---

## Script: `greet.sh`

```bash
#!/bin/bash

echo "Hello, $1!"
```

### Run

```bash
chmod +x greet.sh
./greet.sh Suraj
```

### Output

```text
Hello, Suraj!
```

---

## Script: `args_demo.sh`

```bash
#!/bin/bash

echo "Script Name : $0"
echo "First Argument : $1"
echo "Second Argument : $2"
echo "Total Arguments : $#"
echo "All Arguments : $@"
```

### Run

```bash
chmod +x args_demo.sh
./args_demo.sh DevOps Linux Bash
```

### Output

```text
Script Name : ./args_demo.sh
First Argument : DevOps
Second Argument : Linux
Total Arguments : 3
All Arguments : DevOps Linux Bash
```

---

## Real DevOps Use Case

- Passing server names.
- Passing application versions.
- Providing backup locations.
- Accepting deployment environments.

---

# Task 5 – Install Packages via Script

## What?

A script that installs packages automatically if they are not already installed.

## Why?

Automates software installation on multiple systems.

## Script: `install_packages.sh`

```bash
#!/bin/bash

packages=("git" "curl" "wget")

for package in "${packages[@]}"
do
    if rpm -q "$package" &>/dev/null
    then
        echo "$package is already installed."
    else
        echo "Installing $package..."
        sudo dnf install -y "$package"
    fi
done
```

### Run

```bash
chmod +x install_packages.sh
./install_packages.sh
```

### Sample Output

```text
git is already installed.
Installing curl...
Installing wget...
Complete!
```

---

## Real DevOps Use Case

- Installing Docker.
- Installing Jenkins.
- Installing Git.
- Preparing new Linux servers automatically.

---

# Task 6 – Error Handling

## What?

Error handling prevents scripts from continuing after failures.

## Why?

Improves script reliability and avoids unexpected behavior.

## Script: `safe_script.sh`

```bash
#!/bin/bash

set -e

mkdir /tmp/devops-test || echo "Directory already exists"

echo "Script completed successfully."
```

### Run

```bash
chmod +x safe_script.sh
./safe_script.sh
```

### Output

```text
Directory already exists
Script completed successfully.
```

---

## Real DevOps Use Case

- Stop deployment if build fails.
- Prevent database migration after an error.
- Exit immediately when package installation fails.

---

# Root User Check

## What?

Checks whether the script is executed by the root user.

## Why?

Administrative tasks like package installation require root privileges.

## Script

```bash
#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Please run this script as root."
    exit 1
fi

echo "Running as root."
```

### Run (Normal User)

```bash
./root_check.sh
```

### Output

```text
Please run this script as root.
```

### Run (Root)

```bash
sudo ./root_check.sh
```

### Output

```text
Running as root.
```

---

## Real DevOps Use Case

- Package installation.
- Firewall configuration.
- User management.
- Service management.
- System configuration.

---

# Key Learnings

- Learned how to automate repetitive tasks using **for** and **while** loops.
- Understood command-line arguments (`$1`, `$2`, `$#`, `$@`) for reusable scripts.
- Learned package installation automation using arrays and loops.
- Learned basic error handling using `set -e` and `||`.
- Learned how to verify root privileges using `$EUID`.
- Improved understanding of Bash scripting for DevOps automation.

---

# Conclusion

Today I learned how to write more practical Bash scripts using loops, command-line arguments, package installation, and error handling. These concepts form the foundation of automation in Linux and DevOps by reducing manual effort, improving reliability, and making scripts reusable.

The knowledge gained today will help automate server setup, software installation, deployments, monitoring, and other routine system administration tasks commonly performed by DevOps engineers.
