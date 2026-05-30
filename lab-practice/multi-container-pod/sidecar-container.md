A **Sidecar Container** is a helper container that runs alongside the main application container in the same Pod.

## Real-World Example: Log Collection Sidecar

Imagine your application writes logs to a file, but you don't want to modify the application code to send logs to a logging platform.

### Architecture

```text
                    Kubernetes Pod
┌──────────────────────────────────────────┐
│                                          │
│  App Container                           │
│  ┌────────────────────────────────────┐  │
│  │ Writes logs to /var/log/app.log    │  │
│  └───────────────┬────────────────────┘  │
│                  │                       │
│                  ▼                       │
│          Shared Volume                  │
│                  ▲                       │
│                  │                       │
│  ┌───────────────┴────────────────────┐  │
│  │ Sidecar Container                  │  │
│  │ Reads logs and ships to ELK        │  │
│  └────────────────────────────────────┘  │
│                                          │
└──────────────────────────────────────────┘
```

---

## Kubernetes YAML Example

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
    - |
      while true; do
        echo "$(date) Application Running" >> /logs/app.log
        sleep 5
      done

    volumeMounts:
    - name: log-volume
      mountPath: /logs

  - name: log-sidecar
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

## What Happens?

### Step 1

Application container starts:

```text
app container
     │
     ▼
writes logs
     │
     ▼
/logs/app.log
```

Example log:

```text
2026-05-30 Application Running
2026-05-30 Application Running
```

### Step 2

Sidecar container starts:

```text
sidecar
    │
    ▼
tail -f /logs/app.log
```

### Step 3

Sidecar continuously reads new log entries and can:

* Send to ELK
* Send to Splunk
* Send to Datadog
* Send to CloudWatch

---

## Another Common Sidecar: Service Mesh Proxy

With Istio:

```text
Pod
│
├── Application Container
│
└── Envoy Sidecar
      │
      ├── Traffic Routing
      ├── TLS Encryption
      ├── Metrics
      └── Security Policies
```

Flow:

```text
Client
   │
   ▼
Envoy Sidecar
   │
   ▼
Application
```

The application doesn't need to know anything about TLS, retries, or traffic policies—the sidecar handles it.

---

## Most Common Sidecar Use Cases

| Use Case     | Sidecar Example      |
| ------------ | -------------------- |
| Logging      | Fluent Bit, Logstash |
| Monitoring   | Prometheus Exporter  |
| Service Mesh | Envoy Proxy          |
| Security     | Vault Agent          |
| Config Sync  | Config Reloader      |
| File Sync    | rsync sidecar        |

### Easy Interview Answer

**Question:** Why use a Sidecar Container?

**Answer:**
"A sidecar container extends the functionality of the main application container without changing the application code. Common uses include logging, monitoring, security, configuration management, and service mesh proxies."
