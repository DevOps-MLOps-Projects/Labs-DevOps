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

```bash
nano damonset.yaml
```

### Deploy DaemonSet

```bash
oc apply -f daemonset.yaml
```

```bash
daemonset.apps/privileged-daemon created
```

---

### Verify Deployment

- Check DaemonSet status

```bash
oc get daemonset
```
```bash
NAME                DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
privileged-daemon   1         0         0       0            0           kubernetes.io/os=linux   28s
```

- Check ServiceAccount

```bash
oc get serviceaccount privileged-daemonset-sa
```
```bash
NAME                      SECRETS   AGE
privileged-daemonset-sa   1         3m36s
```

- Verify SCC binding

```bash
oc describe scc anyuid | grep -A 10 "Users:"
```
```bash
Users:                                        <none>
  Groups:                                       system:cluster-admins
Settings:
  Allow Privileged:                             false
  Allow Privilege Escalation:                   true
  Default Add Capabilities:                     <none>
  Required Drop Capabilities:                   MKNOD
  Allowed Capabilities:                         <none>
  Allowed Seccomp Profiles:                     <none>
  Allowed Volume Types:                         configMap,csi,downwardAPI,emptyDir,ephemeral,persistentVolumeClaim,projected,secret
  Allowed Flexvolumes:                          <all>
```


- Verify ServiceAccount usage in pod

```bash
oc describe pod <POD_NAME> | grep -E "(Service Account|Security Context)"
```
```bash

```

- Execute commands in pod to verify root access

```bash
oc exec <POD_NAME> -- id
```
```bash

```

```bash
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
project.project.openshift.io "lab15-daemonset-ozil" deleted
```
