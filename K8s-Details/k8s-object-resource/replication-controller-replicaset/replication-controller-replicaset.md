# ReplicationController & ReplicaSet in Kubernetes

Both **ReplicationController (RC)** and **ReplicaSet (RS)** are Kubernetes controllers used to ensure a specific number of Pod replicas are running.

---

# Main Purpose

They provide:

✅ High Availability
✅ Self-Healing
✅ Pod Replication
✅ Scaling

---

# Simple Idea

Example:

```text
Desired Pods = 3
Running Pods = 2
```

RC/RS automatically creates:

```text
1 more Pod
```

---

# Architecture

```text
ReplicationController / ReplicaSet
                ↓
             Manages
                ↓
              Pods
```

---

# What Happens if Pod Crashes?

```text
Pod deleted/crashed
        ↓
Controller detects mismatch
        ↓
New Pod created automatically
```

---

# ReplicationController (RC)

## Older Kubernetes Controller

ReplicationController is the older method used before ReplicaSet.

Today:

* Mostly replaced by ReplicaSet + Deployment

---

# ReplicationController YAML

```yaml
apiVersion: v1
kind: ReplicationController

metadata:
  name: nginx-rc

spec:
  replicas: 3

  selector:
    app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
      - name: nginx
        image: nginx
```

---

# Create ReplicationController

```bash
kubectl apply -f rc.yaml
```

---

# Check RC

```bash
kubectl get rc
```

---

# Describe RC

```bash
kubectl describe rc nginx-rc
```

---

# Scale RC

```bash
kubectl scale rc nginx-rc --replicas=5
```

---

# Delete RC

```bash
kubectl delete rc nginx-rc
```

---

# ReplicaSet (RS)

ReplicaSet is the modern replacement for ReplicationController.

It provides:
✅ Set-based selectors
✅ More powerful label matching
✅ Used internally by Deployments

---

# ReplicaSet YAML

```yaml
apiVersion: apps/v1
kind: ReplicaSet

metadata:
  name: nginx-rs

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
      - name: nginx
        image: nginx
```

---

# Create ReplicaSet

```bash
kubectl apply -f rs.yaml
```

---

# Check ReplicaSet

```bash
kubectl get rs
```

---

# Describe ReplicaSet

```bash
kubectl describe rs nginx-rs
```

---

# Scale ReplicaSet

```bash
kubectl scale rs nginx-rs --replicas=5
```

---

# Delete ReplicaSet

```bash
kubectl delete rs nginx-rs
```

---

# RC vs RS Selector Difference

---

## ReplicationController

Supports only:

* Equality-based selectors

Example:

```yaml
selector:
  app: nginx
```

---

## ReplicaSet

Supports:
✅ Equality-based
✅ Set-based selectors

Example:

```yaml
selector:
  matchExpressions:
  - key: env
    operator: In
    values:
    - prod
    - dev
```

---

# ReplicaSet Match Expressions

## In

```yaml
operator: In
```

---

## NotIn

```yaml
operator: NotIn
```

---

## Exists

```yaml
operator: Exists
```

---

## DoesNotExist

```yaml
operator: DoesNotExist
```

---

# ReplicaSet Advanced Example

```yaml
apiVersion: apps/v1
kind: ReplicaSet

metadata:
  name: frontend-rs

spec:
  replicas: 3

  selector:
    matchExpressions:
    - key: tier
      operator: In
      values:
      - frontend

  template:
    metadata:
      labels:
        tier: frontend

    spec:
      containers:
      - name: nginx
        image: nginx
```

---

# Self-Healing Example

Delete Pod manually:

```bash
kubectl delete pod <pod-name>
```

ReplicaSet immediately creates new Pod.

---

# Scaling Flow

```text
replicas: 3
       ↓
Change to 5
       ↓
ReplicaSet creates 2 more Pods
```

---

# Important Difference

# ReplicaSet does NOT provide:

❌ Rolling updates
❌ Rollbacks
❌ Deployment history

Deployment provides these features.

---

# Real Kubernetes Flow

In production:

```text
Deployment
    ↓ manages
ReplicaSet
    ↓ manages
Pods
```

Usually:

* We use Deployment
* Deployment automatically creates ReplicaSet

---

# Check Deployment-Owned ReplicaSets

```bash
kubectl get rs
```

Example:

```text
NAME                    DESIRED   CURRENT   READY
nginx-6d4cf56db6       3         3         3
```

---

# Labels & Selectors

ReplicaSet identifies Pods using labels.

Example:

```yaml
labels:
  app: nginx
```

Selector:

```yaml
selector:
  matchLabels:
    app: nginx
```

---

# Important Rule

Template labels MUST match selector labels.

Otherwise:

❌ ReplicaSet creation fails

---

# RC vs RS vs Deployment

| Feature             | RC  | RS            | Deployment |
| ------------------- | --- | ------------- | ---------- |
| Self-healing        | Yes | Yes           | Yes        |
| Scaling             | Yes | Yes           | Yes        |
| Set-based selectors | No  | Yes           | Yes        |
| Rolling updates     | No  | No            | Yes        |
| Rollback            | No  | No            | Yes        |
| Mostly used today   | No  | Rarely direct | Yes        |

---

# Quick Flow Comparison

## ReplicationController

```text
RC
 ↓
Pods
```

---

## ReplicaSet

```text
ReplicaSet
     ↓
Pods
```

---

## Deployment

```text
Deployment
     ↓
ReplicaSet
     ↓
Pods
```

---

# Important Commands Cheatsheet

```bash
###################################################
# REPLICATION CONTROLLER
###################################################

# Create RC
kubectl apply -f rc.yaml

# Get RC
kubectl get rc

# Describe RC
kubectl describe rc nginx-rc

# Scale RC
kubectl scale rc nginx-rc --replicas=5

# Delete RC
kubectl delete rc nginx-rc


###################################################
# REPLICASET
###################################################

# Create RS
kubectl apply -f rs.yaml

# Get RS
kubectl get rs

# Describe RS
kubectl describe rs nginx-rs

# Scale RS
kubectl scale rs nginx-rs --replicas=5

# Delete RS
kubectl delete rs nginx-rs

# Get Pods
kubectl get pods

# Delete Pod (self-healing test)
kubectl delete pod <pod-name>
```

---

# Interview Questions

## What is ReplicaSet?

ReplicaSet ensures desired number of Pod replicas are always running.

---

## Difference between RC and RS?

ReplicaSet supports:

* Set-based selectors

ReplicationController does not.

---

## Difference between ReplicaSet and Deployment?

Deployment manages ReplicaSets and provides:

* Rolling updates
* Rollbacks
* Deployment history

---

## Do we directly use ReplicaSet?

Rarely.

Usually Deployment creates ReplicaSet automatically.

---

# Best Practice

✅ Use Deployment instead of directly using ReplicaSet
✅ ReplicaSet mostly used internally by Deployment
✅ RC is mostly deprecated/legacy
✅ Use labels carefully
✅ Match selectors correctly

---

# Visual Summary

```text
OLD MODEL
ReplicationController
          ↓
         Pods


MODERN MODEL
Deployment
     ↓
ReplicaSet
     ↓
Pods
```
