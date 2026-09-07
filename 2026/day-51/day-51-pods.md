# Day 51 – Kubernetes Manifests and Your First Pods

Today I started deploying workloads on my Kubernetes cluster.

The main focus of Day 51 was understanding **Kubernetes manifest files**, creating Pods, working with labels, comparing **declarative and imperative approaches**, validating manifests, and cleaning up resources.

---

## What I Learned Today

* What a Kubernetes manifest is
* The four main fields of a Kubernetes manifest
* What `apiVersion`, `kind`, `metadata`, and `spec` mean
* How to create a Pod using YAML
* How to inspect Pods using `kubectl`
* How to view Pod logs
* How to execute commands inside a Pod
* Difference between declarative and imperative approaches
* How to generate YAML using `--dry-run`
* How to validate manifests before applying them
* How Pod labels work
* How to filter Pods using labels
* Why standalone Pods are not normally used in production

---

# The Anatomy of a Kubernetes Manifest

## What is a Kubernetes Manifest?

A Kubernetes manifest is a **YAML file that describes the desired state of a Kubernetes resource**.

For example, a Pod manifest tells Kubernetes:

> "I want a Pod with this name, these labels, and this container running this image."

A basic Pod manifest looks like this:

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: my-pod
  labels:
    app: my-app

spec:
  containers:
    - name: my-container
      image: nginx:latest
      ports:
        - containerPort: 80
```

---

## Why are Manifests Important?

Manifests allow us to define Kubernetes resources as code.

Instead of manually typing many commands, we can store the configuration in a YAML file.

For example:

```text
YAML file
   |
   | kubectl apply
   v
Kubernetes API Server
   |
   v
Desired State
   |
   v
Kubernetes creates/updates resource
```

Manifest files can also be stored in Git, which makes them useful for:

* Version control
* Team collaboration
* Reproducible deployments
* CI/CD
* GitOps

---

## The Four Main Fields

Every Kubernetes resource normally has these important top-level fields:

```yaml
apiVersion:
kind:
metadata:
spec:
```

### `apiVersion`

Defines which Kubernetes API version is used.

For a Pod:

```yaml
apiVersion: v1
```

For Pods, the API version is `v1`.

---

### `kind`

Defines the type of Kubernetes resource.

For today's examples:

```yaml
kind: Pod
```

Later, other resources will be used, such as:

```yaml
kind: Deployment
kind: Service
kind: ConfigMap
kind: Secret
```

---

### `metadata`

Contains information that identifies and organizes the resource.

Example:

```yaml
metadata:
  name: nginx-pod
  labels:
    app: nginx
```

`name` identifies the resource.

`labels` are key-value pairs used for organization and selection.

---

### `spec`

Defines the desired state of the resource.

For a Pod, this includes things such as:

* Containers
* Container images
* Commands
* Ports
* Volumes
* Environment variables

Example:

```yaml
spec:
  containers:
    - name: nginx
      image: nginx:latest
```

---

# Task 1: Create Your First Pod (Nginx)

## What?

A Pod is the **smallest deployable unit in Kubernetes**.

For the first task, I created a Pod running an Nginx container.

---

## Why?

This gives me hands-on experience with:

* Writing a Pod manifest
* Creating a resource using YAML
* Checking Pod status
* Viewing Pod information
* Reading container logs
* Accessing a container shell

---

## How?

I created:

```text
nginx-pod.yaml
```

### `nginx-pod.yaml`

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

---

## Apply the Manifest

```bash
kubectl apply -f nginx-pod.yaml
```

This tells Kubernetes:

> Create or update the resource described in this YAML file.

---

## Verify the Pod

```bash
kubectl get pods
```

Example:

```text
NAME         READY   STATUS    RESTARTS   AGE
nginx-pod    1/1     Running   0          20s
```

The important part is:

```text
STATUS
Running
```

---

## Get More Pod Information

```bash
kubectl get pods -o wide
```

The `-o wide` option provides additional information such as:

* Pod IP
* Node
* Container information

---

## Describe the Pod

```bash
kubectl describe pod nginx-pod
```

This shows detailed information about the Pod.

It is especially useful when debugging problems.

Important sections include:

```text
Name
Namespace
Labels
Status
Containers
Events
```

The **Events** section is particularly useful when something goes wrong.

---

## Check Pod Logs

```bash
kubectl logs nginx-pod
```

This displays the container's standard output and error output.

---

## Open a Shell Inside the Pod

```bash
kubectl exec -it nginx-pod -- /bin/bash
```

If `/bin/bash` is unavailable, use:

```bash
kubectl exec -it nginx-pod -- /bin/sh
```

---

## Test Nginx From Inside the Pod

Inside the container:

```bash
curl localhost:80
```

Nginx should return its default HTML response.

Then exit:

```bash
exit
```

---

## What I Learned

I learned that:

```text
YAML
  |
  v
