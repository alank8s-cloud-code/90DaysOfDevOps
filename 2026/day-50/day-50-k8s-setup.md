# Day 50 – Kubernetes Architecture and Cluster Setup

## Introduction — What is Kubernetes?

**Kubernetes (K8s)** is an open-source platform used to **deploy, manage, scale, and maintain containerized applications**.

Docker is excellent for building and running containers, but when an application grows and you have many containers running across multiple servers, managing everything manually becomes difficult.

Kubernetes helps solve this problem by automatically managing containers and their desired state across a cluster of machines.

According to the official Kubernetes documentation, a Kubernetes cluster consists of a **control plane** and one or more **worker nodes**. The control plane manages the cluster, while worker nodes run application workloads.

---

# Why Do We Use Kubernetes?

Imagine running an application with only Docker:

```text
Server 1
├── frontend container
├── backend container
└── database container

Server 2
├── frontend container
├── backend container
└── database container

Server 3
├── backend container
├── worker container
└── cache container
```

As the number of containers increases, several problems appear:

* What happens when a container crashes?
* Which server should run a new container?
* How do we scale from 2 containers to 10?
* How do containers communicate with each other?
* How do we distribute traffic?
* How do we update an application without causing downtime?
* How do we replace failed containers?
* How do we manage hundreds of containers across many machines?

Kubernetes provides mechanisms for these problems.

### Docker vs Kubernetes

```text
Docker
   │
   ├── Build images
   ├── Run containers
   └── Manage individual containers
          │
          ↓
      Works well
      for smaller environments


Kubernetes
   │
   ├── Schedule Pods
   ├── Scale applications
   ├── Restart failed workloads
   ├── Manage multiple nodes
   ├── Provide service discovery
   ├── Perform rolling updates
   └── Maintain desired state
```

### Simple definition

> **Docker runs containers. Kubernetes manages containers at cluster scale.**

Kubernetes continuously works toward the desired state declared by the user rather than simply executing a fixed sequence of commands.

---

# Kubernetes History

Kubernetes was developed at **Google** and was open-sourced in **2014**. It was heavily influenced by Google's experience running large-scale production workloads and ideas from Google's internal systems, especially Borg.

The name **Kubernetes** comes from Greek and means **"helmsman" or "pilot"**, referring to someone who steers a ship.

The abbreviation **K8s** comes from:

```text
K + 8 letters + s

K u b e r n e t e s
^                 ^
K                 s

8 letters between K and s
```

Therefore:

```text
Kubernetes → K8s
```

The official documentation confirms the Greek origin of the name, the K8s abbreviation, and Google's open-sourcing of Kubernetes in 2014.

---

# Task 1 – The Kubernetes Story

## Why was Kubernetes created?

Docker made containers much easier to build and run, but managing a large number of containers across multiple machines introduced a new problem.

Kubernetes was created to provide a system that could manage containerized workloads at scale.

Instead of manually starting, stopping, replacing, and moving containers, Kubernetes uses a **desired state** model.

For example:

```yaml
replicas: 3
```

This means:

> "I want 3 replicas of my application."

If only 2 are running:

```text
Desired: 3
Current: 2

Kubernetes
    ↓
Creates another Pod
    ↓
Current: 3
```

If one Pod crashes:

```text
Desired: 3
Current: 2

Kubernetes
    ↓
Creates replacement Pod
    ↓
Current: 3
```

This continuous reconciliation is one of the most important ideas behind Kubernetes.

---

# Task 2 – Kubernetes Architecture

A Kubernetes cluster has two major parts:

```text
                    Kubernetes Cluster
                           │
              ┌────────────┴────────────┐
              │                         │
        Control Plane              Worker Nodes
              │                         │
       Manages cluster             Runs workloads
```

---

# Control Plane

The **Control Plane** manages the overall state of the Kubernetes cluster.

Main components:

```text
Control Plane
│
├── kube-apiserver
├── etcd
├── kube-scheduler
└── kube-controller-manager
```

The official Kubernetes documentation identifies these as the core control-plane components.

---

## 1. kube-apiserver

The **API Server** is the main entry point into Kubernetes.

When we run:

```bash
kubectl get pods
```

or:

```bash
kubectl apply -f pod.yaml
```

`kubectl` communicates with the Kubernetes API through the API Server.

Think of it as:

```text
User
  │
  │ kubectl
  ↓
kube-apiserver
```

