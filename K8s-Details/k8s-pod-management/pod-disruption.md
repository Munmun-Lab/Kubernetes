# Pod Disruption

---

# What is Pod Disruption?

A disruption means:

> A Pod becomes unavailable.

This can happen intentionally or unintentionally.

---

# Types of Disruptions

| Type        | Example    |
| ----------- | ---------- |
| Voluntary   | Node drain |
| Involuntary | Node crash |

---

# Voluntary Disruption

These are controlled actions.

Examples:

* Cluster upgrade
* Node maintenance
* Node drain
* Autoscaling down
* Manual deletion

---

# Involuntary Disruption

Unexpected failures.

Examples:

* Hardware failure
* VM crash
* Kernel panic
* Power outage
* Network issue

---

# Pod Disruption Flow

```text
Node Maintenance Starts
          |
          v
kubectl drain node
          |
          v
Pods Need Eviction
          |
          v
Check PodDisruptionBudget
          |
    +-----+------+
    |            |
Allowed      Not Allowed
    |            |
    v            v
Evict Pod    Block Eviction
```

---

# PodDisruptionBudget (PDB)

## Definition

PDB protects applications from having too many Pods unavailable simultaneously.

It ensures:

```text
Minimum application availability
during maintenance or disruptions
```

---

# Why PDB is Important?

Imagine:

```text
3 replicas running
```

During node upgrade:

```text
All 3 Pods evicted together
```

Application goes DOWN.

PDB prevents this.

---

# PDB Example

## Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3

  selector:
    matchLabels:
      app: web

  template:
    metadata:
      labels:
        app: web

    spec:
      containers:
      - name: nginx
        image: nginx
```

---

# PodDisruptionBudget YAML

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb

spec:
  minAvailable: 2

  selector:
    matchLabels:
      app: web
```

---

# Meaning

| Total Pods | Minimum Available |
| ---------- | ----------------- |
| 3          | 2                 |

So:

```text
Only 1 Pod can be disrupted at a time
```

---

# PDB Visualization

```text
Before Maintenance

Pod-1  Running
Pod-2  Running
Pod-3  Running

minAvailable = 2


Drain Node
    |
    v

Allowed:
Pod-1 Evicted

Still Running:
Pod-2
Pod-3


NOT Allowed:
Evict another Pod
because only 2 remain
```

---

# Another Method: maxUnavailable

Instead of `minAvailable`, use:

```yaml
maxUnavailable: 1
```

Meaning:

```text
Maximum 1 Pod can be unavailable
```

---

# minAvailable vs maxUnavailable

| Option         | Meaning                             |
| -------------- | ----------------------------------- |
| minAvailable   | Minimum Pods that MUST stay running |
| maxUnavailable | Maximum Pods allowed down           |

---

# PDB Commands

## Check PDB

```bash
kubectl get pdb
```

---

## Describe PDB

```bash
kubectl describe pdb web-pdb
```

---

# Node Drain Example

```bash
kubectl drain worker-node-1 --ignore-daemonsets
```

Kubernetes checks PDB before eviction.

---

# Important Notes About PDB

| Point                                  | Explanation                            |
| -------------------------------------- | -------------------------------------- |
| PDB only handles voluntary disruptions | Not crashes                            |
| Replica count matters                  | Single replica apps cannot maintain HA |
| DaemonSets ignored                     | Usually not controlled by PDB          |
| StatefulSets supported                 | Very important for databases           |

---

# Real Production Example

## Banking Application

| Component | Replicas | PDB               |
| --------- | -------- | ----------------- |
| API       | 5        | minAvailable: 4   |
| Database  | 3        | minAvailable: 2   |
| Redis     | 6        | maxUnavailable: 1 |

This ensures upgrades do not break services.

---

# Pod Priority vs Pod Disruption

| Feature              | Purpose                            |
| -------------------- | ---------------------------------- |
| Pod Priority         | Decide which Pod is more important |
| Pod Preemption       | Remove low-priority Pods           |
| Pod DisruptionBudget | Protect application availability   |
| Eviction             | Graceful Pod removal               |

---

# Combined Production Flow

```text
Cluster Upgrade Starts
          |
          v
Node Drained
          |
          v
PDB Checks Availability
          |
          v
Safe Pods Evicted
          |
          v
Scheduler Reschedules Pods
          |
          v
Priority Determines Scheduling Order
```

---

# Best Practices

## Pod Priority

✅ Use PriorityClass for production apps
✅ Keep batch jobs low priority
✅ Avoid too many highest-priority apps
✅ Separate dev/staging/prod priorities

---

## Pod DisruptionBudget

✅ Use PDB for all HA applications
✅ Minimum 2 replicas recommended
✅ Use StatefulSets carefully
✅ Test node drain operations regularly

---

# Common Interview Questions

## Q1: What is Pod Priority?

Mechanism to schedule important Pods first using `PriorityClass`.

---

## Q2: What is Preemption?

Removal of lower-priority Pods to schedule higher-priority Pods.

---

## Q3: What is PodDisruptionBudget?

A policy that limits how many Pods can be unavailable during voluntary disruptions.

---

## Q4: Does PDB protect against node crashes?

No.

Only voluntary disruptions.

---

# Quick Revision Table

| Topic          | Key Point                          |
| -------------- | ---------------------------------- |
| PriorityClass  | Defines Pod importance             |
| Pod Priority   | Scheduling preference              |
| Preemption     | Evict lower-priority Pods          |
| Disruption     | Pod becomes unavailable            |
| PDB            | Maintains application availability |
| minAvailable   | Minimum Pods must run              |
| maxUnavailable | Max Pods allowed down              |

---

# Real-world Analogy

## Pod Priority

```text
Hospital Emergency Room

Critical patient → treated first
Minor patient → waits
```

---

## PodDisruptionBudget

```text
Airport Runway Maintenance

At least 2 runways must remain open
before closing another
```
