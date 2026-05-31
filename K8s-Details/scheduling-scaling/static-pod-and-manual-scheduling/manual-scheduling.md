#  Manual Scheduling

## What is Manual Scheduling?

Normally Kubernetes Scheduler decides:

```text
Pod Created
      ↓
Scheduler selects node
      ↓
Pod Runs
```

Manual Scheduling means:

"You decide the node."

You bypass the scheduler.

---

## How?

Use:

```yaml
nodeName:
```

Example:

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: nginx-manual

spec:
  nodeName: worker1

  containers:
  - name: nginx
    image: nginx
```

Apply:

```bash
kubectl apply -f pod.yaml
```

Pod directly goes to:

```text
worker1
```

Scheduler is skipped.

---

## Flow of Manual Scheduling

Normal:

```text
Pod
 ↓
Scheduler
 ↓
Worker Node
```

Manual:

```text
Pod
 ↓
nodeName: worker1
 ↓
worker1
```

---

## Verify

Check nodes:

```bash
kubectl get nodes
```

Output:

```text
controlplane
worker1
worker2
```

Use:

```yaml
nodeName: worker2
```

Check:

```bash
kubectl get pod -o wide
```

Output:

```text
NAME            NODE
nginx-manual    worker2
```

---

# Real-Time Use Case

Suppose:

```text
worker1 = GPU Node
worker2 = Normal Node
```

You want AI workload on GPU node.

```yaml
nodeName: worker1
```

Pod always lands on worker1.

---

# Limitation of Manual Scheduling

Suppose:

```yaml
nodeName: worker5
```

But worker5 doesn't exist.

Result:

```text
Pod remains Pending
```

Because Scheduler is bypassed.

Kubernetes won't find another node.

---

# Static Pod vs Manual Scheduling

| Feature                | Static Pod      | Manual Scheduling |
| ---------------------- | --------------- | ----------------- |
| Created by             | Kubelet         | API Server        |
| Managed by             | Kubelet         | Kubernetes        |
| Scheduler used         | No              | No                |
| Manifest location      | Node filesystem | Anywhere          |
| kubectl apply required | No              | Yes               |
| Used for               | Control Plane   | Special workloads |
| nodeName needed        | No              | Yes               |
| API Server needed      | No              | Yes               |

---

# Interview Answer (2 Lines)

### Static Pod

> A Static Pod is a pod managed directly by kubelet from a manifest file stored on the node, usually under `/etc/kubernetes/manifests`.

### Manual Scheduling

> Manual Scheduling is the process of assigning a pod to a specific node using the `nodeName` field, bypassing the Kubernetes Scheduler.

### Easy Memory Trick

```text
Static Pod
= Kubelet creates the pod

Manual Scheduling
= Admin chooses the node
```

That's the simplest way to remember the difference.
