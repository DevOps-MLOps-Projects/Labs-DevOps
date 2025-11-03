### Apply All Resources

```bash
kubectl apply -f namespace.yaml -f limitrange.yaml -f deployment.yaml -f cronjob.yaml
```

```bash
namespace/limitrange-lab created
limitrange/pod-limit-range created
pod/nginx-test-pod created
cronjob.batch/scheduled-task created
```

### Verification

- Verify LimitRange

```bash
kubectl describe limitrange pod-limit-range -n limitrange-lab
```

```bash
Name:       pod-limit-range
Namespace:  limitrange-lab
Type        Resource  Min    Max  Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---    ---  ---------------  -------------  -----------------------
Container   cpu       100m   1    200m             500m           -
Container   memory    128Mi  1Gi  256Mi            512Mi          -
```

- Verify Pod resources

```bash
kubectl describe pod nginx-test-pod -n limitrange-lab
```

```bash
Name:             nginx-test-pod
Namespace:        limitrange-lab
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Mon, 03 Nov 2025 14:10:27 +0200
Labels:           app=nginx-test
Annotations:      kubernetes.io/limit-ranger: LimitRanger plugin set: cpu, memory request for container nginx; cpu, memory limit for container nginx
Status:           Running
IP:               10.244.0.68
IPs:
  IP:  10.244.0.68
Containers:
  nginx:
    Container ID:   docker://175da56754abb6446059642dd2ff2595e13b23bfaeeac2a8cd3eb4db430a1dfa
    Image:          nginx:latest
    Image ID:       docker-pullable://nginx@sha256:f547e3d0d5d02f7009737b284abc87d808e4252b42dceea361811e9fc606287f
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 03 Nov 2025 14:10:29 +0200
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  512Mi
    Requests:
      cpu:        200m
      memory:     256Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-cj4q7 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-cj4q7:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  4m33s  default-scheduler  Successfully assigned limitrange-lab/nginx-test-pod to minikube
  Normal  Pulling    4m32s  kubelet            Pulling image "nginx:latest"
  Normal  Pulled     4m31s  kubelet            Successfully pulled image "nginx:latest" in 1.577s (1.577s including waiting). Image size: 151838304 bytes.
  Normal  Created    4m31s  kubelet            Created container: nginx
  Normal  Started    4m31s  kubelet            Started container nginx
```

- Verify CronJob and Jobs

```bash
kubectl get cronjobs -n limitrange-lab
```

```bash
NAME             SCHEDULE    TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
scheduled-task   * * * * *   <none>     False     0        31s             5m4s
```

```bash
kubectl get jobs -n limitrange-lab
```

```bash
NAME                      STATUS     COMPLETIONS   DURATION   AGE
scheduled-task-29369538   Complete   1/1           5s         2m36s
scheduled-task-29369539   Complete   1/1           5s         96s
scheduled-task-29369540   Complete   1/1           4s         36s
```

- View job logs

```bash
kubectl logs job/scheduled-task-29369540 -n limitrange-lab
```

```bash
Task executed at Mon Nov  3 12:20:02 UTC 2025
```

### Cleanup

```bash
kubectl delete -f k8s/
```

```bash
cronjob.batch "scheduled-task" deleted
pod "nginx-test-pod" deleted
limitrange "pod-limit-range" deleted
namespace "limitrange-lab" deleted
```
