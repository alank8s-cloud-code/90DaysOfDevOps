# Day 54 – Kubernetes ConfigMaps and Secrets

## Objective

Learn how Kubernetes manages application configuration and sensitive information using:

* **ConfigMaps** for non-sensitive configuration
* **Secrets** for sensitive information
* **Environment variables** for simple key-value configuration
* **Volume mounts** when an application needs configuration as files
* How configuration changes behave while a Pod is running

---

# Task 1: Create a ConfigMap from Literals

## What?

A **ConfigMap** stores non-sensitive configuration data as key-value pairs.

For this task, we create:

```text
APP_ENV=production
APP_DEBUG=false
APP_PORT=8080
```

## Why?

We should not hardcode configuration directly inside a container image.

For example, instead of putting:

```text
APP_ENV=production
```

inside the application image, Kubernetes can provide it through a ConfigMap.

This allows the same image to be used in different environments.

```text
              ┌──────────────┐
              │ ConfigMap    │
              │ app-config   │
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │     Pod      │
              │              │
              │ APP_ENV      │
              │ APP_DEBUG    │
              │ APP_PORT     │
              └──────────────┘
```

## How?

Create the ConfigMap:

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  --from-literal=APP_PORT=8080
```

## Verify

List ConfigMaps:

```bash
kubectl get configmap
```

Describe the ConfigMap:

```bash
kubectl describe configmap app-config
```

Get the complete YAML:

```bash
kubectl get configmap app-config -o yaml
```

Expected data:

```yaml
data:
  APP_DEBUG: "false"
  APP_ENV: production
  APP_PORT: "8080"
```

## Important

ConfigMap data created from literals is stored as normal text.

There is:

* No Base64 encoding
* No encryption provided by ConfigMap itself

Therefore, **do not store passwords or other sensitive information in a ConfigMap**.

---

# Task 2: Create a ConfigMap from a File

## What?

A ConfigMap can also be created from the contents of a file.

This is useful when an application needs a complete configuration file rather than individual environment variables.

For this task, we create an Nginx configuration file containing a `/health` endpoint.

## Why?

Some applications expect configuration in a file.

Examples:

```text
Nginx        → nginx.conf
Prometheus   → prometheus.yml
Application  → application.properties
Database     → configuration file
```

In these situations, mounting a ConfigMap as a volume is useful.

## How?

Create `default.conf`:

```nginx
server {
    listen 80;

    location / {
        default_type text/plain;
        return 200 "Hello from Nginx\n";
    }

    location /health {
        default_type text/plain;
        return 200 "healthy\n";
    }
}
```

Create the ConfigMap:

```bash
kubectl create configmap nginx-config \
  --from-file=default.conf=default.conf
```

Verify:

```bash
kubectl get configmap nginx-config -o yaml
```

You should see the contents of `default.conf` stored under the key:

```text
default.conf
```

## Important concept

The key name becomes the filename when the ConfigMap is mounted.

```text
ConfigMap

key: default.conf
       │
       ▼
Mounted volume

/etc/nginx/conf.d/default.conf
```

---

# Task 3: Use ConfigMaps in a Pod

## What?

A ConfigMap can be provided to a Pod in different ways.

The two important methods in this task are:

1. Environment variables
2. Volume mounts

## Why?

The correct method depends on **how the application expects the configuration**.

### Simple rule

> **Application needs a value → use environment variables.**

> **Application needs a file → use a volume mount.**

---

## Part 1: Use ConfigMap with `envFrom`

Create `app-config-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-config-pod
spec:
  containers:
    - name: app
      image: busybox:latest
      command: ["sh", "-c"]
      args:
        - |
          echo "APP_ENV=$APP_ENV"
          echo "APP_DEBUG=$APP_DEBUG"
          echo "APP_PORT=$APP_PORT"
          sleep 3600
      envFrom:
        - configMapRef:
            name: app-config
