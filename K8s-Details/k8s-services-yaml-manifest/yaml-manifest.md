# Kubernetes YAML & Manifest Files — Complete Guide

# What is YAML?

YAML stands for:

```text
YAML Ain't Markup Language
```

YAML is a human-readable configuration language widely used in:

* Kubernetes
* Docker Compose
* Ansible
* CI/CD Pipelines
* Cloud Configuration

In Kubernetes, almost everything is created using YAML manifest files.

---

# Why Kubernetes Uses YAML?

| Reason                   | Purpose                  |
| ------------------------ | ------------------------ |
| Human readable           | Easy to understand       |
| Structured format        | Organized configuration  |
| Declarative model        | Desired state definition |
| Easy automation          | Infrastructure as Code   |
| Version control friendly | GitOps support           |

---

# Kubernetes Declarative Model

In Kubernetes:

```text
You define WHAT you want.
Kubernetes decides HOW to maintain it.
```

Example:

```text
I want 3 nginx pods running.
```

Kubernetes continuously ensures:

* 3 pods stay alive
* failed pods restart
* desired state maintained

---

# YAML Basics

# 1. Key Value Pair

```yaml
name: nginx
```

| Part  | Meaning |
| ----- | ------- |
| name  | Key     |
| nginx | Value   |

---

# 2. Indentation

YAML depends on spaces.

IMPORTANT:

```text
Use spaces only.
Do NOT use tabs.
```

Correct:

```yaml
app:
  name: nginx
```

Wrong:

```yaml
app:
	name: nginx
```

---

# 3. List / Array

```yaml
containers:
  - nginx
  - redis
```

---

# 4. Nested Structure

```yaml
application:
  backend:
    image: nginx
```

---

# 5. Comments

```yaml
# This is comment
name: nginx
```

---

# YAML Flow Diagram

```text
YAML File
    ↓
kubectl apply -f app.yaml
    ↓
API Server
    ↓
etcd
    ↓
Scheduler
    ↓
Worker Node
    ↓
Pod Created
```

---

# Kubernetes Manifest File

Manifest file = YAML file used to create Kubernetes resources.

Examples:

* Pod
* Deployment
* Service
* ConfigMap
* Secret
* Namespace
* StatefulSet

---

# Basic Kubernetes Manifest Structure

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx
```

---

# Manifest Sections Explained

| Section    | Purpose                |
| ---------- | ---------------------- |
| apiVersion | Kubernetes API version |
| kind       | Resource type          |
| metadata   | Resource information   |
| spec       | Desired configuration  |

---

# Example 1 — Pod Manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: web
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80
```

---

# Create Resource

```bash
kubectl apply -f pod.yaml
```

---

# Verify Resource

```bash
kubectl get pods
```

---

# Kubernetes Deployment Manifest

Deployment manages pods automatically.

---

# Example 2 — Deployment YAML

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

# Deployment Flow

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
```

---

# Kubernetes Service Manifest

Service exposes applications.

---

# Example 3 — Service YAML

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

---

# Multi-document YAML

Kubernetes supports multiple resources inside one YAML file.

Separator:

```yaml
---
```

---

# Example — Multi-document YAML

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: demo
spec:
  replicas: 2
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

# Why Multi-document YAML?

| Benefit                 | Purpose             |
| ----------------------- | ------------------- |
| Single file deployment  | Easier management   |
| GitOps friendly         | Version control     |
| Infrastructure grouping | Organized resources |
| CI/CD automation        | Simple deployment   |

---

# Variables & Environment Variables

Applications need configuration values.

Examples:

* Database hostname
* API URL
* Port
* Username
* Password

---

# Environment Variables in Kubernetes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-demo
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: APP_ENV
      value: production
    - name: APP_PORT
      value: "8080"
```

---

# Verify Environment Variables

```bash
kubectl exec -it env-demo -- env
```

---

# ConfigMaps

ConfigMap stores:

```text
Non-sensitive configuration data
```

Examples:

* application.properties
* database hostname
* environment settings
* feature flags

---

# ConfigMap Architecture

```text
ConfigMap
    ↓
Mounted into Pod
    ↓
Application Reads Config
```

---

# Example — ConfigMap YAML

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config

data:
  APP_ENV: production
  APP_PORT: "8080"
  DB_HOST: mysql-service
```

---

# Use ConfigMap in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: app
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
```

---

# ConfigMap as Volume

```yaml
volumes:
- name: config-volume
  configMap:
    name: app-config
```

---

# Secrets

Secrets store:

```text
Sensitive information
```

Examples:

* passwords
* API keys
* tokens
* certificates

---

# Important Difference

