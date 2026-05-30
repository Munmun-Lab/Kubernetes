# CronJob in Simple Words

A **CronJob** is used to run a task automatically at a specific time or on a repeating schedule.

### Example

```text
Every day at 2 AM
       │
       ▼
Take Database Backup
```

Instead of running the backup manually every day, Kubernetes runs it automatically using a CronJob.

---

# What does `* * * * *` mean?

Cron schedule has **5 fields**:

```text
* * * * *
│ │ │ │ │
│ │ │ │ └─ Day of Week (0-6)
│ │ │ └─── Month (1-12)
│ │ └───── Day of Month (1-31)
│ └─────── Hour (0-23)
└───────── Minute (0-59)
```

---

## Meaning of Each `*`

A `*` means:

```text
ANY VALUE
```

or

```text
EVERY
```

---

### `* * * * *`

```text
Every Minute
Every Hour
Every Day
Every Month
Every Day of Week
```

Result:

```text
Run Every Minute
```

---

### Common Examples

| Schedule    | Meaning                            |
| ----------- | ---------------------------------- |
| `* * * * *` | Every minute                       |
| `0 * * * *` | Every hour                         |
| `0 2 * * *` | Every day at 2 AM                  |
| `0 9 * * 1` | Every Monday at 9 AM               |
| `0 0 1 * *` | 1st day of every month at midnight |

---

## Easy Memory Trick

```text
* = Every

* * * * *

Minute
Hour
Day
Month
Weekday
```

So:

```yaml
schedule: "* * * * *"
```

means:

> "Run this CronJob every minute." 🚀
