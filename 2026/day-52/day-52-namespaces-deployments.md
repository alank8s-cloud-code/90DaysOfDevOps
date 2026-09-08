# Day 52 – Kubernetes Deployments and Rolling Updates

## What This Day Is About

### What

This day focuses on **Kubernetes Deployments** and how they manage Pods.

A Deployment is a Kubernetes object that manages the desired state of an application. It makes sure the required number of Pods are running and helps manage application updates.

In this task, we created an Nginx Deployment, generated its YAML manifest, understood Deployment status, performed a Rolling Update, and checked the Deployment revision history.

### Why

Managing Pods manually becomes difficult when an application needs multiple replicas, updates, or automatic replacement of failed Pods.

A Deployment helps Kubernetes:

* Maintain the desired number of Pods
* Manage ReplicaSets
* Replace failed Pods
* Perform Rolling Updates
* Keep track of Deployment revisions
* Roll back to an earlier version when required

### How

The overall flow learned today was:

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
    ↓
Containers
```

For updates:

```text
Old Deployment Version
        ↓
Rolling Update
        ↓
New Deployment Version
        ↓
New Pods
```

---

# Task 1 – Create a Deployment

## What

A **Deployment** manages a set of Pods and keeps the application running according to the desired configuration.

For example, if we want three Nginx Pods, the Deployment makes sure three Pods are available.

## Why

Creating Pods individually is difficult to manage.

A Deployment allows us to define:

* Application name
* Container image
* Number of replicas
* Pod configuration
* Update strategy

If a Pod fails, the Deployment helps ensure that a replacement Pod is created.

## How

Create an Nginx Deployment with three replicas:

```bash
kubectl create deployment nginx-deployment \
  --image=nginx \
  --replicas=3 \
  -n dev
```

Check the Deployment:

```bash
kubectl get deployment -n dev
```

Check the Pods:

```bash
kubectl get pods -n dev
```

The structure is:

```text
Deployment
    ↓
ReplicaSet
    ↓
3 Pods
    ↓
Nginx containers
```

## Key Takeaway

A Deployment allows Kubernetes to manage application Pods instead of managing individual Pods manually.

---

# Task 2 – Generate Deployment YAML Using Dry Run

## What

`kubectl` can generate a Deployment YAML file without actually creating the Deployment.

The command used was:

```bash
kubectl create deployment nginx-deployment \
  --image=nginx \
  --dry-run=client \
  -o yaml > nginx-deployment.yaml
```

## Why

Generating YAML using `kubectl` is useful when learning Kubernetes manifests.

Instead of writing the entire YAML file manually, Kubernetes can create a starting template that we can inspect and modify.

## How

### Step 1 – Use `--dry-run=client`

```bash
--dry-run=client
```

This means:

```text
Do not create the resource.
Only generate the configuration.
```

### Step 2 – Use `-o yaml`

```bash
-o yaml
```

This tells `kubectl` to display the resource definition in YAML format.

### Step 3 – Save the output

```bash
> nginx-deployment.yaml
```

The `>` is a Linux shell redirection operator.

It saves the generated output into:

```text
nginx-deployment.yaml
```

View the file:

```bash
cat nginx-deployment.yaml
```

The generated manifest contains information similar to:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
        - name: nginx
          image: nginx
```

The YAML can then be created in the cluster using:

```bash
kubectl apply -f nginx-deployment.yaml
```

## Key Takeaway

```text
--dry-run=client
        ↓
Don't create the resource
        ↓
-o yaml
        ↓
Generate YAML
        ↓
> nginx-deployment.yaml
        ↓
Save YAML to a file
```

---

# Task 3 – Understand Deployment Status

## What

The Deployment status shows whether the desired Pods are running correctly.

Example:

```text
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           49s
```

## Why

Deployment status helps us understand whether the application is healthy and whether an update has completed.

## How

Check the Deployment:

