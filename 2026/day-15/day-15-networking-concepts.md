# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

## 📌 Objective

Today, I learned the basic networking concepts that every DevOps engineer should know. I learned how DNS works, how IP addresses identify devices, what CIDR and subnetting are, and why ports are important for network communication.

---

# Task 1: DNS – How Names Become IPs

## What is DNS?

DNS (Domain Name System) is like the phonebook of the Internet. It converts a domain name like `google.com` into an IP address so that computers can find each other on the network.

### Example

Instead of remembering an IP address like:

```text
142.250.193.78
```

We simply type:

```text
google.com
```

DNS finds the correct IP address for us.

---

## Why do we need DNS?

Computers communicate using IP addresses, but people can easily remember names like `google.com` or `github.com`.

Without DNS, we would have to remember the IP address of every website we visit.

---

## How does DNS work?

When I type `google.com` in my browser:

1. The browser checks if the IP address is already saved in the local cache.
2. If not found, it sends a request to a DNS server.
3. The DNS server looks up the IP address for `google.com`.
4. The DNS server sends the IP address back to my computer.
5. My browser connects to that IP address.
6. The website opens in the browser.

### Simple Flow

```text
Browser
   │
   ▼
google.com
   │
   ▼
DNS Server
   │
   ▼
IP Address
   │
   ▼
Google Server
   │
   ▼
Website Opens
```

---

## DNS Record Types

| Record | Description |
|---------|-------------|
| **A** | Maps a domain name to an IPv4 address. |
| **AAAA** | Maps a domain name to an IPv6 address. |
| **CNAME** | Points one domain name to another domain name. |
| **MX** | Specifies the mail server used for receiving emails. |
| **NS** | Specifies the authoritative DNS server for a domain. |

---

## Command

Run the following command:

```bash
dig google.com
```

---

## Sample Output

```text
; <<>> DiG <<>> google.com

;; ANSWER SECTION:
google.com.    300    IN    A    142.250.193.78
```

> **Note:** Your IP address and TTL value may be different because Google uses multiple servers.

---

## Identify the A Record

The **A Record** is:

```text
142.250.193.78
```

It maps the domain name to an IPv4 address.

---

## What is TTL?

TTL stands for **Time To Live**.

It tells DNS how long the record should stay in the cache before asking the DNS server again.

Example:

```text
300
```

means the DNS record can be cached for **300 seconds (5 minutes).**

---

## What I Learned from DNS

- DNS converts domain names into IP addresses.
- Computers use IP addresses, but humans remember domain names.
- The **A Record** stores the IPv4 address of a domain.
- TTL tells how long a DNS record can stay in cache.
- The `dig` command helps us check DNS records.

---

# Task 2: IP Addressing

## What is an IPv4 Address?

An IPv4 (Internet Protocol Version 4) address is a unique 32-bit address used to identify a device on a network. Every device connected to a network needs an IP address so it can send and receive data.

### Example

```text
192.168.1.10
```

An IPv4 address contains **4 numbers (octets)** separated by dots (`.`).

Each octet ranges from **0 to 255**.

Example:

```text
192 . 168 . 1 . 10
```

---

## Why do we need an IP Address?

An IP address helps identify each device on a network.

Without an IP address:

- Devices cannot communicate.
- Data cannot reach the correct destination.
- Internet communication is not possible.

Think of an IP address like a **home address**. A delivery person needs your address to deliver a package. Similarly, computers need an IP address to send and receive data.

---

## How does an IP Address work?

When you open a website:

1. DNS converts the domain name into an IP address.
2. Your computer sends a request to that IP address.
3. The server receives the request.
4. The server sends the response back to your computer.

---

# Structure of an IPv4 Address

IPv4 consists of **32 bits**.

It is divided into **4 octets**.

```text
192.168.1.10
```

Binary representation:

```text
11000000.10101000.00000001.00001010
```

Each octet contains **8 bits**.

```text
8 + 8 + 8 + 8 = 32 bits
```

---

# Public IP Address

## What?

A Public IP address is an IP address that can be accessed over the Internet.

## Why?

It allows devices to communicate with servers and users across the Internet.

## How?

A Public IP is assigned by your Internet Service Provider (ISP).

### Example

```text
8.8.8.8
```

Google's public DNS server.

---

# Private IP Address

