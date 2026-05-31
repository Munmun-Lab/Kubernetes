# Kubernetes Autoscaling

Autoscaling means Kubernetes automatically adjusts resources based on workload demand.

There are **3 types of autoscaling**:

| Autoscaler                      | Scales            | Example           |
| ------------------------------- | ----------------- | ----------------- |
| HPA (Horizontal Pod Autoscaler) | Number of Pods    | 2 Pods → 10 Pods  |
| VPA (Vertical Pod Autoscaler)   | CPU/Memory of Pod | 500Mi → 2Gi RAM   |
| Cluster Autoscaler              | Number of Nodes   | 3 Nodes → 5 Nodes |


---

### Update Modes

| Mode     | Description                        |
| -------- | ---------------------------------- |
| Off      | Recommendation only                |
| Initial  | Set resources only at Pod creation |
| Auto     | Automatically update resources     |
| Recreate | Recreate Pod with new resources    |

---

# HPA vs VPA

| Feature              | HPA            | VPA           |
| -------------------- | -------------- | ------------- |
| Scales               | Pods           | CPU/Memory    |
| Method               | Horizontal     | Vertical      |
| Pod Restart Required | No             | Usually Yes   |
| Best For             | Stateless Apps | Stateful Apps |
| Scaling Speed        | Fast           | Slower        |
| Example              | Web Server     | Database      |
| Resource Change      | No             | Yes           |

---

# Real-Time Example

## HPA Use Case

```text
Application: E-commerce Website

Normal:
2 Pods

Sale Starts:
CPU = 90%

HPA:
2 Pods → 5 Pods → 10 Pods
```

Perfect for:

* Nginx
* Apache
* Frontend Apps
* APIs
* Microservices

---

## VPA Use Case

```text
Application: PostgreSQL Database

Current:
CPU=500m
Memory=1Gi

Usage Increased

VPA:
CPU=2 Core
Memory=4Gi
```

Perfect for:

* Databases
* Kafka
* Elasticsearch
* Stateful applications

---

# Can HPA and VPA be used together?

Generally **No** for CPU/Memory scaling because they can conflict:

```text
HPA says:
Add Pods

VPA says:
Increase CPU/Memory
```

Both may react to the same metric and cause instability.

Common practice:

```text
HPA → CPU-based scaling
VPA → Recommendation mode only (Off)
```

---

### Easy way to remember

```text
HPA = More Pods
      (Horizontal)

VPA = Bigger Pods
      (Vertical)

Cluster Autoscaler = More Nodes
```

```text
HPA  → Scale OUT / IN
VPA  → Scale UP / DOWN
CA   → Add/Remove Nodes
```
