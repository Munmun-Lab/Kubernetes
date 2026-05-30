# CronJob in Kubernetes - Complete Beginner Guide

A **CronJob** in Kubernetes is used to run a Job **at a specific time or schedule**.

Think of it as Linux cron:

```bash
0 2 * * * backup.sh
```

In Kubernetes:

```text
Every day at 2 AM
       │
       ▼
Create a Job
       │
       ▼
Run Pod
       │
       ▼
Finish
```

---

# Why Use a CronJob?

For tasks that need to run periodically:

✅ Database backup

✅ Log cleanup

✅ Sending reports

✅ Data synchronization

✅ Health checks

✅ Batch processing

---

# Real-Life Example

Suppose you need:

```text
Every day at 1 AM
       │
       ▼
Backup Database
```

You don't want a Pod running 24x7.

Instead:

```text
1 AM
 │
 ▼
Start Backup Pod
 │
 ▼
Take Backup
 │
 ▼
Exit
```

This is a CronJob.

---

# Architecture

```text
CronJob
    │
    ▼
Creates Job
    │
    ▼
Creates Pod
    │
    ▼
Runs Task
    │
    ▼
Completes
```

---

# Flowchart

```text
Scheduled Time Reached
          │
          ▼
      CronJob
          │
          ▼
      Create Job
          │
          ▼
      Create Pod
          │
          ▼
      Execute Task
          │
          ▼
      Success?
      ┌────┴────┐
      │         │
     Yes       No
      │         │
      ▼         ▼
 Complete    Retry
```

---

# Basic CronJob YAML

```yaml
apiVersion: batch/v1
kind: CronJob

metadata:
  name: hello-cronjob

spec:
  schedule: "* * * * *"

  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command:
            - /bin/sh
            - -c
            - date; echo "Hello Kubernetes"

          restartPolicy: OnFailure
```

Apply:

```bash
kubectl apply -f cronjob.yaml
```

---

# Understanding the YAML

## API Version

```yaml
apiVersion: batch/v1
```

CronJobs belong to the batch API.

---

## Kind

```yaml
kind: CronJob
```

Create a CronJob resource.

---

## Schedule

```yaml
schedule: "* * * * *"
```

Means:

```text
Every minute
```

---

## Job Template

```yaml
jobTemplate:
```

Template used to create Jobs.

Think:

```text
CronJob
   │
   ▼
Job Template
   │
   ▼
Actual Job
```

---

## Container

```yaml
image: busybox
```

Container that performs the task.

---

## Restart Policy

```yaml
restartPolicy: OnFailure
```

If task fails:

```text
Retry
```

If task succeeds:

```text
Exit
```

---

# Cron Schedule Format

```text
* * * * *
│ │ │ │ │
│ │ │ │ └── Day of Week
│ │ │ └──── Month
│ │ └────── Day of Month
│ └──────── Hour
└────────── Minute
```

---

# Common Examples

## Every Minute

```yaml
schedule: "* * * * *"
```

---

## Every Hour

```yaml
schedule: "0 * * * *"
```

---

## Daily at Midnight

```yaml
schedule: "0 0 * * *"
```

---

## Daily at 2 AM

```yaml
schedule: "0 2 * * *"
```

---

## Every Sunday

```yaml
schedule: "0 0 * * 0"
```

---

# Example: Daily Backup

```yaml
apiVersion: batch/v1
kind: CronJob

metadata:
  name: db-backup

spec:
  schedule: "0 1 * * *"

  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command:
            - sh
            - -c
            - echo "Taking Database Backup"

          restartPolicy: OnFailure
```

Flow:

```text
1 AM
 │
 ▼
Create Backup Job
 │
 ▼
Backup Pod
 │
 ▼
Backup Complete
```

---

# Checking CronJobs

## List CronJobs

```bash
kubectl get cronjobs
```

Output:

```text
NAME           SCHEDULE
hello-cronjob  * * * * *
```

---

## Describe CronJob

```bash
kubectl describe cronjob hello-cronjob
```

---

## See Jobs Created

```bash
kubectl get jobs
```

Example:

```text
hello-cronjob-12345
hello-cronjob-67890
```

---

## See Pods

```bash
kubectl get pods
```

Example:

```text
hello-cronjob-12345-abcd
hello-cronjob-67890-xyz
```

---

# CronJob Lifecycle

```text
CronJob
   │
   ▼
Job #1
   │
   ▼
Pod
   │
   ▼
Complete

Next Schedule
   │
   ▼
Job #2
   │
   ▼
Pod
   │
   ▼
Complete
```

---

# Suspend a CronJob

Stop future executions.

```yaml
spec:
  suspend: true
```

or

```bash
kubectl patch cronjob hello-cronjob \
-p '{"spec":{"suspend":true}}'
```

Flow:

```text
Scheduled Time
      │
      ▼
CronJob Suspended
      │
      ▼
No Job Created
```

---

# Concurrency Policy

Controls what happens if a previous run is still executing.

### Allow (Default)

```yaml
concurrencyPolicy: Allow
```

```text
Job1 Running
Job2 Starts
```

---

### Forbid

```yaml
concurrencyPolicy: Forbid
```

```text
Job1 Running
      │
      ▼
Job2 Skipped
```

---

### Replace

```yaml
concurrencyPolicy: Replace
```

```text
Job1 Running
      │
      ▼
Terminate Job1
      │
      ▼
Start Job2
```

---

# History Limits

Keep only a certain number of old Jobs.

```yaml
successfulJobsHistoryLimit: 3

failedJobsHistoryLimit: 1
```

Meaning:

```text
Keep last 3 successful Jobs
Keep last 1 failed Job
```

---

# Delete CronJob

Delete CronJob only:

```bash
kubectl delete cronjob hello-cronjob
```

Delete YAML:

```bash
kubectl delete -f cronjob.yaml
```

---

# CronJob vs Job

| Feature      | Job | CronJob |
| ------------ | --- | ------- |
| Runs Once    | ✅   | ❌       |
| Scheduled    | ❌   | ✅       |
| Repeats      | ❌   | ✅       |
| Creates Pods | ✅   | ✅       |

---

## Job

```text
Run Backup Once
```

```yaml
kind: Job
```

---

## CronJob

```text
Run Backup Every Day
```

```yaml
kind: CronJob
```

---

# Interview Questions

### What is a CronJob?

A CronJob creates Jobs on a schedule, similar to Linux cron.

---

### What does a CronJob create?

```text
CronJob
   │
   ▼
Job
   │
   ▼
Pod
```

---

### Difference between Job and CronJob?

```text
Job
  = Run Once

CronJob
  = Run Repeatedly on Schedule
```

---

### Which API version is used?

```yaml
apiVersion: batch/v1
```

---

# Easy Memory Trick

```text
Pod
 = Run Container

Job
 = Run Once

CronJob
 = Run Again and Again
   According to Time Schedule
```

## Final Diagram

```text
               CronJob
                   │
                   ▼
         Every Day 2 AM
                   │
                   ▼
                Job
                   │
                   ▼
                 Pod
                   │
                   ▼
             Execute Task
                   │
                   ▼
                Complete
```

**Golden Rule:**

* **Pod** → Run application
* **Job** → Run task once
* **CronJob** → Run task on a schedule repeatedly.