kubectl apply
  |
  v
Kubernetes
  |
  v
Pod
  |
  v
Nginx container
```

I also learned how to inspect and debug a running Pod using:

```bash
kubectl get pods
kubectl describe pod
kubectl logs
kubectl exec
```

---

# Task 2: Create a Custom Pod (BusyBox)

## What?

For the second Pod, I created a BusyBox container.

Unlike Nginx, BusyBox does not automatically run a long-lived web server.

Therefore, I used a command to keep the container running.

---

## Why?

This demonstrates an important concept:

> A container needs a running process to remain running.

If the main process finishes, the container exits.

---

## How?

I created:

```text
busybox-pod.yaml
```

### `busybox-pod.yaml`

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev

spec:
  containers:
    - name: busybox
      image: busybox:latest
      command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

---

## Understanding the Command

The important part is:

```yaml
command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

It performs two actions:

```text
echo Hello from BusyBox
        |
        v
Print message
        |
        &&
        v
sleep 3600
```

The `sleep 3600` keeps the container running for approximately one hour.

Without a long-running command, the container would exit after printing the message.

---

## Apply the Manifest

```bash
kubectl apply -f busybox-pod.yaml
```

---

## Verify

```bash
kubectl get pods
```

Then check the logs:

```bash
kubectl logs busybox-pod
```

Expected output:

```text
Hello from BusyBox
```

---

## What I Learned

I learned that the main process inside a container is important.

For example:

```text
Nginx
  |
  v
Nginx server keeps running
  |
  v
Container stays Running
```

But:

```text
BusyBox
  |
  v
echo message
  |
  v
process finishes
  |
  v
container exits
```

Using:

```bash
sleep 3600
```

keeps the BusyBox container running.

---

# Task 3: Imperative vs Declarative

## What?

Kubernetes supports two common ways of creating resources:

### Imperative

Tell Kubernetes directly what action to perform.

Example:

```bash
kubectl run redis-pod --image=redis:latest
```

### Declarative

Describe the desired state in a YAML file.

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest
```

Then:

```bash
kubectl apply -f nginx-pod.yaml
```

---

## Why?

Understanding the difference is important because declarative configuration is widely used in:

* Kubernetes
* CI/CD
* Infrastructure as Code
* GitOps
* Argo CD

The declarative approach allows configuration to be stored in Git and used repeatedly.

---

## Imperative Example

Create a Redis Pod directly:

```bash
kubectl run redis-pod --image=redis:latest
```

Check it:

```bash
kubectl get pods
```

---

## Extract the Generated YAML

```bash
kubectl get pod redis-pod -o yaml
```

Kubernetes returns the complete Pod definition.

The output contains additional information automatically added by Kubernetes, such as:

```text
status
timestamps
uid
resourceVersion
managedFields
```

---

## Declarative Example

Instead of:

```bash
kubectl run redis-pod --image=redis:latest
```

we can create a YAML file:

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: redis-pod

spec:
  containers:
    - name: redis
      image: redis:latest
```

Then:

```bash
kubectl apply -f redis-pod.yaml
```

---

## Generate YAML Without Creating a Pod

Kubernetes can generate a manifest using:

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

Important parts:

```text
--dry-run=client
```

Means:

> Generate the configuration but don't create the resource.

```text
-o yaml
```

Means:

> Display the output as YAML.

---

## Save the Generated YAML

```bash
kubectl run test-pod \
  --image=nginx \
  --dry-run=client \
  -o yaml > test-pod.yaml
```

Now the generated YAML is stored in:

```text
test-pod.yaml
```

---

## Imperative vs Declarative Summary

| Imperative                              | Declarative                        |
| --------------------------------------- | ---------------------------------- |
| Uses commands                           | Uses YAML                          |
| Tells Kubernetes what action to perform | Defines desired state              |
| Good for quick testing                  | Good for repeatable deployments    |
| Configuration may not be stored         | Configuration can be stored in Git |
| Example: `kubectl run`                  | Example: `kubectl apply -f`        |

