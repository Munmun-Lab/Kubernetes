# Init Container

An Init Container runs BEFORE the main application container starts.

### Purpose

* Download configuration
* Verify dependencies
* Wait for database
* Create files/directories

---

## Real-Time Example

A web application requires:

```text
config.txt
```

before it starts.

Init Container creates the file.

Then application starts.

---

### Flowchart

```text
Pod Created
     │
     ▼
Init Container Starts
     │
     ▼
Creates Config File
     │
     ▼
Init Container Exits
     │
     ▼
Application Container Starts
     │
     ▼
Running
```

---

### Design Diagram

```text
+--------------------------------------+
|               Pod                    |
|                                      |
|  Init Container                      |
|  ┌─────────────┐                     |
|  │ Setup File  │                     |
|  └─────────────┘                     |
|          │                           |
|          ▼                           |
|  Shared Volume                       |
|          │                           |
|          ▼                           |
|  Main Application Container          |
|                                      |
+--------------------------------------+
```

---

### Example YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:

  initContainers:
  - name: init-container
    image: busybox
    command:
    - sh
    - -c
    - echo "Welcome" > /work-dir/index.html
    volumeMounts:
    - name: workdir
      mountPath: /work-dir

  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html

  volumes:
  - name: workdir
    emptyDir: {}
```

### Execution Sequence

```text
Init Container
      │
      ▼
Success
      │
      ▼
Nginx Starts
```

If Init Container fails:

```text
Init Container
      │
      ▼
Failed
      │
      ▼
Pod Not Started
```

---

# **Q: Difference between Init Container and Sidecar Container?**

| Init Container             | Sidecar Container         |
| -------------------------- | ------------------------- |
| Runs before application    | Runs with application     |
| Executes once              | Runs continuously         |
| Used for initialization    | Used for supporting tasks |
| Must complete successfully | Runs throughout pod life  |

