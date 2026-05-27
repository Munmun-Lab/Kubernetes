# Kubernetes Deployment

A **Deployment** in Kubernetes is a higher-level controller used to **manage Pods and ReplicaSets**.
It helps you run applications in a reliable, scalable, and declarative way.

Think of it like:

```text
Deployment
   ↓ manages
ReplicaSet
   ↓ manages
Pods
```

---

# Why Deployment is Used

Without Deployment:

* You manually create Pods
* Pods can die permanently
* No rolling updates
* No rollback support

With Deployment:
✅ Self-healing
✅ Scaling
✅ Rolling updates
✅ Rollbacks
✅ Version management
✅ Zero-downtime updates

---

# Deployment Architecture

```text
                 +------------------+
                 |   Deployment     |
                 +------------------+
                           |
                           v
                 +------------------+
                 |   ReplicaSet     |
                 +------------------+
                    |     |     |
                    v     v     v
                  Pod   Pod   Pod
```

---

# Real World Example

Suppose you run:

* 3 nginx web servers

If one Pod crashes:

* Deployment automatically recreates it

If you update image:

* Deployment updates Pods gradually

---

# Basic Deployment YAML

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
        image: nginx:latest

        ports:
        - containerPort: 80
```

---

# Understanding Each Section

---

## 1. apiVersion

```yaml
apiVersion: apps/v1
```

Deployment belongs to:

* apps API group

---

## 2. kind

```yaml
kind: Deployment
```

Defines Kubernetes object type.

---

## 3. metadata

```yaml
metadata:
  name: nginx-deployment
```

Object name.

---

## 4. replicas

```yaml
replicas: 3
```

Desired number of Pods.

---

## 5. selector

```yaml
selector:
  matchLabels:
    app: nginx
```

Deployment identifies Pods using labels.

---

## 6. template

Template used to create Pods.

```yaml
template:
```

---

## 7. containers

```yaml
containers:
- name: nginx
  image: nginx
```

Container definition.

---

# Create Deployment

```bash
kubectl apply -f deployment.yaml
```

---

# Check Deployment

```bash
kubectl get deployments
```

OR

```bash
kubectl get deploy
```

Example:

```text
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           2m
```

---

# Check ReplicaSets

```bash
kubectl get rs
```

---

# Check Pods

```bash
kubectl get pods
```

---

# Describe Deployment

```bash
kubectl describe deployment nginx-deployment
```

Shows:

* Events
* Strategy
* Replica info
* Pod template
* Conditions

---

# Scaling Deployment

Increase Pods:

```bash
kubectl scale deployment nginx-deployment --replicas=5
```

Now:

```text
5 Pods running
```

---

# Autoscaling (HPA)

Horizontal Pod Autoscaler automatically scales Pods.

```bash
kubectl autoscale deployment nginx-deployment \
--cpu-percent=70 \
--min=2 \
--max=10
```

---

# Update Deployment

Example:
Update nginx image version.

```bash
kubectl set image deployment/nginx-deployment \
nginx=nginx:1.27
```

---

# Rolling Update

Deployment updates Pods gradually.

```text
Old Pods ↓
New Pods ↑
```

No downtime.

---

# Rolling Update Flow

```text
Pod v1 running
       ↓
Create Pod v2
       ↓
Delete old Pod v1
       ↓
Continue gradually
```

---

# Check Rollout Status

```bash
kubectl rollout status deployment/nginx-deployment
```

---

# Rollback Deployment

Undo latest deployment:

```bash
kubectl rollout undo deployment/nginx-deployment
```

---

# Rollback to Specific Revision

Check revisions:

```bash
kubectl rollout history deployment/nginx-deployment
```

Rollback:

```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

---

# Restart Deployment

```bash
kubectl rollout restart deployment/nginx-deployment
```

Useful when:

* Secret changed
* ConfigMap updated

---

# Delete Deployment

```bash
kubectl delete deployment nginx-deployment
```

