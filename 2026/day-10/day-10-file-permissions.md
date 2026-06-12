# Day 10 – File Permissions & File Operations Challenge

📖 Introduction

File management and permissions are fundamental concepts in Linux and an essential skill for DevOps engineers and system administrators. Every file and directory in Linux has associated permissions that determine who can read, write, or execute it. Understanding these permissions helps protect system resources, maintain security, and control access to important files.

In this challenge, I explored how to create, read, and manage files using common Linux commands. I also learned how to view and modify file permissions with chmod, assign appropriate access rights to files and directories, and test permission-related scenarios through practical examples.


# Task 1: Create Files

## What?

Create new files using different Linux commands.

## Why?

Files are used to store scripts, notes, configurations, logs, and application data.

## How?

### Commands Used

```bash
touch devops.txt
cat > notes.txt
vim script.sh
ls -l
```

### Command Explanation

#### `touch devops.txt`

**What:** Creates an empty file.

**Why:** Quickly create a file without opening an editor.

**How:** Creates a zero-byte file if it doesn't exist.

#### `cat > notes.txt`

**What:** Creates a file and allows content entry.

**Why:** Useful for quickly writing text.

**How:** Type content and press `CTRL + D` to save.

#### `vim script.sh`

**What:** Opens Vim editor.

**Why:** Create or edit files.

**How:** Press `i` to insert text, then `Esc`, `:wq`.

### Content Added

#### `notes.txt`

(Add your content here)

#### `script.sh`

```bash
echo "Hello DevOps"
```

### 📝 My Output

Paste your output here:

```bash
ls -l
```

(Paste Output)

---

# Task 2: Read Files

## What?

Display file contents without modifying them.

## Why?

To verify content and inspect system files.

## How?

### Commands Used

```bash
cat notes.txt
vim -R script.sh
head -n 5 /etc/passwd
tail -n 5 /etc/passwd
```

### Command Explanation

#### `cat notes.txt`

**What:** Displays complete file content.

**Why:** Quickly read small files.

**How:** Reads and prints file content to terminal.

#### `vim -R script.sh`

**What:** Opens file in read-only mode.

**Why:** Prevent accidental modifications.

**How:** `-R` flag enables read-only mode.

#### `head -n 5 /etc/passwd`

**What:** Shows first 5 lines.

**Why:** View beginning of a file.

**How:** `-n 5` means display 5 lines.

#### `tail -n 5 /etc/passwd`

**What:** Shows last 5 lines.

**Why:** Useful for logs and large files.

**How:** `-n 5` displays last 5 lines.

### 📝 My Output

```bash
cat notes.txt
```

(Paste Output)

```bash
head -n 5 /etc/passwd
```

(Paste Output)

```bash
tail -n 5 /etc/passwd
```

(Paste Output)

---

# Task 3: Understand Permissions

## What?

Linux controls file access using permissions.

## Why?

To protect files from unauthorized access or modification.

## How?

Check permissions:

```bash
ls -l devops.txt notes.txt script.sh
```

### Permission Format

```
rwxrwxrwx
│ │ │
│ │ └── Others
│ └──── Group
└────── Owner
```

### Meaning

| Permission | Value | Meaning |
| ---------- | ----- | ------- |
| r          | 4     | Read    |
| w          | 2     | Write   |
| x          | 1     | Execute |

### Example

```
-rw-r----- notes.txt
```

### Breakdown

#### Owner:

* rw-
* Read ✅
* Write ✅
* Execute ❌

#### Group:

* r--
* Read ✅
* Write ❌
* Execute ❌

#### Others:

---

* No permissions

### 📝 My Permission Output

```bash
ls -l devops.txt notes.txt script.sh
```

(Paste Output)

---

# Task 4: Modify Permissions

## What?

Change permissions using `chmod`.

## Why?

To control who can read, write, or execute files.

## How?

### 1. Make script executable

#### Command

```bash
chmod +x script.sh
```

#### Before

(Paste Output)

#### After

(Paste Output)

#### Run Script

```bash
./script.sh
```

#### Output

```
Hello DevOps
```

---

### 2. Make `devops.txt` Read-Only

#### Commands Used

```bash
chmod a+r devops.txt
chmod 444 devops.txt
```

#### What?

Set read permission for everyone.

#### Why?

Prevent modification of file content.

#### How?

```
444 = r-- r-- r--
```

#### Before

(Paste Output)

#### After

(Paste Output)

---

### 3. Set `notes.txt` to 640

#### Command

```bash
chmod 640 notes.txt
```

#### What?

Assign custom permissions.

#### Why?

Allow owner full access, group read-only, others no access.

#### How?

```
640

6 = rw-
4 = r--
0 = ---
```

#### Before

(Paste Output)

#### After

(Paste Output)

---

### 4. Create `project` Directory with 755

#### Commands

```bash
mkdir project
chmod 755 project/
ls -ld project/
```

#### What?

Create directory and assign permissions.

#### Why?

Common permission setting for application directories.

#### How?

```
755

7 = rwx
5 = r-x
5 = r-x
```

#### Output

(Paste Output)

---

# Task 5: Permission Testing

## Test 1: Write to Read-Only File

### Command

```bash
cat > devops.txt
```

### Expected Result

```
Permission denied
```

or

```
Cannot overwrite file
```

### What Did You Observe?

(Paste Output)

---

## Test 2: Execute File Without Execute Permission

### Commands

```bash
chmod 666 script.sh
./script.sh
```

### Expected Error

```
Permission denied
```

### Actual Output

(Paste Output)

---

# Commands Used During Practice

```bash
touch devops.txt
cat > notes.txt
vim script.sh
cat notes.txt
vim -R script.sh
head -n 5 /etc/passwd
tail -n 5 /etc/passwd

chmod 775 script.sh
chmod +r devops.txt
chmod a+r devops.txt
sudo chmod a+r devops.txt
chmod 444 devops.txt

chmod 640 notes.txt

mkdir project
chmod 755 project/

ls -l
ls -ld project/

cat > devops.txt

chmod 666 script.sh
./script.sh

chmod +x script.sh
./script.sh
```

---

# Key Permission Numbers

| Number | Permission |
| ------ | ---------- |
| 777    | rwxrwxrwx  |
| 755    | rwxr-xr-x  |
| 775    | rwxrwxr-x  |
| 644    | rw-r--r--  |
| 640    | rw-r-----  |
| 600    | rw-------  |
| 444    | r--r--r--  |

---

# What I Learned

### 1. Linux permissions are divided into Owner, Group, and Others.

Understanding these three categories helps control who can access files and directories.

### 2. `chmod` can use Symbolic and Numeric methods.

Examples:

```bash
chmod +x script.sh
chmod 640 notes.txt
```

### 3. Execute permission is required to run scripts.

Even if a script contains valid commands, Linux will not execute it without the execute (`x`) permission.

---

# Final Summary

✔ Created files using `touch`, `cat`, and `vim`

✔ Read files using `cat`, `head`, `tail`, and `vim` read-only mode

✔ Learned Linux permission structure (`rwx`)

✔ Modified permissions using `chmod`

✔ Tested permission-related errors

✔ Executed shell scripts using execute permissions

---

This format is clean for GitHub, DevOps portfolio documentation, and daily learning posts. It also includes dedicated sections for objectives, practical tasks, command explanations, outputs, and key learning outcomes.
