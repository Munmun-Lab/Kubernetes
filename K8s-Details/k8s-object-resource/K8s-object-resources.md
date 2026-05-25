# Kubernetes Objects & Resources

Kubernetes works using **Objects** (desired state definitions) and **Resources** (CPU, memory, storage, etc.).

These objects are created in YAML files and managed through the Kubernetes API.

---

# What are Kubernetes Objects?

A Kubernetes Object is a **persistent entity** used to represent the desired state of the cluster.

Example:

* Run 3 nginx pods
* Expose application on port 80
* Restart failed containers automatically

Kubernetes continuously ensures the actual state matches the desired state.

---

# Kubernetes Object Categories

| Category              | Examples                     |
| --------------------- | ---------------------------- |
| Workload Objects      | Pod, Deployment, StatefulSet |
| Networking Objects    | Service, Ingress             |
| Storage Objects       | PV, PVC                      |
| Configuration Objects | ConfigMap, Secret            |
| Security Objects      | ServiceAccount, RBAC         |
| Scaling Objects       | HPA                          |
| Batch Objects         | Job, CronJob                 |

---

# 1. Pod

## Definition

A Pod is the **smallest deployable unit** in Kubernetes.

A Pod can contain:

* One container (most common)
* Multiple tightly coupled containers

---

## Pod Characteristics

| Feature           | Description                  |
| ----------------- | ---------------------------- |
| Smallest unit     | Basic execution unit         |
| Shared Network    | Containers share same IP     |
| Shared Storage    | Containers can share volumes |
| Ephemeral         | Can be destroyed/recreated   |
| Scheduled on Node | Runs on worker node          |

---

## Pod Architecture

```text
Node
 └── Pod
      ├── Container 1
      ├── Container 2
      └── Shared Volume
```

---

## Pod Lifecycle

```text
Pending → Running → Succeeded/Failed
```

---

## Simple Pod YAML

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: nginx-pod

spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

---

## Create Pod

```bash
kubectl apply -f pod.yaml
```

---

## View Pods

```bash
kubectl get pods
```

---

## Describe Pod

```bash
kubectl describe pod nginx-pod
```

---

## Delete Pod

```bash
kubectl delete pod nginx-pod
```

---

# 2. ReplicaSet

## Definition

ReplicaSet ensures a specified number of Pod replicas are running at all times.

---

## Purpose

If a Pod fails:

* ReplicaSet automatically creates another Pod.

---

## ReplicaSet Flow

```text
ReplicaSet
   ↓
Maintains Desired Pods
   ↓
Failed Pod Recreated Automatically
```

---

## Features

| Feature           | Description                |
| ----------------- | -------------------------- |
| High Availability | Maintains pod count        |
| Self-healing      | Recreates failed pods      |
| Scaling           | Increase/decrease replicas |

---

## ReplicaSet YAML

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

## Commands

```bash
kubectl get rs
kubectl describe rs nginx-rs
kubectl delete rs nginx-rs
```

---

# 3. Deployment

## Definition

Deployment manages ReplicaSets and Pods.

It is the most commonly used Kubernetes workload object.

---

## Deployment Features

| Feature             | Description                |
| ------------------- | -------------------------- |
| Rolling Updates     | Zero-downtime updates      |
| Rollback            | Revert failed deployments  |
| Scaling             | Increase/decrease replicas |
| Self-healing        | Auto pod recreation        |
| Declarative Updates | Desired state management   |

---

## Deployment Architecture

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
```

---

## Deployment YAML

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx-deployment

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
        image: nginx:1.25
```

---

## Deployment Commands

```bash
kubectl get deployments
kubectl rollout status deployment nginx-deployment
kubectl rollout history deployment nginx-deployment
```

---

## Scale Deployment

```bash
kubectl scale deployment nginx-deployment --replicas=5
```

---

