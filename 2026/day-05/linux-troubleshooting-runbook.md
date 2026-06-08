# Day 05 – Linux Troubleshooting Drill: CPU, Memory, and Logs

## 🎯 Objective

Perform a focused Linux troubleshooting drill by collecting system health information, reviewing logs, analyzing resource usage, and documenting findings in a repeatable runbook format.

---

# 🖥️ Environment Information

## Command 1: uname -a

```bash
uname -a
```

### Observation

- Verified Linux kernel version and system architecture.
- Confirmed the environment is running on Ubuntu WSL2.

---

## Command 2: cat /etc/os-release

```bash
cat /etc/os-release
```

### Observation

- Confirmed Ubuntu distribution version.
- Verified operating system details for troubleshooting context.

---

# 📂 Filesystem Sanity Check

## Command 3: Create Test Directory

```bash
mkdir /tmp/runbook-demo
cp /etc/hosts /tmp/runbook-demo/hosts-copy
ls -l /tmp/runbook-demo
```

### Observation

- Successfully created test directory.
- Verified file creation and permissions.

---

## Command 4: Disk Usage

```bash
df -h
```

### Observation

- Disk usage was within safe limits.
- No filesystem nearing full capacity.

---

# ⚡ CPU & Memory Snapshot

## Target Service

**Nginx Web Server**

---

## Command 5: Process Inspection

```bash
ps -C nginx -o pid,ppid,%cpu,%mem,cmd
```

### Observation

- Nginx master and worker processes were running normally.
- CPU and memory utilization remained low.

---

## Command 6: Memory Usage

```bash
free -h
```

### Observation

- Sufficient free memory available.
- No memory pressure or excessive swap usage observed.

---

## Command 7: Virtual Memory Statistics

```bash
vmstat
```

### Observation

- CPU remained mostly idle.
- No blocked processes or significant I/O wait detected.

---

# 💽 Disk & I/O Snapshot

## Command 8: Disk Usage Analysis

```bash
du -sh /var/log
```

### Observation

- Log directory size was within expected range.
- No abnormal log growth detected.

---

## Command 9: Disk I/O Statistics

```bash
iostat
```

### Observation

- Low I/O wait time observed.
- No signs of storage bottlenecks.

---

# 🌐 Network Snapshot

## Command 10: Open Ports Verification

```bash
ss -tulpn
```

### Observation

- Nginx was listening on the configured port.
- Required services were accessible.

---

## Command 11: Service Health Check

```bash
curl -I http://localhost:8090/ping
```

### Observation

- Received HTTP 200 OK response.
- Confirmed Nginx health-check endpoint is operational.

---

# 📜 Logs Reviewed

## Command 12: Service Logs

```bash
journalctl -u nginx -n 50
```

### Observation

- No recent service failures detected.
- Nginx startup and reload operations completed successfully.

---

## Command 13: Access Logs

```bash
tail -n 50 /var/log/nginx/access.log
```

### Observation

- Incoming requests were successfully logged.
- Health-check requests appeared in the access log.

---

# 📸 Screenshots

Add screenshots for the following:

### 1. Nginx Process Monitoring

```text
images/nginx-process-monitoring.png
```

### 2. VMStat Output

```text
images/vmstat-output.png
```

### 3. IOSTAT Output

```text
images/iostat-output.png
```

### 4. Nginx Health Check

```text
images/nginx-ping-check.png
```

### 5. Access Log Verification

```text
images/access-log-verification.png
```

---

# 🔍 Quick Findings

- Nginx service was healthy and responsive.
- CPU usage remained low during testing.
- Memory usage was stable with available free memory.
- Disk utilization and I/O wait remained within normal limits.
- Network connectivity and service endpoints were reachable.
- No critical errors found in service or access logs.

---

# ✍️ Handwritten Notes

To reinforce today's troubleshooting concepts, handwritten notes were created covering:

- Process Monitoring
- CPU & Memory Analysis
- Disk Usage Commands
- Disk I/O Monitoring
- Network Troubleshooting
- Log Analysis
- Nginx Health Checks
- Troubleshooting Workflow

📄 Notes PDF:

```text
day05-linux-troubleshooting-notes.pdf
```

---

# 🚨 If This Worsens (Next Steps)

### 1. Increase Log Investigation

```bash
journalctl -u nginx -f
tail -f /var/log/nginx/error.log
```

Monitor logs in real time for recurring errors.

---

### 2. Collect Resource Metrics

```bash
top
vmstat 1
iostat -x 1
```

Identify CPU, memory, or storage bottlenecks.

---

### 3. Deep Process Investigation

```bash
strace -p <PID>
```

Analyze system calls if the process becomes unresponsive.

---

# 🚀 Outcome

Successfully completed a Linux troubleshooting drill by analyzing system resources, network status, disk I/O, service logs, and Nginx health checks while documenting observations in a reusable runbook.
