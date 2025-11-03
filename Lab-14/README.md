# Lab-14

### Create a New Project

```bash
oc new-project limitrange-lab
```

### Define a LimitRange

```bash
oc create limitrange pod-limit-range \
  --max=cpu=1,memory=1Gi \
  --min=cpu=100m,memory=128Mi \
  --default=cpu=500m,memory=512Mi \
  --default-request=cpu=200m,memory=256Mi \
  --type=Pod \
  -n limitrange-lab
```

### Verify the LimitRange

```bash
oc get limitrange -n limitrange-lab
oc describe limitrange pod-limit-range -n limitrange-lab
```

### Test with a Pod

```bash
oc run nginx-test-pod --image=nginx:latest --port=80 -n limitrange-lab
oc describe pod nginx-test-pod -n limitrange-lab
```

### Create a CronJob

```bash
oc create cronjob scheduled-task \
  --image=busybox:latest \
  --schedule="* * * * *" \
  --restart=OnFailure \
  -n limitrange-lab \
  -- /bin/sh -c 'echo "Task executed at $(date)"'
```

### Verify the CronJob

```bash
oc get cronjobs -n limitrange-lab
oc describe cronjob scheduled-task -n limitrange-lab
oc get jobs -n limitrange-lab
```

### View Job Logs

```bash
oc get jobs -n limitrange-lab

oc logs job/<JOB_NAME> -n limitrange-lab
```

### Verify (For Screenshots)

```bash
oc describe limitrange pod-limit-range -n limitrange-lab

oc describe pod nginx-test-pod -n limitrange-lab

oc get cronjobs -n limitrange-lab
oc get jobs -n limitrange-lab

oc logs job/<JOB_NAME> -n limitrange-lab
```

### Cleanup

```bash
oc delete project limitrange-lab
```