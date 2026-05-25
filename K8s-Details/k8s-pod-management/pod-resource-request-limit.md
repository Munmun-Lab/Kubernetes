# Kubernetes Pod Resource Requests & Limits

In Kubernetes, **Resource Requests** and **Resource Limits** control how much CPU and Memory a Pod/container can **reserve** and **consume**.

They are critical for:

* Cluster stability
* Fair resource sharing
* Preventing noisy neighbors
* Scheduling decisions
* Autoscaling
* Cost optimization

---

# 1. Core Concept

| Resource Type | Meaning                     |
| ------------- | --------------------------- |
| **Request**   | Minimum guaranteed resource |
| **Limit**     | Maximum allowed resource    |

Think of it like:

| Example | Meaning                        |
| ------- | ------------------------------ |
| Request | Reserved hotel room            |
| Limit   | Maximum room occupancy allowed |

---

# 2. Simple Understanding

## CPU

CPU is measured in:

| Unit    | Meaning          |
| ------- | ---------------- |
| `1 CPU` | 1 full vCPU/Core |
| `500m`  | 0.5 CPU          |
| `100m`  | 0.1 CPU          |

`m` = millicores

---

## Memory

Memory measured in:

| Unit | Meaning   |
| ---- | --------- |
| `Mi` | Mebibytes |
| `Gi` | Gibibytes |

Examples:

| Value   | Meaning |
| ------- | ------- |
| `256Mi` | 256 MB  |
| `1Gi`   | 1024 MB |

---

# 3. How Kubernetes Uses Them

---

## Resource Request

Used by:

* kube-scheduler
* Pod placement decision

Kubernetes checks:

> "Does this node have enough free resources?"

If YES → Pod scheduled

If NO → Pod pending

---

## Resource Limit

Used by:

* Linux cgroups
* kubelet
* container runtime

Controls:

* Max CPU usage
* Max memory usage

---

# 4. Visual Architecture

```text
                +----------------------+
                | Kubernetes Scheduler |
                +----------+-----------+
                           |
                  Checks REQUESTS
                           |
         ----------------------------------
         |                                |
+--------v--------+             +---------v--------+
| Worker Node 1   |             | Worker Node 2    |
| Free: 2CPU      |             | Free: 500m CPU   |
| Free: 4Gi RAM   |             | Free: 512Mi RAM  |
+--------+--------+             +------------------+
         |
         | Pod Scheduled
         |
+--------v----------------------------------+
| Pod                                      |
|------------------------------------------|
| Request: CPU 500m, Memory 256Mi          |
| Limit:   CPU 1,    Memory 512Mi          |
+------------------------------------------+
```

---

# 5. Basic YAML Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-resource-demo

spec:
  containers:
  - name: nginx
    image: nginx

    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"

      limits:
        memory: "512Mi"
        cpu: "500m"
```

---

# 6. Explanation of YAML

| Field           | Meaning            |
| --------------- | ------------------ |
| requests.memory | Guaranteed memory  |
| requests.cpu    | Guaranteed CPU     |
| limits.memory   | Max memory allowed |
| limits.cpu      | Max CPU allowed    |

---

# 7. Important Behavior

---

## CPU Limit Behavior

If container exceeds CPU limit:

✅ Container is throttled
❌ NOT killed

Example:

```text
Limit = 500m

Application tries using 900m

Result:
Kubernetes throttles CPU usage to 500m
```

---

## Memory Limit Behavior

If container exceeds memory limit:

❌ Container killed (OOMKilled)

Example:

```text
Limit = 512Mi

Application uses 700Mi

Result:
Container terminated with OOMKilled
```

---

# 8. OOMKilled

OOM = Out Of Memory

Check using:

```bash
kubectl describe pod <pod-name>
```

Output:

```text
Reason: OOMKilled
```

---

# 9. Scheduler Flow

```text
                User Creates Pod
                        |
                        v
             Scheduler Reads Requests
                        |
                        v
         Does Node Have Enough Capacity?
                   /          \
                 YES           NO
                  |             |
                  v             v
          Pod Scheduled     Pod Pending
```

---

# 10. Runtime Enforcement Flow

```text
             Container Running
                      |
          +-----------+-----------+
          |                       |
          v                       v

     CPU Exceeded          Memory Exceeded
          |                       |
          v                       v

    CPU Throttled          Container Killed
```

---

# 11. Real Example

Suppose:

Node capacity:

| Resource | Available |
| -------- | --------- |
| CPU      | 2 Core    |
| Memory   | 4Gi       |

Pods:

| Pod   | Request CPU | Request Memory |
| ----- | ----------- | -------------- |
| Pod-A | 500m        | 512Mi          |
| Pod-B | 1 CPU       | 1Gi            |
| Pod-C | 700m        | 3Gi            |

Scheduler calculation:

CPU:

```text
500m + 1 + 700m = 2.2 CPU
```

Memory:

```text
512Mi + 1Gi + 3Gi > 4Gi
```

Result:

❌ Pod-C cannot schedule

---

# 12. QoS Classes (Very Important)

Kubernetes assigns QoS (Quality of Service) classes.

---

## 1. Guaranteed

Requests = Limits

Example:

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

Highest stability.

---

## 2. Burstable

Requests < Limits

Example:

```yaml
requests:
  memory: "256Mi"

