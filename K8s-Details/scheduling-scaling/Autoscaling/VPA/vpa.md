#  VPA (Vertical Pod Autoscaler)

### What it does

Increases or decreases CPU/Memory assigned to a Pod.

### Example

Before:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
```

Application requires more memory.

VPA updates:

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
```

### Flow

```text
Pod
 │
Memory usage high
 │
 ▼
VPA
 │
 ▼
Increase CPU/RAM
 │
 ▼
Pod Restart
```
