# Day 30 – Docker Images & Container Lifecycle

### Objective

Today's goal is to understand **how Docker images and containers actually work**, including:

* The relationship between images and containers
* Docker image layers
* Image caching and reuse
* Image inspection
* The complete container lifecycle
* Working with running containers
* Container networking, ports, and mounts
* Docker cleanup and disk usage

---

# Task 1 – Docker Images

## What is a Docker Image?

A Docker image is a **read-only template** used to create containers.

For example:

```text
Docker Image
     |
     | docker run
     v
Docker Container
```

An image contains:

* Application files
* Dependencies
* Libraries
* Configuration
* Metadata
* Filesystem layers

---

## 1. Pull `nginx`, `ubuntu`, and `alpine`

### Commands

```bash
docker pull nginx
docker pull ubuntu
docker pull alpine
```

### Why?

`docker pull` downloads an image from a Docker registry such as Docker Hub.

### Verify

```bash
docker images
```

---

## 2. List Docker Images

```bash
docker images
```

Modern Docker also supports:

```bash
docker image ls
```

Example:

```text
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
nginx        latest    ...            ...           161MB
ubuntu       latest    ...            ...           100MB
alpine       latest    ...           ...             8MB
```

---

## Search for Specific Images

If I want to display only `nginx`, `ubuntu`, and `alpine`:

```bash
docker images | grep -E 'nginx|ubuntu|alpine'
```

### What does `-E` mean?

`-E` enables **Extended Regular Expressions**.

This allows `|` to mean **OR**.

```text
nginx | ubuntu | alpine
   ↓       ↓       ↓
       OR
```

So:

```bash
grep -E 'nginx|ubuntu|alpine'
```

means:

> Find nginx OR ubuntu OR alpine.

---

# 3. Ubuntu vs Alpine

## Why is Alpine much smaller?

Ubuntu and Alpine are both Linux-based images, but they have different goals.

| Feature       | Ubuntu                       | Alpine                     |
| ------------- | ---------------------------- | -------------------------- |
| Base          | Debian-based Linux           | Minimal Linux distribution |
| Size          | Larger                       | Much smaller               |
| Packages      | Large collection             | Minimal                    |
| Default tools | More tools                   | Very few                   |
| Typical use   | General-purpose applications | Lightweight containers     |

Typical sizes can be approximately:

```text
Ubuntu  → ~100 MB
Alpine  → ~8 MB
```

The exact size changes depending on the image version.

### Why is Alpine smaller?

Alpine is designed to be **minimal**.

It includes only the components needed for a small Linux environment instead of providing a large collection of general-purpose packages.

---

# 4. Inspect an Image

Use:

```bash
docker image inspect alpine
```

or:

```bash
docker inspect alpine
```

The more explicit command is:

```bash
docker image inspect alpine
```

It returns detailed JSON information.

### Information available

You can find:

* Image ID
* Repository tags
* Creation time
* Image size
* Operating system
* Architecture
* Environment variables
* Default command
* Entrypoint
* Working directory
* Exposed ports
* Volumes
* Labels
* Filesystem layers

---

## Useful Inspection Commands

### Check OS

```bash
docker image inspect alpine --format '{{.Os}}'
```

Output:

```text
linux
```

### Check architecture

```bash
docker image inspect alpine --format '{{.Architecture}}'
```

Output:

```text
amd64
```

### Check image size

```bash
docker image inspect alpine --format '{{.Size}}'
```

### Check default command

```bash
docker image inspect alpine --format '{{json .Config.Cmd}}'
```

---

# 5. Remove an Image

List images:

```bash
docker images
```

Remove an image:

```bash
docker image rm alpine
```

or:

```bash
docker rmi alpine
```

If a container still uses the image, Docker may refuse to remove it until the container is removed.

---

# Task 2 – Image Layers

# What are Docker Image Layers?

A Docker image is built from multiple **read-only filesystem layers**.

Conceptually:

```text
        Docker Image
┌───────────────────────────┐
│ Latest layer              │
├───────────────────────────┤
│ Application files         │
├───────────────────────────┤
│ Configuration             │
├───────────────────────────┤
│ Installed packages        │
├───────────────────────────┤
│ Base filesystem           │
└───────────────────────────┘
```

Each filesystem-changing instruction can contribute a layer.

---

# 1. View Image History

Run:

```bash
docker image history nginx
```

Example:

```text
IMAGE       CREATED       CREATED BY                         SIZE
...         ...           CMD ["nginx"...]                  0B
<missing>   ...           EXPOSE 80                         0B
<missing>   ...           ENTRYPOINT ...                    0B
<missing>   ...           COPY ...                          4.62kB
<missing>   ...           COPY ...                          3.03kB
<missing>   ...           RUN ...                           82.7MB
<missing>   ...           Debian base                       78.6MB
```

---

# Understanding `docker image history`

The history contains both:

1. Filesystem-changing operations
2. Image configuration/metadata

For example:

```text
COPY    → filesystem change
RUN     → filesystem change
```

while:

```text
ENV
CMD
EXPOSE
ENTRYPOINT
LABEL
STOPSIGNAL
```

are generally configuration/metadata entries and may show:

```text
0B
```

---

# Important: History vs Actual Layers

Do not assume:

> Every line from `docker image history` = one filesystem layer.

`docker image history` shows the **build history**.

The actual filesystem layers can be checked with:

```bash
docker image inspect nginx --format '{{len .RootFS.Layers}}'
```

This gives the number of filesystem layers.

To see the actual layer IDs:

```bash
docker image inspect nginx --format '{{json .RootFS.Layers}}'
```

---

# How to Read Image History

`docker image history nginx` displays history from:

```text
NEWEST
  ↓
OLDEST
```

Therefore, if I want to understand the original build order, I can read the history from **bottom to top**.

Conceptually:

```text
Dockerfile / Build Order

FROM Debian       ← First
     ↓
RUN ...            ← Next
     ↓
COPY ...           ← Next
     ↓
COPY ...           ← Next
     ↓
CMD ...            ← Last
```

But:

```bash
docker image history nginx
```

shows:

```text
CMD ...            ← Newest
COPY ...
COPY ...
RUN ...
FROM Debian        ← Oldest
```

### Remember

> **Dockerfile instructions are processed top-to-bottom, while `docker image history` displays newest-to-oldest.**

---

# Why Does Docker Use Layers?

Docker uses layers for:

### 1. Caching

If a layer has not changed, Docker can reuse it during a build.

```text
Layer 1 → REUSED
Layer 2 → REUSED
Layer 3 → BUILD AGAIN
```

### 2. Storage efficiency

Different images can share the same layers.

```text
           Ubuntu Layer
          /            \
         /              \
    Image A          Image B
```

Docker doesn't need duplicate copies of the shared layer.

### 3. Faster downloads

If a layer already exists locally, Docker can reuse it instead of downloading it again.

---

# Task 3 – Container Lifecycle

We will practice the complete lifecycle using:

```text
Image: alpine
Container: lifecycle-demo
```

Because Alpine exits when its main process finishes, use:

```bash
sleep infinity
```

to keep the container running.

---

# Container Lifecycle

```text
CREATE
   ↓
START
   ↓
PAUSE
   ↓
UNPAUSE
   ↓
STOP
   ↓
RESTART
   ↓
KILL
   ↓
REMOVE
```

---

# 1. Create a Container Without Starting

```bash
docker create --name lifecycle-demo alpine sleep infinity
```

Check:

```bash
docker ps -a
```

Expected state:

```text
Created
```

### Important

`docker create`:

> Creates the container but does not start it.

---

# 2. Start the Container

```bash
docker start lifecycle-demo
```

Check:

```bash
docker ps
```

Expected:

```text
Up ...
```

---

# 3. Pause the Container

```bash
docker pause lifecycle-demo
```

Check:

```bash
docker ps
```

The container should show as paused.

### What does pause do?

