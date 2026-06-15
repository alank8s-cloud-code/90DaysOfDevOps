# Day 07 - Linux File System Hierarchy & Scenario-Based Practice

## Objective

Today's goal was to understand the Linux File System Hierarchy and practice troubleshooting scenarios commonly encountered by DevOps engineers.

## Topics Covered

- Linux File System Hierarchy
- Important Linux directories
- Log file investigation
- Configuration files
- Service troubleshooting
- CPU troubleshooting
- Service log analysis
- File permission issues

---

# Part 1: Linux File System Hierarchy

---

## 1. `/` (Root Directory)

### Purpose
The root directory is the top-level directory of Linux. Every file and folder starts from here.

### Example

```bash
ls -l /
```

### Sample Items

- home
- etc

### I would use this when...
Navigating the Linux filesystem or locating important system directories.

### Output Screenshot

```
Add Screenshot Here:
images/root-directory.png
```

---

## 2. `/home`

### Purpose

Stores personal files and directories for normal users.

### Example

```bash
ls -l /home
```

### Sample Items

- user
- suraj

### I would use this when...

Managing user files and personal scripts.

### Output Screenshot

```
Add Screenshot Here:
images/home-directory.png
```

---

## 3. `/root`

### Purpose

Home directory of the root (administrator) user.

### Example

```bash
ls -l /root
```

### Sample Items

- .bashrc
- scripts

### I would use this when...

Performing administrative tasks.

### Output Screenshot

```
Add Screenshot Here:
images/root-home.png
```

---

## 4. `/etc`

### Purpose

Contains system-wide configuration files.

### Example

```bash
ls -l /etc
```

### Sample Items

- hostname
- hosts

### I would use this when...

Editing system configurations.

### Output Screenshot

```
Add Screenshot Here:
images/etc-directory.png
```

---

## 5. `/var/log`

### Purpose

Stores system and application log files.

### Example

```bash
ls -l /var/log
```

### Sample Items

- syslog
- auth.log

### I would use this when...

Troubleshooting system and service issues.

### Output Screenshot

```
Add Screenshot Here:
images/var-log.png
```

---

## 6. `/tmp`

### Purpose

Stores temporary files created by applications and users.

### Example

```bash
ls -l /tmp
```

### Sample Items

- temp files
- cache files

### I would use this when...

Checking temporary application data.

### Output Screenshot

```
Add Screenshot Here:
images/tmp-directory.png
```

---

# Additional Directories

---

## `/bin`

### Purpose

Contains essential Linux commands.

Examples:
- ls
- cp

I would use this when...
Running basic Linux commands.

---

## `/usr/bin`

### Purpose

Contains most user-level executable programs.

Examples:
- git
- python3

I would use this when...
Using installed applications.

---

## `/opt`

### Purpose

Stores optional third-party software.

Examples:
- Google Chrome
- Custom applications

I would use this when...
Installing external software packages.

---

# Hands-on Tasks

---

## Find Largest Log Files

### Command

```bash
du -sh /var/log/* 2>/dev/null | sort -h | tail -5
```

### Output Screenshot

```
images/largest-log-files.png
```

---

## Check Hostname

### Command

```bash
cat /etc/hostname
```

### Output Screenshot

```
images/hostname.png
```

---

## Check Home Directory

### Command

```bash
ls -la ~
```

### Output Screenshot

```
images/home-list.png
```

---

# Part 2: Scenario-Based Practice

---

# Scenario 1: Service Not Starting

## Step 1

```bash
systemctl status myapp
```

Why:
Check whether the service is active, failed, or stopped.

---

## Step 2

```bash
journalctl -u myapp -n 50
```

Why:
Review recent logs for error messages.

---

## Step 3

```bash
systemctl is-enabled myapp
```

Why:
Verify whether the service starts automatically after reboot.

---

## Step 4

```bash
systemctl list-units --type=service
```

Why:
Confirm the service exists and inspect other running services.

---

# Scenario 2: High CPU Usage

## Step 1

```bash
top
```

Why:
Monitor CPU usage in real time.

---

## Step 2

```bash
htop
```

Why:
Provides an interactive process viewer.

---

## Step 3

```bash
ps aux --sort=-%cpu | head -10
```

Why:
Display top CPU-consuming processes.

---

## Step 4

Record the PID of the process consuming the most CPU.

```bash
ps -p PID
```

Why:
Investigate the problematic process.

---

# Scenario 3: Finding Service Logs

## Step 1

```bash
systemctl status docker
```

Why:
Check service health.

---

## Step 2

```bash
journalctl -u docker -n 50
```

Why:
View recent Docker logs.

---

## Step 3

```bash
journalctl -u docker -f
```

Why:
Monitor logs in real time.

---

## Step 4

```bash
journalctl -u docker --since today
```

Why:
View logs generated today.

---

# Scenario 4: File Permission Issue

## Step 1

```bash
ls -l /home/user/backup.sh
```

Why:
Check current permissions.

---

## Step 2

```bash
chmod +x /home/user/backup.sh
```

Why:
Grant execute permission.

---

## Step 3

```bash
ls -l /home/user/backup.sh
```

Why:
Verify execute permission was added.

---

## Step 4

```bash
./backup.sh
```

Why:
Run the script to confirm the issue is resolved.

---

# Key Learnings

✅ Linux has a structured filesystem hierarchy.

✅ `/etc` contains configuration files.

✅ `/var/log` is essential for troubleshooting.

✅ `systemctl` and `journalctl` are primary tools for service management.

✅ `top`, `htop`, and `ps` help diagnose CPU issues.

✅ File execution requires execute (`x`) permission.

✅ A systematic troubleshooting approach is more valuable than memorizing commands.

---

# Commands Practiced

```bash
ls
du
sort
tail
cat
systemctl
journalctl
top
htop
ps
chmod
```

---

# Screenshots Added

- [ ] Root directory
- [ ] Home directory
- [ ] Root user directory
- [ ] /etc contents
- [ ] /var/log contents
- [ ] /tmp contents
- [ ] Largest log files
- [ ] Hostname
- [ ] Home directory listing

---

## Day 07 Status

**Linux File System Hierarchy:** ✅ Completed

**Hands-on Practice:** ✅ Completed

**Scenario-Based Troubleshooting:** ✅ Completed

**Ready for Day 08:** 🚀