| Resource  | Data Type     |
| --------- | ------------- |
| ConfigMap | Non-sensitive |
| Secret    | Sensitive     |

---

# Secret Example

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret

type: Opaque

data:
  username: YWRtaW4=
  password: cGFzc3dvcmQ=
```

---

# Note About Secrets

Values are Base64 encoded.

Example:

```bash
echo -n 'admin' | base64
```

---

# Use Secret in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-demo
spec:
  containers:
  - name: app
    image: nginx
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
```

---

# Init Containers

Init containers run:

```text
BEFORE main application container starts
```

Purpose:

* setup tasks
* wait for dependencies
* initialize configuration
* perform migrations

---

# Init Container Flow

```text
Init Container
      ↓
Successful Completion
      ↓
Main Container Starts
```

---

# Example — Init Container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  initContainers:
  - name: init-service
    image: busybox
    command: ['sh', '-c', 'echo Initializing... && sleep 10']

  containers:
  - name: main-app
    image: nginx
```

---

# Why Init Containers?

| Use Case         | Purpose              |
| ---------------- | -------------------- |
| Wait for DB      | Dependency check     |
| Download config  | Initialization       |
| Schema migration | Database preparation |
| Permission setup | Security preparation |

---

# Sidecar Containers

Sidecar container = helper container running beside main application.

Both run together inside same pod.

---

# Sidecar Architecture

```text
Pod
 ├── Main Application Container
 └── Sidecar Container
```

---

# Common Sidecar Use Cases

| Sidecar          | Purpose                   |
| ---------------- | ------------------------- |
| Log collector    | Send logs                 |
| Monitoring agent | Metrics collection        |
| Proxy container  | Traffic routing           |
| Security agent   | Encryption/authentication |

---

# Example — Sidecar Container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-demo
spec:
  containers:

  - name: main-app
    image: nginx

  - name: log-sidecar
    image: busybox
    command: ['sh', '-c', 'while true; do echo collecting logs; sleep 5; done']
```

---

# Init Container vs Sidecar

| Feature        | Init Container    | Sidecar          |
| -------------- | ----------------- | ---------------- |
| Execution Time | Before app starts | Runs with app    |
| Lifecycle      | Temporary         | Continuous       |
| Purpose        | Initialization    | Support services |
| Runs Together? | No                | Yes              |

---

# Full Kubernetes Resource Relationship

```text
YAML Manifest
      ↓
kubectl apply -f app.yaml
      ↓
API Server
      ↓
etcd
      ↓
Scheduler
      ↓
Worker Node
      ↓
Pod Created
      ↓
Containers Running
```

---

# Kubernetes YAML Best Practices

| Best Practice                     | Reason              |
| --------------------------------- | ------------------- |
| Use labels properly               | Resource management |
| Use namespaces                    | Isolation           |
| Separate secrets                  | Security            |
| Use ConfigMaps                    | External config     |
| Use multi-document YAML carefully | Maintainability     |
| Use version control               | GitOps              |
| Validate YAML indentation         | Prevent errors      |
| Avoid hardcoding passwords        | Security            |

---

# Validate YAML

```bash
kubectl apply --dry-run=client -f app.yaml
```

---

# Common YAML Errors

| Error               | Cause               |
| ------------------- | ------------------- |
| indentation error   | Wrong spacing       |
| unknown field       | Invalid key         |
| apiVersion mismatch | Unsupported API     |
| selector mismatch   | Labels not matching |
| image pull error    | Wrong image         |

---

# Useful Kubernetes YAML Commands

```bash
kubectl apply -f app.yaml
kubectl delete -f app.yaml
kubectl get all
kubectl describe pod pod1
kubectl logs pod1
kubectl explain deployment
kubectl get pod -o yaml
```

---

# Real-world Enterprise Usage

YAML manifests are heavily used in:

* DevOps
* CI/CD
* GitOps
* Kubernetes deployments
* Infrastructure as Code
* Cloud-native applications

---

# GitOps Flow

```text
Developer Writes YAML
        ↓
Push to Git Repository
        ↓
ArgoCD / Flux Detect Changes
        ↓
Kubernetes Cluster Updated
```

---

# Important Final Understanding

```text
YAML defines desired state.
Kubernetes continuously ensures that desired state exists.
```

---

# Summary

| Topic                 | Purpose                        |
| --------------------- | ------------------------------ |
| YAML                  | Configuration language         |
| Manifest              | Kubernetes resource definition |
| Multi-document YAML   | Multiple resources in one file |
| Environment Variables | Runtime configuration          |
| ConfigMap             | Non-sensitive config           |
| Secret                | Sensitive config               |
| Init Container        | Pre-start initialization       |
| Sidecar Container     | Supporting helper container    |

---



