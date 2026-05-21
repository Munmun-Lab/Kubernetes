# OCI Standards & Container Runtime — Complete Detailed Notes

---

# OCI Standards

# What is OCI?

Open Container Initiative (OCI) is an open standard project created to standardize:

* Container image formats
* Container runtime behavior
* Container registry communication

OCI ensures containers work consistently across different platforms and runtimes.

---

# Why OCI Was Needed?

Before OCI:

```text id="y4m1tv"
Docker had its own format
Other vendors had different formats
Compatibility problems existed
```

Problem:

* Vendor lock-in
* No universal standard
* Runtime incompatibility

---

# OCI Solution

```text id="85ks7w"
One Standard
      ↓
All Platforms Compatible
      ↓
Portable Containers
```

---

# OCI History

| Year    | Event                             |
| ------- | --------------------------------- |
| 2013    | Docker introduced containers      |
| 2015    | OCI created                       |
| 2015    | Docker donated runtime technology |
| Current | Industry-wide standard            |

---

# Who Maintains OCI?

OCI is managed by:

* Linux Foundation

OCI contributors include:

* Docker
* Google
* Microsoft
* Red Hat
* IBM

---

# OCI Goals

| Goal             | Purpose                     |
| ---------------- | --------------------------- |
| Standard Images  | Same image works everywhere |
| Standard Runtime | Same runtime behavior       |
| Interoperability | Vendor-neutral containers   |
| Portability      | Move across platforms       |
| Compatibility    | Multi-runtime support       |
| Open Standards   | No vendor lock-in           |

---

# OCI High-Level Architecture

```text id="7kqv4x"
+--------------------------------+
|         OCI Standards          |
+--------------------------------+
| OCI Image Specification        |
| OCI Runtime Specification      |
| OCI Distribution Specification |
+--------------------------------+
               ↓
    Compatible Container Ecosystem
```

---

# OCI Components

---

# 1. OCI Image Specification

# What is OCI Image Spec?

Defines:

```text id="m9h0l7"
How container images are built
How images are packaged
How images are stored
```

---

# OCI Image Structure

```text id="uzuxkc"
Container Image
    ↓
Layers
    ↓
Metadata
    ↓
Manifest
```

---

# Image Layers

Each Docker image consists of layers.

Example:

```dockerfile id="hyx4yh"
FROM ubuntu:22.04
RUN apt update
RUN apt install nginx -y
COPY . /app
```

Each command creates a new layer.

---

# Layer Flow

```text id="sj19cg"
Ubuntu Base Layer
        ↓
Install Packages Layer
        ↓
Application Layer
        ↓
Configuration Layer
```

---

# OCI Image Benefits

| Benefit      | Description      |
| ------------ | ---------------- |
| Layer Reuse  | Faster downloads |
| Smaller Size | Shared layers    |
| Portability  | Run anywhere     |
| Efficiency   | Cache support    |

---

# OCI Image Manifest

## Purpose

Stores metadata about image.

Contains:

* Layers
* Checksums
* OS
* Architecture

---

# Example Manifest Flow

```text id="4pxx7k"
Image Manifest
      ↓
Layer References
      ↓
Filesystem Creation
```

---

# OCI Image Example

```bash id="lnzjlwm"
docker pull nginx
```

The pulled image follows OCI image standards.

---

# 2. OCI Runtime Specification

# What is OCI Runtime Spec?

Defines:

```text id="j83n3y"
How containers should run
How runtimes interact with OS
How isolation works
```

---

# Runtime Responsibilities

| Responsibility      | Description          |
| ------------------- | -------------------- |
| Start containers    | Launch process       |
| Stop containers     | Graceful shutdown    |
| Isolation           | Namespace management |
| Resource limits     | cgroups              |
| Filesystem mounting | Root filesystem      |
| Security            | Permissions          |

---

# OCI Runtime Flow

```text id="bg94xg"
OCI Image
    ↓
Runtime
    ↓
Namespaces
    ↓
cgroups
    ↓
Container Process
```

---

# Low-Level Runtime — runc

# What is runc?

`runc` is the reference OCI runtime implementation.

It directly interacts with:

* Linux kernel
* Namespaces
* cgroups

---

# runc Workflow

```text id="e4jlj8"
OCI Bundle
    ↓
runc
    ↓
Linux Kernel
    ↓
Container Process
```

---

# OCI Bundle

OCI bundle contains:

| File        | Purpose               |
| ----------- | --------------------- |
| rootfs      | Container filesystem  |
| config.json | Runtime configuration |

---

# Example OCI Runtime Config

```json id="rtsaj6"
{
  "process": {
    "terminal": true
  },
  "root": {
    "path": "rootfs"
  }
}
```

---

# 3. OCI Distribution Specification

# What is OCI Distribution Spec?

Defines:

```text id="dzmlg0"
How images are pushed
How images are pulled
How registries communicate
```

---

# Registry Workflow

```text id="sx5l7x"
Developer
    ↓
Push Image
    ↓
Registry
    ↓
Pull Image
    ↓
Container Runtime
```

---

# Popular OCI-Compatible Registries

| Registry                | Provider         |
| ----------------------- | ---------------- |
| Docker DockerHub        | Public registry  |
| Amazon Web Services ECR | AWS              |
| Google GCR              | Google           |
| GHCR                    | GitHub           |
| Harbor                  | Private registry |

---

# OCI Compatibility

# Core Idea

```text id="3iqwhq"
Build Once
      ↓
Run Anywhere
```

---

# Compatibility Flow

```text id="3n23iu"
Docker Image
     ↓
OCI Standard
     ↓
containerd / CRI-O / Docker
     ↓
Works Everywhere
```

---

# OCI Ecosystem

```text id="j7cbjp"
+-----------------------------------+
|          OCI Ecosystem            |
+-----------------------------------+
| Images | Registries | Runtimes    |
+-----------------------------------+
| Docker | containerd | CRI-O       |
| Podman | runc       | Kubernetes  |
+-----------------------------------+
```

