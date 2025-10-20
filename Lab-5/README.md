# Lab 5 - Working with ConfigMaps and Secrets

Deploy a MySQL database using Kubernetes best practices with ConfigMaps, Secrets, Persistent Storage, and Node Taints/Tolerations.

## Deploy MySQL with ConfigMaps and Secrets

```bash
$ kubectl taint nodes minikube db=only:NoSchedule --overwrite
node/minikube modified

$ kubectl create configmap mysql-config --from-file=config.txt
configmap/mysql-config created

$ kubectl create secret generic mysql-secret --from-env-file=secret.txt
secret/mysql-secret created

$ kubectl apply -f mysql-pv.yaml
persistentvolume/mysql-pv created

$ kubectl apply -f mysql-pvc.yaml
persistentvolumeclaim/mysql-pvc created

$ kubectl apply -f mysql-deployment.yaml
deployment.apps/mysql-deployment created

$ kubectl apply -f mysql-service.yaml
service/mysql-service created

```

## Verify All Resources

```bash
$ kubectl get pods

NAME                                READY   STATUS    RESTARTS   AGE
mysql-deployment-77b57d4456-rvmdr   1/1     Running   0          2m13s

$ kubectl get configmap mysql-config

NAME           DATA   AGE
mysql-config   1      5m39s

$ kubectl get secret mysql-secret

NAME           TYPE     DATA   AGE
mysql-secret   Opaque   4      5m37s

$ kubectl get pv,pvc

NAME                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/mysql-pv   2Gi        RWO            Retain           Bound    default/mysql-pvc   manual         <unset>                          6m33s

NAME                              STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/mysql-pvc   Bound    mysql-pv   2Gi        RWO            manual         <unset>                 6m25s

$ kubectl get service mysql-service

NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
mysql-service   ClusterIP   10.110.107.157   <none>        3306/TCP   9m11s

$ kubectl describe node minikube | grep -A 5 "Taints:"

Taints:             db=only:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  minikube
  AcquireTime:     <unset>
  RenewTime:       Mon, 20 Oct 2025 16:31:06 +0300

```

## Verify ConfigMap Details

```bash
$ kubectl describe configmap mysql-config

Name:         mysql-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
config.txt:
----
port=3306
bind-address=0.0.0.0
max_connections=100
innodb_buffer_pool_size=128M

BinaryData
====

Events:  <none>
```

## Verify Secret Details

```bash
$ kubectl describe secret mysql-secret

Name:         mysql-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
MYSQL_ROOT_PASSWORD:  15 bytes
MYSQL_USER:           8 bytes
MYSQL_DATABASE:       6 bytes
MYSQL_PASSWORD:       15 bytes
```

## Verify PV and PVC Binding

```bash
$ kubectl get pv,pvc

NAME                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/mysql-pv   2Gi        RWO            Retain           Bound    default/mysql-pvc   manual         <unset>                          11s

NAME                              STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/mysql-pvc   Bound    mysql-pv   2Gi        RWO            manual         <unset>                 11s
```

## Verify Pod Scheduling and Node Assignment

```bash
$ kubectl get pods -l app=mysql -o wide

NAME                                READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES
mysql-deployment-77b57d4456-rvmdr   1/1     Running   0          3m46s   10.244.0.43   minikube   <none>           <none>
```

## Verify MySQL Environment Variables

```bash
$ kubectl exec -it mysql-deployment-77b57d4456-rvmdr -- env | grep MYSQL

MYSQL_ROOT_PASSWORD=rootpassword123
MYSQL_DATABASE=testdb
MYSQL_USER=testuser
MYSQL_PASSWORD=userpassword123
MYSQL_MAJOR=8.0
MYSQL_VERSION=8.0.40-1.el8
```

## Verify Pod Tolerations

```bash
$ kubectl describe pod mysql-deployment-77b57d4456-rvmdr | grep -A 10 "Tolerations:"

Tolerations:                 db=only:NoSchedule
                             node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
```

## Test Database Functionality

```bash
# Create a test table and insert data
$ kubectl exec -it mysql-deployment-77b57d4456-rvmdr -- mysql -u testuser -puserpassword123 testdb -e "
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));
INSERT INTO users (name) VALUES ('John Doe'), ('Jane Smith');
SELECT * FROM users;"

mysql: [Warning] Using a password on the command line interface can be insecure.
+----+------------+
| id | name       |
+----+------------+
|  1 | John Doe   |
|  2 | Jane Smith |
+----+------------+
```

## Cleanup

```bash

# Delete all resources
$ kubectl delete -f .

# Delete ConfigMap and Secret
$ kubectl delete configmap mysql-config
$ kubectl delete secret mysql-secret

$ kubectl delete configmap mysql-config
$ kubectl delete secret mysql-secret

```