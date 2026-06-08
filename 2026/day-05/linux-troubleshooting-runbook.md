# Day 05 – Linux Troubleshooting Drill: CPU, Memory, Logs & Service Health

## 🎯 Task

Today's  my goal was to analyze the health of an Nginx web server using common Linux and DevOps monitoring commands.
I performed checks on CPU, memory, disk usage, network connectivity, service logs, and application performance to understand the overall system state.
---

## 🛠 Target Service

For this drill, I selected:

```text
Nginx Web Server
```

---

## 📊 Snapshot: CPU & Memory

Run and record outputs for:

```bash
top
free -h
ps -C nginx -o pid,ppid,%cpu,%mem,cmd
vmstat
```

### Observation

* CPU utilization was stable with low memory consumption, and Nginx worker processes were running normally.
* Overall system health appeared good with no signs of resource exhaustion or abnormal process activity.

---

## 💾 Snapshot: Disk & I/O

Run and record outputs for:

```bash
df -h
du -sh /var/log
iostat
```

### Observation

* Disk usage was within safe limits with sufficient free storage available for system and application logs.
* Disk read/write activity was normal, and no significant storage bottlenecks or I/O wait issues were observed.

---

## 🌐 Snapshot: Network

Run and record outputs for:

```bash
ss -tulpn
curl -I http://localhost
curl -I http://localhost:8090/ping
```

### Observation

* Required ports were listening correctly, and Nginx was accepting incoming connections as expected.
* HTTP health checks returned successful responses, confirming that the service was available and operational.

---

## 📜 Logs Reviewed

Run and record outputs for:

```bash
journalctl -u nginx -n 50
tail -n 50 /var/log/nginx/access.log
tail -n 50 /var/log/nginx/error.log
```

### Observation

* Recent Nginx logs showed normal service activity with successful client requests and routine events.
* No critical errors or unusual warnings were found, indicating stable application behavior.

---

## 🧪 Load Testing

Run:

```bash
ab -n 10000 -c 100 http://localhost/myapp/
```

### Observation

* Nginx handled the simulated workload efficiently with high request throughput and minimal response times.
* Failed requests were negligible or absent, demonstrating good service stability under load.

---

## 📸 Screenshots

Capture screenshots of the following:

### 1. Process Monitoring

```text
images/process-monitoring.png
```

### 2. Disk & I/O Monitoring

```text
images/disk-monitoring.png
```

### 3. Network Verification

```text
images/network-check.png
```

### 4. Nginx Ping Endpoint

```text
images/nginx-ping.png
```

### 5. Log Verification

```text
images/log-analysis.png
```

---

## ✍️ Handwritten Notes

Prepared handwritten notes for:

* Process Monitoring
* Memory Analysis
* Disk Usage
* I/O Statistics
* Network Troubleshooting
* Service Logs
* Nginx Health Checks
* Load Testing

📄 Notes PDF:

```text
notes/day05-linux-troubleshooting-notes.pdf
```

---

## 🔍 Quick Findings

* Nginx service was healthy and responding with HTTP 200.
* CPU utilization remained low during normal operation.
* No storage bottlenecks observed (`iowait = 0%`).
* Access logs confirmed incoming requests.
* Health-check endpoint `/ping` returned expected response.

---

## 🚨 If This Worsens (Next Steps)

1. Increase log verbosity and collect detailed logs.

2. Monitor CPU, memory, and disk I/O continuously using `top`, `vmstat`, and `iostat`.

3. Capture process traces using:

```bash
strace -p <PID>
```

4. Restart or reload the service if required:

```bash
sudo systemctl restart nginx
```

5. Escalate with collected logs, metrics, and screenshots.

---

## 🎓 Key Learning

This troubleshooting drill helped me understand how to:

* Investigate service health.
* Analyze CPU and memory usage.
* Detect storage bottlenecks.
* Verify network connectivity.
* Review service logs.
* Build a repeatable incident runbook.

---

## ✅ Conclusion

In this Linux troubleshooting drill, I followed a simple step-by-step approach to check the health of an Nginx web server.

Steps Performed:
* Investigate service health.
* Checked CPU and Memory Usage using top, free, ps, and vmstat to verify system performance.
* Analyzed Disk and I/O using df, du, and iostat to ensure sufficient storage and normal disk activity.
* Verified Network Connectivity using ss and curl commands to confirm that Nginx was listening and responding correctly.
* Reviewed Service Logs using journalctl and Nginx log files to identify any errors or unusual events.
* Performed Load Testing with Apache Benchmark (ab) to evaluate the server's performance under multiple requests.
* Documented Findings by collecting command outputs, screenshots, and handwritten notes for future reference.
