# Selectors in Kubernetes

A **Selector** is a mechanism used by Kubernetes to **find, filter, and group resources based on Labels**.

Selectors allow Kubernetes objects such as Services, Deployments, ReplicaSets, and NetworkPolicies to identify and work with specific Pods based on labels. They provide dynamic resource discovery and grouping without relying on Pod names or IP addresses.

Without labels, selectors cannot work.

```text
Label    = Tag on an object
Selector = Search condition for that tag
```

---

## Real-Time Example

Suppose you have 3 Pods:

```text
Pod1 → app=nginx
Pod2 → app=nginx
Pod3 → app=mysql
```

If you run:

```bash
kubectl get pods -l app=nginx
```

Output:

```text
Pod1
Pod2
```

Kubernetes uses the selector:

```yaml
app: nginx
```

to find matching Pods.

---

## Where Selectors Are Used?

| Kubernetes Object | Purpose                         |
| ----------------- | ------------------------------- |
| Service           | Finds Pods to send traffic      |
| Deployment        | Manages matching Pods           |
| ReplicaSet        | Maintains desired replicas      |
| NetworkPolicy     | Applies rules to selected Pods  |
| Job/CronJob       | Can target resources via labels |

---

Flow:

```text
Service
   |
   | selector: app=nginx
   ▼
Nginx Pods
```

The Service automatically discovers all Pods with:

```yaml
app: nginx
```

---

# Types of Selectors

## 1. Equality-Based Selector

### Equal (=)

```bash
kubectl get pods -l app=nginx
```

or

```bash
kubectl get pods -l app==nginx
```

Meaning:

```text
Select Pods where app = nginx
```

---

### Not Equal (!=)

```bash
kubectl get pods -l app!=nginx
```

Meaning:

```text
Select Pods where app is NOT nginx
```

---

## 2. Set-Based Selector

### IN

```bash
kubectl get pods -l 'env in (dev,prod)'
```

Meaning:

```text
env=dev OR env=prod
```

---

### NOT IN

```bash
kubectl get pods -l 'env notin (test)'
```

Meaning:

```text
Everything except test
```

---

### Exists

```bash
kubectl get pods -l tier
```

Meaning:

```text
Any Pod containing label "tier"
```

Example:

```yaml
tier: frontend
```

```yaml
tier: backend
```

Both will match.

---

### Does Not Exist

```bash
kubectl get pods -l '!tier'
```

Meaning:

```text
Select Pods that do not have tier label
```

---

# Most Common Selector Commands

Get nginx Pods:

```bash
kubectl get pods -l app=nginx
```

Get production Pods:

```bash
kubectl get pods -l env=prod
```

Multiple labels:

```bash
kubectl get pods -l app=nginx,env=prod
```

Show labels:

```bash
kubectl get pods --show-labels
```

---

### Quick Memory Trick

```text
Labels   = Identity Card
Selectors = Search Filter

Service/Deployment
        |
        ▼
   Selector
        |
        ▼
 Matching Pods
```

**Rule:** No Labels → No Selectors → No automatic Pod discovery.
