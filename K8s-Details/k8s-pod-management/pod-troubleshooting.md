# Common Pod Troubleshooting

# Check Events

```bash
kubectl describe pod pod1
```

---

# Check Logs

```bash
kubectl logs pod1
```

---

# Check Previous Container Logs

```bash
kubectl logs pod1 --previous
```

---

# Check Node Issues

```bash
kubectl get nodes
```

---

# Common Pod Errors

| Error                | Meaning                       |
| -------------------- | ----------------------------- |
| CrashLoopBackOff     | Container crashing repeatedly |
| ImagePullBackOff     | Image download failed         |
| Pending              | Scheduling issue              |
| OOMKilled            | Out of memory                 |
| CreateContainerError | Container startup failure     |
