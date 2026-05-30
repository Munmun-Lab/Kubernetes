# Multi-Container Pods in Kubernetes

A Kubernetes Pod can contain **one or more containers** that share:

* Same Network Namespace (same IP)
* Same Storage Volumes
* Same Lifecycle (scheduled together)

```text
Pod
├── Container 1 (Application)
├── Container 2 (Sidecar)
└── Shared Volume
```

---

# Types of Containers in a Pod

## 1. Main Container

Runs the actual application.

Example:

```yaml
containers:
- name: nginx
  image: nginx
```

---

## 2. Init Container

Runs **before** the main container starts.

### Purpose

* Prepare environment
* Download files
* Wait for dependencies
* Database initialization

### Key Points

✅ Runs only once

✅ Runs sequentially

✅ Must complete successfully

✅ Main container waits

❌ Does not run continuously

---

## Init Container Flow

```text
Pod Start
    │
    ▼
Init Container 1
    │
    ▼
Success ?
    │
 ┌──┴──┐
 │ No  │
 ▼     │
Retry  │
       ▼
Init Container 2
       │
       ▼
Main Application Starts
```

---

## Init Container Example

Suppose nginx needs a webpage before starting.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  volumes:
  - name: web-data
    emptyDir: {}

  initContainers:
  - name: download-page
    image: busybox
    command:
      - sh
      - -c
      - "echo Welcome to Kubernetes > /data/index.html"
    volumeMounts:
    - name: web-data
      mountPath: /data

  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: web-data
      mountPath: /usr/share/nginx/html
```

### What Happens?

```text
Init Container
      │
Creates index.html
      │
      ▼
Shared Volume
      │
      ▼
Nginx Reads File
      │
      ▼
Website Available
```

---

# 3. Sidecar Container

Runs alongside the main application.

### Purpose

* Logging
* Monitoring
* Proxy
* Security Agents
* Configuration Sync

### Key Points

✅ Starts with Pod

✅ Runs continuously

✅ Shares resources

✅ Supports main application

❌ Not responsible for business logic

---

## Sidecar Flow

```text
Pod
│
├── Main Container
│       │
│       ▼
│   Application
│
└── Sidecar Container
        │
        ▼
   Logging / Monitoring
```

---

# Sidecar Example

Application writes logs.

Sidecar collects logs.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-demo

spec:
  volumes:
  - name: log-volume
    emptyDir: {}

  containers:

  - name: app
    image: busybox
    command:
    - sh
    - -c
    - while true; do
        echo "Application Running" >> /logs/app.log;
        sleep 5;
      done

    volumeMounts:
    - name: log-volume
      mountPath: /logs

  - name: log-agent
    image: busybox
    command:
    - sh
    - -c
    - tail -f /logs/app.log

    volumeMounts:
    - name: log-volume
      mountPath: /logs
```

---

## Sidecar Design Diagram

```text
                 Kubernetes Pod
 ┌───────────────────────────────────────┐
 │                                       │
 │  Main App Container                   │
 │  ┌───────────────────────────────┐    │
 │  │ Writes Logs                   │    │
 │  └─────────────┬─────────────────┘    │
 │                │                      │
 │                ▼                      │
 │        Shared Volume                  │
 │                ▲                      │
 │                │                      │
 │  ┌─────────────┴─────────────────┐    │
 │  │ Sidecar Container             │    │
 │  │ Reads Logs                    │    │
 │  └───────────────────────────────┘    │
 │                                       │
 └───────────────────────────────────────┘
```

---

# Init Container vs Sidecar

| Feature               | Init Container       | Sidecar Container   |
| --------------------- | -------------------- | ------------------- |
| Runs Before Main App  | ✅ Yes                | ❌ No                |
| Runs Continuously     | ❌ No                 | ✅ Yes               |
| Purpose               | Setup/Initialization | Support Application |
| Execution             | One Time             | Continuous          |
| Main App Waits        | ✅ Yes                | ❌ No                |
| Logging Use Case      | ❌ No                 | ✅ Yes               |
| Monitoring Use Case   | ❌ No                 | ✅ Yes               |
| DB Migration Use Case | ✅ Yes                | ❌ No                |

---

# Real-World Examples

### Init Container

```text
Application Pod
      │
      ▼
Wait for Database
      │
      ▼
Download Config
      │
      ▼
Start Application
```

Used for:

* Database schema creation
* Dependency checks
* Secret retrieval
* Configuration generation

---

### Sidecar

```text
Application
      │
      ▼
Generate Logs
      │
      ▼
Fluent Bit Sidecar
      │
      ▼
Splunk / ELK
```

Used for:

* Fluent Bit
* Logstash
* Monitoring Agents
* Envoy Proxy
* Service Mesh

---

# Interview Question

### Can a Pod have both Init and Sidecar Containers?

**Yes.**

```text
Pod Start
   │
   ▼
Init Container
   │
   ▼
Main Container
   │
   ├── Application
   │
   └── Sidecar
         │
         ▼
     Logging/Monitoring
```

This is very common in production Kubernetes environments.

### Easy Memory Trick

```text
Init Container
= Prepare First

Sidecar Container
= Assist Forever
```

**Init Container → "Setup and Exit"**

**Sidecar Container → "Run and Support"**
