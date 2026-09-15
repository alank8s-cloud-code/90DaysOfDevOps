# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)

## Objective

Today I learned how Kubernetes handles **persistent storage**.

Containers and Pods are generally ephemeral. If a Pod is deleted, the data stored only inside that Pod can disappear. Kubernetes provides **PersistentVolumes (PV)** and **PersistentVolumeClaims (PVC)** to separate application workloads from persistent storage.

By the end of this task, I learned:

* Why Pod-local storage is not persistent
* What a PersistentVolume (PV) is
* What a PersistentVolumeClaim (PVC) is
* How a PVC connects to a PV
* Static vs dynamic provisioning
* StorageClasses
* Access modes
* Reclaim policies
* How data survives Pod deletion
* How dynamic PVs are automatically created

---

# Task 1: See the Problem — Data Lost on Pod Deletion

## What?

`emptyDir` is temporary storage created for a Pod.

It can be used by containers inside the Pod, but its lifecycle is tied to the Pod.

```text
Pod
 │
 └── emptyDir
       │
       └── message.txt
```

When the Pod is deleted, the `emptyDir` storage is deleted with it.

## Why?

This demonstrates why applications such as databases cannot depend only on Pod-local storage.

If a Pod is recreated, the application may start with an empty directory.

## How?

I created a Pod using an `emptyDir` volume and wrote a timestamped message:

```bash
kubectl apply -f emptydir-pod.yaml
```

I checked the file:

```bash
kubectl exec emptydir-pod -- cat /data/message.txt
```

Then I deleted the Pod:

```bash
kubectl delete pod emptydir-pod
```

I recreated it:

```bash
kubectl apply -f emptydir-pod.yaml
```

Then checked the file again:

```bash
kubectl exec emptydir-pod -- cat /data/message.txt
```

### Result

The timestamp after recreation was **different**.

This proved that the original data was lost because `emptyDir` belongs to the Pod lifecycle.

---

# Task 2: Create a PersistentVolume — Static Provisioning

## What?

A **PersistentVolume (PV)** is a piece of storage made available to the Kubernetes cluster.

A PV is a cluster-level resource.

For this task, I created a PV with:

* Capacity: `1Gi`
* Access mode: `ReadWriteOnce`
* Reclaim policy: `Retain`
* Storage type: `hostPath`
* Path: `/tmp/k8s-pv-data`

## Why?

The PV provides storage independently from the Pod.

The Pod can be deleted and recreated while the PV can continue to exist.

This is called **static provisioning** because the administrator manually creates the PV.

```text
Administrator
      │
      ▼
     PV
      │
      ▼
     PVC
      │
      ▼
    Pod
```

## How?

I created the storage directory:

```bash
sudo mkdir -p /tmp/k8s-pv-data
```

Then applied the PV:

```bash
kubectl apply -f pv.yaml
```

I checked the PV:

```bash
kubectl get pv
```

Initially, the PV was:

```text
STATUS: Available
```

### Important

`hostPath` is useful for local Kubernetes learning, but it is generally not suitable for production storage in a multi-node cluster.

---

# Task 3: Create a PersistentVolumeClaim

## What?

A **PersistentVolumeClaim (PVC)** is a request for storage.

The difference is:

```text
PV  = actual storage
PVC = request for storage
```

A PVC is namespaced, while a PV is cluster-wide.

## Why?

Applications should not normally need to know the details of the underlying storage.

Instead of saying:

> "Use this specific disk."

The application says:

> "I need 500Mi of storage with ReadWriteOnce access."

Kubernetes then finds a suitable PV.

## How?

I created a PVC requesting:

```yaml
resources:
  requests:
    storage: 500Mi

accessModes:
  - ReadWriteOnce
```

Then applied it:

```bash
kubectl apply -f pvc.yaml
```

I checked:

```bash
kubectl get pvc
```

and:

```bash
kubectl get pv
```

The PVC became:

```text
STATUS: Bound
```

The PV also became:

```text
STATUS: Bound
```

### How did Kubernetes match them?

The PVC requested:

```text
500Mi
ReadWriteOnce
```

The PV provided:

```text
1Gi
ReadWriteOnce
```

Because `500Mi` is less than `1Gi` and the access mode matched, Kubernetes was able to bind the PVC to the PV.

The relationship can be viewed as:

```text
PVC
 │
 │ Bound to
 ▼
PV
```

The `VOLUME` column of the PVC showed the PV name:

```text
my-pv
```

---

# Task 4: Use the PVC in a Pod — Data That Survives

## What?

A Pod uses a PVC instead of directly using a PV.

The relationship is:

```text
Pod
 │
 ▼
PVC
 │
 ▼
PV
 │
 ▼
Storage
```

## Why?

This separates the application from the actual storage implementation.