### Simple way to remember

```text
Imperative
    ↓
"Do this"

Declarative
    ↓
"I want this state"
```

---

## What I Learned

I learned that Kubernetes can create resources using commands or YAML.

For real DevOps workflows, declarative manifests are especially important because they can be version-controlled and reused.

---

# Task 4: Validate Before Applying

## What?

Before creating a Kubernetes resource, we can validate our manifest using `--dry-run`.

This allows us to check the configuration without actually creating the resource.

---

## Why?

Validation helps catch mistakes before applying changes to the cluster.

This is useful in:

* Development
* CI/CD pipelines
* Production deployments
* Troubleshooting

---

## Client-Side Dry Run

```bash
kubectl apply -f nginx-pod.yaml --dry-run=client
```

This checks the manifest locally without creating the resource.

---

## Server-Side Dry Run

```bash
kubectl apply -f nginx-pod.yaml --dry-run=server
```

This sends the request to the Kubernetes API server for validation but does not persist the resource.

The server can validate the manifest against the Kubernetes API.

---

## Intentionally Break the YAML

For example, remove:

```yaml
image: nginx:latest
```

Then run:

```bash
kubectl apply -f nginx-pod.yaml --dry-run=server
```

Kubernetes should report a validation error because the container definition is incomplete.

The exact error message can vary depending on the Kubernetes version, but the important lesson is:

> Kubernetes validates the resource before accepting it.

---

## What I Learned

I learned that `--dry-run` is useful for testing changes safely.

The important commands are:

```bash
kubectl apply -f file.yaml --dry-run=client
```

and:

```bash
kubectl apply -f file.yaml --dry-run=server
```

---

# Task 5: Pod Labels and Filtering

## What?

A label is a **key-value pair attached to a Kubernetes resource**.

Example:

```yaml
labels:
  app: nginx
  environment: production
```

Labels can be used to organize and select Kubernetes resources.

---

## Why?

Imagine having many Pods:

```text
frontend
frontend
backend
backend
database
database
```

Labels allow us to identify groups of Pods.

For example:

```text
frontend Pods
    app=frontend

backend Pods
    app=backend

database Pods
    app=database
```

Then we can filter them using label selectors.

---

## View Pod Labels

```bash
kubectl get pods --show-labels
```

Example:

```text
NAME          LABELS
nginx-pod     app=nginx
busybox-pod   app=busybox,environment=dev
```

---

## Filter by Label

Find Pods where:

```text
app=nginx
```

using:

```bash
kubectl get pods -l app=nginx
```

Find Pods where:

```text
environment=dev
```

using:

```bash
kubectl get pods -l environment=dev
```

Here:

```text
-l
```

means:

> Use a label selector.

---

## Add a Label

Add a production label to the Nginx Pod:

```bash
kubectl label pod nginx-pod environment=production
```

Verify:

```bash
kubectl get pods --show-labels
```

---

## Remove a Label

Remove the `environment` label:

```bash
kubectl label pod nginx-pod environment-
```

The `-` at the end means:

> Remove this label.

---

## Create a Third Pod with Multiple Labels

I created a third Pod with at least three labels:

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: alpine-pod
  labels:
    app: alpine
    environment: dev
    team: devops

spec:
  containers:
    - name: alpine
      image: alpine:latest
      command: ["sh", "-c", "echo Hello from Alpine && sleep 3600"]
```

Apply it:

```bash
kubectl apply -f alpine-pod.yaml
```

---

## Filter the Third Pod

Filter by application:

```bash
kubectl get pods -l app=alpine
```

Filter by environment:

```bash
kubectl get pods -l environment=dev
```

Filter by team:

```bash
kubectl get pods -l team=devops
```

Filter using multiple labels:

```bash
kubectl get pods -l app=alpine,environment=dev
```

This means:

```text
app=alpine
    AND
environment=dev
```

---

## Labels and Selectors

Labels become especially important when working with Kubernetes Services and Deployments.

For example:

```yaml
selector:
  app: nginx
```

means:

> Find resources with the label `app=nginx`.

Simple way to remember:

```text
Label
  ↓
"Information attached to the resource"

Selector
  ↓
