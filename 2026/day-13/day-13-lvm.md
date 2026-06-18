# Day 13 – Linux Logical Volume Management (LVM)

## Objective

The objective of this lab is to learn Linux Logical Volume Management (LVM), a storage management technology that provides flexibility in managing disk storage. In this exercise, we will create physical volumes, volume groups, logical volumes, format and mount them, and finally extend the storage without affecting existing data.

---

# What is LVM?

**Logical Volume Management (LVM)** is a storage management system in Linux that allows administrators to create flexible disk partitions. Unlike traditional partitioning, LVM abstracts physical storage devices into logical units that can be resized and managed dynamically.

LVM consists of three main components:

1. **Physical Volume (PV)**

   * The actual storage device or partition.
   * Example: `/dev/sdb` or `/dev/loop0`.

2. **Volume Group (VG)**

   * A collection of one or more physical volumes.
   * Acts as a storage pool from which logical volumes are created.

3. **Logical Volume (LV)**

   * Virtual partitions created from the volume group.
   * Can be resized easily without repartitioning disks.

---

# Why Do We Use LVM?

Traditional disk partitions have several limitations:

* Fixed size after creation.
* Difficult to resize.
* Managing multiple disks can be complex.

LVM solves these problems by providing:

* Dynamic resizing of storage.
* Easy addition of new disks.
* Better storage management.
* Online expansion of file systems.
* Flexible allocation of storage space.

---

# Why is LVM Important for DevOps?

LVM is widely used in DevOps and system administration because:

### 1. Scalability

Applications and databases often require additional storage. LVM allows storage expansion without downtime.

### 2. Better Resource Management

Multiple disks can be combined into a single storage pool, simplifying infrastructure management.

### 3. Cloud and Virtual Environments

Many cloud servers and virtual machines use LVM to manage storage efficiently.

### 4. Easy Maintenance

Logical volumes can be resized, moved, and managed with minimal service interruption.

### 5. Backup and Snapshot Support

LVM supports snapshots, making backups safer and easier.

---

# Prerequisites

Switch to the root user:

```bash
sudo -i
```

or

```bash
sudo su
```

If no spare disk is available, create a virtual disk:

```bash
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
losetup -fP /tmp/disk1.img
losetup -a
```

---

# Task 1: Check Current Storage

## Commands

```bash
lsblk
pvs
vgs
lvs
df -h
```

## Output

```text
Paste your command output here.
```

## Screenshot

Add your screenshot here.

---

# Task 2: Create a Physical Volume

## Command

```bash
pvcreate /dev/sdb
```

or

```bash
pvcreate /dev/loop0
```

Verify:

```bash
pvs
```

## Output

```text
Paste your command output here.
```

## Screenshot

Add your screenshot here.

---

# Task 3: Create a Volume Group

## Command

```bash
vgcreate devops-vg /dev/sdb
```

or

```bash
vgcreate devops-vg /dev/loop0
```

Verify:

```bash
vgs
```

## Output

```text
Paste your command output here.
```

## Screenshot

Add your screenshot here.

---

# Task 4: Create a Logical Volume

## Command

```bash
lvcreate -L 500M -n app-data devops-vg
```

Verify:

```bash
lvs
```

## Output

```text
Paste your command output here.
```

## Screenshot

Add your screenshot here.

---

# Task 5: Format and Mount the Logical Volume

## Commands

Create the filesystem:

```bash
mkfs.ext4 /dev/devops-vg/app-data
```

Create a mount point:

```bash
mkdir -p /mnt/app-data
```

Mount the logical volume:

```bash
mount /dev/devops-vg/app-data /mnt/app-data
```

Verify:

```bash
df -h /mnt/app-data
```

## Output

```text
Paste your command output here.
```

## Screenshot

Add your screenshot here.

---

# Task 6: Extend the Logical Volume

## Commands

Extend the logical volume:

```bash
lvextend -L +200M /dev/devops-vg/app-data
```

Resize the filesystem:

```bash
resize2fs /dev/devops-vg/app-data
```

Verify:

```bash
df -h /mnt/app-data
```

## Output

```text
Paste your command output here.
```

## Screenshot

Add your screenshot here.

---

# LVM Architecture

```
+----------------------+
|  Physical Disk       |
| (/dev/sdb, /dev/sdc) |
+----------+-----------+
           |
           v
+----------------------+
| Physical Volume (PV) |
+----------+-----------+
           |
           v
+----------------------+
|  Volume Group (VG)   |
|     devops-vg        |
+----------+-----------+
           |
           v
+----------------------+
| Logical Volume (LV)  |
|      app-data        |
+----------+-----------+
           |
           v
+----------------------+
|   ext4 File System   |
+----------+-----------+
           |
           v
+----------------------+
|    /mnt/app-data     |
+----------------------+
```

---

# Commands Used

```bash
sudo -i
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
losetup -fP /tmp/disk1.img
losetup -a

lsblk
pvs
vgs
lvs
df -h

pvcreate /dev/sdb

vgcreate devops-vg /dev/sdb

lvcreate -L 500M -n app-data devops-vg

mkfs.ext4 /dev/devops-vg/app-data

mkdir -p /mnt/app-data

mount /dev/devops-vg/app-data /mnt/app-data

lvextend -L +200M /dev/devops-vg/app-data

resize2fs /dev/devops-vg/app-data
```

---

# What I Learned

## 1. Understanding LVM Components

I learned that LVM consists of Physical Volumes (PV), Volume Groups (VG), and Logical Volumes (LV), which work together to provide flexible storage management.

## 2. Managing Storage Efficiently

I learned how to create, format, mount, and extend logical volumes without repartitioning the disk.

## 3. DevOps Relevance

I learned that LVM is widely used in DevOps and cloud environments because it allows storage to be expanded dynamically with minimal downtime, making infrastructure management easier and more scalable.

---

# Conclusion

Linux Logical Volume Management (LVM) provides a flexible and efficient way to manage storage. Unlike traditional partitioning, LVM allows administrators to dynamically allocate and resize storage according to application needs. This feature makes LVM an essential skill for Linux system administrators and DevOps engineers working with cloud infrastructure, virtual machines, and production servers.
