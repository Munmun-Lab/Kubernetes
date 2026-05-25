# Linux Namespaces

## Purpose

Namespaces provide isolation.

Each container gets isolated:

* Processes
* Network
* Users
* Filesystem

---

# Namespace Types

| Namespace | Purpose                     |
| --------- | --------------------------- |
| PID       | Process isolation           |
| NET       | Network isolation           |
| MNT       | Filesystem isolation        |
| IPC       | Inter-process communication |
| UTS       | Hostname isolation          |
| USER      | User isolation              |

---

# Namespace Flow

```text id="r2j98t"
Host OS
   ↓
Namespaces
   ↓
Isolated Containers
```

---

# cgroups (Control Groups)

## Purpose

Controls resource usage.

Limits:

* CPU
* Memory
* Disk I/O
* Network

---

# cgroup Example

```text id="tlyyx7"
Container A → 1 CPU, 512MB RAM
Container B → 2 CPU, 1GB RAM
```

---

# Container Isolation Diagram

```text id="v5o4rc"
+--------------------------------+
|           Host OS              |
|--------------------------------|
| Namespaces | cgroups           |
|--------------------------------|
| Container 1 | Container 2      |
| App A       | App B            |
+--------------------------------+
```