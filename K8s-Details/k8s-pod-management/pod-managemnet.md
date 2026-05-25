# Kubernetes Pod Management — Complete Guide

# What is a Pod?

In entity["software","Kubernetes","Container orchestration platform"]:

```text
Pod is the smallest deployable unit.
```

A Pod contains:

* One or more containers
* Shared network
* Shared storage
* Shared lifecycle

---

# Simple Understanding

Think of Pod as:

```text
A wrapper/container around application containers.
```

Example:

```text
Pod
 ├── nginx container
 └── sidecar container
```

---

# Why Pods Exist?

Containers alone are not enough.

Kubernetes needs:

* networking
* scheduling
* scaling
* monitoring
* storage attachment
* lifecycle management

Pod provides this abstraction.

---

# Pod Architecture

```text
+------------------------------------------------+
|                     POD                        |
|                                                |
|  Shared Network Namespace                      |
|  Shared Storage Volumes                        |
|                                                |
|   +------------------+                         |
|   |  Container 1     |                         |
|   |  nginx           |                         |
|   +------------------+                         |
|                                                |
|   +------------------+                         |
|   |  Container 2     |                         |
|   |  sidecar logger  |                         |
|   +------------------+                         |
|                                                |
+------------------------------------------------+
```

---

# Pod Characteristics

| Feature           | Description                   |
| ----------------- | ----------------------------- |
| Ephemeral         | Pods can be recreated anytime |
| Shared IP         | Containers share same IP      |
| Shared storage    | Containers access same volume |
| Atomic scheduling | Entire pod scheduled together |
| Self-healing      | Failed pods recreated         |

---

# Pod Lifecycle

```text
Pending
   ↓
ContainerCreating
   ↓
Running
   ↓
Succeeded / Failed
```

---

# Pod Lifecycle States

| State     | Meaning                 |
| --------- | ----------------------- |
| Pending   | Waiting for scheduling  |
| Running   | Pod active              |
| Succeeded | Completed successfully  |
| Failed    | Pod failed              |
| Unknown   | Node communication lost |

---

# Kubernetes Pod Creation Flow

```text
User Creates YAML
        ↓
kubectl apply -f pod.yaml
        ↓
API Server
        ↓
etcd Stores State
        ↓
Scheduler Selects Node
        ↓
kubelet Creates Pod
        ↓
Container Runtime Starts Containers
        ↓
Pod Running
```

---

# Basic Pod YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80
```

---

# YAML Sections Explained

| Section    | Purpose                |
| ---------- | ---------------------- |
| apiVersion | Kubernetes API version |
| kind       | Resource type          |
| metadata   | Resource identity      |
| spec       | Desired configuration  |
| containers | Application containers |

---

# Create Pod

```bash
kubectl apply -f pod.yaml
```

---

# Verify Pod

```bash
kubectl get pods
```

Example:

```text
NAME         READY   STATUS    RESTARTS   AGE
nginx-pod    1/1     Running   0          30s
```

---

# Describe Pod

```bash
kubectl describe pod nginx-pod
```

Shows:

* events
* node assignment
* image details
* IP address
* volume info
* status

---

# Pod Logs

```bash
kubectl logs nginx-pod
```

---

# Access Pod Shell

```bash
kubectl exec -it nginx-pod -- bash
```

or

```bash
kubectl exec -it nginx-pod -- sh
```

---

# Delete Pod

```bash
kubectl delete pod nginx-pod
```

---

# Multi-container Pods

A Pod can run multiple containers.

---

# Example — Multi-container Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:

  - name: nginx
    image: nginx

  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do sleep 3600; done']
```

---

# Why Multi-container Pods?

| Use Case              | Purpose          |
| --------------------- | ---------------- |
| Sidecar logging       | Log collection   |
| Proxy container       | Service mesh     |
| Monitoring agent      | Metrics          |
| Shared helper process | Utility services |

---

# Pod Networking

Every Pod gets:

* unique IP address
* shared localhost networking

Containers inside pod communicate using:

```text
localhost
```

---

# Pod Networking Diagram

```text
Pod IP: 10.244.1.5

Container A  ---> localhost ---> Container B
```

---

# Pod Storage

Containers can share storage using Volumes.

---

# Example — Pod Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-demo
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /data
      name: shared-storage

  volumes:
  - name: shared-storage
    emptyDir: {}
```

---

# Common Volume Types

| Volume    | Purpose            |
| --------- | ------------------ |
| emptyDir  | Temporary storage  |
| hostPath  | Host filesystem    |
| ConfigMap | Configuration      |
| Secret    | Sensitive data     |
| PVC       | Persistent storage |

---

# Pod Labels

Labels organize resources.

---

# Example

```yaml
labels:
  app: nginx
  env: production
