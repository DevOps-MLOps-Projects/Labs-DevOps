### Create web-app Namespace

```bash
$ kubectl apply -f namespace.yaml -f service.yaml -f deployment.yaml -f quota.yaml -f hpa.yaml

namespace/web-app created
service/nginx-service created
deployment.apps/nginx-deployment created
resourcequota/webapp-quota created
horizontalpodautoscaler.autoscaling/nginx-hpa created
```
### Manual Scaling

```bash
$ kubectl scale deployment nginx-deployment --replicas=4 -n web-app

deployment.apps/nginx-deployment scaled

$ kubectl get pods -n web-app
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-c6c897f54-fzrvf   1/1     Running   0          8s
nginx-deployment-c6c897f54-mq2xp   1/1     Running   0          8s
nginx-deployment-c6c897f54-xr8l2   1/1     Running   0          3m2s
nginx-deployment-c6c897f54-z8n4f   1/1     Running   0          3m2s

$ kubectl get deployment nginx-deployment -n web-app

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   4/4     4            4           4m4s
```

### Update Strategy (Rolling Update)

```bash
$ kubectl apply -f rolling-update.yaml

deployment.apps/nginx-deployment configured

$ kubectl rollout status deployment/nginx-deployment -n web-app

Waiting for deployment "nginx-deployment" rollout to finish: 2 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 2 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 2 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 2 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 3 out of 4 new replicas have been updated...
Waiting for deployment "nginx-deployment" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "nginx-deployment" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "nginx-deployment" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "nginx-deployment" rollout to finish: 3 of 4 updated replicas are available...
deployment "nginx-deployment" successfully rolled out

$ kubectl get pods -n web-app -o wide

NAME                              READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
nginx-deployment-7c7bbd47-c97bh   1/1     Running   0          15s   10.244.0.31   minikube   <none>           <none>
nginx-deployment-7c7bbd47-gz75z   1/1     Running   0          17s   10.244.0.30   minikube   <none>           <none>
nginx-deployment-7c7bbd47-r26qr   1/1     Running   0          55s   10.244.0.29   minikube   <none>           <none>
nginx-deployment-7c7bbd47-rdht4   1/1     Running   0          55s   10.244.0.28   minikube   <none>           <none>

```

### Rollback

```bash
$ kubectl rollout history deployment/nginx-deployment -n web-app

deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

$ kubectl rollout undo deployment/nginx-deployment -n web-app

deployment.apps/nginx-deployment rolled back

$ kubectl rollout status deployment/nginx-deployment -n web-app

deployment "nginx-deployment" successfully rolled out

$ kubectl get pods -n web-app

NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-c6c897f54-g5t2x   1/1     Running   0          43s
nginx-deployment-c6c897f54-mpf5x   1/1     Running   0          44s
nginx-deployment-c6c897f54-qs2fn   1/1     Running   0          37s
nginx-deployment-c6c897f54-whl87   1/1     Running   0          39s

$ kubectl rollout history deployment/nginx-deployment -n web-app

deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
```

### Verification

```bash
$ kubectl get pods -n web-app
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-c6c897f54-g5t2x   1/1     Running   0          2m11s
nginx-deployment-c6c897f54-mpf5x   1/1     Running   0          2m12s
nginx-deployment-c6c897f54-qs2fn   1/1     Running   0          2m5s
nginx-deployment-c6c897f54-whl87   1/1     Running   0          2m7s

$ kubectl get services -n web-app
NAME            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
nginx-service   ClusterIP   10.110.9.22   <none>        80/TCP    10m

$ kubectl get hpa -n web-app
NAME        REFERENCE                     TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx-deployment   cpu: <unknown>/70%   2         8         4          11m

$ kubectl get resourcequota -n web-app
NAME           REQUEST                                                        LIMIT                                        AGE
webapp-quota   pods: 4/10, requests.cpu: 400m/2, requests.memory: 512Mi/2Gi   limits.cpu: 800m/4, limits.memory: 1Gi/4Gi   11m

$ kubectl get all -n web-app

NAME                                   READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-c6c897f54-g5t2x   1/1     Running   0          3m24s
pod/nginx-deployment-c6c897f54-mpf5x   1/1     Running   0          3m25s
pod/nginx-deployment-c6c897f54-qs2fn   1/1     Running   0          3m18s
pod/nginx-deployment-c6c897f54-whl87   1/1     Running   0          3m20s

NAME                    TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/nginx-service   ClusterIP   10.110.9.22   <none>        80/TCP    11m

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   4/4     4            4           11m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-7c7bbd47    0         0         0       5m56s
replicaset.apps/nginx-deployment-c6c897f54   4         4         4       11m

NAME                                            REFERENCE                     TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/nginx-hpa   Deployment/nginx-deployment   cpu: <unknown>/70%   2         8         4          11m
```