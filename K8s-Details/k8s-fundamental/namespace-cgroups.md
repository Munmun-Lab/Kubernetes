# Linux Namespaces & cgroups — Complete Detailed Notes

These are the **core Linux kernel technologies** behind containers like:

* Docker Docker
* Kubernetes
* containerd
* CRI-O
* Podman

Containers work mainly because of:

```text id="a7kk2o"
Namespaces → Isolation
cgroups   → Resource Control
```

---

# What are Linux Namespaces?

# Definition

Linux namespaces provide **isolation** between processes.

They make a process think:

```text id="dtxw1y"
"I am running on my own separate system"
```

Even though all containers share the same Linux kernel.

---

# Simple Real-World Analogy

Imagine:

```text id="q4wb9m"
One Apartment Building
      ↓
Many Separate Apartments
```

Each apartment has:

* Separate rooms
* Separate belongings
* Separate privacy

But all apartments share:

* Same building
* Same electricity
* Same water

Similarly:

```text id="fb3ms8"
Containers share Host Kernel
BUT
Have isolated environments
```

---

# Namespace Purpose

Without namespaces:

```text id="wsr1g9"
All applications see everything
```

With namespaces:

```text id="lq18ix"
Each container sees only its own resources
```

---

# Namespace Architecture

```text id="mf2ic9"
+-----------------------------------+
|           Host OS                 |
|-----------------------------------|
| Linux Kernel                      |
|-----------------------------------|
| Namespaces                        |
|-----------------------------------|
| Container A | Container B         |
| Isolated    | Isolated            |
+-----------------------------------+
```

---

# Why Namespaces are Important?

| Benefit            | Description            |
| ------------------ | ---------------------- |
| Isolation          | Separate environments  |
| Security           | Reduce visibility      |
| Multi-tenancy      | Multiple apps safely   |
| Process Separation | No conflicts           |
| Network Isolation  | Independent networking |

---

# Types of Linux Namespaces

| Namespace | Purpose                               |
| --------- | ------------------------------------- |
| PID       | Process isolation                     |
| NET       | Network isolation                     |
| MNT       | Mount/filesystem isolation            |
| IPC       | Inter-process communication isolation |
| UTS       | Hostname/domain isolation             |
| USER      | User/group isolation                  |
| CGROUP    | cgroup visibility isolation           |
| TIME      | Time isolation                        |

---

# 1. PID Namespace

# Purpose

Isolates process IDs.

Each container gets its own process tree.

---

# Without PID Namespace

```text id="0w2jvq"
All processes visible globally
```

---

# With PID Namespace

```text id="0od5qk"
Container A sees only its processes
Container B sees only its processes
```

---

# PID Namespace Example

Inside container:

```bash id="krvskw"
ps -ef
```

Output:

```text id="gok5hi"
PID 1 nginx
PID 2 worker
```

Even though host has thousands of processes.

---

# PID Namespace Flow

```text id="ayw9q4"
Host Processes
      ↓
PID Namespace
      ↓
Container-specific Process View
```

---

# Important Point

Inside container:

```text id="x3wqzf"
Main process becomes PID 1
```

---

# 2. NET Namespace

# Purpose

Provides separate networking stack.

Each container gets:

* IP address
* Routing table
* Network interfaces
* Firewall rules

---

# NET Namespace Example

Container A:

```text id="h7q9m5"
IP = 10.0.0.2
```

Container B:

```text id="56oqhu"
IP = 10.0.0.3
```

---

# Network Isolation Diagram

```text id="a79nfh"
Host Network
      ↓
Bridge Network
   ↙       ↘
Container A  Container B
```

---

# Commands

# View Interfaces

```bash id="ksw8eu"
ip addr
```

---

# Create Namespace

```bash id="b0tuwy"
ip netns add ns1
```

---

# List Namespaces

```bash id="7gj18i"
ip netns list
```

---

# 3. MNT Namespace (Mount Namespace)

# Purpose

Provides isolated filesystem view.

Each container sees separate filesystem.

---

# Example

Container A:

```text id="dxhtc4"
Sees only /app
```

Container B:

```text id="tjlwm4"
Sees different filesystem
```

---