The Pod can be deleted and recreated without deleting the PVC and PV.

## How?

The Pod references the PVC:

```yaml
volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: my-pvc
```

The volume is mounted inside the container:

```yaml
volumeMounts:
  - name: persistent-storage
    mountPath: /data
```

I wrote data to:

```text
/data/message.txt
```

For the first Pod, I wrote:

```bash
echo "Message from first Pod at $(date)" > /data/message.txt
```

The `>` operator creates or overwrites the file.

After deleting and recreating the Pod, I used:

```bash
echo "Message from second Pod at $(date)" >> /data/message.txt
```

The `>>` operator appends data instead of overwriting it.

I verified the file:

```bash
kubectl exec pvc-pod -- cat /data/message.txt
```

### Result

The file contained data from both Pods.

```text
Message from first Pod at ...
Message from second Pod at ...
```

This proved that the data was stored on the persistent volume instead of being stored only inside the Pod.

---

# Task 5: StorageClasses and Dynamic Provisioning

## What?

A **StorageClass** defines how Kubernetes should dynamically create storage.

It connects a PVC request to a storage provisioner.

```text
PVC
 │
 ▼
StorageClass
 │
 ▼
Provisioner
 │
 ▼
PV
```

## Why?

Without dynamic provisioning, an administrator may need to manually create PVs for every storage request.

Dynamic provisioning makes this easier.

Developers can create a PVC and Kubernetes can automatically create the required PV.

## How?

I checked the StorageClasses:

```bash
kubectl get storageclass
```

My cluster showed:

```text
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer
```

I also checked the details:

```bash
kubectl describe storageclass standard
```

My StorageClass configuration was:

```text
Name:              standard
IsDefaultClass:    Yes
Provisioner:       rancher.io/local-path
ReclaimPolicy:     Delete
VolumeBindingMode: WaitForFirstConsumer
```

### My default StorageClass

> **The default StorageClass in my cluster is `standard`.**

### Important terms

#### Provisioner

```text
rancher.io/local-path
```

The provisioner is responsible for dynamically creating the storage.

#### ReclaimPolicy

```text
Delete
```

The dynamically provisioned PV is automatically deleted when its PVC is deleted.

#### VolumeBindingMode

```text
WaitForFirstConsumer
```

Kubernetes waits until a Pod consumes the PVC before completing the volume provisioning/binding process.

---

# Task 6: Dynamic Provisioning

## What?

Dynamic provisioning means that I create a PVC and Kubernetes automatically creates a PV using the StorageClass.

Instead of:

```text
Manually create PV
       ↓
Create PVC
       ↓
Create Pod
```

Dynamic provisioning works like:

```text
Create PVC
     ↓
StorageClass
     ↓
Provisioner
     ↓
PV automatically created
     ↓
Pod uses PVC
```

## Why?

Dynamic provisioning reduces manual storage management.

A developer does not need to manually create a PV every time an application needs storage.

## How?

I created a PVC using:

```yaml
storageClassName: standard
```

and requested:

```yaml
resources:
  requests:
    storage: 500Mi
```

I applied it:

```bash
kubectl apply -f dynamic-pvc.yaml
```

Then checked:

```bash
kubectl get pvc
```

The PVC became:

```text
NAME          STATUS   VOLUME
dynamic-pvc   Bound    pvc-51b1458c-d018-472b-9e67-a7eb0a8b3c3b
```

The PV was automatically created.

I checked:

```bash
kubectl get pv
```

The dynamically created PV was:

```text
pvc-51b1458c-d018-472b-9e67-a7eb0a8b3c3b
```

It had:

```text
CAPACITY:       500Mi
ACCESS MODES:   RWO
RECLAIM POLICY: Delete
STATUS:         Bound
STORAGECLASS:   standard
```

## Use the dynamic PVC in a Pod

The Pod used:

```yaml
volumes:
  - name: dynamic-storage
    persistentVolumeClaim:
      claimName: dynamic-pvc
```

The volume was mounted at:

```text
/data
```

I checked the Pod:

```bash
kubectl get pod dynamic-pod
```

Result:

```text
NAME          READY   STATUS
dynamic-pod   1/1     Running
```

I verified the stored data:

```bash
kubectl exec dynamic-pod -- cat /data/message.txt
```

Result:

```text
Data created using dynamic provisioning at Tue Sep 15 12:58:48 UTC 2026
Data created using dynamic provisioning at Tue Sep 15 13:11:07 UTC 2026
```

This confirmed that the dynamically provisioned storage was working.

---

# Dynamic Provisioning Troubleshooting

During this task, the PVC initially remained:

```text
dynamic-pvc   Pending
```

The Pod also remained:

```text
dynamic-pod   Pending
```

I checked:

```bash
kubectl describe pvc dynamic-pvc
```

