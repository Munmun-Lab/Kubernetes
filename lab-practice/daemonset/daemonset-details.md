# DaemonSet in Kubernetes

A **DaemonSet** ensures that **one Pod runs on every node** (or selected nodes) in a Kubernetes cluster.

---

### What is a daemonset?
- A daemon set is another type of Kubernetes object that controls pods. Unlike deployment, the DS automatically deploys 1 pod to each available node. You don't need to update the replica based on demand; the DS takes care of it by spinning X number of pods for X number of nodes.
- If you create a ds in a cluster of 5 nodes, then 5 pods will be created.
- If you add another node to the cluster, a new pod will be automatically created on the new node.

### Examples of daemonset
- kube-proxy
- calico
- weave-net
- monitoring agents etc

---

## Why Do We Need DaemonSet?

Normally:

```text
Deployment
│
├── Pod 1 → Node 1
├── Pod 2 → Node 2
└── Pod 3 → Node 1
```

Pods can run anywhere.

But sometimes you need **exactly one Pod on every node**.

Examples:

* Log collection
* Monitoring
* Security scanning
* Node management

This is where **DaemonSet** is used.

---

# DaemonSet Architecture

```text
Cluster
│
├── Node 1
│     └── Fluent Bit Pod
│
├── Node 2
│     └── Fluent Bit Pod
│
├── Node 3
│     └── Fluent Bit Pod
│
└── Node 4
      └── Fluent Bit Pod
```

One Pod per Node.

---

# Real-World Use Cases

### 1. Log Collection

Every node generates logs.

```text
Node 1 Logs ─┐
Node 2 Logs ─┼──► Fluent Bit DaemonSet
Node 3 Logs ─┘
                    │
                    ▼
                 ELK/Splunk
```

Common tools:

* Fluent Bit
* Fluentd
* Logstash

---

### 2. Monitoring

Run monitoring agents on every node.

```text
Node 1 → Monitoring Agent
Node 2 → Monitoring Agent
Node 3 → Monitoring Agent
```

Examples:

* Prometheus Node Exporter
* Datadog Agent

---

### 3. Security

Security agents on every node.

Examples:

* Falco
* Antivirus agents
* Compliance scanners

---

# DaemonSet vs Deployment

| Feature              | Deployment               | DaemonSet                 |
| -------------------- | ------------------------ | ------------------------- |
| Number of Pods       | User decides             | One per Node              |
| Scales with Replicas | Yes                      | No                        |
| New Node Added       | No new Pod automatically | Pod created automatically |
| Common Use           | Applications             | Node-level services       |

---

## Example

### Deployment

```yaml
replicas: 3
```

Cluster with 10 nodes:

```text
Node1  Pod
Node2  Pod
Node3  Pod

Remaining nodes: No Pod
```

---

### DaemonSet

Cluster with 10 nodes:

```text
Node1  Pod
Node2  Pod
Node3  Pod
Node4  Pod
Node5  Pod
Node6  Pod
Node7  Pod
Node8  Pod
Node9  Pod
Node10 Pod
```

---

# DaemonSet YAML

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset

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

Create:

```bash
kubectl apply -f daemonset.yaml
```

---

# Verify DaemonSet

### List DaemonSets

```bash
kubectl get ds
```

Output:

```text
NAME              DESIRED   CURRENT   READY
nginx-daemonset   3         3         3
```

Meaning:

```text
DESIRED = Nodes available
CURRENT = Pods created
READY   = Pods running
```

---

### Describe DaemonSet

```bash
kubectl describe ds nginx-daemonset
```

---

### View Pods

```bash
kubectl get pods -o wide
```

Output:

```text
nginx-abc   Node1
nginx-def   Node2
nginx-ghi   Node3
```

One Pod per node.

---

# What Happens When a New Node Is Added?

Suppose:

```text
Node1
Node2
Node3
```

DaemonSet Pods:

```text
Pod1
Pod2
Pod3
```

Now add:

```text
Node4
```

Kubernetes automatically creates:

```text
Pod4
```

No manual action required.

---

# Node Selector with DaemonSet

Run Pods only on specific nodes.

```yaml
spec:
  template:
    spec:
      nodeSelector:
        env: production
```

Flow:

```text
Node1 env=production   → Pod Created
Node2 env=production   → Pod Created
Node3 env=dev          → No Pod
```

---

# Tolerations in DaemonSet

Control-plane nodes are often tainted.

To run DaemonSet there:

```yaml
tolerations:
- operator: Exists
```

This is common for:

* Monitoring agents
* Network plugins
* Logging agents

---

# DaemonSet Update Process

When image changes:

```yaml
image: nginx:1.26
```

Apply:

```bash
kubectl apply -f daemonset.yaml
```

Kubernetes performs a rolling update:

```text
Node1 Pod Updated
      ↓
Node2 Pod Updated
      ↓
Node3 Pod Updated
```

---

# DaemonSet Update Strategy

```yaml
updateStrategy:
  type: RollingUpdate
```

Default strategy.

---

# Delete DaemonSet

Delete only DaemonSet:

```bash
kubectl delete ds nginx-daemonset
```

Delete YAML:

```bash
kubectl delete -f daemonset.yaml
```

---

# Common Kubernetes Components Running as DaemonSets

Many clusters run these as DaemonSets:

* kube-proxy
* Flannel
* Calico
* Fluent Bit
* Prometheus Node Exporter

---

# Interview Questions

### Q1: What is a DaemonSet?

A DaemonSet ensures that a copy of a Pod runs on every node (or selected nodes) in a Kubernetes cluster.

---

### Q2: When would you use a DaemonSet?

For node-level services such as:

* Logging
* Monitoring
* Security
* Networking

---

### Q3: What happens when a new node joins the cluster?

Kubernetes automatically schedules a DaemonSet Pod on that node.

---

### Q4: Difference Between Deployment and DaemonSet?

```text
Deployment
    └── Fixed number of replicas

DaemonSet
    └── One Pod per Node
```

---

# Easy Memory Trick

```text
Deployment
=
How many Pods?

DaemonSet
=
How many Nodes?
      ↓
One Pod on each Node
```

### Visual Summary

```text
Cluster
│
├── Node1
│     └── DaemonSet Pod
│
├── Node2
│     └── DaemonSet Pod
│
├── Node3
│     └── DaemonSet Pod
│
└── Node4
      └── DaemonSet Pod
```

**Rule to remember:**
**Deployment = Application workload**
**DaemonSet = Node-level workload (1 Pod per Node)**.
