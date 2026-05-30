Let's break this DaemonSet YAML line by line in a beginner-friendly way.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-ds
  labels:
    env: demo

spec:
  template:
    metadata:
      labels:
        env: demo
      name: nginx

    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80

  selector:
    matchLabels:
      env: demo
```

---

# 1. What is this YAML doing?

It tells Kubernetes:

> "Run one Nginx Pod on every node in the cluster."

Example:

```text
3 Nodes Cluster

Node1  → nginx Pod
Node2  → nginx Pod
Node3  → nginx Pod
```

---

# 2. apiVersion

```yaml
apiVersion: apps/v1
```

Tells Kubernetes which API version to use for DaemonSet.

```text
apps
 └── v1
      └── DaemonSet
```

Most workloads use:

```yaml
apps/v1
```

Examples:

* Deployment
* DaemonSet
* StatefulSet

---

# 3. kind

```yaml
kind: DaemonSet
```

Specifies the resource type.

Other examples:

```yaml
kind: Pod
kind: Deployment
kind: Service
kind: DaemonSet
```

Here:

```text
Create a DaemonSet
```

---

# 4. metadata

```yaml
metadata:
  name: nginx-ds
```

DaemonSet name:

```text
nginx-ds
```

Check it:

```bash
kubectl get ds
```

Output:

```text
nginx-ds
```

---

# 5. Labels

```yaml
labels:
  env: demo
```

A label is simply a key-value pair.

```text
env = demo
```

Think of labels as tags.

```text
Pod
 └── env=demo
```

Used for:

* Selection
* Filtering
* Grouping

---

# 6. spec

```yaml
spec:
```

Defines:

```text
How should Kubernetes create the DaemonSet?
```

---

# 7. template

```yaml
template:
```

This is the Pod blueprint.

Think:

```text
DaemonSet
    │
    ▼
Pod Template
    │
    ▼
Actual Pods
```

---

# 8. Pod Metadata

```yaml
metadata:
  labels:
    env: demo
```

Every Pod created by this DaemonSet gets:

```text
env=demo
```

Example:

```bash
kubectl get pods --show-labels
```

Output:

```text
nginx-abc   env=demo
nginx-def   env=demo
nginx-ghi   env=demo
```

---

# 9. Pod Name

```yaml
name: nginx
```

Inside `template.metadata`, this field is generally unnecessary.

Usually write:

```yaml
template:
  metadata:
    labels:
      env: demo
```

Kubernetes automatically generates Pod names:

```text
nginx-ds-abc12
nginx-ds-xyz34
```

---

# 10. Pod Spec

```yaml
spec:
```

Defines what runs inside the Pod.

---

# 11. Container Definition

```yaml
containers:
```

List of containers.

Here only one:

```yaml
- image: nginx
  name: nginx
```

Meaning:

```text
Container Name = nginx
Image = nginx
```

Kubernetes pulls:

```text
nginx:latest
```

from Docker Hub.

---

# 12. Port

```yaml
ports:
- containerPort: 80
```

Nginx listens on:

```text
Port 80
```

Diagram:

```text
Browser
   │
   ▼
Pod
   │
   ▼
Nginx Container
   │
   ▼
Port 80
```

Note:

```yaml
containerPort: 80
```

is mainly documentation and visibility. It does not expose the Pod externally.

For external access you need a Service.

---

# 13. Selector

```yaml
selector:
  matchLabels:
    env: demo
```

Very important.

The DaemonSet manages Pods having:

```text
env=demo
```

---

## How Selector Works

```text
DaemonSet
    │
    ▼
selector:
 env=demo
    │
    ▼
Find Pods
 env=demo
```

The selector must match the Pod labels.

---

### Matching Example

Pod Labels:

```yaml
labels:
  env: demo
```

Selector:

```yaml
matchLabels:
  env: demo
```

✅ Match found

DaemonSet manages the Pod.

---

### Wrong Example

Pod Labels:

```yaml
labels:
  env: prod
```

Selector:

```yaml
matchLabels:
  env: demo
```

❌ No match

DaemonSet won't manage those Pods.

---

# Complete Flow

```text
DaemonSet nginx-ds
          │
          ▼
Selector env=demo
          │
          ▼
Pod Template
          │
          ▼
Nginx Container
          │
          ▼
Port 80
          │
          ▼
One Pod on Every Node
```

---

# Cluster Example

Suppose:

```text
Cluster
├── Node1
├── Node2
└── Node3
```

After:

```bash
kubectl apply -f daemonset.yaml
```

Result:

```text
Cluster
├── Node1
│   └── nginx Pod
│
├── Node2
│   └── nginx Pod
│
└── Node3
    └── nginx Pod
```

---

# Verify

```bash
kubectl get ds
```

```bash
kubectl get pods -o wide
```

```bash
kubectl describe ds nginx-ds
```

---

### CKA Exam Tip

The most commonly forgotten part is:

```yaml
selector:
  matchLabels:
    env: demo
```

must match

```yaml
template:
  metadata:
    labels:
      env: demo
```

If they don't match, Kubernetes will reject the DaemonSet.

