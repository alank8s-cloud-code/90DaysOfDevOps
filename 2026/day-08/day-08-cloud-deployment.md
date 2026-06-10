# Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment

## Objective

The goal of this task is to launch a cloud server, connect to it using SSH, install Nginx, configure network access, collect logs, and verify that the website is accessible from the internet.

This is a basic DevOps activity because servers are commonly used to host applications and websites.

---

# Prerequisites

* AWS Free Tier account or Utho account
* SSH client (Terminal or PuTTY)
* Key pair (.pem file for AWS)
* Basic Linux command knowledge

---

# Part 1: Launch Cloud Instance & SSH Access

## What?

A cloud instance is a virtual computer running on the internet.

## Why?

Instead of buying physical servers, companies use cloud servers because they are scalable and cost-effective.

## How?

### Step 1: Launch an Instance

For AWS:

1. Login to AWS Console.
2. Go to EC2 Dashboard.
3. Click Launch Instance.
4. Enter instance name.
5. Choose Ubuntu Server 24.04 LTS.
6. Select t2.micro (Free Tier).
7. Create or select a key pair.
8. Allow:

   * SSH (Port 22)
   * HTTP (Port 80)
9. Launch the instance.

### Screenshot 1

📸 Add screenshot of your EC2 instance running.

---

## Step 2: Connect using SSH

Find your Public IPv4 address.

Change permission of your key:

```bash
chmod 400 your-key.pem
```

Connect:

```bash
ssh -i your-key.pem ubuntu@YOUR_PUBLIC_IP
```

Example:

```bash
ssh -i mykey.pem ubuntu@13.233.xxx.xxx
```

If successful, you will see:

```text
Welcome to Ubuntu...
ubuntu@ip-xxx:~$
```

### Screenshot 2

📸 Add screenshot of successful SSH connection.

---

# Part 2: Update Server and Install Docker & Nginx

## What?

Docker is a container platform.

Nginx is a web server.

## Why?

Docker helps run applications consistently.

Nginx serves web pages to users.

---

## Step 1: Update System

Update package information:

```bash
sudo apt update
```

Upgrade installed packages:

```bash
sudo apt upgrade -y
```

---

## Step 2: Install Docker

Install Docker:

```bash
sudo apt install docker.io -y
```

Check Docker version:

```bash
docker --version
```

Start Docker:

```bash
sudo systemctl start docker
```

Enable Docker:

```bash
sudo systemctl enable docker
```

Check status:

```bash
sudo systemctl status docker
```

---

## Step 3: Install Nginx

Install Nginx:

```bash
sudo apt install nginx -y
```

Start Nginx:

```bash
sudo systemctl start nginx
```

Enable Nginx:

```bash
sudo systemctl enable nginx
```

Check status:

```bash
sudo systemctl status nginx
```

You should see:

```text
Active: active (running)
```

### Screenshot 3

📸 Add screenshot showing Nginx service running.

---

# Part 3: Configure Security Group

## What?

A Security Group acts like a firewall for your server.

## Why?

Without opening HTTP traffic, users cannot access your website.

## How?

In AWS:

Go to:

EC2 → Security Groups → Inbound Rules

Ensure these ports are allowed:

| Type | Port |
| ---- | ---- |
| SSH  | 22   |
| HTTP | 80   |

Save the rules.

---

## Test Web Access

Open your browser:

```
http://YOUR_PUBLIC_IP
```

You should see:

# Welcome to nginx!

This means your web server is working.

### Screenshot 4

📸 Add screenshot of Nginx welcome page in browser.

---

# Part 4: Extract Nginx Logs

## What?

Logs store server activity.

## Why?

DevOps engineers use logs to monitor and troubleshoot servers.

---

## Step 1: View Logs

Check access logs:

```bash
sudo cat /var/log/nginx/access.log
```

Check error logs:

```bash
sudo cat /var/log/nginx/error.log
```

---

## Step 2: Save Logs

Save access logs:

```bash
sudo cp /var/log/nginx/access.log ~/nginx-logs.txt
```

Verify:

```bash
cat ~/nginx-logs.txt
```

### Screenshot 5

📸 Add screenshot of log file contents.

---

## Step 3: Download Logs

Open another terminal on your local machine.

AWS:

```bash
scp -i your-key.pem ubuntu@YOUR_PUBLIC_IP:~/nginx-logs.txt .
```

Utho:

```bash
scp root@YOUR_PUBLIC_IP:~/nginx-logs.txt .
```

This downloads the log file to your computer.

### Screenshot 6

📸 Add screenshot of successful SCP command.

---

# Commands Used

```bash
sudo apt update
sudo apt upgrade -y

sudo apt install docker.io -y
docker --version
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx

sudo cat /var/log/nginx/access.log
sudo cat /var/log/nginx/error.log

sudo cp /var/log/nginx/access.log ~/nginx-logs.txt
cat ~/nginx-logs.txt

scp -i your-key.pem ubuntu@YOUR_PUBLIC_IP:~/nginx-logs.txt .
```

---

# Challenges Faced

## Challenge 1

SSH connection failed.

Solution:

* Checked the correct key file.
* Verified port 22 was open.

---

## Challenge 2

Nginx page did not open.

Solution:

* Started Nginx service.
* Allowed HTTP port 80 in Security Group.

---

## Challenge 3

Could not copy logs.

Solution:

* Verified file location.
* Used the correct SCP command.

---

# What I Learned

* Learned how to launch a cloud server.
* Learned how to connect to a server using SSH.
* Learned how to install Docker and Nginx.
* Learned how to configure Security Groups for web access.
* Learned how to check and save Nginx logs.
* Learned how to transfer files from a remote server to a local machine.

---

# Files for Submission

## README.md

✔ This documentation file.

## nginx-logs.txt

✔ Saved Nginx access logs.

## Screenshots

✔ EC2 instance running.

✔ SSH connection.

✔ Nginx service running.

✔ Nginx welcome page.

✔ Log file contents.

✔ SCP download command.

---

# Conclusion

In this task, I successfully launched a cloud server, connected using SSH, installed Docker and Nginx, configured web access, extracted server logs, and verified that the web server was accessible from the internet. This hands-on exercise provided practical experience with basic server administration and real-world DevOps operations.
