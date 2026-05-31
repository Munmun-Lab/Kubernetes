# Job in Kubernetes

A **Job** is used when you want a task to run **once** and then stop.

Unlike a Deployment, which keeps Pods running forever, a Job completes its work and exits.

---

## Simple Example

Suppose you want to:

```text
Print "Hello Kubernetes"
       │
       ▼
Task Completes
       │
       ▼
Pod Stops
```

This is a perfect use case for a Job.

---

# Job Flow

```text
Job
 │
 ▼
Create Pod
 │
 ▼
Run Task
 │
 ▼
Task Completed
 │
 ▼
Pod Finished
```

---

# Simple Job YAML

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-job

spec:
  template:
    spec:
      containers:
      - name: hello
        image: busybox
        command:
        - echo
        - "Hello Kubernetes"

      restartPolicy: Never
```

---

# What Happens?

```bash
kubectl apply -f job.yaml
```

Kubernetes:

```text
Job
 │
 ▼
Creates Pod
 │
 ▼
Runs:
echo "Hello Kubernetes"
 │
 ▼
Exits Successfully
 │
 ▼
Job Completed
```

---

# Check Job

```bash
kubectl get jobs
```

Example:

```text
NAME        COMPLETIONS   DURATION
hello-job   1/1           5s
```

### Meaning

```text
1/1
│
└── 1 successful completion out of 1 required
```

---

# Check Pod

```bash
kubectl get pods
```

Output:

```text
hello-job-abcde   Completed
```

Notice:

```text
Completed
```

not

```text
Running
```

because the task finished.

---

# View Logs

```bash
kubectl logs <pod-name>
```

Output:

```text
Hello Kubernetes
```

---

# Job vs Deployment

| Feature          | Job            | Deployment    |
| ---------------- | -------------- | ------------- |
| Runs Once        | ✅              | ❌             |
| Long Running App | ❌              | ✅             |
| Completes        | ✅              | ❌             |
| Example          | Backup, Report | Nginx, Apache |

---

## Visual Comparison

### Job

```text
Create Pod
     │
     ▼
Run Task
     │
     ▼
Complete
```

### Deployment

```text
Create Pod
     │
     ▼
Run Application
     │
     ▼
Keep Running Forever
```

---

# Real-World Uses

### Database Backup

```text
Job
 │
 ▼
Take Backup
 │
 ▼
Finish
```

### Data Import

```text
Job
 │
 ▼
Import CSV
 │
 ▼
Finish
```

### Report Generation

```text
Job
 │
 ▼
Generate Report
 │
 ▼
Finish
```

---

# Job vs CronJob

### Job

```text
Run Once
```

Example:

```text
Take backup now
```

### CronJob

```text
Run Repeatedly
```

Example:

```text
Take backup every day at 2 AM
```

Flow:

```text
CronJob
   │
   ▼
Creates Job
   │
   ▼
Creates Pod
```

---

# Easy Memory Trick

```text
Pod
  = Run Container

Deployment
  = Run Forever

Job
  = Run Once

CronJob
  = Run on Schedule
```

### Interview One-Liner

> A Kubernetes Job creates one or more Pods to perform a task and ensures the task completes successfully. Once the task is finished, the Job ends instead of keeping the Pod running.