## What?

A Private IP address is used inside private networks such as homes, offices, or companies.

## Why?

Private IP addresses save public IP addresses and allow many devices to communicate within the same local network.

## How?

Routers assign private IP addresses to devices using DHCP.

### Example

```text
192.168.1.100
```

---

# Difference Between Public and Private IP

| Public IP | Private IP |
|-----------|------------|
| Used on the Internet | Used inside local networks |
| Globally unique | Can be reused in different networks |
| Assigned by ISP | Assigned by router |
| Accessible from the Internet | Not directly accessible from the Internet |

### Example

**Public IP**

```text
8.8.8.8
```

**Private IP**

```text
192.168.1.100
```

---

# Private IP Ranges

IPv4 has three private IP address ranges.

| Range | CIDR |
|--------|------|
| 10.0.0.0 – 10.255.255.255 | /8 |
| 172.16.0.0 – 172.31.255.255 | /12 |
| 192.168.0.0 – 192.168.255.255 | /16 |

If your IP address belongs to one of these ranges, it is a **Private IP**.

---

# Command

Run the following command:

```bash
ip addr show
```

---

# Sample Output

```text
2: eth0:
    inet 192.168.1.25/24
```

---

# Identify the Private IP

In the example above:

```text
192.168.1.25
```

is a **Private IP** because it belongs to the range:

```text
192.168.0.0/16
```

---

# How to Identify a Public or Private IP

Check the first numbers of the IP address.

| IP Address | Type |
|------------|------|
| 10.10.5.8 | Private |
| 172.20.10.5 | Private |
| 192.168.1.100 | Private |
| 8.8.8.8 | Public |
| 1.1.1.1 | Public |

---

# What I Learned from IP Addressing

- Every device on a network needs an IP address.
- An IPv4 address has 32 bits and 4 octets.
- Public IP addresses are used on the Internet.
- Private IP addresses are used inside local networks.
- The `ip addr show` command displays the IP addresses assigned to my system.
- I can identify a private IP by checking whether it belongs to one of the three private IP ranges.

---


# Task 3: CIDR & Subnetting

## What is CIDR?

CIDR (Classless Inter-Domain Routing) is a method used to divide IP networks using a prefix like `/24` or `/16`.

The number after the `/` tells us how many bits are used for the **network**.

### Example

```text
192.168.1.0/24
```

Here:

- `/24` = 24 Network Bits
- `8` = Host Bits (32 - 24 = 8)

---

## Why do we use CIDR?

CIDR helps us use IP addresses more efficiently.

Without CIDR, many IP addresses would be wasted.

CIDR also makes network management easier.

---

## How does CIDR work?

An IPv4 address has **32 bits**.

The CIDR number tells us how many bits belong to the network.

Example:

```text
192.168.1.0/24
```

Calculation:

```text
Total Bits = 32
Network Bits = 24
Host Bits = 32 - 24 = 8
```

Number of addresses:

```text
2^8 = 256
```

Usable hosts:

```text
256 - 2 = 254
```

(The first address is the Network Address and the last address is the Broadcast Address.)

---

# What is a Subnet Mask?

## What?

A subnet mask separates the **Network ID** and the **Host ID** of an IP address.

Example:

```text
IP Address  : 192.168.1.10
Subnet Mask : 255.255.255.0
```

Network Part:

```text
192.168.1
```

Host Part:

```text
10
```

---

## Why do we need a Subnet Mask?

A subnet mask helps devices know whether another device is on the same network or a different network.

If both devices are on the same network, they can communicate directly.

If they are on different networks, the data is sent through a router.

---

## How does a Subnet Mask work?

The subnet mask uses:

- **1 = Network Bit**
- **0 = Host Bit**

Example:

```text
CIDR : /24

Binary Mask

11111111.11111111.11111111.00000000
```

Decimal:

```text
255.255.255.0
```

---

# What does `/24` mean in `192.168.1.0/24`?

It means:

- 24 bits are used for the Network.
- 8 bits are used for Hosts.

Subnet Mask:

```text
255.255.255.0
```

Total IP Addresses:

```text
2^8 = 256
```

Usable Hosts:

```text
254
```

---

# Usable Hosts

## `/24`

Host Bits:

```text
32 - 24 = 8
```

Total IPs:

```text
2^8 = 256
```