It freezes the processes inside the container.

It does not remove the container.

---

# 4. Unpause

```bash
docker unpause lifecycle-demo
```

Check:

```bash
docker ps
```

The container should return to:

```text
Up ...
```

---

# 5. Stop

```bash
docker stop lifecycle-demo
```

Check:

```bash
docker ps -a
```

Expected:

```text
Exited
```

### `docker stop`

Gracefully stops the container.

---

# 6. Restart

```bash
docker restart lifecycle-demo
```

Check:

```bash
docker ps
```

The container should be running again.

Conceptually:

```text
restart = stop + start
```

---

# 7. Kill

```bash
docker kill lifecycle-demo
```

Check:

```bash
docker ps -a
```

The container should be:

```text
Exited
```

### Stop vs Kill

```text
docker stop
    ↓
Graceful shutdown

docker kill
    ↓
Immediate termination
```

---

# 8. Remove

The container must be stopped before removing it.

```bash
docker rm lifecycle-demo
```

Verify:

```bash
docker ps -a
```

The container should no longer exist.

---

# Task 4 – Working with Running Containers

# 1. Run Nginx in Detached Mode

```bash
docker run -d --name nginx-demo nginx
```

Check:

```bash
docker ps
```

### What does `-d` mean?

`-d` means **detached mode**.

Docker runs the container in the background and returns control of the terminal to you.

---

# 2. View Container Logs

```bash
docker logs nginx-demo
```

This displays logs generated by the container's main process.

---

# 3. Follow Logs in Real Time

```bash
docker logs -f nginx-demo
```

`-f` means:

> Follow the logs continuously.

Stop following with:

```text
Ctrl + C
```

This does **not** stop the container.

---

# 4. Enter the Running Container

Check the container:

```bash
docker ps
```

Then:

```bash
docker exec -it nginx-demo sh
```

Now you are inside the container.

Try:

```bash
pwd
ls
ls -la
cat /etc/os-release
```

Exit:

```bash
exit
```

The container continues running.

---

# 5. Run a Single Command Without Entering

If you don't want to open an interactive shell:

```bash
docker exec nginx-demo ls
```

Other examples:

```bash
docker exec nginx-demo pwd
```

```bash
docker exec nginx-demo cat /etc/os-release
```

```bash
docker exec nginx-demo ps
```

### Difference

Interactive shell:

```bash
docker exec -it nginx-demo sh
```

Single command:

```bash
docker exec nginx-demo ls
```

---

# Important Docker Concept

If a container is running in the background, you don't need to enter it to execute commands.

Use:

```bash
docker exec <container> <command>
```

Example:

```bash
docker exec nginx-demo ls -la /etc/nginx
```

---

# 6. Inspect the Container

```bash
docker inspect nginx-demo
```

This provides detailed information about the container.

---

# Find IP Address

Using `grep`:

```bash
docker inspect nginx-demo | grep -iwE "ipaddress"
```

Or a cleaner Docker approach:

```bash
docker inspect nginx-demo --format '{{.NetworkSettings.IPAddress}}'
```

Example:

```text
172.17.0.2
```

---

# Find Mounts

Using `grep`:

```bash
docker inspect nginx-demo | grep -iwE "mounts"
```

Or:

```bash
docker inspect nginx-demo --format '{{json .Mounts}}'
```

If there are no mounts:

```text
[]
```

---

# Find Ports

Using `grep`:

```bash
docker inspect nginx-demo | grep -iwE "ports"
```

To show the port information around the match:

```bash
docker inspect nginx-demo | grep -iwA 5 "ports"
```

### Important `grep` options

```text
-i      Ignore case
-w      Match whole words
-E      Extended regular expressions
-A 5    Show 5 lines after the match
```

For example:

```bash
docker inspect nginx-demo | grep -iwE "ipaddress|mounts|ports"
```

means:

> Find `IPAddress` OR `Mounts` OR `Ports`, ignoring case and matching whole words.

---

# Why `-A 5` Shows Port Details

