### Deploy to the k8s cluster

> You must follow the sequence
> deploy `mysql-db` -> deploy `GoApp` -> deploy `nginx-proxy`

- deploy `mysql-db`

```bash
$ kubectl apply -f db-secret.yaml -f db-data-pv.yaml -f db-data-pvc.yaml -f database_deployment.yaml -f db-service.yaml

secret/db-secret created
persistentvolume/db-data-pv created
persistentvolumeclaim/db-data-pvc created
deployment.apps/database-deployment created
service/db created
```

- deploy `GoApp`

```bash
$ kubectl apply -f backend_deployment.yaml -f backend_service.yaml

deployment.apps/backend-deployment created
service/go-backend created
```


- deploy `nginx-proxy`

```bash
$ kubectl apply -f nginx-configmap.yaml -f proxy_deployment.yaml -f proxy_nodeport.yaml

configmap/nginx-config created
deployment.apps/proxy-deployment created
service/proxy-service created
```

---

### get endpoint (url)

```bash
$ minikube service proxy-service --url

http://192.168.49.2:30080
http://192.168.49.2:30443

# OR
$ minikube service proxy-service

┌───────────┬───────────────┬─────────────┬───────────────────────────┐
│ NAMESPACE │     NAME      │ TARGET PORT │            URL            │
├───────────┼───────────────┼─────────────┼───────────────────────────┤
│ default   │ proxy-service │ http/80     │ http://192.168.49.2:30080 │
│           │               │ https/443   │ http://192.168.49.2:30443 │
└───────────┴───────────────┴─────────────┴───────────────────────────┘
[default proxy-service http/80
https/443 http://192.168.49.2:30080
http://192.168.49.2:30443]
```

---

### Clean Up

```bash
$ kubectl delete -f nginx-configmap.yaml -f proxy_deployment.yaml -f proxy_nodeport.yaml

configmap "nginx-config" deleted
deployment.apps "proxy-deployment" deleted
service "proxy-service" deleted


$ kubectl delete -f backend_deployment.yaml -f backend_service.yaml

deployment.apps "backend-deployment" deleted
service "go-backend" deleted

$ kubectl delete -f db-secret.yaml -f db-data-pv.yaml -f db-data-pvc.yaml -f database_deployment.yaml -f db-service.yaml

secret "db-secret" deleted
persistentvolume "db-data-pv" deleted
persistentvolumeclaim "db-data-pvc" deleted
deployment.apps "database-deployment" deleted
service "db" deleted
```

Or 

```bash
$ kubectl delete -f .

deployment.apps "backend-deployment" deleted
service "go-backend" deleted
deployment.apps "database-deployment" deleted
persistentvolume "db-data-pv" deleted
persistentvolumeclaim "db-data-pvc" deleted
secret "db-secret" deleted
service "db" deleted
configmap "nginx-config" deleted
deployment.apps "proxy-deployment" deleted
service "proxy-service" deleted
```