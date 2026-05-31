# Kubernetes Pod Priority & Pod Disruption

These are advanced Kubernetes scheduling and availability concepts used in **production-grade clusters** to ensure:

* Critical applications run first
* Important Pods survive resource shortages
* Maintenance/upgrades do not break applications
* High availability is maintained during disruptions

---

# 1. Pod Priority

## What is Pod Priority?

Pod Priority tells Kubernetes:

> “Which Pod is more important?”

When cluster resources are limited (CPU/RAM), Kubernetes schedules **higher priority Pods first**.

Lower-priority Pods can even be **evicted (removed)** if necessary.

---

# Why Pod Priority is Important?

Imagine:

| Pod        | Importance |
| ---------- | ---------- |
| Database   | Critical   |
| Monitoring | Medium     |
| Test App   | Low        |

If cluster memory becomes full:

* Kubernetes keeps Database Pod alive
* May remove Test App Pod
* Monitoring survives if possible

This is controlled using **PriorityClass**.

---

# Pod Priority Flow

```text
User Creates Pod
        |
        v
Scheduler Checks Resources
        |
        v
Compare Pod Priorities
        |
        +---- High Priority Pod
        |          |
        |          v
        |    Scheduled First
        |
        +---- Low Priority Pod
                   |
                   v
          Wait / Evicted if needed
```

---

# PriorityClass

A `PriorityClass` defines the importance value.

Higher number = Higher priority.

---

# Example Priority Levels

| Application   | Priority |
| ------------- | -------- |
| Production DB | 100000   |
| API Server    | 50000    |
| Monitoring    | 10000    |
| Dev/Test      | 100      |

---

# Kubernetes Built-in Priorities

| PriorityClass             | Purpose                     |
| ------------------------- | --------------------------- |
| `system-node-critical`    | Critical node components    |
| `system-cluster-critical` | Critical cluster components |

Used internally by Kubernetes.

---

# PriorityClass YAML Example

## Create PriorityClass

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 100000
globalDefault: false
description: "High priority production workloads"
```

Apply:

```bash
kubectl apply -f priorityclass.yaml
```

---

# Use Priority in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-high
spec:
  priorityClassName: high-priority

  containers:
  - name: nginx
    image: nginx
```

---

# How Scheduling Works

## Scenario

Cluster has only:

```text
2 CPU Free
```

### Existing Pod

```text
Low Priority App
CPU = 2
Priority = 100
```

### New Pod

```text
Production API
CPU = 2
Priority = 100000
```

Result:

```text
Scheduler evicts low priority Pod
High priority Pod gets scheduled
```

This process is called:

# Preemption

---

# Pod Preemption

## Definition

Kubernetes can remove lower-priority Pods to make room for higher-priority Pods.

---

# Preemption Flow

```text
High Priority Pod Pending
          |
          v
No Resources Available
          |
          v
Scheduler Finds Lower Priority Pods
          |
          v
Evict Lower Priority Pods
          |
          v
Schedule High Priority Pod
```

---

# Important Notes

| Point                   | Explanation                  |
| ----------------------- | ---------------------------- |
| Preemption is automatic | Scheduler handles it         |
| Same priority Pods      | No eviction                  |
| Stateful apps           | Use carefully                |
| Not immediate           | Graceful termination happens |

---

# Real Production Use Cases

| Use Case           | Example       |
| ------------------ | ------------- |
| Critical workloads | Databases     |
| Monitoring         | Prometheus    |
| Logging            | Fluentd       |
| Ingress Controller | NGINX Ingress |
| Service Mesh       | Istio         |
| Batch Jobs         | Low priority  |

---

# Best Practice

## Recommended Priority Strategy

| Environment     | Priority |
| --------------- | -------- |
| System Critical | 1000000  |
| Production      | 100000   |
| Staging         | 10000    |
| Dev             | 100      |
| Batch Jobs      | 10       |

---