The events showed:

```text
Waiting for a volume to be created by the external provisioner
'rancher.io/local-path'
```

I then checked:

```bash
kubectl get pods -A | grep local-path
```

The Local Path Provisioner was:

```text
CrashLoopBackOff
```

I investigated the provisioner Pod and found:

```text
Exit Code: 139
```

The Kubernetes nodes themselves were healthy:

```text
alank8s-cloud-control-plane   Ready
alank8s-cloud-worker          Ready
```

I restarted the Local Path Provisioner:

```bash
kubectl rollout restart deployment local-path-provisioner -n local-path-storage
```

After the provisioner became healthy, the PVC was successfully provisioned and became:

```text
Bound
```

This was a useful real-world troubleshooting lesson:

> When a PVC is stuck in `Pending`, check the PVC events and verify that the StorageClass provisioner is running.

---

# Task 7: Clean Up

## What?

Cleanup removes the Pods, PVCs, and remaining PVs after the exercise.

The important concept in this task is the **PV reclaim policy**.

## Why?

Different storage environments need different behavior after a PVC is deleted.

There are two important policies from this exercise:

```text
Delete
Retain
```

## How?

First, Pods should be deleted:

```bash
kubectl delete pod dynamic-pod
```

Then PVCs can be deleted:

```bash
kubectl delete pvc dynamic-pvc
```

After deleting the dynamic PVC, check:

```bash
kubectl get pv
```

The dynamically provisioned PV used:

```text
ReclaimPolicy: Delete
```

Therefore, the dynamic PV was automatically deleted.

### Dynamic PV

```text
PVC deleted
     ↓
ReclaimPolicy: Delete
     ↓
PV automatically deleted
```

The dynamic PV was:

```text
pvc-51b1458c-d018-472b-9e67-a7eb0a8b3c3b
```

## Manual PV

The manual PV was originally created with:

```text
ReclaimPolicy: Retain
```

With a `Retain` policy, deleting the PVC does not automatically delete the PV.

The PV can enter:

```text
Released
```

and the administrator must handle the remaining storage manually.

```text
PVC deleted
     ↓
ReclaimPolicy: Retain
     ↓
PV remains
     ↓
Released
     ↓
Administrator handles cleanup
```

### Important note about my cluster

At the time of my final verification, the manually created `my-pv` was already deleted from my cluster.

Therefore, I verified the automatic deletion of the dynamic PV, but I did **not** observe the `Released` state for `my-pv` during the final cleanup.

---

# Static vs Dynamic Provisioning

| Feature               | Static Provisioning                  | Dynamic Provisioning                |
| --------------------- | ------------------------------------ | ----------------------------------- |
| PV creation           | Administrator creates it             | Kubernetes creates it automatically |
| PVC creation          | Developer/User                       | Developer/User                      |
| StorageClass required | Not necessarily                      | Yes                                 |
| Provisioner           | Not required for manually created PV | Required                            |
| Example               | `my-pv`                              | `pvc-51b1458c-...`                  |
| Management            | More manual                          | More automated                      |

### Static

```text
Administrator
      │
      ▼
     PV
      │
      ▼
     PVC
      │
      ▼
    Pod
```

### Dynamic

```text
Developer
    │
    ▼
   PVC
    │
    ▼
StorageClass
    │
    ▼
Provisioner
    │
    ▼
   PV
    │
    ▼
   Pod
```

---

# Access Modes

Access modes describe how a volume can be accessed.

## ReadWriteOnce — RWO

```text
Read + Write
from a single node at a time
```

Example:

```yaml
accessModes:
  - ReadWriteOnce
```

This was the access mode used in this exercise.

## ReadOnlyMany — ROX

```text
Read-only
from many nodes
```

## ReadWriteMany — RWX

```text
Read + Write
from many nodes
```

Not every storage backend supports every access mode.

---

# PV Lifecycle

A PV can move through different states:

```text
Available
    ↓
Bound
    ↓
Released
```

### Available

The PV exists but is not bound to a PVC.

### Bound

The PV is connected to a PVC.

```text
PVC → PV
```

### Released

The PVC that was using the PV has been deleted, but the PV has not been automatically removed.

This commonly happens with:

```text
ReclaimPolicy: Retain
```

---

# Reclaim Policies

## Delete

```text
PVC deleted
     ↓
PV deleted automatically
```

This was used by my dynamic StorageClass:

```text
standard
ReclaimPolicy: Delete
```

## Retain

```text
PVC deleted
     ↓
PV retained
     ↓
Released
```

This was used by my manually created PV.

---

# Where is the Data Stored?

For dynamic provisioning in my cluster, the StorageClass uses:

```text
Provisioner: rancher.io/local-path
```

The Local Path Provisioner uses local storage on the Kubernetes node.

