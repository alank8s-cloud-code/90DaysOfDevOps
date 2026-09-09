# Day 53 – Kubernetes Services

## What Are Kubernetes Services?

A Kubernetes **Service** provides a stable way to communicate with Pods.

Pods have their own IP addresses, but Pod IPs are **not permanent**. When a Pod restarts or is replaced, it can receive a new IP address. Also, a Deployment can run multiple Pods, so connecting directly to individual Pod IPs is not practical.

A Service solves these problems by providing:

* **Stable IP address**
* **Stable DNS name**
* **Traffic distribution across matching Pods**
* A single network endpoint for multiple Pods

### Simple Flow

```text
Client
   |
   v
Service
Stable IP + DNS
   |
   +--------> Pod 1
   |
   +--------> Pod 2
   |
   +--------> Pod 3
```

### Most Important Point ⭐

> **Deployment manages Pods, while Service provides stable network access to those Pods.**

---

# Task 1: Deploy the Application

First, create a Deployment with **3 Nginx Pods**.

## `app-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: web-app
  labels:
    app: web-app

spec:
  replicas: 3

  selector:
    matchLabels:
      app: web-app

  template:
    metadata:
      labels:
        app: web-app

    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

### Important Fields

### `replicas: 3`

```yaml
replicas: 3
```

This tells Kubernetes to maintain **3 Pods**.

```text
Deployment
   |
   +---- Pod 1
   +---- Pod 2
   +---- Pod 3
```

### `labels`

```yaml
labels:
  app: web-app
```

The Pods receive the label:

```text
app=web-app
```

This label will later be used by the Service to find these Pods.

### `containerPort: 80`

Nginx listens on port `80`.

## Apply the Deployment

```bash
kubectl apply -f app-deployment.yaml
```

Check the Pods:

```bash
kubectl get pods -o wide
```

You should see three Pods with their own IP addresses.

Example:

```text
NAME                       IP
web-app-xxxxx-aaaaa        10.244.0.5
web-app-xxxxx-bbbbb        10.244.0.6
web-app-xxxxx-ccccc        10.244.0.7
```

### Important Point ⭐

These Pod IPs can change when Pods restart or are replaced.

That is the problem that **Services solve**.

---

# Task 2: ClusterIP Service – Internal Access

**ClusterIP** is the default Kubernetes Service type.

It provides a stable IP that can be reached from **inside the cluster**.

## `clusterip-service.yaml`

```yaml
apiVersion: v1
kind: Service

metadata:
  name: web-app-clusterip

spec:
  type: ClusterIP

  selector:
    app: web-app

  ports:
  - port: 80
    targetPort: 80
```

## Important Fields

### `type: ClusterIP`

```yaml
type: ClusterIP
```

The Service gets a stable internal IP.

It is intended for communication inside the Kubernetes cluster.

### `selector`

```yaml
selector:
  app: web-app
```

This is extremely important.

The Service searches for Pods with:

```yaml
labels:
  app: web-app
```

So:

```text
Service
   |
   | selector: app=web-app
   |
   +----> Pod 1
   +----> Pod 2
   +----> Pod 3
```

### `port`

```yaml
port: 80
```

This is the port on which the **Service listens**.

### `targetPort`

```yaml
targetPort: 80
```

This is the port on the **Pod/application** where traffic is forwarded.

```text
Client
   |
   | Service port 80
   v
Service
   |
   | targetPort 80
   v
Pod
```

### Most Important Point ⭐⭐⭐

> **`port` = Service port**
> **`targetPort` = Pod port**

They do not have to be the same number.

For example:

```yaml
port: 80
targetPort: 8080
```

means:

```text
Client
   |
   | :80
   v
Service
   |
   | :8080
   v
Pod
```

## Apply the Service

```bash
kubectl apply -f clusterip-service.yaml
```

Check:

```bash
kubectl get services
```

Example:

```text
NAME                 TYPE        CLUSTER-IP       PORT(S)
web-app-clusterip    ClusterIP   10.96.205.115    80/TCP
```

The ClusterIP remains stable even when the Pods change.

## Test the Service

Create a temporary Pod:

```bash
kubectl run test-client \
  --image=busybox:latest \
  --rm -it \
  --restart=Never \
  -- sh
```

Inside the Pod:

```bash
wget -qO- http://web-app-clusterip
```

You should receive the Nginx welcome page.

Exit:

```bash
exit
```

### What Happened?

```text
test-client Pod
      |
      | http://web-app-clusterip
      v
ClusterIP Service
      |
      +------> Pod 1
      |
      +------> Pod 2
      |
      +------> Pod 3
```

The Service distributes traffic to the matching Pods.

---

# Task 3: Discover Services with DNS

Kubernetes has a built-in DNS system.

Every Service automatically gets a DNS name.

## DNS Format

```text
<service-name>.<namespace>.svc.cluster.local
```

For this Service:

