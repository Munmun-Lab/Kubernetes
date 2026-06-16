# Kubernetes Network Policy Project using Kind and Calico

## Objective

This project demonstrates:

* Creating a Kind Kubernetes cluster with the default CNI disabled
* Installing Calico as the networking solution
* Deploying frontend, backend, and db applications
* Exposing applications using NodePort services
* Verifying pod-to-pod connectivity
* Implementing Kubernetes Network Policies
* Restricting MySQL database access so that only the backend pod can connect on port 3306

---

# Architecture

```text
Frontend Pod  -----> Backend Pod -----> DB Pod (MySQL)
       |                   |                  |
       +-------------------+------------------+
                 Connectivity Allowed

After Network Policy:

Frontend Pod  ----X----> DB Pod:3306
Backend Pod   ---------> DB Pod:3306
```

---

# Prerequisites

* Docker
* Kind
* kubectl

Verify installation:

```bash
docker --version
kind version
kubectl version --client
```

---

# Step 1: Create Kind Cluster with Default CNI Disabled

Create file:

## kind-config.yaml

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

networking:
  disableDefaultCNI: true
```

Create cluster:

```bash
kind create cluster \
--name calico-lab \
--config kind-config.yaml
```

Verify:

```bash
kubectl get nodes
```

Expected:

```text
STATUS = NotReady
```

Nodes remain NotReady until a CNI plugin is installed.

---

# Step 2: Install Calico

Install Calico:

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
```

Verify:

```bash
kubectl get pods -n kube-system
```

Verify nodes:

```bash
kubectl get nodes
```

Expected:

```text
STATUS = Ready
```

---

# Step 3: Create Frontend Deployment

## frontend.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1

  selector:
    matchLabels:
      app: frontend

  template:
    metadata:
      labels:
        app: frontend

    spec:
      containers:
      - name: frontend
        image: nginx

        ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f frontend.yaml
```

---

# Step 4: Create Backend Deployment

## backend.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend

spec:
  replicas: 1

  selector:
    matchLabels:
      app: backend

  template:
    metadata:
      labels:
        app: backend

    spec:
      containers:
      - name: backend
        image: nginx

        ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f backend.yaml
```

---

# Step 5: Create DB Deployment

## db.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db

spec:
  replicas: 1

  selector:
    matchLabels:
      app: db

  template:
    metadata:
      labels:
        app: db

    spec:
      containers:
      - name: mysql
        image: mysql:8

        env:
        - name: MYSQL_ROOT_PASSWORD
          value: root123

        ports:
        - containerPort: 3306
```

Apply:

```bash
kubectl apply -f db.yaml
```

---

# Step 6: Create NodePort Services

## frontend-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend

spec:
  type: NodePort

  selector:
    app: frontend

  ports:
  - port: 80
    targetPort: 80
```

## backend-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend

spec:
  type: NodePort

  selector:
    app: backend

  ports:
  - port: 80
    targetPort: 80
```

## db-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db

spec:
  type: NodePort

  selector:
    app: db

  ports:
  - port: 3306
    targetPort: 3306
```

Apply:

```bash
kubectl apply -f frontend-service.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f db-service.yaml
```

Verify:

```bash
kubectl get svc
```

---

# Step 7: Verify Deployments

```bash
kubectl get deployments
kubectl get pods -o wide
kubectl get svc
```

---

# Step 8: Connectivity Testing

Open shell inside frontend pod:

```bash
kubectl exec -it deployment/frontend -- sh
```

Test backend:

```bash
wget -qO- http://backend
```

Test db:

```bash
nc -zv db 3306
```

Exit:

```bash
exit
```

Open backend pod:

```bash
kubectl exec -it deployment/backend -- sh
```

Test db:

```bash
nc -zv db 3306
```

Expected:

```text
Connection succeeded
```

---

# Step 9: Create Network Policy

Goal:

Allow only backend pod to access db pod on TCP port 3306.

## network-policy.yaml

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy

metadata:
  name: allow-backend-db

spec:
  podSelector:
    matchLabels:
      app: db

  policyTypes:
  - Ingress

  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend

    ports:
    - protocol: TCP
      port: 3306
```

Apply:

```bash
kubectl apply -f network-policy.yaml
```

---

# Step 10: Validate Network Policy

From frontend:

```bash
kubectl exec -it deployment/frontend -- sh
```

Test:

```bash
nc -zv db 3306            # Netcat, similar like telnet to check for testing connectivity to a specific port
```

Expected:

```text
Connection refused
or
Connection timed out
```

---

From backend:

```bash
kubectl exec -it deployment/backend -- sh
```

Test:

```bash
nc -zv db 3306
```

Expected:

```text
Connection succeeded
```

---

# Verification Commands

```bash
kubectl get pods
kubectl get svc
kubectl get networkpolicy
kubectl describe networkpolicy allow-backend-db
```

---

# Project Outcome

Successfully:

* Created Kind cluster with default CNI disabled
* Installed Calico CNI
* Created frontend deployment
* Created backend deployment
* Created MySQL database deployment
* Exposed applications using NodePort services
* Verified pod connectivity
* Implemented NetworkPolicy
* Restricted MySQL access to backend pod only
* Blocked frontend access to MySQL on port 3306