It is the central communication point between users and the Kubernetes cluster.

---

## 2. etcd

`etcd` is the database used by Kubernetes to store cluster state.

It stores information about Kubernetes objects and configuration.

Conceptually:

```text
Kubernetes state
      ↓
    etcd
      ↓
Cluster data
```

For example, Kubernetes needs to know things such as:

```text
Which Pods exist?
Which Nodes exist?
What Deployments exist?
What configuration has been requested?
```

The API Server communicates with etcd to persist Kubernetes API data.

---

## 3. kube-scheduler

The **Scheduler** decides which node should run a newly created Pod.

For example:

```text
New Pod
   │
   ↓
kube-scheduler
   │
   ├── Worker 1
   ├── Worker 2
   └── Worker 3
          │
          ↓
     Selects a node
```

The scheduler looks for Pods that have not yet been assigned to a node and assigns them to a suitable node.

---

## 4. kube-controller-manager

Controllers continuously monitor the cluster and try to make the actual state match the desired state.

Example:

```text
Desired:
3 Pods

Current:
2 Pods

Controller
   ↓
Creates another Pod

Current:
3 Pods
```

Controllers interact with the Kubernetes API Server rather than directly running containers themselves.

---

# Worker Node

Worker nodes are machines where application Pods run.

A node normally contains:

```text
Worker Node
│
├── kubelet
├── kube-proxy
├── Container Runtime
└── Pods
```

The official documentation identifies kubelet, a container runtime, and kube-proxy as node components, with kube-proxy being optional depending on the networking implementation.

---

## 1. kubelet

`kubelet` is the agent running on each node.

Its job is to make sure the containers described in Pod specifications are running and healthy.

Simple flow:

```text
API Server
    │
    ↓
 kubelet
    │
    ↓
Container Runtime
    │
    ↓
Container
```

The kubelet does not itself run the container; it works with the container runtime.

---

## 2. kube-proxy

`kube-proxy` helps implement Kubernetes Services by maintaining networking rules on nodes.

Simple idea:

```text
Client
  │
  ↓
Service
  │
  ↓
kube-proxy / networking rules
  │
  ├── Pod 1
  ├── Pod 2
  └── Pod 3
```

This allows traffic to be directed toward the appropriate Pods.

Note: modern Kubernetes networking implementations can provide Service proxying without kube-proxy, so kube-proxy is considered optional in the official documentation.

---

## 3. Container Runtime

The container runtime is responsible for actually running containers.

Examples include:

```text
containerd
CRI-O
```

Kubernetes communicates with container runtimes through the **Container Runtime Interface (CRI)**.

In my KIND cluster, the node uses:

```text
containerd
```

---

# Kubernetes Architecture Diagram

My simplified architecture:

```text
                         Kubernetes Cluster
                                │
                ┌───────────────┴───────────────┐
                │                               │
          CONTROL PLANE                     WORKER NODE
                │                               │
        ┌───────┼────────┐              ┌───────┼────────┐
        │       │        │              │       │        │
        ↓       ↓        ↓              ↓       ↓        ↓
   API Server  etcd  Scheduler       kubelet kube-proxy Runtime
        │                │               │                 │
        │                │               │                 ↓
        │                │               │               Containers
        │                │               │
        └───────────────┬┴───────────────┘
                        │
                        ↓
                       Pods
```

A more practical view:

```text
                         kubectl
                            │
                            ↓
                     kube-apiserver
                            │
              ┌─────────────┼─────────────┐
              ↓             ↓             ↓
            etcd       scheduler    controller-manager
                                          │
                                          ↓
                                    Desired State
                                          │
                                          ↓
                              ┌───────────┴───────────┐
                              │                       │
                         Worker Node             Worker Node
                              │                       │
                         ┌────┼────┐             ┌────┼────┐
                         │    │    │             │    │    │
                      kubelet proxy runtime    kubelet proxy runtime
                                          
                              │                       │
                              ↓                       ↓
                            Pods                    Pods
```

---

# What Happens When I Run `kubectl apply -f pod.yaml`?

This is an important Kubernetes flow to understand.

Suppose I run:

```bash
kubectl apply -f pod.yaml
```

The process is approximately:

