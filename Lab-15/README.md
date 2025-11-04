# Lab 15: OpenShift DaemonSet with Elevated Privileges


### Create a New Project
```bash
oc new-project lab15-daemonset-ozil
```

```bash
Now using project "lab15-daemonset-ozil" on server "https://api.crc.testing:6443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app rails-postgresql-example

to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

    kubectl create deployment hello-node --image=registry.k8s.io/e2e-test-images/agnhost:2.43 -- /agnhost serve-hostname

```

---

### Create a ServiceAccount
```bash
oc create serviceaccount privileged-daemonset-sa
```

```bash
serviceaccount/privileged-daemonset-sa created
```

---

### Assign Elevated Privileges
```bash
oc adm policy add-scc-to-user anyuid -z privileged-daemonset-sa
```

```bash
clusterrole.rbac.authorization.k8s.io/system:openshift:scc:anyuid added: "privileged-daemonset-sa"
```

---

### Create DaemonSet YAML

[**`daemonset.yaml`**](daemonset.yaml)

### Deploy DaemonSet
```bash
oc apply -f daemonset.yaml
```

```bash
```

---

### Verify Deployment
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

```bash
```

---

### Cleanup

```bash
oc delete project lab15-daemonset-ozil
```

```bash
```