```

Apply:

```bash
kubectl apply -f app-config-pod.yaml
```

Check the Pod:

```bash
kubectl get pod app-config-pod
```

Check logs:

```bash
kubectl logs app-config-pod
```

Expected:

```text
APP_ENV=production
APP_DEBUG=false
APP_PORT=8080
```

### How `envFrom` works

```yaml
envFrom:
  - configMapRef:
      name: app-config
```

This means:

> Take **all keys** from `app-config` and create environment variables from them.

```text
ConfigMap
───────────────
APP_ENV=production
APP_DEBUG=false
APP_PORT=8080
       │
       ▼
Container environment
───────────────
APP_ENV=production
APP_DEBUG=false
APP_PORT=8080
```

---

## Part 2: Mount Nginx ConfigMap as a Volume

Create `nginx-config-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-config-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80

      volumeMounts:
        - name: nginx-config-volume
          mountPath: /etc/nginx/conf.d

  volumes:
    - name: nginx-config-volume
      configMap:
        name: nginx-config
```

Apply:

```bash
kubectl apply -f nginx-config-pod.yaml
```

Check the Pod:

```bash
kubectl get pod nginx-config-pod
```

Check the mounted file:

```bash
kubectl exec nginx-config-pod -- ls -l /etc/nginx/conf.d
```

Read the configuration:

```bash
kubectl exec nginx-config-pod -- cat /etc/nginx/conf.d/default.conf
```

Test Nginx configuration:

```bash
kubectl exec nginx-config-pod -- nginx -t
```

---

## Test the `/health` Endpoint

Port-forward the Pod:

```bash
kubectl port-forward pod/nginx-config-pod 8080:80
```

In another terminal:

```bash
curl -s http://localhost:8080/health
```

Expected:

```text
healthy
```

## Environment Variable vs Volume Mount

| Method         | Application receives     | Example                          |
| -------------- | ------------------------ | -------------------------------- |
| `envFrom`      | Environment variables    | `APP_ENV=production`             |
| `secretKeyRef` | One environment variable | `DB_USER=admin`                  |
| Volume mount   | Files                    | `/etc/nginx/conf.d/default.conf` |

### Mental model

```text
                 Configuration
                       │
             ┌─────────┴─────────┐
             │                   │
        Needs a value?      Needs a file?
             │                   │
             ▼                   ▼
       Environment          Volume Mount
        Variable                 │
             │                   ▼
          envFrom             /etc/config/
```

---

# Task 4: Create a Secret

## What?

A **Secret** stores sensitive information such as:

* Database usernames
* Database passwords
* API tokens
* Credentials
* TLS certificates

For this task:

```text
DB_USER=admin
DB_PASSWORD=s3cureP@ssw0rd
```

## Why?

Sensitive information should not be stored in a ConfigMap because ConfigMaps are intended for non-sensitive configuration.

A Secret provides Kubernetes-specific mechanisms for handling sensitive values, including access control and optional encryption at rest.

**Important:** Base64 itself does not provide security.

## How?

Create the Secret:

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD='s3cureP@ssw0rd'
```

Check the Secret:

```bash
kubectl get secret db-credentials
```

View the YAML:

```bash
kubectl get secret db-credentials -o yaml
```

You will see something similar to:

```yaml
data:
  DB_PASSWORD: ...
  DB_USER: ...
```

The values under `data` are Base64 encoded.

---

## Decode a Secret Value

Get the encoded password:

```bash
kubectl get secret db-credentials \
  -o jsonpath='{.data.DB_PASSWORD}'
```

Decode it:

```bash
kubectl get secret db-credentials \
  -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode
```

Expected:

```text
s3cureP@ssw0rd
```

You can also encode a value yourself:

```bash
echo -n 's3cureP@ssw0rd' | base64
```

Decode:

```bash
echo -n '<base64-value>' | base64 --decode
```

## Why `echo -n`?

Without `-n`:

```bash
echo "password" | base64
```

