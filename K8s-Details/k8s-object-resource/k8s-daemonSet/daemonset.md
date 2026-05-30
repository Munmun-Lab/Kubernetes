# DaemonSet - Complete Beginner-Friendly Guide

## What is a DaemonSet?

A **DaemonSet** ensures that **one Pod runs on every node** in a Kubernetes cluster.

Think:

```text
Deployment
    = Number of Pods decided by you

DaemonSet
    = Number of Pods decided by number of Nodes
```

---

# Why Do We Need DaemonSet?

Suppose your cluster has:

```text
Node1
Node2
Node3
```

You want a log collector on every node.

Without DaemonSet:

```text
Node1 → Log Collector
Node2 → No Log Collector
Node3 → No Log Collector
```

Not good.

With DaemonSet:

```text
Node1 → Log Collector
Node2 → Log Collector
Node3 → Log Collector
```

Perfect.

---

# Real-Life Analogy

Imagine a company with 3 offices:

```text
Office Kolkata
Office Delhi
Office Mumbai
```

Every office needs:

* CCTV
* Security Guard
* Cleaning Staff

You don't manually assign them.

DaemonSet automatically places one on every office (node).

---

# Architecture Diagram

```text
                Kubernetes Cluster

 ┌─────────────────────────────────────┐
 │                                     │
 │  Node 1                             │
 │  ┌─────────────────────────────┐    │
 │  │ DaemonSet Pod              │    │
 │  └─────────────────────────────┘    │
 │                                     │
 │  Node 2                             │
 │  ┌─────────────────────────────┐    │
 │  │ DaemonSet Pod              │    │
 │  └─────────────────────────────┘    │
 │                                     │
 │  Node 3                             │
 │  ┌─────────────────────────────┐    │
 │  │ DaemonSet Pod              │    │
 │  └─────────────────────────────┘    │
 │                                     │
 └─────────────────────────────────────┘
```

---

# DaemonSet Flowchart

```text
Create DaemonSet
       │
       ▼
Kubernetes Checks Nodes
       │
       ▼
Node1 → Create Pod
Node2 → Create Pod
Node3 → Create Pod
       │
       ▼
New Node Added?
       │
   Yes ▼
Create New Pod
       │
       ▼
Keep One Pod Per Node
```

---

# Basic DaemonSet YAML

```yaml
apiVersion: apps/v1
kind: DaemonSet

metadata:
  name: nginx-ds

spec:
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

Apply:

```bash
kubectl apply -f daemonset.yaml
```

---

# What Happens Internally?

Suppose:

```text
3 Nodes
```

```bash
kubectl apply -f daemonset.yaml
```

Kubernetes automatically creates:

```text
Node1 → nginx Pod
Node2 → nginx Pod
Node3 → nginx Pod
```

---

# Verify DaemonSet

## List DaemonSets

```bash
kubectl get ds
```

Output:

```text
NAME       DESIRED CURRENT READY
nginx-ds   3       3       3
```

### Meaning

```text
DESIRED = Number of Nodes

CURRENT = Pods Created

READY = Running Pods
```

---

## See Pods

```bash
kubectl get pods -o wide
```

Example:

```text
NAME                 NODE
nginx-ds-abc12       worker1
nginx-ds-def34       worker2
nginx-ds-xyz56       worker3
```

---

# New Node Scenario

Before:

```text
Node1
Node2
Node3
```

DaemonSet creates:

```text
Pod1
Pod2
Pod3
```

Add:

```text
Node4
```

Automatically:

```text
Node4
 └── Pod4
```

No manual action needed.

---

# DaemonSet vs Deployment

| Feature        | Deployment           | DaemonSet                 |
| -------------- | -------------------- | ------------------------- |
| Replica Count  | Fixed                | Per Node                  |
| Scaling        | Manual               | Automatic with Nodes      |
| Use Case       | Applications         | Node Services             |
| New Node Added | No Pod automatically | Pod automatically created |

---

## Deployment

```yaml
replicas: 3
```

Result:

```text
Node1 → Pod
Node2 → Pod
Node3 → Pod
```

Only 3 Pods.

---

## DaemonSet

```text
10 Nodes
=
10 Pods
```

One Pod per Node.

---

# Most Common DaemonSet Use Cases

## 1. Log Collection

```text
Node Logs
    │
    ▼
Fluent Bit Pod
    │
    ▼
ELK / Splunk
```

Commonly done with:

* Fluent Bit
* Fluentd

---

## 2. Monitoring

```text
Node Metrics
     │
     ▼
Node Exporter
     │
     ▼
Prometheus
```

Example:

* Prometheus Node Exporter

---

## 3. Networking

Every node needs network rules.

Examples:

* Calico
* Flannel
* kube-proxy

---

## 4. Security

```text
Node
 │
 ▼
Security Agent
 │
 ▼
Threat Detection
```

Example:

* Falco

---

# Node Selector Example

Run only on Linux nodes.

```yaml
spec:
  template:
    spec:
      nodeSelector:
        kubernetes.io/os: linux
```

Result:

```text
Linux Node → Pod Created
Windows Node → No Pod
```

---

# Taints and Tolerations

Control-plane nodes often have taints.

To run DaemonSet there:

```yaml
tolerations:
- operator: Exists
```

Result:

```text
Worker Nodes
Control Plane Node
       │
       ▼
DaemonSet Runs Everywhere
```

---

# Rolling Update

Change image:

```yaml
image: nginx:1.27
```

Apply:

```bash
kubectl apply -f daemonset.yaml
```

Update flow:

```text
Node1 Pod Updated
      │
      ▼
Node2 Pod Updated
      │
      ▼
Node3 Pod Updated
```

---

# Delete DaemonSet

```bash
kubectl delete ds nginx-ds
```

or

```bash
kubectl delete -f daemonset.yaml
```

All Pods created by the DaemonSet are deleted.

---

# Common Commands

```bash
kubectl get ds

kubectl describe ds nginx-ds

kubectl get pods -o wide

kubectl delete ds nginx-ds

kubectl apply -f daemonset.yaml

kubectl rollout status ds/nginx-ds
```

---

# Interview Questions

### What is a DaemonSet?

A DaemonSet ensures that a Pod runs on every node (or selected nodes) in a Kubernetes cluster.

### What happens when a new node joins?

A new DaemonSet Pod is automatically created on that node.

### Can a DaemonSet run on specific nodes?

Yes, using:

* nodeSelector
* node affinity
* taints and tolerations

### Difference between Deployment and DaemonSet?

```text
Deployment
   = Fixed number of Pods

DaemonSet
   = One Pod per Node
```

---

# Easy Memory Trick

```text
Deployment
    = Application

StatefulSet
    = Database

DaemonSet
    = One Pod on Every Node
```

### Final Visual

```text
Cluster
│
├── Node1
│   └── DaemonSet Pod
│
├── Node2
│   └── DaemonSet Pod
│
├── Node3
│   └── DaemonSet Pod
│
└── Node4
    └── DaemonSet Pod
```

**Golden Rule:**
When you hear **"run this service on every node"**, think **DaemonSet**.