Usable Hosts:

```text
254
```

---

## `/16`

Host Bits:

```text
32 - 16 = 16
```

Total IPs:

```text
2^16 = 65,536
```

Usable Hosts:

```text
65,534
```

---

## `/28`

Host Bits:

```text
32 - 28 = 4
```

Total IPs:

```text
2^4 = 16
```

Usable Hosts:

```text
14
```

---

# Why do we Subnet?

Subnetting means dividing one large network into smaller networks.

### Benefits of Subnetting

- Better network performance.
- Better security.
- Easy network management.
- Efficient use of IP addresses.
- Reduces unnecessary network traffic.

---

# CIDR Table

| CIDR | Subnet Mask | Total IPs | Usable Hosts |
|------|-------------|----------:|-------------:|
| /24 | 255.255.255.0 | 256 | 254 |
| /16 | 255.255.0.0 | 65,536 | 65,534 |
| /28 | 255.255.255.240 | 16 | 14 |

---

# Example of CIDR and Subnet Mask

| CIDR | Subnet Mask |
|------|-------------|
| /24 | 255.255.255.0 |
| /25 | 255.255.255.128 |
| /26 | 255.255.255.192 |
| /27 | 255.255.255.224 |
| /28 | 255.255.255.240 |
| /29 | 255.255.255.248 |
| /30 | 255.255.255.252 |

---

# Quick Summary

| CIDR | Network Bits | Host Bits | Usable Hosts |
|------|-------------:|----------:|-------------:|
| /24 | 24 | 8 | 254 |
| /16 | 16 | 16 | 65,534 |
| /28 | 28 | 4 | 14 |

---

# What I Learned from CIDR & Subnetting

- CIDR tells how many bits belong to the network.
- A subnet mask separates the network part and the host part of an IP address.
- Subnetting divides a large network into smaller networks.
- I can calculate host bits using **32 − CIDR**.
- Total IP addresses are calculated using **2^(Host Bits)**.
- Usable hosts are calculated using **2^(Host Bits) − 2**.

---

# Task 4: Ports – The Doors to Services

## What is a Port?

A port is a logical communication endpoint used by applications on a computer. It helps the operating system send network data to the correct application or service.

Think of it like this:

- **IP Address** = House Address 🏠
- **Port Number** = Room Number 🚪

Example:

```text
192.168.1.10:22
```

- `192.168.1.10` → Device
- `22` → SSH Service

---

## Why do we need Ports?

One computer can run many services at the same time.

For example:

- SSH
- Nginx
- Apache
- MySQL
- Redis
- MongoDB

All these services use the same IP address but different port numbers.

Without ports, the computer would not know which service should receive the incoming data.

---

## How do Ports work?

When a client sends a request, it connects to both an IP address and a port number.

Example:

```text
http://192.168.1.10:80
```

The computer checks:

- IP Address → Which device?
- Port Number → Which service?

Then it sends the request to the correct application.

---

# Port Number Range

Ports are **16-bit numbers**.

The port range is:

```text
0 - 65535
```

Ports are divided into three categories.

| Port Range | Type | Description |
|------------|------|-------------|
| 0 - 1023 | Well-Known Ports | Used by common services like SSH, HTTP, HTTPS and DNS |
| 1024 - 49151 | Registered Ports | Used by applications like MySQL and PostgreSQL |
| 49152 - 65535 | Dynamic Ports | Temporary ports used by clients |

---

# Common Ports

| Port | Service | Description |
|------|---------|-------------|
| 22 | SSH | Secure remote login |
| 53 | DNS | Domain Name System |
| 80 | HTTP | Web traffic without encryption |
| 443 | HTTPS | Secure web traffic |
| 3306 | MySQL | MySQL Database |
| 6379 | Redis | Redis Database / Cache |
| 27017 | MongoDB | MongoDB Database |

---

# Examples

### SSH

```text
192.168.1.10:22
```

Connects to the SSH service.

---

### HTTP

```text
http://example.com
```

Uses Port **80**.

---

### HTTPS

```text
https://example.com
```

Uses Port **443**.

---

### MySQL

```text
192.168.1.20:3306
```

Connects to the MySQL database.

---

### Redis

```text
192.168.1.20:6379
```

Connects to the Redis server.

---

### MongoDB

```text
192.168.1.20:27017
```