the newline added by `echo` can also be encoded.

Use:

```bash
echo -n "password" | base64
```

to encode exactly the password.

---

# Task 5: Use Secrets in a Pod

## What?

Secrets can be consumed by a Pod as:

1. Environment variables
2. Mounted files

This task uses both methods.

## Why?

Different applications consume credentials differently.

For example:

```python
os.getenv("DB_USER")
```

expects an environment variable.

Another application might expect:

```text
/etc/db-credentials/DB_PASSWORD
```

as a file.

---

## Part 1: Inject `DB_USER` Using `secretKeyRef`

Create `secret-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
    - name: app
      image: busybox:latest

      command: ["sh", "-c"]
      args:
        - |
          echo "DB_USER=$DB_USER"
          sleep 3600

      env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: DB_USER

      volumeMounts:
        - name: db-credentials-volume
          mountPath: /etc/db-credentials
          readOnly: true

  volumes:
    - name: db-credentials-volume
      secret:
        secretName: db-credentials
```

Apply:

```bash
kubectl apply -f secret-pod.yaml
```

Check:

```bash
kubectl get pod secret-pod
```

Check the environment variable:

```bash
kubectl exec secret-pod -- printenv DB_USER
```

Expected:

```text
admin
```

---

## Understanding `secretKeyRef`

```yaml
env:
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_USER
```

There are three important parts:

```text
name: DB_USER
        │
        └── Environment variable inside container

name: db-credentials
        │
        └── Kubernetes Secret name

key: DB_USER
        │
        └── Key inside the Secret
```

The environment variable name and Secret key **do not have to be the same**.

For example:

```yaml
env:
  - name: DATABASE_USERNAME
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_USER
```

The container would have:

```text
DATABASE_USERNAME=admin
```

---

## Part 2: Mount the Secret as a Volume

The same Pod contains:

```yaml
volumeMounts:
  - name: db-credentials-volume
    mountPath: /etc/db-credentials
    readOnly: true
```

And:

```yaml
volumes:
  - name: db-credentials-volume
    secret:
      secretName: db-credentials
```

This creates files inside the container.

Because the Secret contains:

```text
DB_USER
DB_PASSWORD
```

the Pod gets:

```text
/etc/db-credentials/DB_USER
/etc/db-credentials/DB_PASSWORD
```

---

## Verify the Mounted Files

List the directory:

```bash
kubectl exec secret-pod -- ls -l /etc/db-credentials
```

Read `DB_USER`:

```bash
kubectl exec secret-pod -- cat /etc/db-credentials/DB_USER
```

Expected:

```text
admin
```

Read `DB_PASSWORD`:

```bash
kubectl exec secret-pod -- cat /etc/db-credentials/DB_PASSWORD
```

Expected:

```text
s3cureP@ssw0rd
```

### Important

The mounted file contains the **decoded plaintext value**, not the Base64 value.

```text
Secret data:

DB_PASSWORD
    │
    ▼
Base64 representation in Kubernetes API
    │
    ▼
Kubernetes decodes it for the mounted volume
    │
    ▼
/etc/db-credentials/DB_PASSWORD
    │
    ▼
s3cureP@ssw0rd
```

---

# Task 6: Update a ConfigMap and Observe Propagation

## What?

This task demonstrates what happens when a ConfigMap changes while a Pod is already running.

We will create:

```text
message=hello
```

Then change it to:

```text
message=world
```

without restarting the Pod.

## Why?

This is an important difference between:

* ConfigMap mounted as a volume
* ConfigMap used as an environment variable

A volume-mounted ConfigMap can be updated by Kubernetes after the ConfigMap changes.

Environment variables are populated when the container starts and do not automatically change when the ConfigMap changes.

---

## Step 1: Create the ConfigMap

Create `live-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: live-config
data:
  message: hello
```

Apply:

```bash
kubectl apply -f live-config.yaml
```

Verify:

