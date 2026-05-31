For **AWS EKS**, there are typically **two autoscaling layers**:

```text
Users
  │
  ▼
Application Load
  │
  ▼
HPA (Adds Pods)
  │
  ▼
More Pods Need Resources
  │
  ▼
Cluster Autoscaler / Karpenter
  │
  ▼
Adds EC2 Worker Nodes
```

---

# 1. EKS Deployment Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx

spec:
  replicas: 2

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
      - name: nginx
        image: nginx:latest

        resources:
          requests:
            cpu: 200m
            memory: 256Mi

          limits:
            cpu: 500m
            memory: 512Mi

        ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f nginx-deployment.yaml
```

---

# 2. HPA Example for EKS

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa

spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx

  minReplicas: 2
  maxReplicas: 10

  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

Apply:

```bash
kubectl apply -f nginx-hpa.yaml
```

---

# 3. Verify HPA

```bash
kubectl get hpa

kubectl describe hpa nginx-hpa

kubectl top pods
```

Expected:

```text
NAME        REFERENCE             TARGETS
nginx-hpa   Deployment/nginx      25%/50%
```

---

# 4. Generate Load

```bash
kubectl run load-generator \
--image=busybox \
--restart=Never \
-it -- sh
```

Run:

```sh
while true; do
  wget -q -O- http://nginx
done
```

Watch scaling:

```bash
kubectl get hpa -w

kubectl get pods -w
```

---

# 5. EKS Node Group Autoscaling

Your EKS Managed Node Group might be configured like this:

```text
Min Nodes      = 2
Desired Nodes  = 2
Max Nodes      = 5
```

When HPA creates more Pods than current nodes can host:

```text
2 Nodes
  │
  ▼
Resources Full
  │
  ▼
Cluster Autoscaler
  │
  ▼
3 Nodes
  │
  ▼
4 Nodes
```

---

# AWS CLI Example (Managed Node Group)

```bash
aws eks update-nodegroup-config \
  --cluster-name my-eks-cluster \
  --nodegroup-name workers \
  --scaling-config minSize=2,maxSize=5,desiredSize=2
```

This configures node scaling limits for the EKS worker nodes.

---

# Production Example

```text
Application: Online Shopping Site

Normal Day
-----------
2 Pods
2 Worker Nodes

Black Friday Sale
-----------------
CPU = 90%

HPA:
2 Pods -> 5 Pods -> 10 Pods

Nodes Become Full

Cluster Autoscaler:
2 Nodes -> 4 Nodes

Traffic Reduces

HPA:
10 Pods -> 2 Pods

Cluster Autoscaler:
4 Nodes -> 2 Nodes
```

---

# EKS Autoscaling Components

| Component          | Purpose                           |
| ------------------ | --------------------------------- |
| Metrics Server     | Provides CPU/Memory metrics       |
| HPA                | Scales Pods                       |
| VPA                | Adjusts Pod CPU/Memory requests   |
| Cluster Autoscaler | Scales EC2 worker nodes           |
| Karpenter          | Modern AWS-native node autoscaler |
| Managed Node Group | EC2 worker nodes managed by EKS   |

### Commands Used Frequently

```bash
# View HPA
kubectl get hpa

# View Pod Metrics
kubectl top pods

# View Node Metrics
kubectl top nodes

# View Deployments
kubectl get deploy

# Watch Pods
kubectl get pods -w

# View Nodes
kubectl get nodes

# Describe HPA
kubectl describe hpa nginx-hpa
```

In modern EKS environments, many organizations now use Karpenter instead of the traditional Cluster Autoscaler because it provisions EC2 capacity faster and more efficiently.
