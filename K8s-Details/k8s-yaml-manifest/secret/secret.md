# Kubernetes Secrets

A **Secret** is a Kubernetes object used to store **sensitive information** such as:

* Database passwords
* API keys
* SSH keys
* TLS certificates
* Tokens

**A Secret is a Kubernetes object used to store and manage sensitive information such as passwords, API keys, certificates, and tokens. Applications can consume Secrets as environment variables or mounted files, keeping sensitive data separate from container images and application code.**

Instead of putting passwords directly in Pod YAML files, store them in a Secret and let the Pod read them.

---

## ConfigMap vs Secret

| ConfigMap          | Secret                                    |
| ------------------ | ----------------------------------------- |
| Non-sensitive data | Sensitive data                            |
| DB Host, Port      | DB Password                               |
| App Environment    | API Keys                                  |
| Plain text         | Base64 encoded (not encrypted by default) |

Example:

### ConfigMap

```text
DB_HOST=mysql-service
DB_PORT=3306
```

### Secret

```text
DB_PASSWORD=MyPassword123
```

---

# Real-Time Example

Assume:

```text
Database Service : mysql-service
Username         : admin
Password         : MyPassword123
```

Store the password in a Secret.

---

## Step 1: Create Secret from Command

```bash
kubectl create secret generic mysql-secret \
--from-literal=username=admin \
--from-literal=password=MyPassword123
```

Verify:

```bash
kubectl get secret
```

```bash
kubectl describe secret mysql-secret
```

---

## Step 2: View Secret YAML

```bash
kubectl get secret mysql-secret -o yaml
```

Output:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret

data:
  username: YWRtaW4=
  password: TXlQYXNzd29yZDEyMw==
```

Notice the values are Base64 encoded.

Decode:

```bash
echo YWRtaW4= | base64 --decode
```

Output:

```text
admin
```

---

## Step 3: Create Secret Using YAML

Generate Base64:

```bash
echo -n "admin" | base64
```

```bash
echo -n "MyPassword123" | base64
```

Create:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret

type: Opaque

data:
  username: YWRtaW4=
  password: TXlQYXNzd29yZDEyMw==
```

Apply:

```bash
kubectl apply -f secret.yaml
```

---

# Using Secret as Environment Variable

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-client
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh","-c","env && sleep 3600"]

    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: mysql-secret
          key: username

    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: mysql-secret
          key: password
```

Apply:

```bash
kubectl apply -f pod.yaml
```

Check:

```bash
kubectl exec -it mysql-client -- env | grep DB
```

Output:

```text
DB_USER=admin
DB_PASSWORD=MyPassword123
```

---

# Import Entire Secret

```yaml
envFrom:
- secretRef:
    name: mysql-secret
```

Pod gets all keys as environment variables.

---

# Secret as Volume

Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret

stringData:
  password: MyPassword123
```

Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-demo
spec:
  containers:
  - name: app
    image: nginx

    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secrets

  volumes:
  - name: secret-vol
    secret:
      secretName: db-secret
```

Apply:

```bash
kubectl apply -f pod.yaml
```

Verify:

```bash
kubectl exec -it secret-volume-demo -- ls /etc/secrets
```

Output:

```text
password
```

Read:

```bash
kubectl exec -it secret-volume-demo -- cat /etc/secrets/password
```

Output:

```text
MyPassword123
```

---

# Types of Secrets

| Type                                | Purpose                     |
| ----------------------------------- | --------------------------- |
| Opaque                              | Generic secrets             |
| kubernetes.io/tls                   | TLS certificates            |
| kubernetes.io/dockerconfigjson      | Docker registry credentials |
| kubernetes.io/service-account-token | Service Account token       |

---

# Service Awareness Example

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret

stringData:
  username: admin
  password: MyPassword123
```

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config

data:
  DB_HOST: mysql-service
  DB_PORT: "3306"
```

### Application Pod

```yaml
envFrom:
- configMapRef:
    name: app-config

- secretRef:
    name: db-secret
```

Application receives:

```text
DB_HOST=mysql-service
DB_PORT=3306
username=admin
password=MyPassword123
```

---

# Useful Commands

Create:

```bash
kubectl create secret generic mysecret \
--from-literal=password=Welcome123
```

List:

```bash
kubectl get secret
```

Describe:

```bash
kubectl describe secret mysecret
```

YAML:

```bash
kubectl get secret mysecret -o yaml
```

Delete:

```bash
kubectl delete secret mysecret
```

Decode:

```bash
kubectl get secret mysecret -o jsonpath='{.data.password}' | base64 --decode
```

---

### Easy Memory Trick

```text
ConfigMap = Configuration
Secret    = Passwords / Sensitive Data
```

```text
DB_HOST      → ConfigMap
DB_PORT      → ConfigMap
DB_PASSWORD  → Secret
```