```text
1. kubectl
     │
     ↓
2. kube-apiserver
     │
     ↓
3. etcd
     │
     ↓
4. kube-scheduler
     │
     ↓
5. API Server
     │
     ↓
6. kubelet on selected node
     │
     ↓
7. Container Runtime
     │
     ↓
8. Container
     │
     ↓
9. Pod Running
```

### Step-by-step

### Step 1 — kubectl

I execute:

```bash
kubectl apply -f pod.yaml
```

`kubectl` sends the request to the Kubernetes API Server.

### Step 2 — API Server

The API Server receives and validates the request.

### Step 3 — etcd

The desired state is persisted in the cluster's data store.

### Step 4 — Scheduler

If the Pod has not been assigned to a node, the scheduler selects a suitable node.

### Step 5 — kubelet

The kubelet on the selected node notices that it needs to run the Pod.

### Step 6 — Container Runtime

The kubelet asks the container runtime to create and run the containers.

### Step 7 — Pod runs

The container starts and the Pod becomes:

```text
Running
```

---

# What Happens If the API Server Goes Down?

If the API Server becomes unavailable:

```text
kubectl
   │
   X
   │
API Server DOWN
```

I cannot normally use `kubectl` to interact with the cluster.

Operations such as:

```bash
kubectl get pods
kubectl apply
kubectl delete
```

will fail because they need the API Server.

However, existing workloads on worker nodes do **not necessarily stop immediately** just because the API Server is unavailable.

The kubelet and container runtime on a worker can continue running existing workloads.

This is why my earlier KIND experiment was useful:

```text
Control Plane
API Server
   ↓
STOPPED

Worker
   ↓
Existing containers
   ↓
Can continue running
```

---

# What Happens If a Worker Node Goes Down?

Suppose:

```text
Worker Node
     ↓
   DOWN
```

Pods running on that node become unavailable.

If those Pods are managed by controllers such as a Deployment and healthy nodes are available, Kubernetes can create replacement Pods on other suitable nodes.

```text
Worker 1
   ↓
  DOWN
   ↓
Pod unavailable

        Kubernetes
            ↓
      detects problem
            ↓
   creates replacement
            ↓
       Worker 2
            ↓
        New Pod
```

Kubernetes nodes send heartbeats/status information to the control plane, which helps Kubernetes detect node failures.

---

# Task 3 – Install kubectl

`kubectl` is the primary command-line tool used to communicate with the Kubernetes cluster through the Kubernetes API.

For Linux:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl

sudo mv kubectl /usr/local/bin/
```

Verify:

```bash
kubectl version --client
```

Example:

```text
Client Version: ...
```

---

# Task 4 – Local Kubernetes Cluster

## Tool Chosen: KIND

I chose **KIND (Kubernetes IN Docker)**.

KIND allows Kubernetes clusters to run using Docker containers.

My local environment contains:

```text
KIND Cluster
│
├── alank8s-cloud-control-plane
│
└── alank8s-cloud-worker
```

I chose KIND because I am already comfortable with Docker and wanted to understand how Kubernetes nodes work while running a lightweight local cluster.

---

# KIND Cluster Setup

Create the cluster:

```bash
kind create cluster --name alank8s-cloud
```

Check cluster information:

```bash
kubectl cluster-info
```

Check nodes:

```bash
kubectl get nodes
```

My cluster:

```text
NAME                          STATUS   ROLES           AGE
alank8s-cloud-control-plane   Ready    control-plane   ...
alank8s-cloud-worker          Ready    <none>          ...
```

---

# Task 5 – Explore the Cluster

## 1. Cluster Information

```bash
kubectl cluster-info
```

This verifies that `kubectl` can communicate with the Kubernetes API Server.

---

## 2. List Nodes

```bash
kubectl get nodes
```

For more information:

```bash
kubectl get nodes -o wide
```

My cluster contains:

```text
Control Plane:
alank8s-cloud-control-plane

