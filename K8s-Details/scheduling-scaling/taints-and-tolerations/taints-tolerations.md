# Kubernetes Taints & Tolerations 

Taints and Tolerations are used to **control where Pods can run**.

Think of it like this:

* **Node = House**
* **Pod = Guest**
* **Taint = "No Entry" board on the house**
* **Toleration = Special permission pass for the guest**

Without permission, the Pod cannot stay on that Node.

---

## Why Do We Need Taints?

Suppose you have 3 nodes:

```text
Node1 --> Application Pods
Node2 --> Database Pods
Node3 --> GPU Workloads
```

You don't want normal application Pods running on Node3.

Add a taint to Node3:

```bash
kubectl taint nodes node3 gpu=true:NoSchedule
```

Now Node3 says:

```text
Only Pods that tolerate gpu=true
can run here.
```

---

## Architecture Diagram

```text
                    Scheduler
                        |
                        v

+------------+   +------------+   +------------+
|   Node1    |   |   Node2    |   |   Node3    |
|            |   |            |   | Tainted    |
| App Pods   |   | DB Pods    |   | gpu=true   |
|            |   |            |   | NoSchedule |
+------------+   +------------+   +------------+
                                        ^
                                        |
                               Only Pods with
                                Toleration
```

---

# Taint Syntax

```bash
kubectl taint nodes <node-name> key=value:effect
```

Example:

```bash
kubectl taint nodes worker1 env=prod:NoSchedule
```

Components:

| Part       | Meaning |
| ---------- | ------- |
| env        | Key     |
| prod       | Value   |
| NoSchedule | Effect  |

---

# Taint Effects

## 1. NoSchedule

New Pods will not be scheduled.

```bash
kubectl taint nodes worker1 env=prod:NoSchedule
```

```text
Pod without toleration
        |
        X
Cannot run
```

---

## 2. PreferNoSchedule

Soft restriction.

Scheduler tries to avoid the node.

```bash
kubectl taint nodes worker1 env=prod:PreferNoSchedule
```

```text
Avoid this node if possible
```

Pod may still run there if needed.

---

## 3. NoExecute

Most strict effect.

```bash
kubectl taint nodes worker1 env=prod:NoExecute
```

Effects:

* New Pods cannot be scheduled.
* Existing Pods are evicted.

```text
Node gets NoExecute
       |
       v
Existing Pods removed
```

---

# View Taints

Check node taints:

```bash
kubectl describe node worker1
```

Output:

```yaml
Taints:
  env=prod:NoSchedule
```

---

# Remove Taint

Add a minus (-) at the end.

```bash
kubectl taint nodes worker1 env=prod:NoSchedule-
```

Verify:

```bash
kubectl describe node worker1
```

---

# What is a Toleration?

A Pod uses a toleration to say:

```text
I am allowed to run on a tainted node.
```

Example Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx

  tolerations:
  - key: "env"
    operator: "Equal"
    value: "prod"
    effect: "NoSchedule"
```

---

# Complete Example

## Step 1: Add Taint

```bash
kubectl taint nodes worker1 env=prod:NoSchedule
```

Node:

```text
worker1
   |
   +--> env=prod:NoSchedule
```

---

## Step 2: Create Pod Without Toleration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  containers:
  - name: nginx
    image: nginx
```

Result:

```text
Pending
```

Check:

```bash
kubectl describe pod pod1
```

You will see:

```text
node had taint {env: prod}
```

---

## Step 3: Create Pod With Toleration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod2
spec:
  containers:
  - name: nginx
    image: nginx

  tolerations:
  - key: "env"
    operator: "Equal"
    value: "prod"
    effect: "NoSchedule"
```

Result:

```text
Running on worker1
```

---

# Important Interview Question

### Does toleration force a Pod onto a node?

**No.**

Toleration only allows the Pod to run on that node.

```text
Taint
  +
Toleration
      =
Permission
```

It does **not** guarantee scheduling there.

For guaranteed placement, use:

* NodeSelector
* Node Affinity

along with Taints/Tolerations.

---

# Real-World Use Cases

| Scenario          | Usage                        |
| ----------------- | ---------------------------- |
| Dedicated DB Node | Taint DB node                |
| GPU Server        | Taint GPU node               |
| Production Nodes  | Taint Prod nodes             |
| Critical Apps     | Toleration for critical Pods |
| Maintenance Node  | NoExecute taint              |

---

# Quick Commands Cheat Sheet

```bash
# Add taint
kubectl taint nodes worker1 env=prod:NoSchedule

# View taints
kubectl describe node worker1

# Remove taint
kubectl taint nodes worker1 env=prod:NoSchedule-

# List nodes
kubectl get nodes

# Check pod scheduling issue
kubectl describe pod <pod-name>
```

## Memory Trick

```text
Taint = Push Pods Away
Toleration = Allow Pods In
Node Affinity = Pull Pods Toward Node
```

```text
Taint      → Node Side Rule
Toleration → Pod Side Permission
Affinity   → Pod Side Preference
```

This is the most common Kubernetes scheduling combination used in production:

```text
Taint + Toleration + Node Affinity
```

to create dedicated nodes for databases, monitoring, logging, GPU workloads, and critical applications.
