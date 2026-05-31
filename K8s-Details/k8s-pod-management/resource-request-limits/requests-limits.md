# Kubernetes Requests & Limits (Very Important for CKA/CKAD)

Think of a Kubernetes node as a hotel.

* **Request** = Room you reserve in advance.
* **Limit** = Maximum room space you are allowed to use.

If you reserve 1 room but try to use 10 rooms, the hotel may stop you.

---

## 1. What is Resource Request?

A **request** tells Kubernetes:

> "Please schedule my Pod only on a node that has at least this much CPU and Memory available."

### Example

```yaml
resources:
  requests:
    cpu: "250m"
    memory: "256Mi"
```

Meaning:

| Resource | Request              |
| -------- | -------------------- |
| CPU      | 250m (0.25 CPU Core) |
| Memory   | 256Mi                |

Kubernetes scheduler will find a node having at least:

* 0.25 CPU
* 256Mi RAM

available.

---

## 2. What is Resource Limit?

A **limit** tells Kubernetes:

> "Even if more resources are available, don't let this container use more than this amount."

### Example

```yaml
resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
```

Meaning:

| Resource | Limit               |
| -------- | ------------------- |
| CPU      | 500m (0.5 CPU Core) |
| Memory   | 512Mi               |

Container can never use:

* More than 0.5 CPU
* More than 512Mi RAM

---

# Request vs Limit

| Feature            | Request | Limit |
| ------------------ | ------- | ----- |
| Used by Scheduler  | ✅ Yes   | ❌ No  |
| Minimum Guaranteed | ✅ Yes   | ❌ No  |
| Maximum Allowed    | ❌ No    | ✅ Yes |
| Node Selection     | ✅ Yes   | ❌ No  |

---

# Example 1 - Simple Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx

    resources:
      requests:
        cpu: "200m"
        memory: "128Mi"

      limits:
        cpu: "500m"
        memory: "256Mi"
```

### Meaning

```
CPU:
200m  -------- Requested
500m  -------- Maximum allowed

Memory:
128Mi -------- Requested
256Mi -------- Maximum allowed
```

---

# Example 2 - CPU Behavior

Suppose:

```yaml
requests:
  cpu: "500m"

limits:
  cpu: "1000m"
```

### Pod Starts

```
CPU Reserved = 0.5 Core
```

### Application Needs More CPU

```
Uses:
600m
700m
800m
900m
```

Allowed because under limit.

### Application Tries

```
1200m
```

Not allowed.

Linux cgroups throttle CPU.

---

# Example 3 - Memory Behavior

```yaml
requests:
  memory: "256Mi"

limits:
  memory: "512Mi"
```

Application uses:

```
300Mi
400Mi
500Mi
```

Allowed.

Application uses:

```
600Mi
```

❌ Exceeds limit.

Result:

```text
OOMKilled
```

Container gets killed and restarted.

---

# Example 4 - Request Only

```yaml
resources:
  requests:
    cpu: "200m"
    memory: "128Mi"
```

No limits.

### Result

* Scheduler reserves resources.
* Container can use more if available.
* Dangerous in production.

---

# Example 5 - Limit Only

```yaml
resources:
  limits:
    cpu: "1"
    memory: "1Gi"
```

Kubernetes automatically sets:

```yaml
requests:
  cpu: "1"
  memory: "1Gi"
```

if no request is specified (depending on cluster configuration/default behavior).

Result:

Pod may become harder to schedule because it appears to need the full amount.

---

# Production Best Practice

```yaml
resources:
  requests:
    cpu: "500m"
    memory: "512Mi"

  limits:
    cpu: "1"
    memory: "1Gi"
```

This means:

```
Guaranteed:
CPU = 0.5 Core
RAM = 512Mi

Maximum:
CPU = 1 Core
RAM = 1Gi
```

---

# Real-World Example

### Java Application

```yaml
resources:
  requests:
    cpu: "1"
    memory: "2Gi"

  limits:
    cpu: "2"
    memory: "4Gi"
```

Meaning:

* Reserve 1 CPU and 2Gi RAM.
* Can burst up to 2 CPUs and 4Gi RAM.
* More than 4Gi RAM → OOMKilled.

---

# Check Requests & Limits

View pod resources:

```bash
kubectl describe pod nginx-pod
```

Look for:

```text
Requests:
  cpu:     200m
  memory:  128Mi

Limits:
  cpu:     500m
  memory:  256Mi
```

---

# Easy Interview Answer

**Request**

> Minimum CPU/Memory guaranteed to a container and used by the scheduler to place the Pod.

**Limit**

> Maximum CPU/Memory a container can consume. CPU is throttled if exceeded, while Memory exceeding the limit causes OOMKilled.

### Quick Memory Trick

```text
Request = Reserve
Limit   = Restrict
```

```
Request <= Actual Usage <= Limit
```

Example:

```yaml
requests:
  cpu: 250m
  memory: 256Mi

limits:
  cpu: 500m
  memory: 512Mi
```

Meaning:

* Guaranteed: 250m CPU, 256Mi RAM
* Allowed maximum: 500m CPU, 512Mi RAM
* Memory > 512Mi → OOMKilled
* CPU > 500m → Throttled (slowed down)

```
```
