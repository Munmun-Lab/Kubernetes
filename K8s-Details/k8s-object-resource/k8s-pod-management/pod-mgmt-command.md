# Pod Management Commands

# Create Pod

```bash
kubectl apply -f pod.yaml
```

---

# List Pods

```bash
kubectl get pods
```

---

# Wide Output

```bash
kubectl get pods -o wide
```

---

# Watch Pods

```bash
kubectl get pods -w
```

---

# Describe Pod

```bash
kubectl describe pod pod1
```

---

# Pod Logs

```bash
kubectl logs pod1
```

---

# Follow Logs

```bash
kubectl logs -f pod1
```

---

# Execute Command Inside Pod

```bash
kubectl exec -it pod1 -- bash
```

---

# Delete Pod

```bash
kubectl delete pod pod1
```

---

# Force Delete Pod

```bash
kubectl delete pod pod1 --force --grace-period=0
```

---

# Export YAML

```bash
kubectl get pod pod1 -o yaml
```

---

# Edit Pod

```bash
kubectl edit pod pod1
```

---