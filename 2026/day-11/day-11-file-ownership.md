# Day 11 – File Ownership Challenge (chown & chgrp)

# Introduction

File ownership is one of the core security features of Linux. Every file and directory belongs to a specific user (owner) and a specific group. Linux uses this ownership model to control who can read, write, or execute files.

The `chown` (change owner) and `chgrp` (change group) commands allow system administrators and DevOps engineers to manage file permissions efficiently.

In this challenge, I learned how to:

* Identify file owners and groups.
* Change file ownership.
* Change file groups.
* Change both owner and group simultaneously.
* Apply ownership changes recursively to directories.
* Manage multiple users and groups in a practical scenario.

---

# Objective

The objective of this challenge was to understand Linux file ownership and practice managing file permissions using:

* `chown`
* `chgrp`
* Recursive ownership changes (`-R`)

---

# Task 1: Understanding Ownership

## Command Used

```bash
ls -l
```

Example output:

```text
-rw-r--r-- 1 suraj suraj 0 Jun 13 devops-file.txt
```

### Format

```text
-rw-r--r-- 1 owner group size date filename
```

### Owner vs Group

| Owner                              | Group                                                         |
| ---------------------------------- | ------------------------------------------------------------- |
| The user who owns the file.        | A collection of users who share permissions.                  |
| Has primary control over the file. | Group members can access the file based on group permissions. |

### Learning

Every Linux file has:

* One owner
* One group

Ownership helps control file access and system security.

### Output

![Task 1](screenshots/task1-ls-l.png)

---

# Task 2: Basic chown Operations

## Created users

```bash
sudo adduser tokyo
sudo adduser berlin
```

## Created file

```bash
touch devops-file.txt
```

## Checked ownership

```bash
ls -l devops-file.txt
```

## Changed owner

```bash
sudo chown tokyo devops-file.txt
sudo chown berlin devops-file.txt
```

## Verified

```bash
ls -l devops-file.txt
```

### Result

```
devops-file.txt

Original:
suraj:suraj

After:
tokyo:suraj

Final:
berlin:suraj
```

---

# Task 3: Basic chgrp Operations

## Created file

```bash
cat > team-notes.txt
```

## Created group

```bash
sudo addgroup heist-team
```

## Changed group

```bash
sudo chgrp heist-team team-notes.txt
```

## Verified

```bash
ls -l team-notes.txt
```

### Result

```
team-notes.txt

Original:
suraj:suraj

Updated:
suraj:heist-team
```

---

# Task 4: Combined Owner & Group Change

## Created file

```bash
touch project-config.yaml
```

## Created user

```bash
sudo useradd -m -s /bin/bash professor
```

## Changed owner and group

```bash
sudo chown professor:heist-team project-config.yaml
```

## Verified

```bash
ls -l project-config.yaml
```

### Result

```
project-config.yaml

suraj:suraj

↓

professor:heist-team
```

---

## Directory Ownership

Created directory:

```bash
mkdir app-logs
```

Changed ownership:

```bash
sudo chown berlin:heist-team app-logs/
```

Verified:

```bash
ls -ld app-logs/
```

Result:

```
app-logs/

berlin:heist-team
```

---

# Task 5: Recursive Ownership

## Directory Structure

```bash
mkdir -p heist-project/vault
mkdir -p heist-project/plans

touch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf
```

Created group:

```bash
sudo addgroup planners
```

Changed ownership recursively:

```bash
sudo chown -R professor:planners heist-project/
```

Verified:

```bash
ls -lR heist-project/
```

### Result

All files and directories inside:

```
Owner:
professor

Group:
planners
```

Including:

```
heist-project/
vault/
plans/
gold.txt
strategy.conf
```

---

# Task 6: Practice Challenge

## Users Created

```
tokyo
berlin
nairobi
```

## Groups Created

```
vault-team
tech-team
```

## Directory Created

```bash
mkdir -p bank-heist/
```

## Files Created

```bash
touch bank-heist/access-codes.txt

touch bank-heist/blueprints.txt

touch bank-heist/escape-plan.txt
```

## Ownership Assigned

### Access Codes

```bash
sudo chown tokyo:vault-team bank-heist/access-codes.txt
```

Result:

```
tokyo:vault-team
```

---

### Blueprints

```bash
sudo chown berlin:tech-team bank-heist/blueprints.txt
```

Result:

```
berlin:tech-team
```

---

### Escape Plan

```bash
sudo chown nairobi:vault-team bank-heist/escape-plan.txt
```

Result:

```
nairobi:vault-team
```

Verified:

```bash
ls -l bank-heist/
```

---

# Commands Used

## View ownership

```bash
ls -l
```

## Change owner

```bash
sudo chown owner filename
```

## Change group

```bash
sudo chgrp group filename
```

## Change owner and group

```bash
sudo chown owner:group filename
```

## Recursive ownership

```bash
sudo chown -R owner:group directory
```

## Create user

```bash
sudo adduser username
```

## Create group

```bash
sudo addgroup groupname
```

---

# Files & Directories Created

## Files

```
devops-file.txt
team-notes.txt
project-config.yaml

heist-project/vault/gold.txt
heist-project/plans/strategy.conf

bank-heist/access-codes.txt
bank-heist/blueprints.txt
bank-heist/escape-plan.txt
```

## Directories

```
app-logs/

heist-project/
heist-project/vault/
heist-project/plans/

bank-heist/
```

---

# Ownership Changes Summary

| File                | Before      | After                |
| ------------------- | ----------- | -------------------- |
| devops-file.txt     | suraj:suraj | berlin:suraj         |
| team-notes.txt      | suraj:suraj | suraj:heist-team     |
| project-config.yaml | suraj:suraj | professor:heist-team |
| app-logs            | suraj:suraj | berlin:heist-team    |
| heist-project       | suraj:suraj | professor:planners   |
| access-codes.txt    | suraj:suraj | tokyo:vault-team     |
| blueprints.txt      | suraj:suraj | berlin:tech-team     |
| escape-plan.txt     | suraj:suraj | nairobi:vault-team   |

---

# What I Learned

## 1. What is File Ownership?

Linux assigns every file and directory:

* An owner (user)
* A group

These determine who can access and modify the file.

---

## 2. Why is File Ownership Important?

* Improves system security.
* Prevents unauthorized access.
* Enables team collaboration through groups.
* Essential for server and DevOps administration.

---

## 3. How Did I Solve This Challenge?

I completed the challenge by:

* Creating users and groups.
* Creating files and directories.
* Viewing ownership using `ls -l`.
* Changing owners using `chown`.
* Changing groups using `chgrp`.
* Changing both owner and group together.
* Applying recursive ownership using `chown -R`.
* Verifying every change with `ls -l` and `ls -lR`.

---

# Key Takeaways

* Every Linux file has an owner and a group.
* `chown` changes file ownership.
* `chgrp` changes the file's group.
* `chown owner:group` changes both at once.
* `chown -R` recursively updates directories and their contents.
* Users and groups must exist before assigning ownership.
* Always verify changes using `ls -l`.

---

# Conclusion

This Day 11 challenge provided practical experience with Linux file ownership management. I learned how to manage users, groups, and file permissions effectively using `chown` and `chgrp`. These concepts are fundamental for Linux administration and are widely used in DevOps for managing application files, shared resources, deployment directories, and system security.