Deletes:

* Deployment
* ReplicaSets
* Pods

---

# Deployment Strategies

## 1. RollingUpdate (Default)

```text
Old Pods replaced gradually
```

Best for production.

---

## 2. Recreate

Kills all old Pods first.

```yaml
strategy:
  type: Recreate
```

Causes downtime.

---

# RollingUpdate Parameters

```yaml
strategy:
  type: RollingUpdate

  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

---

## maxSurge

Extra Pods allowed during update.

---

## maxUnavailable

Pods allowed unavailable during update.

---

# Deployment Lifecycle

```text
Create Deployment
       ↓
Deployment creates ReplicaSet
       ↓
ReplicaSet creates Pods
       ↓
Pods run containers
       ↓
Deployment monitors state
```

---

# Important Commands

| Purpose             | Command                                    |
| ------------------- | ------------------------------------------ |
| Create deployment   | `kubectl apply -f deploy.yaml`             |
| Get deployments     | `kubectl get deploy`                       |
| Describe deployment | `kubectl describe deploy <name>`           |
| Scale deployment    | `kubectl scale deploy <name> --replicas=5` |
| Update image        | `kubectl set image deploy/<name>`          |
| Rollout status      | `kubectl rollout status deploy/<name>`     |
| Rollback            | `kubectl rollout undo deploy/<name>`       |
| Restart             | `kubectl rollout restart deploy/<name>`    |
| Delete              | `kubectl delete deploy <name>`             |

---

# Deployment vs ReplicaSet

| Feature         | Deployment | ReplicaSet        |
| --------------- | ---------- | ----------------- |
| Pod Management  | Yes        | Yes               |
| Rolling Updates | Yes        | No                |
| Rollbacks       | Yes        | No                |
| Versioning      | Yes        | No                |
| Recommended     | Yes        | Rarely direct use |

---

# Deployment vs StatefulSet

| Deployment       | StatefulSet      |
| ---------------- | ---------------- |
| Stateless apps   | Stateful apps    |
| Random Pod names | Stable Pod names |
| Web servers      | Databases        |

Examples:

* Deployment → nginx, frontend
* StatefulSet → MySQL, MongoDB

---

# Best Practices

✅ Use labels properly
✅ Use readiness probes
✅ Use resource limits
✅ Use rolling updates
✅ Use versioned images
❌ Avoid `latest` in production
✅ Use namespaces
✅ Monitor rollout status

---

# Production Example

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: frontend

spec:
  replicas: 3

  strategy:
    type: RollingUpdate

  selector:
    matchLabels:
      app: frontend

  template:
    metadata:
      labels:
        app: frontend

    spec:
      containers:
      - name: frontend
        image: nginx:1.27

        ports:
        - containerPort: 80

        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"

          limits:
            cpu: "500m"
            memory: "512Mi"

        readinessProbe:
          httpGet:
            path: /
            port: 80

          initialDelaySeconds: 5
          periodSeconds: 10
```

---

# Interview Questions

## What is Deployment?

A Kubernetes controller used for managing stateless applications using ReplicaSets and Pods.

---

## Why Deployment instead of Pod?

Deployment provides:

* Self-healing
* Scaling
* Updates
* Rollbacks

Pods alone cannot.

---

## What happens during Deployment update?

Deployment creates a new ReplicaSet and gradually replaces old Pods.

---

## Difference between Deployment and StatefulSet?

Deployment:

* Stateless workloads

StatefulSet:

* Stateful workloads with stable identity/storage

---

# Quick Visual Summary

```text
Deployment
   ↓
ReplicaSet
   ↓
Pods
   ↓
Containers
```

---

# Most Important Things to Remember

✅ Deployment manages ReplicaSets
✅ ReplicaSets manage Pods
✅ Supports scaling
✅ Supports rolling updates
✅ Supports rollback
✅ Best for stateless applications
✅ Most commonly used Kubernetes object after Pods