## Rolling Update

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:latest
```

---

## Rollback

```bash
kubectl rollout undo deployment nginx-deployment
```

---

# Difference: Pod vs ReplicaSet vs Deployment

| Object     | Purpose                         |
| ---------- | ------------------------------- |
| Pod        | Single running instance         |
| ReplicaSet | Maintains pod count             |
| Deployment | Manages ReplicaSets and updates |

---

# 4. StatefulSet

## Definition

StatefulSet manages stateful applications.

Used when applications require:

* Stable hostname
* Persistent storage
* Ordered deployment

---

## Stateful Applications

Examples:

* MySQL
* PostgreSQL
* MongoDB
* Apache Kafka

---

## StatefulSet Features

| Feature            | Description           |
| ------------------ | --------------------- |
| Stable Network ID  | Predictable hostname  |
| Persistent Volumes | Data retained         |
| Ordered Startup    | Sequential deployment |
| Ordered Deletion   | Safe termination      |

---

## Naming Example

```text
mysql-0
mysql-1
mysql-2
```

---

## StatefulSet YAML

```yaml
apiVersion: apps/v1
kind: StatefulSet

metadata:
  name: mysql

spec:
  serviceName: mysql
  replicas: 3

  selector:
    matchLabels:
      app: mysql

  template:
    metadata:
      labels:
        app: mysql

    spec:
      containers:
      - name: mysql
        image: mysql:8
```

---

# Deployment vs StatefulSet

| Feature             | Deployment | StatefulSet |
| ------------------- | ---------- | ----------- |
| Stateless Apps      | Yes        | No          |
| Stable Hostname     | No         | Yes         |
| Persistent Identity | No         | Yes         |
| Ordered Scaling     | No         | Yes         |

---

# 5. DaemonSet

## Definition

DaemonSet ensures one Pod runs on every node.

---

## Common Use Cases

| Use Case        | Example                     |
| --------------- | --------------------------- |
| Log Collection  | Fluentd                     |
| Monitoring      | Prometheus Node Exporter    |
| Security Agents | Antivirus/Security scanning |

---

## DaemonSet Behavior

```text
New Node Added
      ↓
Pod Automatically Created
```

---

## DaemonSet YAML

```yaml
apiVersion: apps/v1
kind: DaemonSet

metadata:
  name: fluentd

spec:
  selector:
    matchLabels:
      app: fluentd

  template:
    metadata:
      labels:
        app: fluentd

    spec:
      containers:
      - name: fluentd
        image: fluentd
```

---

# Deployment vs DaemonSet

| Feature          | Deployment | DaemonSet |
| ---------------- | ---------- | --------- |
| Fixed Replicas   | Yes        | No        |
| One Pod Per Node | No         | Yes       |
| Auto on New Node | No         | Yes       |

---

# 6. Job

## Definition

A Job runs Pods to completion.

Used for:

* Backup
* Batch processing
* Data migration
* One-time tasks

---

## Job Workflow

```text
Job Starts
    ↓
Pod Runs Task
    ↓
Task Completes
    ↓
Pod Stops
```

---

## Job YAML

```yaml
apiVersion: batch/v1
kind: Job

metadata:
  name: backup-job

spec:
  template:
    spec:
      containers:
      - name: backup
        image: busybox
        command: ["echo", "Backup Complete"]

      restartPolicy: Never
```

---

# 7. CronJob

## Definition

CronJob runs Jobs on a schedule.

Similar to Linux cron.

---

## Cron Format

```text
* * * * *
| | | | |
| | | | └── Day of Week
| | | └──── Month
| | └────── Day
| └──────── Hour
└────────── Minute
```

---

## Example Schedules

| Schedule      | Meaning         |
| ------------- | --------------- |
| `0 * * * *`   | Every hour      |
| `0 0 * * *`   | Daily midnight  |
| `*/5 * * * *` | Every 5 minutes |

---

## CronJob YAML

```yaml
apiVersion: batch/v1
kind: CronJob

metadata:
  name: backup-cron

spec:
  schedule: "*/5 * * * *"

  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ["echo", "Scheduled Backup"]

          restartPolicy: Never
```

---

# Job vs CronJob

| Feature        | Job | CronJob |
| -------------- | --- | ------- |
| One-time Task  | Yes | No      |
| Scheduled Task | No  | Yes     |

---

# 8. Namespace

## Definition

Namespace logically separates cluster resources.

---

## Why Namespaces?

| Benefit          | Description         |
| ---------------- | ------------------- |
| Isolation        | Separate teams/apps |
| Security         | RBAC boundaries     |
| Resource Control | Apply quotas        |
| Organization     | Better management   |

---

## Default Namespaces

| Namespace       | Purpose               |
| --------------- | --------------------- |
| default         | Default workloads     |
| kube-system     | Kubernetes components |
| kube-public     | Public resources      |
| kube-node-lease | Node heartbeat        |

---

## Create Namespace

```yaml
apiVersion: v1
kind: Namespace