```

---

# Why Labels Important?

Used for:

* service selection
* deployments
* monitoring
* grouping
* filtering

---

# List Pods Using Labels

```bash
kubectl get pods -l app=nginx
```

---

# Pod Selectors

Selectors match labels.

---

# Service Selector Example

```yaml
selector:
  app: nginx
```

---

# Pod Resource Requests & Limits

Control CPU and memory.

---

# Example

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

---

# Requests vs Limits

| Resource | Meaning            |
| -------- | ------------------ |
| Requests | Guaranteed minimum |
| Limits   | Maximum allowed    |

---

# Pod Restart Policy

Defines restart behavior.

---

# Restart Policies

| Policy    | Meaning           |
| --------- | ----------------- |
| Always    | Restart always    |
| OnFailure | Restart if failed |
| Never     | Never restart     |

---

# Example

```yaml
restartPolicy: Always
```

---

# Init Containers

Init containers run before main application.

---

# Example

```yaml
initContainers:
- name: init-demo
  image: busybox
  command: ['sh', '-c', 'echo initializing']
```

---

# Pod Probes

Kubernetes checks application health.

---

# Probe Types

| Probe     | Purpose            |
| --------- | ------------------ |
| Liveness  | Is app alive?      |
| Readiness | Ready for traffic? |
| Startup   | Startup completed? |

---

# Liveness Probe Example

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 10
  periodSeconds: 5
```

---

# Readiness Probe Example

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
```

---

# Probe Flow

```text
Kubernetes Probe Check
         ↓
Application Healthy?
     YES / NO
        ↓
Restart or Keep Running
```

---

# Pod Scheduling

Scheduler decides:

```text
Which node should run the Pod?
```

Based on:

* CPU
* memory
* taints
* affinity
* node labels

---

# Pod Scheduling Flow

```text
Pending Pod
      ↓
Scheduler Checks Nodes
      ↓
Best Node Selected
      ↓
Pod Assigned
```

---

# Node Selector Example

```yaml
nodeSelector:
  disktype: ssd
```

---

# Pod Affinity

Controls pod placement rules.

---

# Example Use Cases

| Type          | Purpose            |
| ------------- | ------------------ |
| Affinity      | Keep pods together |
| Anti-affinity | Separate pods      |

---

# Taints & Tolerations

Control node restrictions.

---

# Simple Understanding

| Component  | Meaning         |
| ---------- | --------------- |
| Taint      | Reject pods     |
| Toleration | Allow exception |

---

# Pod Security Context

Controls security settings.

---

# Example

```yaml
securityContext:
  runAsUser: 1000
```

---

# Pod Deletion Lifecycle

```text
kubectl delete pod
       ↓
SIGTERM Sent
       ↓
Grace Period
       ↓
SIGKILL
       ↓
Pod Removed
```

---

# Static Pods

Managed directly by kubelet.

Used for:

* API server
* scheduler
* controller-manager
* etcd

---

# Static Pod Location

```text
/etc/kubernetes/manifests/
```

---

# Mirror Pods

Static pod representation inside API server.

---

# Pod vs Container

| Feature             | Pod | Container |
| ------------------- | --- | --------- |
| Kubernetes object   | Yes | No        |
| Scheduling unit     | Yes | No        |
| Shared networking   | Yes | Limited   |
| Contains containers | Yes | No        |

---

# Pod vs Deployment

| Pod                                | Deployment           |
| ---------------------------------- | -------------------- |
| Single instance                    | Managed replicas     |
| Not self-healing alone             | Self-healing         |
| Manual scaling                     | Auto scaling         |
| Rarely used directly in production | Production preferred |

---

# Real-world Best Practices

| Best Practice                              | Reason                   |
| ------------------------------------------ | ------------------------ |
| Use Deployments instead of standalone Pods | High availability        |
| Define resource limits                     | Stability                |
| Use probes                                 | Health monitoring        |
| Use labels consistently                    | Management               |
| Avoid privileged containers                | Security                 |
| Use ConfigMaps & Secrets                   | Configuration management |
| Use namespaces                             | Isolation                |

---

# Enterprise Pod Flow

```text
Developer Writes YAML
        ↓
Git Repository
        ↓
CI/CD Pipeline
        ↓
kubectl apply
        ↓
Kubernetes Cluster
        ↓
Pods Running
        ↓
Monitoring & Logging
```

---

# Final Important Understanding

```text
Pods are temporary.
Controllers maintain desired state.
```

If pod fails:

```text
Kubernetes recreates it automatically.
```

---

# Summary

| Topic               | Purpose                  |
| ------------------- | ------------------------ |
| Pod                 | Smallest deployable unit |
| Multi-container pod | Shared helper services   |
| Volumes             | Shared storage           |
| Labels              | Resource organization    |
| Probes              | Health checks            |
| Scheduling          | Node placement           |
| Init container      | Pre-start tasks          |
| Sidecar             | Supporting service       |
| Resources           | CPU & memory control     |

---

