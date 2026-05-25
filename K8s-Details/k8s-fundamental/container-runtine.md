# Container Runtime

# What is Container Runtime?

Software responsible for:

* Pulling images
* Creating containers
* Running processes
* Managing isolation
* Managing networking

---

# Runtime Workflow

```text id="7rt9m0"
Pull Image
    ↓
Create Filesystem
    ↓
Configure Namespace
    ↓
Apply cgroups
    ↓
Start Process
    ↓
Container Running
```

---

# Container Runtime Responsibilities

| Responsibility      | Description           |
| ------------------- | --------------------- |
| Image Management    | Pull/store images     |
| Container Lifecycle | Start/stop containers |
| Isolation           | Namespaces            |
| Resource Limits     | cgroups               |
| Networking          | Container network     |
| Storage             | Mount volumes         |

---

# Runtime Types

| Type               | Description       |
| ------------------ | ----------------- |
| High-Level Runtime | containerd, CRI-O |
| Low-Level Runtime  | runc              |

---

# Runtime Architecture

```text id="3pnjlwm"
Kubernetes
     ↓
High-Level Runtime
     ↓
Low-Level Runtime
     ↓
Linux Kernel
```

---

# Popular Container Runtimes

---

# 1. containerd

# What is containerd?

`containerd` is an industry-standard container runtime.

Originally part of Docker.

Now widely used by Kubernetes.

---

# containerd Architecture

```text id="z4pcxt"
Kubernetes
     ↓
containerd
     ↓
runc
     ↓
Linux Kernel
```

---

# containerd Responsibilities

| Responsibility      | Description          |
| ------------------- | -------------------- |
| Image Pulling       | Download images      |
| Storage Management  | Store layers         |
| Container Execution | Run containers       |
| Snapshot Management | Filesystem snapshots |
| Networking          | Interface support    |

---

# containerd Features

| Feature           | Description       |
| ----------------- | ----------------- |
| Lightweight       | Faster            |
| OCI Compatible    | Industry standard |
| Stable            | Production ready  |
| Kubernetes Native | Preferred runtime |

---

# containerd CLI

# ctr Command

```bash id="h62pr8"
ctr images pull docker.io/library/nginx:latest
```

---

# List Images

```bash id="v8lq0y"
ctr images ls
```

---

# Run Container

```bash id="o6o1tx"
ctr run docker.io/library/nginx:latest mynginx
```

---

# 2. CRI-O

# What is CRI-O?

`CRI-O` is a Kubernetes-focused container runtime.

Designed specifically for Kubernetes.

---

# CRI-O Architecture

```text id="kh7ykv"
Kubernetes
     ↓
CRI-O
     ↓
OCI Runtime (runc)
     ↓
Linux Kernel
```

---

# CRI-O Goals

| Goal              | Description               |
| ----------------- | ------------------------- |
| Kubernetes Native | Built only for Kubernetes |
| Lightweight       | Minimal overhead          |
| OCI Compatible    | Open standards            |
| Secure            | Reduced attack surface    |

---

# CRI-O Workflow

```text id="4h3u1s"
Kubernetes Pod Request
        ↓
CRI-O
        ↓
Pull OCI Image
        ↓
runc
        ↓
Container Running
```

---

# CRI-O Features

| Feature                | Description        |
| ---------------------- | ------------------ |
| Fast Startup           | Lightweight        |
| Kubernetes Integration | Native             |
| OCI Support            | Full compatibility |
| Security               | SELinux/AppArmor   |

---

# containerd vs CRI-O

| Feature            | containerd      | CRI-O           |
| ------------------ | --------------- | --------------- |
| Origin             | Docker          | Kubernetes      |
| Usage              | General-purpose | Kubernetes only |
| Complexity         | Medium          | Lightweight     |
| OCI Support        | Yes             | Yes             |
| Kubernetes Support | Excellent       | Excellent       |

---

# 3. Docker Engine

# What is Docker Engine?

Full container platform including:

* Build tools
* Runtime
* CLI
* Networking

---

# Docker Architecture

