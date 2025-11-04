# Lab 15: OpenShift DaemonSet with Elevated Privileges

## Lab Commands

### Step 1 – Create a New Project
```bash
oc new-project lab15-daemonset
```

### Step 2 – Create a ServiceAccount
```bash
oc create serviceaccount privileged-daemonset-sa
```

### Step 3 – Assign Elevated Privileges
```bash
oc adm policy add-scc-to-user anyuid -z privileged-daemonset-sa
```

### Step 4 – Create DaemonSet YAML

[**`daemonset.yaml`**](daemonset.yaml)

### Step 5 – Deploy DaemonSet
```bash
oc apply -f daemonset.yaml
```

### Step 6 – Verify Deployment
```bash
# Check DaemonSet status
oc get daemonset

# Check pods
oc get pods -o wide

# Check ServiceAccount
oc get serviceaccount privileged-daemonset-sa

# Verify SCC binding
oc describe scc anyuid | grep -A 10 "Users:"

# Check pod logs to verify root access
oc logs -l app=privileged-daemon --tail=20

# Verify ServiceAccount usage in pod
oc describe pod <POD_NAME> | grep -E "(Service Account|Security Context)"

# Execute commands in pod to verify root access
oc exec <POD_NAME> -- id
oc exec <POD_NAME> -- whoami
```

### Step 7 – Cleanup
```bash
oc delete project lab15-daemonset
```