My configuration contains:

```text
/var/local-path-provisioner
```

Therefore, the data is stored on the node's local filesystem managed by the Local Path Provisioner.

The important point is:

```text
Pod
 │
 ▼
PVC
 │
 ▼
PV
 │
 ▼
Node's storage
```

Deleting the Pod does not delete the PVC or PV.

Therefore:

```text
Delete Pod
    ↓
Pod removed
    ↓
PVC remains
    ↓
PV remains
    ↓
Data remains
```

However, deleting a dynamically provisioned PVC with a `Delete` reclaim policy can also remove the dynamically created PV and its associated storage.

---

# Useful Commands

## Pods

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl exec <pod-name> -- cat /data/message.txt
kubectl delete pod <pod-name>
```

## PersistentVolume

```bash
kubectl get pv
kubectl describe pv <pv-name>
kubectl delete pv <pv-name>
```

## PersistentVolumeClaim

```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
kubectl delete pvc <pvc-name>
```

## StorageClass

```bash
kubectl get storageclass
kubectl describe storageclass standard
```

## Troubleshooting Dynamic Provisioning

```bash
kubectl get pods -A | grep local-path
kubectl describe pvc <pvc-name>
kubectl describe pod <pod-name>
```

Restart the Local Path Provisioner if required:

```bash
kubectl rollout restart deployment local-path-provisioner -n local-path-storage
```

---

# Important Kubernetes Storage Concepts

```text
                   Kubernetes Storage

                         Pod
                          │
                          ▼
                         PVC
                  PersistentVolumeClaim
                          │
                          ▼
                         PV
                   PersistentVolume
                          │
                          ▼
                   Actual Storage
```

### Remember

* **Pod** = runs the application
* **PVC** = requests storage
* **PV** = provides storage
* **StorageClass** = defines how storage is dynamically provisioned
* **Provisioner** = creates/provides the storage
* **ReclaimPolicy** = controls what happens when a PVC is deleted
* **AccessMode** = controls how the volume can be accessed

---

# What I Learned

1. Pod-local storage such as `emptyDir` is tied to the Pod lifecycle.
2. Deleting a Pod does not delete a separate persistent volume.
3. A PV is actual storage available to the cluster.
4. A PVC is a request for storage.
5. Kubernetes can automatically bind a PVC to a suitable PV.
6. Static provisioning requires manually creating PVs.
7. Dynamic provisioning allows Kubernetes to create PVs automatically.
8. A StorageClass defines the dynamic provisioning behavior.
9. My cluster's default StorageClass is `standard`.
10. The `standard` StorageClass uses `rancher.io/local-path`.
11. `Delete` and `Retain` reclaim policies behave differently.
12. `hostPath` and local-path storage are useful for learning but have limitations in multi-node production environments.
13. When a PVC is `Pending`, checking PVC events and the provisioner is an important troubleshooting step.

---

# Interview Questions

### 1. What is a PV?

A PersistentVolume is cluster-level storage that can be used by applications in Kubernetes.

### 2. What is a PVC?

A PersistentVolumeClaim is a request for storage made by a user or application.

### 3. What is the difference between PV and PVC?

```text
PV  = storage provided
PVC = storage requested
```

### 4. What is dynamic provisioning?

Dynamic provisioning automatically creates a PV when a PVC requests storage through a StorageClass.

### 5. What is a StorageClass?

A StorageClass defines the type of storage and the provisioner Kubernetes should use for dynamic provisioning.

### 6. What happens when a Pod using a PVC is deleted?

The Pod is deleted, but the PVC, PV, and data can remain.

### 7. What is the difference between Delete and Retain?

`Delete` allows the dynamically provisioned PV/storage to be deleted when the PVC is deleted.

`Retain` keeps the PV so an administrator can manually manage the remaining storage.

### 8. What happens if a PVC is Pending?

Check:

```bash
kubectl describe pvc <pvc-name>
```

Then inspect the events and verify that:

* A suitable PV exists for static provisioning, or
* The StorageClass exists
* The provisioner is running
* The requested capacity/access mode can be satisfied

---

# Final Day 55 Summary

The biggest lesson from Day 55 is:

```text
Without persistent storage:

Pod → Data
       ↓
    Pod deleted
       ↓
     Data lost
```

With persistent storage:

```text
Pod
 │
 ▼
PVC
 │
 ▼
PV
 │
 ▼
Persistent Storage

Pod deleted
     ↓
PVC/PV remain
     ↓
Data remains
```

And with dynamic provisioning:

```text
PVC
 │
 ▼
StorageClass
 │
 ▼
Provisioner
 │
 ▼
PV automatically created
 │
 ▼
Persistent Storage
```

**Persistent storage allows Kubernetes applications to survive Pod restarts and recreation without losing their data.**