```bash
kubectl get configmap live-config -o yaml
```

---

## Step 2: Create a Pod That Reads the File

Create `live-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: live-pod
spec:
  containers:
    - name: app
      image: busybox:latest

      command: ["sh", "-c"]
      args:
        - |
          while true; do
            echo "message=$(cat /etc/config/message)"
            sleep 5
          done

      volumeMounts:
        - name: config-volume
          mountPath: /etc/config

  volumes:
    - name: config-volume
      configMap:
        name: live-config
```

Apply:

```bash
kubectl apply -f live-pod.yaml
```

Check the Pod:

```bash
kubectl get pod live-pod
```

Watch the logs:

```bash
kubectl logs -f live-pod
```

Expected:

```text
message=hello
message=hello
message=hello
```

The command:

```bash
sleep 5
```

causes the container to wait five seconds before reading the file again.

---

## Step 3: Update the ConfigMap

Run:

```bash
kubectl patch configmap live-config \
  --type merge \
  -p '{"data":{"message":"world"}}'
```

Verify:

```bash
kubectl get configmap live-config -o yaml
```

You should now see:

```yaml
data:
  message: world
```

---

## Step 4: Wait for the Volume to Update

Continue watching:

```bash
kubectl logs -f live-pod
```

After Kubernetes propagates the update, the output should change from:

```text
message=hello
```

to:

```text
message=world
```

You can also check the mounted file directly:

```bash
kubectl exec live-pod -- cat /etc/config/message
```

Expected:

```text
world
```

The Pod itself does not need to be restarted.

---

## How ConfigMap Volume Updates Work

The flow is:

```text
             ConfigMap
           live-config
               │
               │
        message=hello
               │
               ▼
          Pod volume
               │
               ▼
     /etc/config/message
               │
               ▼
             hello
```

After the update:

```text
             ConfigMap
           live-config
               │
               │
        message=world
               │
               ▼
          Pod volume
               │
               ▼
     /etc/config/message
               │
               ▼
             world
```

The update is **eventually consistent**, not instantaneous. Kubernetes periodically refreshes the projected ConfigMap volume, so it can take some time for the new value to appear.

---

## Environment Variables Do Not Automatically Update

Suppose a Pod uses:

```yaml
envFrom:
  - configMapRef:
      name: live-config
```

When the container starts:

```text
ConfigMap
message=hello
     │
     ▼
Container starts
     │
     ▼
Environment variable
message=hello
```

If the ConfigMap later changes:

```text
message=hello
       ↓
message=world
```

the already-running container's environment variable remains:

```text
message=hello
```

A Pod/container restart is normally required to get the new environment variable value.

---

# Task 7: Clean Up

## What?

Delete the Kubernetes resources created during Day 54.

## Why?

Cleaning up prevents unused Pods, ConfigMaps, and Secrets from remaining in your cluster.

This is especially important when using cloud Kubernetes clusters because unnecessary resources can consume resources and potentially increase costs.

## How?

Delete the Pods:

```bash
kubectl delete pod app-config-pod
kubectl delete pod nginx-config-pod
kubectl delete pod secret-pod
kubectl delete pod live-pod
```

Delete the ConfigMaps:

```bash
kubectl delete configmap app-config
kubectl delete configmap nginx-config
kubectl delete configmap live-config
```

Delete the Secret:

```bash
kubectl delete secret db-credentials
```

Verify:

```bash
kubectl get pods
kubectl get configmaps
kubectl get secrets
```

---

# ConfigMap vs Secret

| Feature                 | ConfigMap                        | Secret                           |
| ----------------------- | -------------------------------- | -------------------------------- |
| Purpose                 | Non-sensitive configuration      | Sensitive configuration          |
| Example                 | App environment                  | DB password                      |
| Environment variable    | Yes                              | Yes                              |
| Volume mount            | Yes                              | Yes                              |
| Base64 required         | No                               | `data` values are Base64 encoded |
| Base64 encryption?      | No                               | **No**                           |
| RBAC can control access | Yes                              | Yes                              |
| Encryption at rest      | Depends on cluster configuration | Can be enabled/configured        |

