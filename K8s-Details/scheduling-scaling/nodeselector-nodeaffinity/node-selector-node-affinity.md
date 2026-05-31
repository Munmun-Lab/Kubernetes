# Node Selector vs Node Affinity

Both are used to control **which node a Pod should run on**.

---

# Node Selector

## Definition

`nodeSelector` is the simplest way to tell Kubernetes:

> "Run this Pod only on nodes that have a specific label."

---

## Step 1: Label the Node

Suppose you have a node:

```bash
kubectl label node worker1 env=prod
```

Verify:

```bash
kubectl get nodes --show-labels
```

Output:

```text
worker1   env=prod
worker2   env=dev
```

---

## Step 2: Use NodeSelector

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-selector
spec:
  nodeSelector:
    env: prod

  containers:
  - name: nginx
    image: nginx
```

### Flow

```text
Pod
 │
 ▼
nodeSelector
 env=prod
 │
 ▼
worker1
```

Result:

```text
Pod runs only on worker1
```

---

# Node Affinity

## Definition

Node Affinity is an advanced version of NodeSelector.

It provides:

* Multiple matching rules
* AND / OR conditions
* Preferred nodes
* Required nodes

---

## Types of Node Affinity

### 1. RequiredDuringSchedulingIgnoredDuringExecution

Mandatory rule.

```text
If node doesn't match
      ↓
Pod will NOT run
```

### 2. PreferredDuringSchedulingIgnoredDuringExecution

Soft rule.

```text
Try this node first
If unavailable
run elsewhere
```

---

# Example 1: Required Node Affinity

Label node:

```bash
kubectl label node worker1 env=prod
```

Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: env
            operator: In
            values:
            - prod

  containers:
  - name: nginx
    image: nginx
```

### Flow

```text
Pod
 │
 ▼
env IN (prod)
 │
 ▼
worker1
```

Result:

```text
Pod runs only on worker1
```

---

# Example 2: Preferred Node Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-preferred
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: env
            operator: In
            values:
            - prod

  containers:
  - name: nginx
    image: nginx
```

Meaning:

```text
Prefer env=prod node
If unavailable
schedule somewhere else
```

---

# Node Affinity Operators

| Operator     | Meaning         |
| ------------ | --------------- |
| In           | Match value     |
| NotIn        | Not match value |
| Exists       | Label exists    |
| DoesNotExist | Label absent    |
| Gt           | Greater than    |
| Lt           | Less than       |

---

## Example: Exists

```yaml
matchExpressions:
- key: gpu
  operator: Exists
```

Meaning:

```text
Run on any node having label gpu
```

---

## Example: NotIn

```yaml
matchExpressions:
- key: env
  operator: NotIn
  values:
  - dev
```

Meaning:

```text
Run everywhere except dev nodes
```

---

# Node Selector vs Node Affinity

| Feature              | NodeSelector | Node Affinity |
| -------------------- | ------------ | ------------- |
| Easy                 | ✅            | ❌             |
| Label Matching       | ✅            | ✅             |
| Multiple Rules       | ❌            | ✅             |
| AND/OR Conditions    | ❌            | ✅             |
| Preferred Scheduling | ❌            | ✅             |
| Production Use       | Limited      | Common        |

---

# Real-World Example

Dedicated Database Node:

### Label Node

```bash
kubectl label node worker1 role=database
```

### Taint Node

```bash
kubectl taint node worker1 dedicated=db:NoSchedule
```

### Database Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-db
spec:
  nodeSelector:
    role: database

  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "db"
    effect: "NoSchedule"

  containers:
  - name: mysql
    image: mysql:8.0
```

### Scheduling Logic

```text
worker1
│
├─ Label: role=database
│
└─ Taint: dedicated=db:NoSchedule
          ▲
          │
     Toleration
          │
      MySQL Pod
```

Result:

```text
Only MySQL Pod runs on worker1.
Application Pods cannot run there.
```

---

# Quick Memory Trick

```text
NodeSelector
    =
Exact Match

Node Affinity
    =
Smart Match

Taint
    =
Keep Pods Away

Toleration
    =
Allow Pods In
```

### Production Formula

```text
Node Label
     +
Node Affinity
     +
Taint
     +
Toleration
     =
Dedicated Kubernetes Workload Placement
```

This combination is commonly used for databases, monitoring tools, logging platforms, GPU nodes, and production-critical workloads.
