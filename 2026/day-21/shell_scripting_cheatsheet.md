# Day 21 – Shell Scripting Cheat Sheet: Build Your Own Reference Guide

# Bash Scripting Cheat Sheet – DevOps

> **Purpose:** Quick reference for Bash scripting used in Linux, DevOps, automation, CI/CD, log analysis, and system administration.

---

# Quick Reference Table

| Topic          | Key Syntax               | Example                            |
| -------------- | ------------------------ | ---------------------------------- |
| Shebang        | `#!/bin/bash`            | `#!/bin/bash`                      |
| Variable       | `VAR="value"`            | `NAME="DevOps"`                    |
| Argument       | `$1`, `$2`               | `./script.sh arg1`                 |
| If             | `if [ condition ]; then` | `if [ -f file ]; then`             |
| For loop       | `for i in list; do`      | `for i in 1 2 3; do`               |
| While loop     | `while condition; do`    | `while [ $count -lt 5 ]; do`       |
| Function       | `name() { ... }`         | `greet() { echo "Hi"; }`           |
| Grep           | `grep pattern file`      | `grep -i "error" app.log`          |
| Awk            | `awk '{print $1}' file`  | `awk -F: '{print $1}' /etc/passwd` |
| Sed            | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' config.txt`  |
| Cut            | `cut -d: -f1 file`       | `cut -d, -f1 users.csv`            |
| Sort           | `sort file`              | `sort -n numbers.txt`              |
| Uniq           | `uniq file`              | `sort names.txt \| uniq`           |
| Tr             | `tr 'a-z' 'A-Z'`         | `echo hello \| tr 'a-z' 'A-Z'`     |
| WC             | `wc -l file`             | `wc -l app.log`                    |
| Head           | `head -n 10 file`        | `head -n 10 app.log`               |
| Tail           | `tail -f file`           | `tail -f app.log`                  |
| Exit code      | `$?`                     | `echo $?`                          |
| Debug          | `set -x`                 | `set -x`                           |
| Error handling | `set -euo pipefail`      | `set -euo pipefail`                |

---

# Task 1 – Bash Basics

## 1. Shebang

### What?

The shebang tells Linux **which interpreter should execute the script**.

### Why?

It allows you to run the script directly using `./script.sh`.

### How?

```bash
#!/bin/bash
```

### Example

```bash
#!/bin/bash

echo "Hello DevOps"
```

Run:

```bash
chmod +x script.sh
./script.sh
```

---

## 2. Running a Bash Script

### Method 1 – Execute directly

```bash
chmod +x script.sh
./script.sh
```

`chmod +x` gives execute permission.

### Method 2 – Run using Bash

```bash
bash script.sh
```

This does not require execute permission.

---

## 3. Comments

### What?

Comments are ignored by Bash and are used to explain code.

### Single-line comment

```bash
# This is a comment
echo "Hello"
```

### Inline comment

```bash
echo "Starting application"  # Print startup message
```

---

# 4. Variables

### What?

Variables store values that can be reused in a script.

### How?

```bash
NAME="Suraj"
AGE=25

echo "$NAME"
echo "$AGE"
```

> No spaces around `=`.

### `$VAR`

```bash
NAME="Suraj"
echo $NAME
```

### `"$VAR"` – Recommended

```bash
NAME="DevOps Engineer"
echo "$NAME"
```

Quotes preserve spaces and special characters.

### `'$VAR'`

```bash
NAME="Suraj"
echo '$NAME'
```

Output:

```text
$NAME
```

Single quotes prevent variable expansion.

### Practical Example

```bash
APP_NAME="flask-app"
echo "Deploying $APP_NAME"
```

---

# 5. Reading User Input

### What?

`read` gets input from the user.

### Why?

Useful for interactive scripts.

### Example

```bash
#!/bin/bash

read -p "Enter your name: " NAME

echo "Hello, $NAME"
```

---

# 6. Command-Line Arguments

Run:

```bash
./script.sh DevOps Linux
```

Inside the script:

| Variable | Meaning                         |
| -------- | ------------------------------- |
| `$0`     | Script name                     |
| `$1`     | First argument                  |
| `$2`     | Second argument                 |
| `$#`     | Number of arguments             |
| `$@`     | All arguments                   |
| `$?`     | Exit status of previous command |

### Example

```bash
#!/bin/bash

echo "Script: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Arguments count: $#"
echo "All arguments: $@"
```

Run:

