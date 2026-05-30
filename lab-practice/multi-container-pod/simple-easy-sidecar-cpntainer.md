## Simple Example: Web Server + Log Viewer

### Sidecar Container (Very Simple example)

A **Sidecar Container** is a helper container that runs together with the main application container in the same Pod.

### Example

Suppose you have:

* **Container 1:** Nginx Web Server (Main Container)
* **Container 2:** Log Viewer (Sidecar Container)

```text id="v18dpc"
Pod
│
├── Nginx (Main Container)
│      │
│      └── Creates logs
│
└── Log Viewer (Sidecar)
       │
       └── Reads logs
```

### Simple YAML

```yaml id="swdb6o"
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-demo

spec:
  containers:
  - name: nginx
    image: nginx

  - name: helper
    image: busybox
    command: ["sh", "-c", "while true; do echo monitoring nginx; sleep 10; done"]
```

### Remember

```text id="9v8e5i"
Main Container  = Does the job
Sidecar Container = Helps the main container
```

**Examples of Sidecars:**

* Log collector
* Monitoring agent
* Proxy (Envoy)
* Security agent

### Interview One-Liner

> A Sidecar Container is a helper container that runs alongside the main application container in the same Pod to provide supporting features such as logging, monitoring, or proxy services.


### Scenario

* Main container = Nginx web server
* Sidecar container = Continuously watches Nginx logs
* Both share the same log folder

### Diagram

```text
                 Kubernetes Pod
┌─────────────────────────────────┐
│                                 │
│  Container 1 (Main App)         │
│  nginx                          │
│                                 │
│  Writes logs                    │
│        │                        │
│        ▼                        │
│   Shared Volume                 │
│        ▲                        │
│        │                        │
│  Container 2 (Sidecar)          │
│  Log Viewer                     │
│  tail -f access.log             │
│                                 │
└─────────────────────────────────┘
```

---

## YAML Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-demo

spec:
  volumes:
  - name: shared-logs
    emptyDir: {}

  containers:

  - name: app
    image: busybox
    command:
    - sh
    - -c
    - |
      while true
      do
        echo "Hello Kubernetes" >> /logs/app.log
        sleep 5
      done

    volumeMounts:
    - name: shared-logs
      mountPath: /logs

  - name: sidecar
    image: busybox
    command:
    - sh
    - -c
    - tail -f /logs/app.log

    volumeMounts:
    - name: shared-logs
      mountPath: /logs
```

---

## How It Works

### Step 1: Pod Starts

```text
Pod
│
├── app container
└── sidecar container
```

### Step 2: App Container Writes Logs

```text
Hello Kubernetes
Hello Kubernetes
Hello Kubernetes
```

saved to:

```bash
/logs/app.log
```

### Step 3: Sidecar Reads Logs

```bash
tail -f /logs/app.log
```

Output:

```text
Hello Kubernetes
Hello Kubernetes
Hello Kubernetes
```

---

## Verify It

Create pod:

```bash
kubectl apply -f sidecar.yaml
```

Check containers:

```bash
kubectl get pod sidecar-demo
```

View app container logs:

```bash
kubectl logs sidecar-demo -c app
```

View sidecar container logs:

```bash
kubectl logs sidecar-demo -c sidecar
```

---

## Easy Memory Trick

```text
Main Container
    =
Does the actual work

Sidecar Container
    =
Helps the main container
```

Real-life analogy:

```text
Motorcycle = Main Container
Sidecar Seat = Sidecar Container
```

The motorcycle does the main job (moving).

The sidecar helps by carrying extra luggage/passengers, but it cannot operate independently.