Without `-A`:

```bash
docker inspect nginx-demo | grep -iwE "ports"
```

you may see only:

```text
"Ports": {
```

With:

```bash
docker inspect nginx-demo | grep -iwA 5 "ports"
```

you can see the following lines too:

```text
"Ports": {
    "80/tcp": null
},
```

The line:

```text
"80/tcp": null
```

was not necessarily matched by `grep`.

It was printed because of:

```text
-A 5
```

---

# What Does `"80/tcp": null` Mean?

If you see:

```json
"Ports": {
    "80/tcp": null
}
```

it means port `80/tcp` exists in the container configuration, but there is **no host port mapping**.

It does NOT mean:

```text
Host 8080 → Container 80
```

A published mapping would look more like:

```text
Host 8080 → Container 80
```

and can be created with:

```bash
docker run -d --name nginx-published -p 8080:80 nginx
```

Check:

```bash
docker port nginx-published
```

---

# Task 5 – Cleanup

## 1. Stop All Running Containers

To stop all currently running containers:

```bash
docker stop $(docker ps -q)
```

### Explanation

```bash
docker ps -q
```

returns only container IDs.

Then:

```bash
docker stop $(...)
```

passes those IDs to `docker stop`.

---

# 2. Remove All Stopped Containers

```bash
docker container prune
```

Docker will ask for confirmation.

Or:

```bash
docker rm $(docker ps -aq --filter status=exited)
```

### Difference

```text
docker container prune
        ↓
Remove unused stopped containers
```

---

# 3. Remove Unused Images

```bash
docker image prune
```

To remove all unused images, including images not referenced by any container:

```bash
docker image prune -a
```

Be careful with:

```bash
docker image prune -a
```

because it can remove images you may want to keep locally.

---

# 4. Check Docker Disk Usage

```bash
docker system df
```

This shows Docker's disk usage.

For example:

```text
TYPE            TOTAL     ACTIVE    SIZE
Images          ...       ...       ...
Containers      ...       ...       ...
Local Volumes   ...       ...       ...
Build Cache     ...       ...       ...
```

For more detailed information:

```bash
docker system df -v
```

---

# Important Commands

## Images

```bash
docker pull nginx
docker pull ubuntu
docker pull alpine
docker images
docker image ls
docker image inspect alpine
docker image history nginx
docker image rm alpine
```

## Layers

```bash
docker image history nginx
docker image history --no-trunc nginx
docker image inspect nginx --format '{{len .RootFS.Layers}}'
docker image inspect nginx --format '{{json .RootFS.Layers}}'
```

## Containers

```bash
docker create
docker start
docker pause
docker unpause
docker stop
docker restart
docker kill
docker rm
```

## Running containers

```bash
docker ps
docker ps -a
docker logs nginx-demo
docker logs -f nginx-demo
docker exec nginx-demo ls
docker exec -it nginx-demo sh
docker inspect nginx-demo
```

## Cleanup

```bash
docker stop $(docker ps -q)
docker container prune
docker image prune
docker image prune -a
docker system df
docker system df -v
```

---

# Useful `grep` Commands Learned

## Search one exact word

```bash
grep -iw "ports"
```

## Search multiple words

```bash
grep -iwE "ipaddress|mounts|ports"
```

## Show lines after a match

```bash
grep -iwA 5 "ports"
```

## Understand the options

```text
-i
↓
Ignore case

-w
↓
Whole word

-E
↓
Extended regular expression

-A 5
↓
5 lines after match
```

---

# Challenges Faced

## Challenge 1 – Image vs Container

Initially, I tried:

```bash
docker exec -it alpine sh
```

and received:

```text
No such container: alpine
```

### Why?

`alpine` was the **image name**, not a container name.

I needed to create a container first:

```bash
docker run -it --name alpine-container alpine sh
```

### Learning

```text
Image
  ↓ docker run
Container
```

An image and a container are different Docker objects.

---

## Challenge 2 – Alpine Container Exited

Running:

```bash
docker run alpine
```

caused the container to exit immediately.

### Why?

A container remains running only while its **main process is running**.

For Alpine, there is no long-running default process.

For testing:

```bash
docker run -d --name alpine-bg alpine sleep infinity
```

---

## Challenge 3 – `grep` Matched `PublishAllPorts`

I initially searched:

```bash
grep -i "ports"
```

and it could match:

```text
PublishAllPorts
```

### Solution

Use whole-word matching:

```bash
grep -iw "ports"
```

`-w` makes `ports` match as a complete word.

---

## Challenge 4 – `|` in grep

I learned that:

```bash
grep -E "ipaddress|mounts|ports"
```

means:

```text
ipaddress OR mounts OR ports
```

But:

```bash
grep -E "ipaddress|"
```

contains an empty alternative and can match every line.

So I should avoid an unnecessary trailing `|`.

---

## Challenge 5 – Understanding `-A`

I used:

```bash
grep -iwEA 5 "ipaddress|mounts|ports"
```

and saw additional lines.

I learned:

```text
-A 5
```

means:

> Print 5 lines **after** the matching line.

Therefore, a line such as:

```text
"80/tcp": null
```

may appear because it is near the matched `"Ports"` line, not because it itself matched `grep`.

---

# What I Learned

* A **Docker image** is a read-only template used to create containers.
* A **container** is a running or stopped instance created from an image.
* Alpine is much smaller than Ubuntu because it is designed as a minimal Linux distribution.
* `docker image inspect` provides detailed image metadata and configuration.
* `docker image history` shows image build history from newest to oldest.
* Docker images use **filesystem layers** for caching, reuse, storage efficiency, and faster transfers.
* Not every `docker image history` entry represents a filesystem layer; entries such as `CMD`, `ENV`, and `EXPOSE` can be metadata and show `0B`.
* `.RootFS.Layers` can be used to determine the actual filesystem layer count.
* A container runs only while its main process is running.
* `docker exec` allows commands to be executed inside a running container.
* `docker logs -f` displays container logs in real time.
* `docker stop` performs a graceful shutdown, while `docker kill` terminates the main process immediately.
* `docker inspect` provides detailed information about containers.
* `grep -w` is useful when I want to search for complete words.
* `grep -E` allows multiple search patterns using `|` as OR.
* Docker's `--format` is often cleaner than parsing JSON output with `grep`.
* `docker system df` helps monitor Docker disk usage.

---

# Key Concept Summary

```text
                 Docker
                   │
          ┌────────┴────────┐
          │                 │
       IMAGE             CONTAINER
          │                 │
    Read-only          Running/Stopped
      layers                │
          │                 │
          └──── docker run ─┘
```

### Image Layers

```text
       Latest Layer
           ↓
     Application
           ↓
       Packages
           ↓
      Base System
           ↓
       Base Image
```

### Container Lifecycle

```text
CREATE
  ↓
START
  ↓
PAUSE
  ↓
UNPAUSE
  ↓
STOP
  ↓
RESTART
  ↓
KILL
  ↓
REMOVE
```

---

# Final Takeaway

> **Docker images are built from reusable read-only filesystem layers. Containers are runtime instances of those images with their own writable layer and lifecycle. Understanding images, layers, inspection, networking, logs, and the container lifecycle is fundamental to working effectively with Docker and DevOps.**

---

## Screenshots to Add

For the final GitHub documentation, add screenshots of:

1. `docker images`
2. `docker image inspect alpine`
3. `docker image history nginx`
4. `docker image inspect nginx --format '{{len .RootFS.Layers}}'`
5. `docker ps -a` during the lifecycle
6. `docker logs nginx-demo`
7. `docker logs -f nginx-demo`
8. `docker exec -it nginx-demo sh`
9. `docker inspect nginx-demo`
10. `docker system df`

Example Markdown syntax for an image:

```markdown
![Docker Image History](images/docker-image-history.png)
```

Keep screenshots in an `images/` directory inside your GitHub repository.