```bash
kubectl get deployment nginx-deployment -n dev
```

The important columns are:

### READY

```text
3/3
```

Means:

```text
3 Pods are ready
out of
3 desired Pods
```

So:

```text
3/3 = All Pods are ready
```

### UP-TO-DATE

```text
3
```

Means three Pods are running the latest version of the Deployment's Pod template.

This is especially important during a Rolling Update.

### AVAILABLE

```text
3
```

Means three Pods are currently available to serve the application.

### AGE

```text
49s
```

Shows how long the Deployment has existed.

## Example

```text
READY       UP-TO-DATE       AVAILABLE
3/3              3                3
```

This means:

```text
Desired Pods       = 3
Ready Pods         = 3
Latest Pods        = 3
Available Pods     = 3
```

## Key Takeaway

The three most important Deployment status columns are:

```text
READY       → Are the Pods ready?
UP-TO-DATE  → Are they using the latest version?
AVAILABLE   → Can they currently serve the application?
```

---

# Task 4 – Understand Rolling Update

## What

A **Rolling Update** gradually replaces old Pods with new Pods when the Deployment configuration changes.

For example, suppose three Pods are running:

```text
Pod 1 → nginx:old
Pod 2 → nginx:old
Pod 3 → nginx:old
```

After updating the image, Kubernetes gradually replaces them with the new version:

```text
Pod 1 → nginx:new
Pod 2 → nginx:old
Pod 3 → nginx:old
```

Then:

```text
Pod 1 → nginx:new
Pod 2 → nginx:new
Pod 3 → nginx:old
```

Finally:

```text
Pod 1 → nginx:new
Pod 2 → nginx:new
Pod 3 → nginx:new
```

## Why

Rolling Updates help reduce downtime during application updates.

Instead of deleting all old Pods at once, Kubernetes gradually replaces them.

This allows the application to continue running while the update is happening.

## How

First check the Deployment:

```bash
kubectl get deployment nginx-deployment -n dev
```

Update the image:

```bash
kubectl set image deployment/nginx-deployment \
  nginx=nginx:1.27 \
  -n dev
```

Check the rollout status:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

You should see:

```text
deployment "nginx-deployment" successfully rolled out
```

Watch Pods during the update:

```bash
kubectl get pods -n dev -w
```

The general process is:

```text
Old Pods
   ↓
New Pods are created
   ↓
Old Pods are gradually removed
   ↓
New Pods become ready
   ↓
Rolling Update completed
```

## Key Takeaway

A Rolling Update means:

> **Gradually replace old Pods with new Pods instead of replacing everything at once.**

---

# Task 5 – Check Deployment Rollout History

## What

Kubernetes keeps a history of Deployment revisions.

After performing an update, we can check the revision history using:

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

Example output:

```text
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

## Why

Revision history is useful because it allows us to:

* See previous Deployment versions
* Understand how many revisions exist
* Inspect a specific revision
* Roll back a Deployment if an update causes problems

## How

Check the history:

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

In this example:

```text
REVISION
1
2
```

means the Deployment has two revisions.

The flow is:

```text
Revision 1
    ↓
Initial Deployment
    ↓
Update image
    ↓
Rolling Update
    ↓
Revision 2
```

To inspect a particular revision:

```bash
kubectl rollout history deployment/nginx-deployment \
  --revision=2 \
  -n dev
```

## Key Takeaway

A Deployment revision represents a version of the Deployment's Pod template.

```text
Revision 1 → First version
Revision 2 → Updated version
Revision 3 → Another update
```

---

# Task 6 – Roll Back a Deployment

## What

A rollback means returning a Deployment to a previous revision.

## Why

Sometimes a new application version has a problem.

For example:

```text
Version 1 → Working ✅
Version 2 → Bug ❌
```

Instead of manually fixing everything immediately, we can roll back to the previous version.

## How

Roll back the Deployment:

```bash
kubectl rollout undo deployment/nginx-deployment -n dev
```

Check the rollout:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

Check the history:

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

The rollback flow is:

```text
Revision 1 → Working version
      ↓