Worker:
alank8s-cloud-worker
```

---

## 3. Describe a Node

```bash
kubectl describe node alank8s-cloud-control-plane
```

This provides detailed information about:

* Node name
* Node role
* CPU
* Memory
* Conditions
* Taints
* Pod CIDR
* Container runtime
* Kubernetes version
* Pods running on the node
* Events

Important conditions include:

```text
MemoryPressure
DiskPressure
PIDPressure
Ready
```

For example:

```text
Ready:
True
```

means the node is currently considered ready to run workloads.

---

# 4. List Namespaces

```bash
kubectl get namespaces
```

Namespaces provide a way to divide and organize resources inside a cluster.

Example:

```text
default
kube-system
kube-public
kube-node-lease
```

My application also uses:

```text
flask-app
```

---

# 5. List All Pods

```bash
kubectl get pods -A
```

The `-A` means:

```text
--all-namespaces
```

Therefore:

```bash
kubectl get pods -A
```

is equivalent to:

```bash
kubectl get pods --all-namespaces
```

To see which node each Pod is running on:

```bash
kubectl get pods -A -o wide
```

The `NODE` column shows the node hosting each Pod.

---

# My Cluster Pod Placement

I used:

```bash
kubectl get pods -A -o wide
```

and observed:

```text
NAMESPACE            NAME                                      NODE
kube-system          coredns-...                               alank8s-cloud-control-plane
kube-system          etcd-...                                  alank8s-cloud-control-plane
kube-system          kube-apiserver-...                        alank8s-cloud-control-plane
kube-system          kube-controller-manager-...               alank8s-cloud-control-plane
kube-system          kube-scheduler-...                        alank8s-cloud-control-plane
kube-system          kindnet-...                               alank8s-cloud-control-plane
kube-system          kindnet-...                               alank8s-cloud-worker
kube-system          kube-proxy-...                            alank8s-cloud-control-plane
kube-system          kube-proxy-...                            alank8s-cloud-worker
```

This helped me understand the relationship between:

```text
Pod → Node
```

---

# kube-system Namespace

I checked the system Pods using:

```bash
kubectl get pods -n kube-system
```

These Pods represent important Kubernetes infrastructure.

## etcd

```text
etcd-alank8s-cloud-control-plane
```

Purpose:

```text
Stores Kubernetes cluster state
```

---

## kube-apiserver

```text
kube-apiserver-alank8s-cloud-control-plane
```

Purpose:

```text
Main Kubernetes API
```

`kubectl` communicates with the cluster through the API Server.

---

## kube-controller-manager

```text
kube-controller-manager-alank8s-cloud-control-plane
```

Purpose:

```text
Runs controllers that continuously work toward the desired state.
```

---

## kube-scheduler

```text
kube-scheduler-alank8s-cloud-control-plane
```

Purpose:

```text
Selects suitable nodes for unscheduled Pods.
```

---

## kube-proxy

Example:

```text
kube-proxy-9b2wd
kube-proxy-fwp9v
```

There is one on each of my nodes.

Purpose:

```text
Maintains networking rules used by Kubernetes Services.
```

---

## kindnet

Example:

```text
kindnet-mg6cb
kindnet-5q9qr
```

These are part of the networking setup provided by KIND.

They help provide networking for Pods.

---

## CoreDNS

Example:

```text
coredns-7d764666f9-k4dmb
coredns-7d764666f9-nn8qc
```

CoreDNS provides DNS-based service discovery inside the Kubernetes cluster.

For example, applications can use Kubernetes Service names instead of manually knowing Pod IP addresses.

---

# Task 6 – Kubernetes Cluster Lifecycle

## Delete the Cluster

```bash
kind delete cluster --name alank8s-cloud
```

This removes the local KIND cluster.

---

## Recreate the Cluster

```bash
kind create cluster --name alank8s-cloud
```

Verify:

```bash
kubectl get nodes
```

Expected:

```text
NAME                          STATUS   ROLES           AGE
alank8s-cloud-control-plane   Ready    control-plane   ...
alank8s-cloud-worker          Ready    <none>          ...
```

---

# Kubernetes Contexts

## Check Current Context

```bash
kubectl config current-context
```

Example:

```text
kind-alank8s-cloud
```

This tells me which Kubernetes context `kubectl` is currently using.

---

## List All Contexts

```bash
kubectl config get-contexts
```

A context connects information such as:

```text
Context
├── Cluster
├── User
└── Namespace
```

The `*` indicates the current context.

Example:

```text
CURRENT   NAME                 CLUSTER              AUTHINFO
*         kind-alank8s-cloud   kind-alank8s-cloud   kind-alank8s-cloud
```

---

# What is kubeconfig?

A **kubeconfig** is a configuration file that tells `kubectl` how to connect to Kubernetes clusters.

It contains information about:

```text
kubeconfig
│
├── Clusters
│     └── API Server information
│
├── Users
│     └── Authentication information
│
└── Contexts
      └── Which cluster/user to use