metadata:
  name: dev
```

---

## Commands

```bash
kubectl get ns
kubectl create ns dev
kubectl delete ns dev
```

---

# 9. Labels

## Definition

Labels are key-value pairs attached to Kubernetes objects.

---

## Example

```yaml
labels:
  app: nginx
  env: prod
  tier: frontend
```

---

## Uses

| Use Case   | Purpose            |
| ---------- | ------------------ |
| Grouping   | Organize resources |
| Selection  | Match objects      |
| Monitoring | Filtering          |
| Automation | CI/CD operations   |

---

# 10. Selectors

## Definition

Selectors identify objects using labels.

---

## Example

```yaml
selector:
  matchLabels:
    app: nginx
```

---

## How It Works

```text
Labels Applied to Pods
        ↓
Selector Matches Labels
        ↓
Deployment/Service Finds Pods
```

---

# Labels vs Selectors

| Labels             | Selectors          |
| ------------------ | ------------------ |
| Applied to objects | Query labels       |
| Metadata           | Matching mechanism |

---

# 11. Annotations

## Definition

Annotations store non-identifying metadata.

Unlike labels:

* Not used for selection
* Used for additional information

---

## Examples

```yaml
annotations:
  owner: admin-team
  backup: daily
  description: production-app
```

---

## Common Uses

| Use Case      | Description           |
| ------------- | --------------------- |
| Documentation | Notes/details         |
| Monitoring    | External integrations |
| CI/CD         | Build information     |
| Backup Tools  | Metadata tracking     |

---

# Labels vs Annotations

| Feature            | Labels | Annotations |
| ------------------ | ------ | ----------- |
| Used for Selection | Yes    | No          |
| Queryable          | Yes    | No          |
| Metadata Size      | Small  | Large       |

---

# 12. Resource Quotas

## Definition

ResourceQuota limits resource usage within a namespace.

---

## Controlled Resources

| Resource | Example |
| -------- | ------- |
| CPU      | 4 cores |
| Memory   | 8Gi     |
| Pods     | 20      |
| PVCs     | 10      |

---

## Purpose

| Benefit                     | Description         |
| --------------------------- | ------------------- |
| Prevent Resource Exhaustion | Avoid abuse         |
| Fair Usage                  | Multi-team clusters |
| Capacity Planning           | Resource control    |

---

## ResourceQuota YAML

```yaml
apiVersion: v1
kind: ResourceQuota

metadata:
  name: dev-quota
  namespace: dev

spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
```

---

# Check Quotas

```bash
kubectl get resourcequota
kubectl describe resourcequota dev-quota
```

---

# Real-World Kubernetes Object Usage

| Object        | Real Usage                 |
| ------------- | -------------------------- |
| Pod           | Single container execution |
| Deployment    | Web applications           |
| StatefulSet   | Databases                  |
| DaemonSet     | Monitoring/logging         |
| Job           | Backup scripts             |
| CronJob       | Scheduled tasks            |
| Namespace     | Team separation            |
| Labels        | Resource grouping          |
| ResourceQuota | Resource control           |

---

# Kubernetes Object Relationship

```text
Namespace
   ├── Deployment
   │      └── ReplicaSet
   │              └── Pods
   │
   ├── StatefulSet
   ├── DaemonSet
   ├── Job
   ├── CronJob
   │
   ├── Labels
   ├── Selectors
   ├── Annotations
   └── ResourceQuota
```

---

# Important kubectl Commands

| Command                          | Purpose            |
| -------------------------------- | ------------------ |
| `kubectl get all`                | View all resources |
| `kubectl describe <resource>`    | Detailed info      |
| `kubectl apply -f file.yaml`     | Create/update      |
| `kubectl delete -f file.yaml`    | Delete object      |
| `kubectl logs <pod>`             | View logs          |
| `kubectl exec -it <pod> -- bash` | Access container   |

---

# Key Interview Questions

| Question                                      | Expected Topic             |
| --------------------------------------------- | -------------------------- |
| Difference between Deployment and StatefulSet | Stateless vs Stateful      |
| Why use ReplicaSet?                           | High availability          |
| What is DaemonSet?                            | One pod per node           |
| Labels vs Annotations                         | Selection vs metadata      |
| Job vs CronJob                                | One-time vs scheduled      |
| Why ResourceQuota?                            | Namespace resource control |

