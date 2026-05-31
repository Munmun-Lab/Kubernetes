#  HPA (Horizontal Pod Autoscaler)

### What it does

Increases or decreases the **number of Pod replicas**.

### Example

Current Load:

```text
Deployment: nginx
Replicas: 2
CPU Usage: 90%
Target CPU: 50%
```

HPA action:

```text
2 Pods → 4 Pods → 6 Pods
```

Traffic spreads across more Pods.

### Flow

```text
Users
  │
  ▼
Deployment
  │
  ▼
2 Pods
  │
CPU > 50%
  │
  ▼
HPA
  │
  ▼
6 Pods
```

### Requirements

```text
Metrics Server
CPU/Memory requests configured
```