# Filesystem Isolation Flow

```text id="qjlh4t"
Host Filesystem
       ↓
Mount Namespace
       ↓
Container Filesystem View
```

---

# Example Command

```bash id="tbydtw"
mount
```

Shows mounted filesystems.

---

# 4. IPC Namespace

# Purpose

Isolates communication between processes.

Includes:

* Shared memory
* Message queues
* Semaphores

---

# IPC Isolation

```text id="rjlwm1"
Container A IPC
      ≠
Container B IPC
```

---

# IPC Commands

```bash id="3vbjlwm"
ipcs
```

---

# 5. UTS Namespace

# Purpose

Isolates:

* Hostname
* Domain name

---

# Example

Container A hostname:

```text id="7cfnyg"
web-container
```

Container B hostname:

```text id="jlwm5m"
db-container
```

---

# View Hostname

```bash id="jlwm5n"
hostname
```

---

# 6. USER Namespace

# Purpose

Provides user isolation.

Container root user ≠ Host root user.

---

# Security Benefit

Inside container:

```text id="6jlwmk"
root user
```

May map to:

```text id="pjlwm3"
non-root user on host
```

---

# USER Namespace Flow

```text id="jlwm6p"
Container Root
       ↓
Mapped UID
       ↓
Host User
```

---

# 7. CGROUP Namespace

# Purpose

Isolates cgroup information visibility.

Container sees only its own resource limits.

---

# 8. TIME Namespace

# Purpose

Provides isolated time settings.

Used in advanced workloads/testing.

---

# Namespace Workflow in Containers

```text id="mjlwm8"
Start Container
      ↓
Create Namespaces
      ↓
Isolate Resources
      ↓
Run Application
```

---

# Namespace Example in Docker

# Run Container

```bash id="jlwm9q"
docker run -it ubuntu bash
```

---

# Check Process Isolation

Inside container:

```bash id="rjlwm7"
ps -ef
```

You see only container processes.

---

# Check Network Isolation

```bash id="jlwm1a"
ip addr
```

Shows container-specific network.

---

# What are cgroups?

# Definition

cgroups = Control Groups

Linux kernel feature for controlling:

* CPU
* Memory
* Disk I/O
* Network
* Process limits

---

# Simple Understanding

Namespaces = Isolation

cgroups = Resource Limits

---

# Real-World Analogy

```text id="jlwm2b"
Apartment Isolation = Namespace
Electricity Usage Limit = cgroup
```

---

# Why cgroups are Needed?

Without cgroups:

```text id="jlwm3c"
One container can consume all CPU/RAM
```

Problem:

* Server crash
* Resource starvation
* Poor performance

---

# cgroups Solution

```text id="jlwm4d"
Limit resources per container
```

---

# cgroups Architecture

```text id="jlwm5e"
+----------------------------------+
|            Host OS               |
|----------------------------------|
| cgroups                          |
|----------------------------------|
| Container A → 1 CPU, 1GB RAM    |
| Container B → 2 CPU, 2GB RAM    |
+----------------------------------+
```

---

# cgroups Main Functions

| Function          | Description        |
| ----------------- | ------------------ |
| Resource Limiting | Restrict usage     |
| Prioritization    | Allocate priority  |
| Accounting        | Monitor usage      |
| Isolation         | Separate workloads |

---

# Resources Controlled by cgroups

| Resource | Example              |
| -------- | -------------------- |
| CPU      | CPU shares           |
| Memory   | RAM limits           |
| Disk I/O | Read/write limits    |
| Network  | Bandwidth control    |
| PIDs     | Process count limits |

---

# CPU cgroup Example

# Limit CPU

```bash id="jlwm6f"
docker run --cpus="1" nginx
```

Container can use only 1 CPU core.

---

# Memory cgroup Example

# Limit Memory

```bash id="jlwm7g"
docker run -m 512m nginx
```

Container limited to 512 MB RAM.

---

# Combined Example

```bash id="jlwm8h"
docker run -it \
  --cpus="2" \
  -m 1g \
  ubuntu
```

---

# cgroup Workflow

```text id="jlwm9i"
Container Starts
      ↓
cgroup Created
      ↓
Resource Limits Applied
      ↓
Kernel Enforces Limits
```

