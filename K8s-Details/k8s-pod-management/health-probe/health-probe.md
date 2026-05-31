# Health Probes in Kubernetes

A **Health Probe** is a mechanism used by Kubernetes to check whether a container is:

* Running properly
* Ready to accept traffic
* Started successfully

Kubernetes performs these checks automatically and takes action based on the result.

---

# Types of Health Probes

| Probe Type      | Purpose                                          | Action if Failed                     |
| --------------- | ------------------------------------------------ | ------------------------------------ |
| Liveness Probe  | Checks if application is alive                   | Container is restarted               |
| Readiness Probe | Checks if application is ready to serve requests | Pod removed from Service endpoints   |
| Startup Probe   | Checks if application has started successfully   | Container restarted if startup fails |

---

# 1. Liveness Probe

### Purpose

Checks whether the application is still running.

### Example Scenario

A Java application hangs due to memory issues.

Without a liveness probe:

* Pod = Running
* Application = Stuck
* Users cannot access service

With a liveness probe:

* Kubernetes detects failure
* Restarts container automatically

---

## Liveness Probe YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-liveness
spec:
  containers:
  - name: nginx
    image: nginx

    livenessProbe:
      httpGet:
        path: /
        port: 80

      initialDelaySeconds: 10
      periodSeconds: 5
```

### Flow

```text
Pod Running
     │
     ▼
Probe Checks /
     │
     ▼
200 OK ?
 ├─ Yes → Continue
 └─ No  → Restart Container
```

---

# 2. Readiness Probe

### Purpose

Checks if application is ready to receive traffic.

### Example Scenario

Application startup takes 30 seconds.

Without readiness probe:

* Service sends traffic immediately
* Requests fail

With readiness probe:

* Traffic waits until application becomes ready

---

## Readiness Probe YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-readiness
spec:
  containers:
  - name: nginx
    image: nginx

    readinessProbe:
      httpGet:
        path: /
        port: 80

      initialDelaySeconds: 5
      periodSeconds: 5
```

### Flow

```text
Pod Started
     │
     ▼
Ready Check
     │
     ▼
Ready?
 ├─ Yes → Add to Service
 └─ No  → Don't send traffic
```

---

# 3. Startup Probe

### Purpose

Used for slow-starting applications.

Example:

* Spring Boot
* Tomcat
* Large Java applications

These may take 1–2 minutes to start.

Without startup probe:

* Liveness probe may fail
* Kubernetes restarts container repeatedly

---

## Startup Probe YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-startup
spec:
  containers:
  - name: nginx
    image: nginx

    startupProbe:
      httpGet:
        path: /
        port: 80

      failureThreshold: 30
      periodSeconds: 10
```

### Flow

```text
Container Starts
       │
       ▼
Startup Probe Runs
       │
       ▼
Started?
 ├─ Yes → Enable Liveness & Readiness
 └─ No  → Keep Checking
```

---

# Probe Methods

Kubernetes supports 3 probe methods.

| Method       | Usage                        |
| ------------ | ---------------------------- |
| HTTP GET     | Check URL                    |
| TCP Socket   | Check Port                   |
| Exec Command | Run Command Inside Container |

---

# HTTP Probe Example

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
```

---

# TCP Probe Example

Checks whether port is listening.

```yaml
livenessProbe:
  tcpSocket:
    port: 3306

  initialDelaySeconds: 10
```

### Real-time Use

```text
MySQL
PostgreSQL
MongoDB
Redis
```

---

# Exec Probe Example

Runs command inside container.

```yaml
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
```

If file exists → Success

If file missing → Failure

---

# Real-Time Production Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp

spec:
  replicas: 3

  selector:
    matchLabels:
      app: webapp

  template:
    metadata:
      labels:
        app: webapp

    spec:
      containers:
      - name: webapp
        image: nginx

        startupProbe:
          httpGet:
            path: /
            port: 80
          failureThreshold: 30
          periodSeconds: 10

        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5

        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
```

---

# Important Parameters

| Parameter           | Meaning                     |
| ------------------- | --------------------------- |
| initialDelaySeconds | Wait before first check     |
| periodSeconds       | How often to check          |
| timeoutSeconds      | Probe timeout               |
| successThreshold    | Success count needed        |
| failureThreshold    | Failure count before action |

---

# CKA Exam Quick Notes

```text
Liveness Probe
--------------
Is app alive?
Failure = Restart Container

Readiness Probe
---------------
Is app ready?
Failure = Remove from Service

Startup Probe
-------------
Did app start?
Failure = Restart Container

HTTP GET
TCP Socket
Exec Command
```

### Validation Commands

```bash
kubectl get pods

kubectl describe pod <pod-name>

kubectl logs <pod-name>

kubectl get endpoints

kubectl exec -it <pod-name> -- sh
```

### Check Probe Events

```bash
kubectl describe pod nginx-liveness
```

Look for:

```text
Liveness probe failed
Readiness probe failed
Startup probe failed
Killing container
Container restarted
```

This is the typical interview answer:

**Liveness = "Is the application alive?"**
**Readiness = "Can the application serve traffic?"**
**Startup = "Has the application finished starting?"**
