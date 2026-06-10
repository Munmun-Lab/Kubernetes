# Kubernetes ConfigMap – Complete Understanding

## What is a ConfigMap?

A **ConfigMap** stores application configuration separately from container images.

ConfigMap provides service awareness by supplying service names, ports, URLs, and other non-sensitive configuration values to Pods, allowing applications to locate and communicate with Kubernetes Services without hardcoding those details into the container image.

Instead of hardcoding configuration inside a Pod or Docker image:

❌ Bad

```yaml
env:
- name: DB_HOST
  value: mysql-server
```

✅ Better

Store configuration in a ConfigMap and consume it in Pods.

---

# Why ConfigMap?

Imagine your application needs:

```text
Database Host = mysql-server
Database Port = 3306
Environment = Production
```

If these values change, you don't want to rebuild the image.

ConfigMap allows:

```text
Image = Same
Configuration = Changes
```

---

# Real-World Example

Application:

```text
Online Shopping App
```

Configurations:

```text
DB_HOST=mysql-prod
DB_PORT=3306
APP_ENV=production
```

Store these in ConfigMap.

---

# Method 1: Create ConfigMap from YAML

## configmap.yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config

data:
  APP_ENV: production
  DB_HOST: mysql-server
  DB_PORT: "3306"
```

Apply:

```bash
kubectl apply -f configmap.yaml
```

Verify:

```bash
kubectl get configmap
```

```bash
kubectl describe configmap app-config
```

---

# Method 2: Create ConfigMap from Command

```bash
kubectl create configmap app-config \
--from-literal=APP_ENV=production \
--from-literal=DB_HOST=mysql-server \
--from-literal=DB_PORT=3306
```

Verify:

```bash
kubectl get cm
```

---

# View ConfigMap YAML

```bash
kubectl get configmap app-config -o yaml
```

Output:

```yaml
data:
  APP_ENV: production
  DB_HOST: mysql-server
  DB_PORT: "3306"
```

---

# Using ConfigMap as Environment Variables

## Pod Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-configmap
spec:
  containers:
  - name: nginx
    image: nginx

    env:
    - name: APP_ENV
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_ENV
```

Check:

```bash
kubectl exec -it nginx-configmap -- env
```

Output:

```text
APP_ENV=production
```

---

# Import Entire ConfigMap

Instead of one key:

```yaml
envFrom:
- configMapRef:
    name: app-config
```

Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: nginx

    envFrom:
    - configMapRef:
        name: app-config
```

Inside container:

```bash
kubectl exec -it app-pod -- env
```

Output:

```text
APP_ENV=production
DB_HOST=mysql-server
DB_PORT=3306
```

---

# ConfigMap as Volume

Very common in production.

ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config

data:
  app.conf: |
    server=nginx
    port=80
```

---

## Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-volume
spec:
  containers:
  - name: nginx
    image: nginx

    volumeMounts:
    - name: config-volume
      mountPath: /etc/config

  volumes:
  - name: config-volume
    configMap:
      name: web-config
```

---

Check Mounted File

```bash
kubectl exec -it nginx-volume -- ls /etc/config
```

Output:

```text
app.conf
```

Read File:

```bash
kubectl exec -it nginx-volume -- cat /etc/config/app.conf
```

Output:

```text
server=nginx
port=80
```

---

# Create ConfigMap from File

File:

```text
app.properties
```

```text
DB_HOST=mysql
DB_PORT=3306
```

Create:

```bash
kubectl create configmap app-config \
--from-file=app.properties
```

Verify:

```bash
kubectl describe cm app-config
```

---

# ConfigMap Flow

```text
        ConfigMap
             │
             │
    ┌────────┴────────┐
    │                 │
    ▼                 ▼

 Environment      Volume Mount
 Variables            Files
    │                 │
    ▼                 ▼

 Application Reads Configuration
```

---

# Update ConfigMap

Edit:

```bash
kubectl edit configmap app-config
```

or

```bash
kubectl apply -f configmap.yaml
```

---

# Important Behavior

### Environment Variables

```yaml
env:
```

or

```yaml
envFrom:
```

After ConfigMap changes:

❌ Pod does NOT automatically get updated values.

Need restart:

```bash
kubectl rollout restart deployment nginx
```

---

### Volume Mount

```yaml
volumeMounts:
```

ConfigMap updates are usually reflected automatically in mounted files (within a short sync period).

No pod restart required in many cases.

---

# ConfigMap vs Secret

| Feature         | ConfigMap | Secret |
| --------------- | --------- | ------ |
| Stores Config   | Yes       | Yes    |
| Stores Password | No        | Yes    |
| Base64 Encoded  | No        | Yes    |
| DB Host         | Yes       | No     |
| API Key         | No        | Yes    |
| Username        | No        | Yes    |

Example:

### ConfigMap

```text
DB_HOST=mysql
APP_ENV=prod
```

### Secret

```text
DB_PASSWORD=MyPass123
AWS_SECRET_KEY=xxxxx
```

---

# Useful Commands

Create:

```bash
kubectl create configmap app-config --from-literal=env=prod
```

List:

```bash
kubectl get cm
```

Describe:

```bash
kubectl describe cm app-config
```

YAML Output:

```bash
kubectl get cm app-config -o yaml
```

Delete:

```bash
kubectl delete cm app-config
```

---

# Interview Answer

**ConfigMap is a Kubernetes object used to store non-sensitive configuration data as key-value pairs. It allows applications to consume configuration through environment variables, command-line arguments, or mounted files, keeping configuration separate from container images.**

### Real Example

```text
ConfigMap:
DB_HOST=mysql
DB_PORT=3306
APP_ENV=production

Pod:
Reads values from ConfigMap

Benefit:
Change configuration without rebuilding the image.
```