```text
web-app-clusterip.default.svc.cluster.local
```

### DNS Parts

```text
web-app-clusterip
       |
       +--> Service name

default
       |
       +--> Namespace

svc
       |
       +--> Service

cluster.local
       |
       +--> Cluster DNS domain
```

## Test DNS

Create a temporary Pod:

```bash
kubectl run dns-test \
  --image=busybox:latest \
  --rm -it \
  --restart=Never \
  -- sh
```

### Short Name

Inside the same namespace:

```bash
wget -qO- http://web-app-clusterip
```

### Full DNS Name

```bash
wget -qO- http://web-app-clusterip.default.svc.cluster.local
```

### Check DNS

```bash
nslookup web-app-clusterip
```

The DNS lookup should return the Service's **ClusterIP**.

For example:

```text
Name: web-app-clusterip.default.svc.cluster.local
Address: 10.96.205.115
```

### Important Point ⭐⭐⭐

DNS resolves the Service name to the **Service ClusterIP**, not directly to a Pod.

```text
Service DNS name
       |
       v
ClusterIP
       |
       v
Service
       |
       +----> Pod 1
       +----> Pod 2
       +----> Pod 3
```

This means applications can communicate using a stable name instead of tracking changing Pod IPs.

Exit:

```bash
exit
```

---

# Task 4: NodePort Service – External Access

A **NodePort** Service exposes the application through a port on every Kubernetes Node.

## `nodeport-service.yaml`

```yaml
apiVersion: v1
kind: Service

metadata:
  name: web-app-nodeport

spec:
  type: NodePort

  selector:
    app: web-app

  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

## Important Fields

### `type: NodePort`

```yaml
type: NodePort
```

This allows access from outside the cluster through a Node.

### `nodePort`

```yaml
nodePort: 30080
```

This is the port opened on the Kubernetes Nodes.

The allowed NodePort range is:

```text
30000 - 32767
```

## Traffic Flow

```text
External Client
      |
      | NodeIP:30080
      v
Kubernetes Node
      |
      v
NodePort Service
      |
      | targetPort: 80
      v
Nginx Pod:80
```

## Apply

```bash
kubectl apply -f nodeport-service.yaml
```

Check:

```bash
kubectl get services
```

You may see:

```text
NAME               TYPE       CLUSTER-IP      PORT(S)
web-app-nodeport   NodePort   10.96.x.x       80:30080/TCP
```

This means:

```text
80     = Service port
30080  = NodePort
```

## Kind

For Kind, check the Node information:

```bash
kubectl get nodes -o wide
```

Then the task can be tested using:

```text
<NodeIP>:30080
```

Depending on your Kind configuration, host port mapping may also be required.

### Important Point ⭐

> **NodePort allows external access through `<NodeIP>:<NodePort>`.**

---

# Task 5: LoadBalancer Service

A **LoadBalancer** Service is commonly used for external access in cloud Kubernetes environments.

For example:

```text
AWS
GCP
Azure
```

## `loadbalancer-service.yaml`

```yaml
apiVersion: v1
kind: Service

metadata:
  name: web-app-loadbalancer

spec:
  type: LoadBalancer

  selector:
    app: web-app

  ports:
  - port: 80
    targetPort: 80
```

## Apply

```bash
kubectl apply -f loadbalancer-service.yaml
```

Check:

```bash
kubectl get services
```

In a cloud environment, Kubernetes can request an external load balancer.

The traffic flow is:

```text
Internet
   |
   v
Cloud Load Balancer
   |
   v
Kubernetes Nodes
   |
   v
Service
   |
   v
Pods
```

## Why Does Kind Show `<pending>`?

On a local Kind cluster, you may see:

```text
EXTERNAL-IP
<pending>
```

This is expected because Kind does not automatically have a cloud provider creating a real external load balancer.

So:

```text
Kind
 |
 X
No Cloud Load Balancer
 |
 v
EXTERNAL-IP = <pending>
```

### Important Point ⭐⭐⭐

> **`<pending>` on a local cluster does not automatically mean the Service is broken. It means no external LoadBalancer has been provisioned.**

In a real cloud cluster, the external IP or hostname would normally be provided by the cloud provider.

---

# Task 6: Understand Service Types Side by Side

Check all Services:

```bash
kubectl get services -o wide
```

## Service Comparison

| Service Type     | Accessible From                     | Main Use                          |
| ---------------- | ----------------------------------- | --------------------------------- |
| **ClusterIP**    | Inside the cluster                  | Internal communication            |
| **NodePort**     | Outside through Node IP + NodePort  | Development and testing           |
| **LoadBalancer** | Outside through cloud load balancer | Cloud/production external traffic |

## ClusterIP

```text
Inside Cluster
      |
      v
ClusterIP
      |
      v
Pods
```

Use it for communication between applications inside Kubernetes.

Example:

```text
Frontend → Backend Service
Backend → Database Service
```

## NodePort

```text
Outside
   |
   v
