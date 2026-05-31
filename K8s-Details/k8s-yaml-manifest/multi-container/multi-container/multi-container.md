# Multi-Container Pod

Think of a **Pod** as a **single house**.

* Containers inside the Pod are people living in the same house.
* They share the same network (same IP).
* They can share storage (Volumes).

---

#  Multi-Container Pod

A pod can contain multiple containers that work together.

## Real-Time Example

Suppose you have:

* Nginx Web Server
* Log Collector

Both need to run together.

```text
Pod
│
├── Nginx Container
│
└── Log Collector Container
```

### Design Diagram

```text
+----------------------------------+
|           Pod                    |
|                                  |
|  +-----------+   +-----------+   |
|  |  Nginx    |   | Fluentd   |   |
|  | Container |   | Container |   |
|  +-----------+   +-----------+   |
|                                  |
|     Shared Volume               |
+----------------------------------+
```

---

### Example YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:

  - name: nginx
    image: nginx
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html

  - name: busybox
    image: busybox
    command: ["/bin/sh","-c"]
    args:
      - while true;
        do echo "Hello Kubernetes" > /data/index.html;
        sleep 10;
        done
    volumeMounts:
    - name: shared-data
      mountPath: /data

  volumes:
  - name: shared-data
    emptyDir: {}
```

### Flow

```text
Busybox writes file
        │
        ▼
Shared Volume
        │
        ▼
Nginx serves webpage
```

---

# Complete Lifecycle Comparison

```text
                 POD
                  │
                  ▼

         Init Container
                  │
          (Runs Once)
                  │
                  ▼

     Main Application Container
                  │
                  │
                  ▼

        Sidecar Container
      (Runs Alongside App)
```

---

# Multi-Container vs Init vs Sidecar

| Feature             | Multi-Container Pod | Init Container | Sidecar Container |
| ------------------- | ------------------- | -------------- | ----------------- |
| Runs Before App     | No                  | Yes            | No                |
| Runs Continuously   | Yes                 | No             | Yes               |
| Used For Setup      | No                  | Yes            | No                |
| Used For Logging    | Sometimes           | No             | Yes               |
| Used For Monitoring | Sometimes           | No             | Yes               |
| Restarts With App   | Yes                 | N/A            | Yes               |
| Execution Order     | Parallel            | Sequential     | Parallel          |

---

### Easy Memory Trick

🏗️ **Building Construction Example**

```text
Init Container
    =
Workers preparing the building

Main Container
    =
People living in building

Sidecar Container
    =
Security Guard / Cleaner
working continuously
```

**Init = Setup First**

**Main Container = Actual Application**

**Sidecar = Helper running beside the application**
