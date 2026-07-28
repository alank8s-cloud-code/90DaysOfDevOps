# Day 18 – Bash Scripting: Functions & Strict Mode

## 📌 Overview

I learned how to write modular Bash scripts using functions, pass arguments, use local variables, enable Strict Mode for safer scripts, and build a complete **System Information Reporter**.

---

# 🧠 What I Learned

- Creating and calling Bash functions
- Passing arguments to functions using `$1`, `$2`
- Using arithmetic expansion with `$(( ))`
- Creating reusable scripts
- Using `local` variables inside functions
- Understanding global variables
- Writing safer scripts with `set -euo pipefail`
- Monitoring Linux system resources using Bash
- Organizing scripts with a `main()` function

---

# ✅ Task 1 – Basic Functions

### Objective

Create a script named `functions.sh` that:

- Creates a `greet()` function
- Creates an `add()` function
- Calls both functions

### Script

```bash
#!/bin/bash

greet() {
    echo "Hello, $1!"
}

add() {
    read -p "Enter first number: " num1
    read -p "Enter second number: " num2

    echo "Sum: $((num1 + num2))"
}

greet "Alan"
add
```

### Output

![my-image-alt-text](path/to/image.png)

---

# ✅ Task 2 – Functions with Return Values

### Objective

Create `disk_check.sh` that prints

- Disk Usage
- Memory Usage

### Script

```bash
#!/bin/bash

check_disk() {
    echo "===== Disk Usage ====="
    df -h
}

check_memory() {
    echo
    echo "===== Memory Usage ====="
    free -h
}

echo "System Health Report"
echo "--------------------"

check_disk
check_memory
```

### Output

![my-image-alt-text](path/to/image.png)

---

# ✅ Task 3 – Strict Mode (`set -euo pipefail`)

### Objective

Learn how Strict Mode makes Bash scripts safer.

```bash
#!/bin/bash

set -euo pipefail
```

## Demonstrations

### Undefined Variable

```bash
echo "$username"
```

Output

```
bash: username: unbound variable
```

---

### Failed Command

```bash
ls /folder_that_does_not_exist
```

Output

```
No such file or directory
```

---

### Pipeline Failure

```bash
cat missing_file.txt | grep hello
```

### Output

![my-image-alt-text](path/to/image.png)


---

## Strict Mode Explanation

| Flag | Description |
|------|-------------|
| `set -e` | Exit immediately if a command fails |
| `set -u` | Treat undefined variables as errors |
| `set -o pipefail` | Fail if any command in a pipeline fails |

---

# ✅ Task 4 – Local Variables

### Objective

Understand the difference between local and global variables.

### Script

```bash
#!/bin/bash

local_demo() {
    local name="Alan"
    local age=25

    echo "$name"
    echo "$age"
}

global_demo() {
    city="London"
    country="UK"
}

local_demo

echo "$name"

global_demo

echo "$city"
```

### Output

![my-image-alt-text](path/to/image.png)

### Observation

- Local variables exist only inside their function.
- Global variables remain available after the function finishes.

---

# ✅ Task 5 – System Information Reporter

### Objective

Create a complete monitoring script using functions.

Features

- Hostname
- OS Information
- System Uptime
- Top 5 Largest Files/Folders
- Memory Usage
- Top 5 CPU Processes
- Strict Mode
- Main Function

### Script Structure

```
system_info()

system_uptime()

disk_usage()

memory_usage()

top_cpu_processes()

main()
```

### Main Function

```bash
main() {

    echo "========================================"
    echo "SYSTEM HEALTH REPORT"
    echo "========================================"

    system_info

    system_uptime

    disk_usage

    memory_usage

    top_cpu_processes

}
```

### Output

![my-image-alt-text](.png)

---

# 📚 Commands Used

| Command | Purpose |
|----------|----------|
| `chmod +x` | Make script executable |
| `./script.sh` | Execute script |
| `df -h` | Display disk usage |
| `free -h` | Display memory usage |
| `hostname` | Show system hostname |
| `uptime` | Show system uptime |
| `du -sh` | Calculate directory sizes |
| `sort -hr` | Sort by largest size |
| `head -n 5` | Display first five lines |
| `ps -eo pid,ppid,cmd,%cpu --sort=-%cpu` | Show CPU-consuming processes |
| `cat /etc/os-release` | Display OS information |

---

# ⚠️ Challenges Faced

- Learned the difference between local and global variables.
- Accidentally used `pip` instead of `pid` in the `ps` command.
- Called an incorrect function name (`cpu_process`) which caused a `command not found` error.
- Understood how `set -u` stops scripts when using undefined variables.
- Learned why `set -o pipefail` is important when working with pipelines.

---

# 🎯 Key Takeaways

- Functions improve code reusability and readability.
- Arguments make functions dynamic.
- Local variables prevent unwanted changes outside functions.
- Strict Mode (`set -euo pipefail`) helps write safer and more reliable scripts.
- A `main()` function organizes script execution cleanly.
- Linux utilities like `df`, `free`, `uptime`, `ps`, and `du` are powerful tools for system monitoring.

---

## Connect With Me

If you're also learning Linux and DevOps, feel free to connect and share your journey!

⭐ If you found this helpful, consider starring the repository.