"Find resources matching this information"
```

---

## What I Learned

I learned that labels are key-value pairs:

```text
app=nginx
environment=production
team=devops
```

and selectors can use those labels to find specific Pods.

The important command is:

```bash
kubectl get pods -l <key>=<value>
```

---

# Task 6: Clean Up

## What?

After completing the exercises, I deleted the Pods created during the practice.

---

## Why?

Cleaning up resources prevents unnecessary Pods from continuing to run in the cluster.

It is also good Kubernetes practice to remove temporary resources after testing.

---

## Delete Pods by Name

```bash
kubectl delete pod nginx-pod
```

```bash
kubectl delete pod busybox-pod
```

```bash
kubectl delete pod redis-pod
```

If the third Pod was created:

```bash
kubectl delete pod alpine-pod
```

---

## Delete Using the Manifest

Instead of deleting the Pod by name, we can delete it using its manifest:

```bash
kubectl delete -f nginx-pod.yaml
```

Kubernetes reads the resource definition from the file and deletes that resource.

---

## Verify

```bash
kubectl get pods
```

The Pods created during this exercise should no longer be present.

---

## Important Observation

A standalone Pod does not have a controller managing it.

Therefore:

```text
Delete Pod
    |
    v
Pod is gone
```

Kubernetes will not automatically recreate it.

This is one reason production workloads normally use a:

```text
Deployment
```

instead of creating standalone Pods.

Deployments will be covered next.

---

# Expected Output

The Day 51 task expected:

* At least 3 Pod manifests written by hand
* A markdown file named `day-51-pods.md`
* Screenshot of `kubectl get pods` showing running Pods

Example manifests created during this task:

```text
nginx-pod.yaml
busybox-pod.yaml
alpine-pod.yaml
```

---

# Useful Kubernetes Commands

## Create or Update a Resource

```bash
kubectl apply -f file.yaml
```

---

## List Pods

```bash
kubectl get pods
```

---

## List Pods with Additional Information

```bash
kubectl get pods -o wide
```

---

## Show Pod Labels

```bash
kubectl get pods --show-labels
```

---

## Filter Pods

```bash
kubectl get pods -l app=nginx
```

---

## Describe a Pod

```bash
kubectl describe pod <pod-name>
```

---

## View Logs

```bash
kubectl logs <pod-name>
```

---

## Execute a Command Inside a Pod

```bash
kubectl exec -it <pod-name> -- /bin/sh
```

---

## Delete a Pod

```bash
kubectl delete pod <pod-name>
```

---

## Generate YAML

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

---

## Validate a Manifest Locally

```bash
kubectl apply -f file.yaml --dry-run=client
```

---

## Validate Against the Kubernetes API

```bash
kubectl apply -f file.yaml --dry-run=server
```

---

# Key Takeaways

### 1. Kubernetes Manifest

A manifest describes the desired state of a Kubernetes resource.

```text
apiVersion
kind
metadata
spec
```

---

### 2. Pod

A Pod is the smallest deployable unit in Kubernetes.

It can contain one or more containers.

---

### 3. Declarative Configuration

YAML describes what state we want:

```bash
kubectl apply -f file.yaml
```

Kubernetes then works to make the cluster match that desired state.

---

### 4. Imperative Commands

Commands directly tell Kubernetes what action to perform:

```bash
kubectl run redis-pod --image=redis:latest
```

---

### 5. Dry Run

Dry runs allow us to validate or generate configuration without creating the resource.

```bash
--dry-run=client
```

and:

```bash
--dry-run=server
```

---

### 6. Labels

Labels are key-value pairs used to organize and select resources.

Example:

```yaml
labels:
  app: nginx
  environment: production
  team: devops
```

---

### 7. Standalone Pods

A standalone Pod is not automatically recreated after deletion.

For production workloads, Kubernetes Deployments are normally preferred.

---

# Day 51 Summary

Today I moved from simply having a Kubernetes cluster to actually deploying workloads.

I learned how to:

```text
Write YAML
    ↓
Create Pods
    ↓
Inspect Pods
    ↓
Read Logs
    ↓
Execute Commands
    ↓
Generate YAML
    ↓
Validate Manifests
    ↓
Use Labels
    ↓
Filter Pods
    ↓
Clean Up Resources
```

The most important concept from today is:

> **Kubernetes manifests describe the desired state of resources, and Kubernetes works to make the actual cluster state match that desired state.**