```

By default, `kubectl` looks for:

```text
~/.kube/config
```

On my Linux machine this is:

```text
/home/alan/.kube/config
```

The official documentation confirms that the default kubeconfig location is `~/.kube/config`.

Useful commands:

```bash
kubectl config current-context
```

```bash
kubectl config get-contexts
```

```bash
kubectl config view
```

---

# Important Kubernetes Commands Learned

| Command                           | Purpose                           |
| --------------------------------- | --------------------------------- |
| `kubectl cluster-info`            | Show cluster information          |
| `kubectl get nodes`               | List nodes                        |
| `kubectl get nodes -o wide`       | List nodes with extra information |
| `kubectl describe node <node>`    | Detailed node information         |
| `kubectl get namespaces`          | List namespaces                   |
| `kubectl get pods -A`             | List Pods across all namespaces   |
| `kubectl get pods -A -o wide`     | List Pods with node information   |
| `kubectl get pods -n kube-system` | List system Pods                  |
| `kubectl config current-context`  | Show current context              |
| `kubectl config get-contexts`     | List contexts                     |
| `kubectl config view`             | Display kubeconfig                |
| `kind get clusters`               | List KIND clusters                |
| `kind delete cluster`             | Delete a KIND cluster             |
| `kind create cluster`             | Create a KIND cluster             |

---

# Screenshots

## 1. Kubernetes Nodes

Add the screenshot of:

```bash
kubectl get nodes
```

Expected result:

```text
NAME                          STATUS   ROLES           AGE   VERSION
alank8s-cloud-control-plane   Ready    control-plane   ...   ...
alank8s-cloud-worker          Ready    <none>          ...   ...
```

**Screenshot:**

```text
[Insert screenshot of kubectl get nodes here]
```

---

## 2. kube-system Pods

Command:

```bash
kubectl get pods -n kube-system
```

**Screenshot:**

```text
[Insert screenshot of kubectl get pods -n kube-system here]
```

---

# What I Learned Today

### 1. Kubernetes

Kubernetes manages containerized applications across a cluster.

### 2. Control Plane

The control plane manages the cluster.

```text
API Server
etcd
Scheduler
Controller Manager
```

### 3. Worker Node

Worker nodes run application workloads.

```text
kubelet
kube-proxy
Container Runtime
Pods
```

### 4. Pod

A Pod is the smallest deployable unit in Kubernetes.

### 5. Scheduler

The scheduler decides which node should run a new Pod.

### 6. kubelet

The kubelet makes sure the required containers are running on its node.

### 7. Container Runtime

The container runtime actually runs the containers.

### 8. kubeconfig

`kubectl` uses kubeconfig to know which cluster and credentials to use.

Default location:

```text
~/.kube/config
```

### 9. Desired State

One of the most important Kubernetes concepts:

```text
Desired State
      ↓
Kubernetes Controllers
      ↓
Actual State
      ↓
Reconciliation
```

Kubernetes continuously tries to make the actual cluster state match the desired state.

---

# Final Architecture Summary

```text
                         USER
                          │
                          │ kubectl
                          ↓
                  ┌─────────────────┐
                  │  API SERVER     │
                  └────────┬────────┘
                           │
             ┌─────────────┼──────────────┐
             ↓             ↓              ↓
           etcd       Scheduler     Controller Manager
                                         │
                                         │
                                         ↓
                              Desired State Management
                                         │
                         ┌───────────────┴───────────────┐
                         │                               │
                         ↓                               ↓
                  WORKER NODE                     WORKER NODE
                         │                               │
              ┌──────────┼──────────┐         ┌──────────┼──────────┐
              ↓          ↓          ↓         ↓          ↓          ↓
           kubelet   kube-proxy  Runtime   kubelet   kube-proxy  Runtime
                         │                               │
                         ↓                               ↓
                       Pods                            Pods
```

# Conclusion

Today I started my Kubernetes journey by understanding why Kubernetes is needed, how its architecture works, and how the Control Plane communicates with Worker Nodes.

I created a local Kubernetes cluster using KIND and practiced basic `kubectl` commands to inspect nodes, namespaces, Pods, and system components.

The most important concept I learned is that Kubernetes is based on **desired state and continuous reconciliation**. Instead of manually managing every container, I tell Kubernetes what I want, and Kubernetes works continuously to make the cluster match that desired state.