```bash
./script.sh Docker Kubernetes
```

---

# Task 2 – Operators and Conditionals

# 1. String Comparisons

| Operator | Meaning             |
| -------- | ------------------- |
| `=`      | Equal               |
| `!=`     | Not equal           |
| `-z`     | String is empty     |
| `-n`     | String is not empty |

### Example

```bash
NAME="Suraj"

if [ "$NAME" = "Suraj" ]; then
    echo "Name matched"
fi
```

### Empty string

```bash
NAME=""

if [ -z "$NAME" ]; then
    echo "Name is empty"
fi
```

---

# 2. Integer Comparisons

| Operator | Meaning               |
| -------- | --------------------- |
| `-eq`    | Equal                 |
| `-ne`    | Not equal             |
| `-lt`    | Less than             |
| `-gt`    | Greater than          |
| `-le`    | Less than or equal    |
| `-ge`    | Greater than or equal |

### Example

```bash
CPU=85

if [ "$CPU" -gt 80 ]; then
    echo "High CPU usage"
fi
```

---

# 3. File Test Operators

| Operator | Meaning               |
| -------- | --------------------- |
| `-f`     | Regular file exists   |
| `-d`     | Directory exists      |
| `-e`     | File/directory exists |
| `-r`     | Readable              |
| `-w`     | Writable              |
| `-x`     | Executable            |
| `-s`     | File is not empty     |

### Example

```bash
if [ -f "/var/log/app.log" ]; then
    echo "Log file exists"
fi
```

### Directory check

```bash
if [ -d "/var/log" ]; then
    echo "Log directory exists"
fi
```

---

# 4. if / elif / else

### Syntax

```bash
if [ condition ]; then
    # command
elif [ condition ]; then
    # command
else
    # command
fi
```

### Example

```bash
DISK=85

if [ "$DISK" -ge 90 ]; then
    echo "Critical"
elif [ "$DISK" -ge 80 ]; then
    echo "Warning"
else
    echo "Normal"
fi
```

---

# 5. Logical Operators

### AND – `&&`

Both conditions must succeed.

```bash
if [ -f app.log ] && [ -r app.log ]; then
    echo "File exists and is readable"
fi
```

### OR – `||`

At least one condition must succeed.

```bash
if [ "$ENV" = "dev" ] || [ "$ENV" = "test" ]; then
    echo "Non-production environment"
fi
```

### NOT – `!`

Reverses a condition.

```bash
if ! [ -f app.log ]; then
    echo "Log file missing"
fi
```

---

# 6. Case Statement

### What?

`case` is useful when checking one variable against multiple possible values.

### Syntax

```bash
case "$VARIABLE" in
    pattern1)
        command
        ;;
    pattern2)
        command
        ;;
    *)
        default_command
        ;;
esac
```

### Example

```bash
ACTION="start"

case "$ACTION" in
    start)
        echo "Starting application"
        ;;
    stop)
        echo "Stopping application"
        ;;
    restart)
        echo "Restarting application"
        ;;
    *)
        echo "Invalid action"
        ;;
esac
```

---

# Task 3 – Loops

# 1. For Loop – List Based

### What?

Runs commands for each item in a list.

### Example

```bash
for server in web1 web2 web3; do
    echo "Checking $server"
done
```

---

# 2. C-Style For Loop

### Example

```bash
for ((i=1; i<=5; i++)); do
    echo "Number: $i"
done
```

Useful when working with counters.

---

# 3. While Loop

### What?

Runs while a condition is true.

### Example

```bash
count=1

while [ "$count" -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

---

# 4. Until Loop

### What?

Runs until the condition becomes true.

### Example

```bash
count=1