---

# `envFrom` vs `secretKeyRef` vs Volume

This is one of the most important concepts from Day 54.

## `envFrom`

Use when you want **all keys** as environment variables.

```yaml
envFrom:
  - configMapRef:
      name: app-config
```

If the ConfigMap contains:

```text
APP_ENV
APP_DEBUG
APP_PORT
```

all three become environment variables.

---

## `secretKeyRef`

Use when you want **one specific Secret key**.

```yaml
env:
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_USER
```

Only `DB_USER` is injected.

---

## Volume Mount

Use when the application needs configuration as **files**.

```yaml
volumeMounts:
  - name: config-volume
    mountPath: /etc/config

volumes:
  - name: config-volume
    configMap:
      name: live-config
```

The ConfigMap key:

```text
message
```

becomes:

```text
/etc/config/message
```

---

# The 2 × 2 Mental Model

First ask:

> **Is the data sensitive?**

Then ask:

> **Does the application need a value or a file?**

|                    | Application needs a value                 | Application needs a file |
| ------------------ | ----------------------------------------- | ------------------------ |
| **Normal data**    | ConfigMap + `envFrom` / `configMapKeyRef` | ConfigMap + volume       |
| **Sensitive data** | Secret + `envFrom` / `secretKeyRef`       | Secret + volume          |

Examples:

```text
APP_ENV=production
        ↓
ConfigMap + environment variable
```

```text
DB_PASSWORD
        ↓
Secret + environment variable
```

```text
nginx.conf
        ↓
ConfigMap + volume
```

```text
TLS certificate
        ↓
Secret + volume
```

---

# Base64: Encoding Is Not Encryption

A common Kubernetes beginner mistake is thinking:

> "Secret uses Base64, so my password is encrypted."

This is **incorrect**.

Base64 is simply an encoding format.

For example:

```bash
echo -n "my-password" | base64
```

produces:

```text
bXktcGFzc3dvcmQ=
```

Anyone can decode it:

```bash
echo -n "bXktcGFzc3dvcmQ=" | base64 --decode
```

Result:

```text
my-password
```

Therefore:

```text
Base64 ≠ Encryption
```

Kubernetes Secrets provide a mechanism for storing and distributing sensitive values, but their security depends on things such as:

* RBAC
* Kubernetes API access controls
* Encryption at rest configuration
* Node security
* Pod/container permissions
* Proper secret management practices

---

# Common Mistakes

## 1. Using ConfigMap for passwords

Incorrect:

```yaml
kind: ConfigMap
data:
  DB_PASSWORD: mypassword
```

Use a Secret for sensitive information.

---

## 2. Thinking Base64 means encrypted

Incorrect assumption:

```text
Base64 = encryption
```

Correct:

```text
Base64 = encoding
```

---

## 3. Confusing `envFrom` and `secretKeyRef`

`envFrom`:

```yaml
envFrom:
  - secretRef:
      name: db-credentials
```

injects **all keys**.

`secretKeyRef`:

```yaml
env:
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_USER
```

injects **one specific key**.

---

## 4. Confusing `volumes` and `volumeMounts`

Think:

```text
volumes
    ↓
What volume should exist?

volumeMounts
    ↓
Where should the volume appear inside the container?
```

Example:

```yaml
volumes:
  - name: config-volume
    configMap:
      name: live-config
```

defines the volume.

```yaml
volumeMounts:
  - name: config-volume
    mountPath: /etc/config
```

mounts it inside the container.

---

## 5. Using the wrong field name

Correct:

```yaml
volumeMounts:
```

Incorrect:

```yaml
volumesMounts:
```

---

## 6. Incorrect shell loop syntax

Correct:

```bash
while true; do
    echo "hello"
    sleep 5
done
```

