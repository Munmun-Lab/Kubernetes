# Real-Time Kubernetes Requests & Limits Lab

Imagine you have an Nginx web server running in Kubernetes.

---

## Step 1: Create Pod

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
        cpu: "100m"
        memory: "128Mi"

      limits:
        cpu: "200m"
        memory: "256Mi"
```

Apply:

```bash
kubectl apply -f pod.yaml
```

Verify:

```bash
kubectl get pod
```

---

## Step 2: Check Resource Allocation

```bash
kubectl describe pod nginx-resource-demo
```

Output:

```text
Requests:
  cpu:     100m
  memory:  128Mi

Limits:
  cpu:     200m
  memory:  256Mi
```

Meaning:

```text
Guaranteed:
CPU = 0.1 Core
RAM = 128Mi

Maximum:
CPU = 0.2 Core
RAM = 256Mi
```

---

## Step 3: Generate CPU Load

Enter Pod:

```bash
kubectl exec -it nginx-resource-demo -- bash
```

Install stress tool:

```bash
apt update
apt install stress -y
```

Run:

```bash
stress --cpu 2
```

This tries to consume 2 CPU cores.

---

## Step 4: Observe CPU Throttling

Open another terminal:

```bash
kubectl top pod nginx-resource-demo
```

Output:

```text
NAME                  CPU(cores)   MEMORY(bytes)
nginx-resource-demo   200m         50Mi
```

Notice:

```text
Limit = 200m
Usage = 200m
```

Even though stress wants 2 CPUs:

```text
Requested = 100m
Limit     = 200m
Actual    = 200m
```

Kubernetes throttles CPU.

---

## Step 5: Generate Memory Load

Inside Pod:

```bash
stress --vm 1 --vm-bytes 300M
```

This tries to allocate:

```text
300 MB RAM
```

But limit is:

```text
256Mi
```

---

## Step 6: Watch Pod

```bash
kubectl get pod -w
```

Output:

```text
NAME                  READY   STATUS      RESTARTS
nginx-resource-demo   1/1     Running     0

nginx-resource-demo   0/1     OOMKilled   1

nginx-resource-demo   1/1     Running     1
```

Container gets killed and restarted.

---

# Visual Flow

```text
          User Traffic
                │
                ▼

         Nginx Container
                │
      ┌─────────┴─────────┐
      │                   │
      ▼                   ▼

 CPU Usage           Memory Usage
      │                   │

 Limit=200m         Limit=256Mi
      │                   │

 CPU > 200m ?       RAM > 256Mi ?
      │                   │
      ▼                   ▼

 Throttled          OOMKilled
```

---

# Real Production Example

Suppose you have a Java application.

```yaml
resources:
  requests:
    cpu: "1"
    memory: "2Gi"

  limits:
    cpu: "2"
    memory: "4Gi"
```

### During Normal Hours

```text
CPU = 700m
RAM = 1.5Gi
```

Runs fine.

### During Peak Traffic

```text
CPU = 1.8
RAM = 3Gi
```

Still fine.

### Huge Traffic Spike

```text
CPU = 3
RAM = 5Gi
```

Result:

```text
CPU → throttled to 2 cores
RAM → exceeds 4Gi
Container → OOMKilled
```

---

# Most Common Interview Scenario

Node Capacity:

```text
4 CPU
8 Gi RAM
```

Pod A:

```yaml
requests:
  cpu: 2
  memory: 4Gi
```

Pod B:

```yaml
requests:
  cpu: 2
  memory: 4Gi
```

Node becomes full:

```text
CPU Reserved = 4/4
RAM Reserved = 8/8
```

Now Pod C:

```yaml
requests:
  cpu: 500m
  memory: 512Mi
```

Result:

```text
Pending
```

Why?

```text
Scheduler checks REQUESTS only.
```

Even if Pods A and B are currently using very little CPU, the node has no remaining requested capacity available for scheduling.

This is the most practical way to understand **Requests = scheduling guarantee** and **Limits = runtime restriction**.