NodeIP:30080
   |
   v
Service
   |
   v
Pods
```

Useful for development/testing and direct Node access.

## LoadBalancer

```text
Internet
   |
   v
Cloud Load Balancer
   |
   v
Kubernetes
   |
   v
Pods
```

Useful for external traffic in cloud environments.

## Most Important Relationship ⭐⭐⭐

The Service types can be understood as layers:

```text
LoadBalancer
      |
      v
   NodePort
      |
      v
   ClusterIP
      |
      v
     Pods
```

A normal LoadBalancer Service also gets a ClusterIP and, by default, a NodePort.

You can verify it with:

```bash
kubectl describe service web-app-loadbalancer
```

You should be able to see the Service configuration, including its ClusterIP and NodePort.

### Most Important Point ⭐⭐⭐

> **ClusterIP = internal access**
> **NodePort = external access through a Node**
> **LoadBalancer = external access through a cloud load balancer**

---

# Task 7: Clean Up

After completing the practice, remove all resources.

## Delete Deployment

```bash
kubectl delete -f app-deployment.yaml
```

## Delete ClusterIP Service

```bash
kubectl delete -f clusterip-service.yaml
```

## Delete NodePort Service

```bash
kubectl delete -f nodeport-service.yaml
```

## Delete LoadBalancer Service

```bash
kubectl delete -f loadbalancer-service.yaml
```

## Verify

```bash
kubectl get pods
```

```bash
kubectl get services
```

The built-in Kubernetes Service should remain.

```text
kubernetes
```

### Important Point ⭐

Always clean up resources after practice when they are no longer required.

---

# Challenges I Faced

## 1. Understanding Why Services Are Needed ⭐⭐⭐

The biggest concept was understanding why we shouldn't directly use Pod IPs.

```text
Pod IP
  |
  | Pod restarts
  v
New Pod IP
```

This makes direct Pod communication unreliable.

The Service gives us:

```text
Stable IP
   +
Stable DNS
   +
Traffic distribution
```

---

## 2. Understanding Service Selectors ⭐⭐⭐

I learned that the Service needs to know **which Pods it should send traffic to**.

The Service:

```yaml
selector:
  app: web-app
```

must match the Pod:

```yaml
labels:
  app: web-app
```

If they don't match:

```text
Service
   |
   X
No matching Pods
```

The Service exists, but it has no Pods to route traffic to.

---

## 3. Understanding `port` and `targetPort` ⭐⭐⭐

This was an important distinction:

```text
port
  ↓
Service

targetPort
  ↓
Pod
```

Example:

```yaml
port: 80
targetPort: 8080
```

means:

```text
Client
  |
  | :80
  v
Service
  |
  | :8080
  v
Pod
```

---

## 4. Understanding Kubernetes DNS ⭐⭐⭐

I learned that Kubernetes automatically creates DNS records for Services.

```text
web-app-clusterip
        |
        v
Kubernetes DNS
        |
        v
ClusterIP
        |
        v
Service
        |
        v
Pods
```

The full DNS format is:

```text
<service-name>.<namespace>.svc.cluster.local
```

---

## 5. Understanding `EXTERNAL-IP: <pending>` ⭐⭐⭐

On a local Kind cluster:

```text
EXTERNAL-IP = <pending>
```

does not necessarily mean something is wrong.

It happens because a local cluster does not automatically have a cloud provider creating a real external load balancer.

---

# What I Learned

## Most Important Learning Points ⭐⭐⭐

### 1. Service solves the Pod IP problem

```text
Pod IPs can change
        ↓
Service provides stable endpoint
```

### 2. Deployment and Service have different jobs

```text
Deployment
    ↓
Creates and manages Pods

Service
    ↓
Provides network access to Pods
```

### 3. Selector connects Service to Pods

```text
Service selector
       ↓
app=web-app
       ↓
Pods with app=web-app
```

### 4. `port` and `targetPort` are different

```text
port       → Service
targetPort → Pod
```

### 5. ClusterIP is internal

```text
ClusterIP
   ↓
Inside cluster
```

### 6. NodePort provides Node-based external access

```text
NodeIP:NodePort
       ↓
Service
       ↓
Pods
```

### 7. LoadBalancer provides cloud-based external access

```text
Internet
   ↓
Cloud Load Balancer
   ↓
Service
   ↓
Pods
```

### 8. Kubernetes provides Service DNS

```text
Service Name
     ↓
DNS
     ↓
ClusterIP
```

### 9. LoadBalancer normally builds on Service networking

```text
LoadBalancer
     ↓
NodePort
     ↓
ClusterIP
     ↓
Pods
```

### 10. Endpoints show where the Service sends traffic

Useful command:

```bash
kubectl get endpoints <service-name>
```

This helps verify which Pod IPs the Service is currently routing traffic to.

---