```text id="tf3k2y"
Docker CLI
     ↓
Docker Daemon
     ↓
containerd
     ↓
runc
     ↓
Linux Kernel
```

---

# Important Point

Docker internally uses:

* containerd
* runc

---

# Why Kubernetes Removed Docker?

# Old Kubernetes Architecture

```text id="v4ruwz"
Kubernetes
     ↓
Docker Engine
     ↓
containerd
     ↓
runc
```

---

# Problem

Docker Engine added extra layer:

* More overhead
* More complexity
* Not CRI-native

---

# Kubernetes Change

Kubernetes deprecated Dockershim.

Now Kubernetes directly uses:

* containerd
* CRI-O

---

# Modern Kubernetes Runtime Flow

```text id="i2l4wf"
Kubernetes
     ↓
CRI
     ↓
containerd / CRI-O
     ↓
runc
     ↓
Linux Kernel
```

---

# Important Clarification

## Kubernetes Did NOT Remove Docker Images

Kubernetes still supports Docker-built images because:

```text id="emjlwm"
Docker Images follow OCI standards
```

---

# What Kubernetes Removed

Kubernetes removed:

```text id="jlwm2n"
Docker Engine Dependency
```

NOT Docker images.

---

# CRI (Container Runtime Interface)

# What is CRI?

CRI is an API interface between:

```text id="gtncde"
Kubernetes
     ↔
Container Runtime
```

---

# CRI Purpose

Allows Kubernetes to work with different runtimes.

---

# CRI Benefits

| Benefit         | Description         |
| --------------- | ------------------- |
| Standardization | Common interface    |
| Flexibility     | Multiple runtimes   |
| Portability     | Runtime independent |
| Simplicity      | Easy integration    |

---

# CRI Workflow

```text id="yzyh6d"
kubectl apply
      ↓
API Server
      ↓
Kubelet
      ↓
CRI
      ↓
containerd / CRI-O
      ↓
runc
      ↓
Container Started
```

---

# Kubelet & CRI

## kubelet Role

`kubelet` communicates with runtime through CRI.

---

# kubelet Runtime Flow

```text id="xyfdbj"
Kubelet
    ↓
CRI API
    ↓
containerd
```

---

# CRI Runtime Examples

| Runtime    | CRI Support         |
| ---------- | ------------------- |
| containerd | Native              |
| CRI-O      | Native              |
| Docker     | Required Dockershim |

---

# Why CRI Matters in Kubernetes

Without CRI:

```text id="7e1rmx"
Kubernetes tightly coupled with Docker
```

With CRI:

```text id="jyn5m5"
Kubernetes supports multiple runtimes
```

---

# End-to-End Container Flow

```text id="1r77dy"
Developer Writes Dockerfile
          ↓
Build OCI Image
          ↓
Push to Registry
          ↓
Kubernetes Deploys Pod
          ↓
Kubelet Calls CRI
          ↓
containerd / CRI-O
          ↓
runc Creates Container
          ↓
Linux Kernel Runs Process
```

---

# Real Production Example

# EKS / AKS / GKE Runtime

| Platform                | Runtime    |
| ----------------------- | ---------- |
| Amazon Web Services EKS | containerd |
| Microsoft AKS           | containerd |
| Google GKE              | containerd |
| Red Hat OpenShift       | CRI-O      |

---

# Important Commands

# Check Container Runtime

```bash id="r7v7j3"
crictl info
```

---

# View Running Containers

```bash id="93b5o4"
crictl ps
```

---

# Pull Image Using crictl

```bash id="4jlwmz"
crictl pull nginx
```

---

# Check containerd Service

```bash id="u9i4zv"
systemctl status containerd
```

---

# Final Summary

OCI provides:

* Standard images
* Standard runtimes
* Standard registries

Container runtimes:

* Pull images
* Create isolation
* Start containers
* Communicate with Kubernetes

Modern Kubernetes architecture relies heavily on:

* OCI
* CRI
* containerd
* CRI-O
* runc

These are the foundation of:

* Kubernetes
* Cloud Native
* DevOps
* Platform Engineering
* Modern Infrastructure