limits:
  memory: "1Gi"
```

Most common.

---

## 3. BestEffort

No requests or limits.

```yaml
resources: {}
```

Lowest priority.

Usually first to be evicted.

---

# 13. QoS Diagram

```text
Highest Stability
        |
        v

+----------------+
| Guaranteed     |
+----------------+

+----------------+
| Burstable      |
+----------------+

+----------------+
| BestEffort     |
+----------------+

Lowest Stability
```

---

# 14. Resource Usage Commands

---

## Check Pod Resource Usage

```bash
kubectl top pod
```

---

## Check Node Usage

```bash
kubectl top node
```

Requires:

```text
metrics-server
```

---

# 15. Example Deployment

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: web-app

spec:
  replicas: 3

  selector:
    matchLabels:
      app: web

  template:
    metadata:
      labels:
        app: web

    spec:
      containers:
      - name: web-container
        image: nginx

        resources:
          requests:
            cpu: "200m"
            memory: "256Mi"

          limits:
            cpu: "500m"
            memory: "512Mi"
```

---

# 16. Why Requests & Limits Matter

| Problem                  | Without Limits      |
| ------------------------ | ------------------- |
| One pod uses all memory  | Node crash          |
| CPU starvation           | Other apps slow     |
| Unpredictable scheduling | Cluster instability |
| No capacity planning     | Resource wastage    |

---

# 17. Production Best Practices

| Best Practice          | Recommendation         |
| ---------------------- | ---------------------- |
| Always define requests | YES                    |
| Always define limits   | YES                    |
| Avoid huge limits      | Prevent node pressure  |
| Monitor usage          | Use Prometheus/Grafana |
| Use HPA/VPA            | Autoscaling            |
| Start small            | Tune gradually         |
| Use LimitRange         | Namespace defaults     |

---

# 18. LimitRange Example

Defines default resources per namespace.

```yaml
apiVersion: v1
kind: LimitRange

metadata:
  name: default-limits

spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"

    defaultRequest:
      cpu: "200m"
      memory: "256Mi"

    type: Container
```

---

# 19. ResourceQuota Example

Controls total namespace usage.

```yaml
apiVersion: v1
kind: ResourceQuota

metadata:
  name: team-a-quota

spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi

    limits.cpu: "8"
    limits.memory: 16Gi
```

---

# 20. Relationship with HPA & VPA

| Component | Uses Requests/Limits? |
| --------- | --------------------- |
| HPA       | Uses CPU requests     |
| VPA       | Adjusts requests      |
| Scheduler | Uses requests         |
| kubelet   | Uses limits           |

---

# 21. Common Interview Questions

---

## Q1. Difference between Request and Limit?

| Request             | Limit                |
| ------------------- | -------------------- |
| Guaranteed minimum  | Maximum allowed      |
| Used for scheduling | Used for enforcement |

---

## Q2. What happens if CPU exceeds limit?

CPU throttled.

---

## Q3. What happens if Memory exceeds limit?

Container killed → OOMKilled.

---

## Q4. Which QoS class is best?

Guaranteed.

---

# 22. Real Production Strategy

Typical production setup:

| Application Type | Request           | Limit      |
| ---------------- | ----------------- | ---------- |
| API Server       | Medium            | Medium     |
| Java App         | Higher Memory     | Controlled |
| Batch Job        | Low Request       | High Limit |
| Monitoring       | Stable Guaranteed | Stable     |

---

# 23. Full End-to-End Flow

```text
Developer Defines:
Requests + Limits
         |
         v

Scheduler Uses Requests
         |
         v

Pod Scheduled to Node
         |
         v

Container Runtime Enforces Limits
         |
         +------------------+
         |                  |
         v                  v

CPU Overuse         Memory Overuse
Throttled           OOMKilled
```

---

# 24. Recommended Learning Order

1. Pod Basics
2. Requests
3. Limits
4. QoS
5. LimitRange
6. ResourceQuota
7. HPA
8. VPA
9. Cluster Autoscaler
10. Monitoring

---

# 25. Important Commands Cheat Sheet

| Command                  | Purpose          |
| ------------------------ | ---------------- |
| `kubectl top pod`        | Pod usage        |
| `kubectl top node`       | Node usage       |
| `kubectl describe pod`   | Events/resources |
| `kubectl get quota`      | ResourceQuota    |
| `kubectl get limitrange` | LimitRange       |
| `kubectl describe node`  | Node capacity    |

---

# 26. Summary

| Concept       | Purpose                 |
| ------------- | ----------------------- |
| Requests      | Scheduling guarantee    |
| Limits        | Runtime control         |
| CPU limit     | Throttle                |
| Memory limit  | Kill                    |
| QoS           | Priority/stability      |
| LimitRange    | Namespace defaults      |
| ResourceQuota | Namespace maximum usage |

---

# Final Memory Trick

```text
REQUEST  = Reservation
LIMIT    = Restriction
CPU      = Throttle
MEMORY   = Kill
```