---

# How cgroups Work Internally

```text id="jlwm1j"
Linux Kernel
      ↓
cgroup Subsystems
      ↓
CPU / Memory / IO Controllers
```

---

# Important cgroup Controllers

| Controller | Purpose                |
| ---------- | ---------------------- |
| cpu        | CPU limits             |
| memory     | RAM limits             |
| blkio      | Disk IO                |
| pids       | Process count          |
| cpuset     | CPU affinity           |
| net_cls    | Network classification |

---

# cgroup Example Structure

```text id="jlwm2k"
sys/fs/cgroup/
    ├── cpu/
    ├── memory/
    ├── pids/
```

---

# View cgroups

```bash id="jlwm3l"
ls /sys/fs/cgroup
```

---

# Check Memory Limit

```bash id="jlwm4m"
cat /sys/fs/cgroup/memory.max
```

---

# cgroups v1 vs v2

| Version    | Description          |
| ---------- | -------------------- |
| cgroups v1 | Older implementation |
| cgroups v2 | Unified hierarchy    |

---

# cgroups v2 Benefits

| Benefit            | Description         |
| ------------------ | ------------------- |
| Simpler            | Unified structure   |
| Better Performance | Improved efficiency |
| Better Security    | Stronger isolation  |
| Easier Management  | Cleaner hierarchy   |

---

# Namespaces vs cgroups

| Feature     | Namespaces       | cgroups             |
| ----------- | ---------------- | ------------------- |
| Purpose     | Isolation        | Resource control    |
| Focus       | Visibility       | Usage limits        |
| Example     | Separate network | Limit RAM           |
| Security    | High             | Medium              |
| Performance | Isolation        | Resource governance |

---

# Together They Create Containers

```text id="jlwm5n"
Namespaces
   +
cgroups
   +
Filesystem
   +
Container Runtime
   =
Containers
```

---

# Complete Container Creation Flow

```text id="jlwm6o"
Docker/containerd
        ↓
Create Namespaces
        ↓
Apply cgroups
        ↓
Mount Filesystem
        ↓
Start Process
        ↓
Container Running
```

---

# Docker Internals

# Docker Uses

| Feature         | Linux Technology |
| --------------- | ---------------- |
| Isolation       | Namespaces       |
| Resource Limits | cgroups          |
| Filesystem      | OverlayFS        |
| Runtime         | runc/containerd  |

---

# Kubernetes & cgroups

Kubernetes uses cgroups for:

* CPU limits
* Memory requests
* Resource quotas

---

# Kubernetes Example

```yaml id="jlwm7p"
resources:
  requests:
    memory: "256Mi"
    cpu: "500m"

  limits:
    memory: "512Mi"
    cpu: "1"
```

---

# Kubernetes Flow

```text id="jlwm8q"
Pod Spec
    ↓
Kubelet
    ↓
containerd
    ↓
cgroups Applied
```

---

# Real Production Example

# Multi-Tenant Cluster

```text id="jlwm9r"
Team A Containers
      ↓
1 CPU, 2GB RAM

Team B Containers
      ↓
2 CPU, 4GB RAM
```

cgroups prevent one team from consuming all resources.

---

# Common Commands

# View Running Containers

```bash id="jlwm1s"
docker ps
```

---

# Inspect Container

```bash id="jlwm2t"
docker inspect <container_id>
```

---

# Check Resource Usage

```bash id="jlwm3u"
docker stats
```

---

# View Process Tree

```bash id="jlwm4v"
pstree
```

---

# Best Practices

| Best Practice     | Reason            |
| ----------------- | ----------------- |
| Set CPU limits    | Prevent overload  |
| Set memory limits | Avoid OOM         |
| Use namespaces    | Security          |
| Use cgroups v2    | Modern standard   |
| Monitor usage     | Capacity planning |

---

# Final Summary

Namespaces provide:

* Isolation
* Security
* Separate environments

cgroups provide:

* Resource limits
* Resource accounting
* Fair resource sharing

Together they form the foundation of:

* Containers
* Docker
* Kubernetes
* containerd
* CRI-O
* Cloud Native Infrastructure
