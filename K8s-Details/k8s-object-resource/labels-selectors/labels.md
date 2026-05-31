# Labels in Kubernetes

A **Label** is a **key-value pair** attached to Kubernetes objects (Pod, Deployment, Service, Node, Namespace, etc.) to identify and organize them.

**Labels are key-value pairs attached to Kubernetes objects for identification and grouping. They are used by Services, Deployments, ReplicaSets, Node Selectors, and other controllers to select and manage resources. Label selectors allow Kubernetes to discover and connect related resources dynamically.**


Think of labels like tags on files:

```yaml
env: prod
app: nginx
tier: frontend
```

Kubernetes uses labels to:

* Group resources
* Filter resources
* Connect Services to Pods
* Schedule workloads
* Manage deployments

---

## Simple Example

### Pod with Labels

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    env: dev

spec:
  containers:
  - name: nginx
    image: nginx
```

Create:

```bash
kubectl apply -f pod.yaml
```

Check labels:

```bash
kubectl get pods --show-labels
```

Output:

```text
NAME        READY   STATUS
nginx-pod   1/1     Running

LABELS
app=nginx,env=dev
```

---

# Real-Time Example

Imagine an e-commerce application:

```text
Frontend Pods
    |
    | app=web
    ▼
Backend Pods
    |
    | app=api
    ▼
Database Pods
```

Labels:

```yaml
app: web
```

```yaml
app: api
```

```yaml
app: mysql
```

Now Kubernetes can identify which pods belong to which application tier.

---

# Label Selector

Used to find resources with specific labels.

Find all nginx pods:

```bash
kubectl get pods -l app=nginx
```

Find all prod pods:

```bash
kubectl get pods -l env=prod
```

---

# Multiple Labels

```yaml
metadata:
  labels:
    app: nginx
    env: prod
    tier: frontend
```

Search:

```bash
kubectl get pods -l app=nginx,env=prod
```

---

### Why important?

```yaml
selector:
  matchLabels:
    app: nginx
```

Deployment manages only Pods having:

```yaml
app: nginx
```

---

# Service Using Labels

Pods:

```yaml
labels:
  app: nginx
```

Service:

```yaml
selector:
  app: nginx
```

Diagram:

```text
Service
   |
   | selector: app=nginx
   ▼
+------------+
| Nginx Pod1 |
+------------+

+------------+
| Nginx Pod2 |
+------------+

+------------+
| Nginx Pod3 |
+------------+
```

Service automatically discovers Pods through labels.

---

# Node Labels

Check node labels:

```bash
kubectl get nodes --show-labels
```

Example:

```text
node1
  disktype=ssd
  zone=us-east-1a

node2
  disktype=hdd
```

Add a label:

```bash
kubectl label nodes worker1 disktype=ssd
```

Verify:

```bash
kubectl get nodes --show-labels
```

---

# Common Label Examples

```yaml
labels:
  app: nginx
  env: prod
  version: v1
  team: devops
  tier: frontend
```

| Label         | Purpose           |
| ------------- | ----------------- |
| app=nginx     | Application name  |
| env=dev       | Environment       |
| version=v1    | Version           |
| team=devops   | Ownership         |
| tier=frontend | Application layer |

---

# Useful Commands

Show labels:

```bash
kubectl get pods --show-labels
```

Add label:

```bash
kubectl label pod nginx-pod env=prod
```

Overwrite label:

```bash
kubectl label pod nginx-pod env=prod --overwrite
```

Delete label:

```bash
kubectl label pod nginx-pod env-
```

Filter by label:

```bash
kubectl get pods -l app=nginx
```

Describe labels:

```bash
kubectl describe pod nginx-pod
```