Connects to the MongoDB server.

---

# Command

Run the following command:

```bash
ss -tulpn
```

---

# Sample Output

```text
Netid State  Local Address:Port

tcp   LISTEN 0.0.0.0:22
tcp   LISTEN 0.0.0.0:80
tcp   LISTEN 127.0.0.1:3306
```

---

# Match Listening Ports to Services

| Port | Service |
|------|---------|
| 22 | SSH Server |
| 80 | HTTP Web Server |
| 3306 | MySQL Database |

> **Note:** Your output may be different depending on the services running on your system.

---

# Real DevOps Examples

### SSH Login

```bash
ssh user@192.168.1.10
```

Uses:

```text
Port 22
```

---

### Open a Website

```text
https://google.com
```

Uses:

```text
Port 443
```

---

### Connect to MySQL

```bash
mysql -h 192.168.1.20 -P 3306
```

Uses:

```text
Port 3306
```

---

### Docker Port Mapping

```bash
docker run -p 8080:80 nginx
```

Meaning:

- Host Port → **8080**
- Container Port → **80**

When we open:

```text
http://localhost:8080
```

Docker forwards the request to port **80** inside the container.

---

# What I Learned from Ports

- A port identifies a specific service running on a device.
- IP addresses identify devices, while ports identify applications.
- One device can run multiple services using different port numbers.
- The `ss -tulpn` command shows which ports are currently listening.
- Common ports like **22**, **80**, **443**, and **3306** are important for DevOps and system administration.

---

# Task 5: Putting It Together

## Question 1

### You run:

```bash
curl http://myapp.com:8080
```

### What networking concepts are involved?

When I run this command, several networking concepts work together.

1. **DNS** converts `myapp.com` into an IP address.
2. **IP Address** identifies the server where the application is running.
3. **Port 8080** tells the operating system which application or service should receive the request.
4. The server processes the request and sends the response back to my terminal.

---

## Question 2

### Your app can't reach a database at:

```text
10.0.1.50:3306
```

### What would you check first?

I would check the following:

- Is the database server running?
- Is the IP address (`10.0.1.50`) correct?
- Is port **3306** open and listening?
- Is the firewall blocking the connection?
- Are both systems on the same network?
- Can I reach the server using `ping` or `telnet`?

---

# Commands Used

## Check DNS Record

```bash
dig google.com
```

---

## Check IP Address

```bash
ip addr show
```

---

## Check Listening Ports

```bash
ss -tulpn
```

---

# Summary Table

| Topic | Purpose |
|-------|---------|
| DNS | Converts a domain name into an IP address. |
| IPv4 | Identifies a device on a network. |
| Public IP | Used for communication over the Internet. |
| Private IP | Used inside local networks. |
| CIDR | Divides networks using prefixes like `/24`. |
| Subnet Mask | Separates the network and host parts of an IP address. |
| Subnetting | Divides one large network into smaller networks. |
| Port | Identifies a service running on a device. |

---

# What I Learned

### 1. DNS

I learned that DNS converts a domain name into an IP address so that computers can communicate with each other.

---

### 2. IP Addressing

I learned the difference between Public and Private IP addresses and how to identify a private IP using `ip addr show`.

---

### 3. CIDR and Subnetting

I learned how CIDR works, how to calculate host bits, total IP addresses, and usable hosts. I also learned why subnetting is important for managing networks.

---

### 4. Ports

I learned that ports allow multiple services to run on the same device. I also learned common ports used by SSH, HTTP, HTTPS, MySQL, Redis, and MongoDB.

---

# Key Takeaways

- DNS converts domain names into IP addresses.
- Every device needs an IP address to communicate on a network.
- CIDR and subnetting help organize and manage IP addresses efficiently.
- A subnet mask separates the network part and host part of an IP address.
- Ports allow different services to communicate on the same device.
- Linux commands like `dig`, `ip addr show`, and `ss -tulpn` are useful for troubleshooting network issues.

---

# Conclusion

Today, I learned the basic networking concepts that every DevOps engineer should know. I now understand how DNS resolves domain names, how IP addresses identify devices, how CIDR and subnetting organize networks, and how ports allow different services to communicate. These concepts will help me understand networking better and build a strong foundation for learning Docker, Kubernetes, cloud platforms, and other DevOps tools.

---