Revision 2 → Problematic version
      ↓
Rollback
      ↓
Revision 1 → Restored
```

## Key Takeaway

Rollback allows us to return to a previous Deployment configuration when the new version has a problem.

---

# Task 7 – Understand CHANGE-CAUSE

## What

The `CHANGE-CAUSE` column explains why a Deployment revision was created.

Example:

```text
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

`<none>` means no change description was recorded.

## Why

A change description makes Deployment history easier to understand.

For example:

```text
REVISION  CHANGE-CAUSE
1         Initial deployment
2         Updated nginx image to 1.27
```

This is much easier to understand later.

## How

A change cause can be recorded using an annotation:

```bash
kubectl annotate deployment nginx-deployment \
  kubernetes.io/change-cause="Updated nginx image to 1.27" \
  -n dev
```

Then check the history:

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

## Key Takeaway

`CHANGE-CAUSE` helps us understand **why a Deployment revision was created**.

---

# Important Commands Learned

## Deployment Commands

```bash
kubectl create deployment nginx-deployment \
  --image=nginx \
  --replicas=3 \
  -n dev
```

```bash
kubectl get deployment -n dev
```

```bash
kubectl get pods -n dev
```

## Generate YAML

```bash
kubectl create deployment nginx-deployment \
  --image=nginx \
  --dry-run=client \
  -o yaml > nginx-deployment.yaml
```

## Apply YAML

```bash
kubectl apply -f nginx-deployment.yaml
```

## Update Image

```bash
kubectl set image deployment/nginx-deployment \
  nginx=nginx:1.27 \
  -n dev
```

## Check Rollout

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

## Check Rollout History

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

## Inspect a Revision

```bash
kubectl rollout history deployment/nginx-deployment \
  --revision=2 \
  -n dev
```

## Roll Back

```bash
kubectl rollout undo deployment/nginx-deployment -n dev
```

---

# Overall Kubernetes Deployment Flow

```text
                    Deployment
                         │
                         ↓
                    ReplicaSet
                         │
              ┌──────────┼──────────┐
              ↓          ↓          ↓
            Pod 1      Pod 2      Pod 3
              │          │          │
              ↓          ↓          ↓
           Container   Container   Container
              │          │          │
              └──────────┼──────────┘
                         ↓
                    Application
```

When the image changes:

```text
Old Deployment Version
        │
        ↓
Rolling Update
        │
        ↓
New ReplicaSet
        │
        ↓
New Pods
        │
        ↓
New Application Version
```

If the new version has a problem:

```text
New Version
     ↓
Problem
     ↓
kubectl rollout undo
     ↓
Previous Version
```

---

# Final Summary

## What

A **Deployment** manages Pods and maintains the desired state of an application.

## Why

Deployments make it easier to:

* Run multiple replicas
* Replace failed Pods
* Update applications
* Perform Rolling Updates
* Track revisions
* Roll back changes

## How

The main workflow learned in this task is:

```text
Create Deployment
       ↓
Run multiple Pods
       ↓
Check Deployment status
       ↓
Update container image
       ↓
Rolling Update
       ↓
Check rollout history
       ↓
Rollback if required
```

## Key Concepts

```text
Deployment
    ↓
Manages
    ↓
ReplicaSet
    ↓
Manages
    ↓
Pods
    ↓
Run
    ↓
Containers
```

The most important commands from this day are:

```bash
kubectl create deployment
kubectl get deployment
kubectl get pods
kubectl set image
kubectl rollout status
kubectl rollout history
kubectl rollout undo
```

### Final Takeaway

> **A Kubernetes Deployment manages the desired number of Pods, handles application updates through Rolling Updates, keeps revision history, and allows us to roll back when something goes wrong.**