Incorrect:

```bash
while true: do
```

Shell uses `;` or a newline before `do`, not `:`.

---

# Key Learnings

### ConfigMaps

I learned that ConfigMaps are used to store non-sensitive configuration separately from application images.

They can be created from:

```bash
--from-literal
```

or:

```bash
--from-file
```

---

### Secrets

I learned that Kubernetes Secrets are designed for sensitive values such as database credentials.

Secret values shown under:

```yaml
data:
```

are Base64 encoded.

Base64 is **not encryption**.

---

### Environment Variables

I learned that:

```yaml
envFrom:
```

can inject all keys from a ConfigMap or Secret.

For one specific key, I can use:

```yaml
secretKeyRef:
```

or:

```yaml
configMapKeyRef:
```

---

### Volume Mounts

I learned that when a ConfigMap or Secret is mounted as a volume:

```text
Key → File
```

For example:

```text
message
   ↓
/etc/config/message
```

Secret mounted files contain the **decoded plaintext value**, not the Base64 representation.

---

### Configuration Updates

I learned that a ConfigMap mounted as a volume can receive updates while the Pod is running.

Environment variables do not automatically update because they are established when the container starts.

---

# Final Mental Model

```text
                         Kubernetes Configuration
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
               ConfigMap                     Secret
                    │                           │
             Non-sensitive                  Sensitive
                    │                           │
              ┌─────┴─────┐              ┌─────┴─────┐
              │           │              │           │
           Env vars     Volume         Env vars     Volume
              │           │              │           │
           envFrom       Files        secretKeyRef   Files
              │           │              │           │
              ▼           ▼              ▼           ▼
          APP_ENV     nginx.conf      DB_USER    DB_PASSWORD
```

## Most Important Rule

> **ConfigMap vs Secret tells you WHAT kind of data you have.**

> **Environment variable vs volume tells you HOW the application consumes that data.**

---

# Interview Questions

### 1. What is a ConfigMap?

A ConfigMap stores non-sensitive configuration data as key-value pairs and allows Pods to consume that configuration without rebuilding the container image.

### 2. What is a Secret?

A Secret is a Kubernetes resource designed for storing sensitive information such as passwords, tokens, and credentials.

### 3. Is Kubernetes Secret Base64 encrypted?

No. Base64 is encoding, not encryption.

### 4. What is the difference between `envFrom` and `secretKeyRef`?

`envFrom` imports all keys from a ConfigMap or Secret, while `secretKeyRef` allows a specific key to be injected as an environment variable.

### 5. What happens when a ConfigMap mounted as a volume is updated?

Kubernetes eventually updates the projected volume, so the application can see the new file contents without necessarily restarting the Pod.

### 6. Do ConfigMap environment variables automatically update?

No. Environment variables are populated when the container starts. The Pod/container normally needs to be restarted to receive the updated value.

### 7. When should you use a volume instead of an environment variable?

Use a volume when the application expects configuration as a file, such as an Nginx configuration file, certificate, or application configuration file.

---

# Day 54 Summary

Today I learned how Kubernetes separates application configuration from container images.

I practiced:

* Creating ConfigMaps from literals
* Creating ConfigMaps from files
* Using ConfigMaps as environment variables
* Mounting ConfigMaps as volumes
* Creating Secrets
* Encoding and decoding Base64 values
* Using `secretKeyRef`
* Mounting Secrets as volumes
* Understanding plaintext mounted Secret values
* Updating ConfigMaps
* Observing ConfigMap volume propagation
* Understanding why environment variables do not automatically update
* Cleaning up Kubernetes resources

The main concept I learned is:

```text
Configuration
     │
     ├── Non-sensitive → ConfigMap
     │
     └── Sensitive     → Secret
                              │
                 ┌────────────┴────────────┐
                 │                         │
             Environment                Volume
              Variable                   Mount
                 │                         │
             Value-based               File-based
```