until [ "$count" -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

---

# 5. break

### What?

Stops the loop immediately.

```bash
for i in 1 2 3 4 5; do
    if [ "$i" -eq 3 ]; then
        break
    fi

    echo "$i"
done
```

Output:

```text
1
2
```

---

# 6. continue

### What?

Skips the current iteration and continues the loop.

```bash
for i in 1 2 3 4 5; do
    if [ "$i" -eq 3 ]; then
        continue
    fi

    echo "$i"
done
```

Output:

```text
1
2
4
5
```

---

# 7. Looping Over Files

### Example

```bash
for file in *.log; do
    echo "Processing: $file"
done
```

### Practical Example

```bash
for file in /var/log/*.log; do
    echo "Checking $file"
done
```

---

# 8. Looping Over Command Output

Use `while read` when processing command output line by line.

```bash
docker ps --format '{{.Names}}' |
while read -r container; do
    echo "Container: $container"
done
```

`read -r` prevents backslash interpretation.

---

# Task 4 – Functions

# 1. Defining a Function

### What?

Functions group reusable commands.

### Example

```bash
greet() {
    echo "Hello DevOps"
}
```

---

# 2. Calling a Function

```bash
greet
```

---

# 3. Passing Arguments

Arguments inside a function use `$1`, `$2`, etc.

```bash
greet() {
    echo "Hello $1"
}

greet "Suraj"
```

Output:

```text
Hello Suraj
```

### Multiple arguments

```bash
deploy() {
    echo "Application: $1"
    echo "Environment: $2"
}

deploy "flask-app" "production"
```

---

# 4. return vs echo

### `return`

Returns an **exit status** from `0–255`.

```bash
check_file() {
    [ -f "$1" ]
}

check_file "app.log"

echo "$?"
```

### `echo`

Returns actual data/output.

```bash
get_status() {
    echo "Application is running"
}

STATUS=$(get_status)

echo "$STATUS"
```

> Use `return` for success/failure status and `echo` for data.

---

# 5. Local Variables

### What?

`local` makes a variable available only inside the function.

```bash
deploy() {
    local APP="flask-app"

    echo "Deploying $APP"
}

deploy
```

This prevents accidental modification of global variables.

---

# Task 5 – Text Processing Commands

# 1. grep

### What?

Searches text using patterns.

```bash
grep "ERROR" app.log
```

### Useful flags

| Flag | Purpose          | Example                 |                |
| ---- | ---------------- | ----------------------- | -------------- |
| `-i` | Ignore case      | `grep -i error app.log` |                |
| `-r` | Recursive search | `grep -r "TODO" .`      |                |
| `-c` | Count matches    | `grep -c ERROR app.log` |                |
| `-n` | Show line number | `grep -n ERROR app.log` |                |
| `-v` | Invert match     | `grep -v INFO app.log`  |                |
| `-E` | Extended regex   | `grep -E "ERROR         | WARN" app.log` |

### Real DevOps example

```bash
grep -i "error" /var/log/app.log
```

---

# 2. awk

### What?

`awk` processes structured text, especially columns.

### Print first column

```bash
awk '{print $1}' users.txt
```

### Field separator

```bash
awk -F: '{print $1}' /etc/passwd
```

### Multiple columns

```bash
awk '{print $1, $3}' users.txt
```

### Pattern

```bash
awk '$3 > 80 {print $1, $3}' disk.txt
```

### BEGIN / END

```bash
awk 'BEGIN {print "Users"} {print $1} END {print "Done"}' users.txt
```

---

# 3. sed

### What?

`sed` modifies or filters text streams.

### Substitute

```bash
sed 's/old/new/g' config.txt
```

### Delete lines

```bash
sed '2d' file.txt
```

### Delete blank lines

```bash
sed '/^$/d' file.txt
```

### In-place edit

```bash
sed -i 's/http/https/g' config.txt
```

> Use `-i` carefully because it modifies the original file.

---

# 4. cut

### What?

Extracts specific fields or characters.

### CSV first column

```bash
cut -d',' -f1 users.csv
```

### `/etc/passwd`

```bash
cut -d: -f1 /etc/passwd
```

---

# 5. sort

### Alphabetical

```bash
sort names.txt
```

### Numerical

```bash
sort -n numbers.txt
```

### Reverse

```bash
sort -r names.txt
```

### Unique

```bash
sort -u names.txt
```

---

# 6. uniq

### What?

Removes/counts consecutive duplicate lines.

### Remove duplicates

```bash
sort names.txt | uniq
```

### Count occurrences

```bash
sort names.txt | uniq -c
```

### Most common values

```bash
sort names.txt | uniq -c | sort -nr
```

---

# 7. tr

### What?

Translates or deletes characters.

### Lowercase → uppercase

```bash
echo "hello" | tr 'a-z' 'A-Z'
```

Output:

```text
HELLO
```

### Delete spaces

```bash
echo "hello world" | tr -d ' '
```

---

# 8. wc

### Count lines

```bash
wc -l app.log
```

### Count words

```bash
wc -w file.txt
```

### Count characters

```bash
wc -m file.txt
```

---

# 9. head

### What?

Displays the beginning of a file.

```bash
head file.txt
```

### First 10 lines

```bash
head -n 10 app.log
```

---

# 10. tail

### What?

Displays the end of a file.

```bash
tail -n 10 app.log
```

### Follow log in real time

```bash
tail -f /var/log/app.log
```

### Follow and filter errors

```bash
tail -f app.log | grep -i "error"
```

---

# Task 6 – Useful Real-World One-Liners

## 1. Find files older than 7 days

### What?

Finds old log files.

### Example

```bash
find /var/log -name "*.log" -type f -mtime +7
```

### Delete them

```bash
find /var/log -name "*.log" -type f -mtime +7 -delete
```

> Always verify with the first command before using `-delete`.

---

# 2. Count lines in all `.log` files

```bash
wc -l *.log
```

### Total line count

```bash
cat *.log | wc -l
```

---

# 3. Replace a string across multiple files

```bash
sed -i 's/localhost/production-server/g' *.conf
```

> Test with `sed` without `-i` first.

---

# 4. Check if a service is running

```bash
systemctl is-active --quiet nginx && echo "Running" || echo "Stopped"
```

---

# 5. Disk usage alert

```bash
df -h / | awk 'NR==2 {gsub("%","",$5); if ($5 > 80) print "ALERT: Disk usage is " $5 "%"}'
```

---

# 6. Parse CSV

Example CSV:

```text
name,age,city
Suraj,25,Panchkula
Amit,24,Delhi
```

Get names:

```bash
awk -F',' 'NR>1 {print $1}' users.csv
```

---

# 7. Parse JSON

Using `jq`:

```bash
jq '.name' user.json
```

Get multiple fields:

```bash
jq '.name, .email' user.json
```

> `jq` is the standard practical tool for JSON processing in shell scripts.

---

# 8. Monitor errors in real time

```bash
tail -f app.log | grep --line-buffered -i "error"
```

`--line-buffered` makes matching lines appear immediately.

---

# 9. Find largest files

```bash
du -ah /var/log | sort -rh | head -n 10
```

Useful when investigating disk-space problems.

---

# 10. Check running Docker containers

```bash
docker ps --format '{{.Names}}'
```

Count running containers:

```bash
docker ps -q | wc -l
```

---

# Task 7 – Error Handling and Debugging

# 1. Exit Codes

### What?

Linux commands return an exit status.

* `0` → Success
* Non-zero → Failure

### Example

```bash
ls /tmp

echo $?
```

---

# 2. exit

### Success

```bash
exit 0
```

### Failure

```bash
exit 1
```

### Example

```bash
if [ ! -f app.conf ]; then
    echo "Config file missing"
    exit 1
fi
```

---

# 3. set -e

### What?

Stops the script when a command fails.

```bash
set -e

mkdir /invalid/path
echo "This may not execute"
```

Useful for deployment scripts where continuing after an error is dangerous.

---

# 4. set -u

### What?

Treats unset variables as errors.

```bash
set -u

echo "$UNDEFINED_VAR"
```

This helps catch variable-name mistakes.

---

# 5. set -o pipefail

### What?

Makes a pipeline fail if **any command** in the pipeline fails.

```bash
set -o pipefail

cat missing.txt | grep "error"
```

Without `pipefail`, a later successful command can hide an earlier failure.

---

# 6. Recommended Strict Mode

For many production scripts:

```bash
#!/bin/bash

set -euo pipefail
```

Meaning:

```text
-e → exit on error
-u → error on unset variables
-o pipefail → catch pipeline failures
```

---

# 7. set -x

### What?

Prints commands before executing them.

### Example

```bash
set -x

echo "Deploying application"
docker ps

set +x
```

Useful for debugging CI/CD scripts.

---

# 8. trap

### What?

`trap` runs cleanup code when a script exits.

### Example

```bash
#!/bin/bash

cleanup() {
    echo "Cleaning temporary files..."
    rm -f /tmp/app.tmp
}

trap cleanup EXIT

touch /tmp/app.tmp

echo "Running application..."
```

`cleanup` runs automatically when the script exits.

---

# Task 8 – Practical DevOps Script

The following combines variables, arguments, functions, conditions, exit codes, and error handling.

```bash
#!/bin/bash

set -euo pipefail

APP_NAME="${1:-flask-app}"
ENVIRONMENT="${2:-dev}"

deploy() {
    local app="$1"
    local env="$2"

    echo "Deploying $app to $env"

    if [ "$env" = "production" ]; then
        echo "Production deployment started"
    else
        echo "Non-production deployment started"
    fi
}

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <app-name> [environment]"
    exit 1
fi

deploy "$APP_NAME" "$ENVIRONMENT"

echo "Deployment completed successfully"
exit 0
```

Run:

```bash
chmod +x deploy.sh

./deploy.sh flask-app production
```

---

# Important Bash Patterns for DevOps

## Check command success

```bash
if command; then
    echo "Success"
else
    echo "Failed"
fi
```

---

## Run command only if previous command succeeds

```bash
docker build -t flask-app . && docker run flask-app
```

---

## Run fallback command if previous command fails

```bash
docker ps || echo "Docker is not running"
```

---

## Store command output

```bash
CONTAINERS=$(docker ps -q)

echo "$CONTAINERS"
```

---

## Check whether a variable is empty

```bash
if [ -z "${NAME:-}" ]; then
    echo "NAME is empty"
fi
```

---

## Default value for an unset variable

```bash
NAME="${1:-Guest}"

echo "Hello $NAME"
```

Run:

```bash
./script.sh
```

Output:

```text
Hello Guest
```

Run:

```bash
./script.sh Suraj
```

Output:

```text
Hello Suraj
```

---

# Bash Quoting Quick Reference

| Syntax       | Meaning                 | Example        |
| ------------ | ----------------------- | -------------- |
| `$VAR`       | Variable expansion      | `echo $NAME`   |
| `"$VAR"`     | Safe variable expansion | `echo "$NAME"` |
| `'$VAR'`     | Literal text            | `echo '$NAME'` |
| `$(command)` | Command substitution    | `DATE=$(date)` |
| `\`          | Escape character        | `echo \$NAME`  |

### Recommended

Prefer:

```bash
echo "$NAME"
```

instead of:

```bash
echo $NAME
```

because quoting prevents unexpected word splitting and glob expansion.

---

# Bash Cheat Sheet – Most Used Commands

```bash
# Variables
NAME="DevOps"
echo "$NAME"

# Input
read -p "Enter name: " NAME

# Arguments
echo "$0"
echo "$1"
echo "$#"
echo "$@"

# Conditions
if [ -f file.txt ]; then
    echo "Exists"
fi

# Loop
for file in *.log; do
    echo "$file"
done

# Function
greet() {
    echo "Hello $1"
}

greet "Suraj"

# Search
grep -i "error" app.log

# Columns
awk '{print $1}' file.txt

# Replace
sed 's/old/new/g' file.txt

# Extract
cut -d',' -f1 users.csv

# Sort
sort -n numbers.txt

# Unique
sort file.txt | uniq -c

# Translate
echo "hello" | tr 'a-z' 'A-Z'

# Count
wc -l app.log

# First lines
head -n 10 app.log

# Last lines
tail -n 10 app.log

# Follow log
tail -f app.log

# Exit status
echo $?

# Strict mode
set -euo pipefail

# Debug
set -x
```

---

# Key Takeaways for DevOps

| Requirement             | Bash Tool               |
| ----------------------- | ----------------------- |
| Automate commands       | Scripts                 |
| Accept user input       | `read`                  |
| Accept CI/CD parameters | `$1`, `$2`, `$@`        |
| Make decisions          | `if`, `case`            |
| Repeat tasks            | `for`, `while`, `until` |
| Reuse code              | Functions               |
| Search logs             | `grep`                  |
| Process columns         | `awk`                   |
| Modify configuration    | `sed`                   |
| Extract fields          | `cut`                   |
| Sort data               | `sort`                  |
| Remove duplicates       | `uniq`                  |
| Transform characters    | `tr`                    |
| Count data              | `wc`                    |
| Monitor logs            | `tail -f`               |
| Handle failures         | `set -euo pipefail`     |
| Debug scripts           | `set -x`                |
| Cleanup                 | `trap`                  |

---

# Golden Rule

For production-oriented Bash scripts, a good starting template is:

```bash
#!/bin/bash

set -euo pipefail

cleanup() {
    # Cleanup resources here
    :
}

trap cleanup EXIT

main() {
    echo "Starting script..."
    
    # Your logic here
    
    echo "Script completed successfully"
}

main "$@"
```

This structure gives you:

**Shebang → Strict error handling → Cleanup → Main function → Arguments → Automation**

Perfect foundation for **Linux administration, Docker automation, CI/CD pipelines, and DevOps scripting**. 🚀
