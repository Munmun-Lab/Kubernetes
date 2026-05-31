# Sidecar Container

A Sidecar is a helper container running alongside the main application.

Both start together and run continuously.

---

## Real-Time Example

Application writes logs.

```text
/var/log/app.log
```

Sidecar reads logs and sends them to:

* Splunk
* ELK
* Datadog
* Log Insight

---

### Design Diagram

```text
+----------------------------------------+
|                Pod                     |
|                                        |
| +------------+                         |
| | Application|                         |
| +------------+                         |
|        │                               |
|        ▼                               |
|   Shared Volume                        |
|        ▲                               |
|        │                               |
| +------------+                         |
| | Sidecar    |                         |
| | Log Agent  |                         |
| +------------+                         |
+----------------------------------------+
```

---

### Flowchart

```text
Application Running
        │
        ▼
Writes Logs
        │
        ▼
Shared Volume
        │
        ▼
Sidecar Reads Logs
        │
        ▼
Splunk / ELK
```

---

### Example YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-demo

spec:
  containers:

  - name: app
    image: busybox
    command:
    - sh
    - -c
    - while true; do
        echo "$(date) App Running" >> /var/log/app.log;
        sleep 5;
      done

    volumeMounts:
    - name: logs
      mountPath: /var/log

  - name: sidecar
    image: busybox
    command:
    - sh
    - -c
    - tail -f /var/log/app.log

    volumeMounts:
    - name: logs
      mountPath: /var/log

  volumes:
  - name: logs
    emptyDir: {}
```

---