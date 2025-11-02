### Create New Project

Create a new OpenShift project for the lab `nginx-ozil`.

```bash
oc new-project nginx-ozil
oc project
```

### Apply Security Policy (SCC anyuid)

```bash
$ oc adm policy add-scc-to-user anyuid -z default -n nginx-ozil

clusterrole.rbac.authorization.k8s.io/system:openshift:scc:anyuid added: "default"

# Verify SCC assignment
oc describe scc anyuid | grep Users
```

### Deploy Nginx Application

```bash
$ oc new-app --name=nginx-app --docker-image=nginx:latest

Flag --docker-image has been deprecated, Deprecated flag use --image
--> Found container image 9d0e6f6 (4 days old) from Docker Hub for "nginx:latest"

    * An image stream tag will be created as "nginx-app:latest" that will track this image

--> Creating resources ...
    imagestream.image.openshift.io "nginx-app" created
    deployment.apps "nginx-app" created
    service "nginx-app" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose service/nginx-app' 
    Run 'oc status' to view your app.

$ oc get pods -n nginx-ozil

NAME                         READY   STATUS    RESTARTS   AGE
nginx-app-84fd578d56-sp9nl   1/1     Running   0          46s

$ oc get services

NAME        TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
nginx-app   ClusterIP   10.217.5.55   <none>        80/TCP    3m21s

```


### Create HTTPS Route
Expose the deployed Nginx service using an HTTPS route (edge termination).

```bash
$ oc create route edge nginx-https-route --service=nginx-app --port=80

route/nginx-https-route created

$ oc get routes

NAME                HOST/PORT                                       PATH   SERVICES    PORT   TERMINATION   WILDCARD
nginx-https-route   nginx-https-route-nginx-ozil.apps-crc.testing          nginx-app   80     edge          None

$ oc describe route nginx-https-route

Name:                   nginx-https-route
Namespace:              nginx-ozil
Created:                About a minute ago
Labels:                 app=nginx-app
                        app.kubernetes.io/component=nginx-app
                        app.kubernetes.io/instance=nginx-app
Annotations:            openshift.io/host.generated=true
Requested Host:         nginx-https-route-nginx-ozil.apps-crc.testing
                           exposed on router default (host router-default.apps-crc.testing) about a minute ago
Path:                   <none>
TLS Termination:        edge
Insecure Policy:        <none>
Endpoint Port:          80

Service:        nginx-app
Weight:         100 (100%)
Endpoints:      10.217.0.110:80
```

### Verify Resources

```bash
$ oc get all

Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
NAME                             READY   STATUS    RESTARTS   AGE
pod/nginx-app-84fd578d56-sp9nl   1/1     Running   0          6m56s

NAME                TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/nginx-app   ClusterIP   10.217.5.55   <none>        80/TCP    7m16s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-app   1/1     1            1           7m16s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-app-6dd96598fd   0         0         0       7m15s
replicaset.apps/nginx-app-84fd578d56   1         1         1       6m57s

NAME                                       IMAGE REPOSITORY                                                               TAGS     UPDATED
imagestream.image.openshift.io/nginx-app   default-route-openshift-image-registry.apps-crc.testing/nginx-ozil/nginx-app   latest   7 minutes ago

NAME                                         HOST/PORT                                       PATH   SERVICES    PORT   TERMINATION   WILDCARD
route.route.openshift.io/nginx-https-route   nginx-https-route-nginx-ozil.apps-crc.testing          nginx-app   80     edge          None

$ oc get pods -o wide

NAME                         READY   STATUS    RESTARTS   AGE     IP             NODE   NOMINATED NODE   READINESS GATES
nginx-app-84fd578d56-sp9nl   1/1     Running   0          7m11s   10.217.0.110   crc    <none>           <none>

$ oc get services -o wide

NAME        TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE     SELECTOR
nginx-app   ClusterIP   10.217.5.55   <none>        80/TCP    7m44s   deployment=nginx-app

$ oc get routes -o wide

NAME                HOST/PORT                                       PATH   SERVICES    PORT   TERMINATION   WILDCARD
nginx-https-route   nginx-https-route-nginx-ozil.apps-crc.testing          nginx-app   80     edge          None

$ oc get deployments -o wide

NAME        READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES                                                                          SELECTOR
nginx-app   1/1     1            1           8m7s   nginx-app    nginx@sha256:12549785f32b3daca6f1c39e7d756226eeb0e8bb20b9e2d8a03d484160862b58   deployment=nginx-app

$ oc status

Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
In project nginx-ozil on server https://api.crc.testing:6443

https://nginx-https-route-nginx-ozil.apps-crc.testing to pod port 80 (svc/nginx-app)
  deployment/nginx-app deploys istag/nginx-app:latest 
    deployment #2 running for 8 minutes - 1 pod
    deployment #1 deployed 8 minutes ago


1 info identified, use 'oc status --suggest' to see details.
```

### Test Application

```bash
$ curl -k https://nginx-https-route-nginx-ozil.apps-crc.testing

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Verify Pods

```bash
$ oc get pods -n nginx-ozil

NAME                         READY   STATUS    RESTARTS   AGE
nginx-app-84fd578d56-sp9nl   1/1     Running   0          19m

$ oc logs nginx-app-84fd578d56-sp9nl -n nginx-ozil

/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/11/02 12:29:02 [notice] 1#1: using the "epoll" event method
2025/11/02 12:29:02 [notice] 1#1: nginx/1.29.3
2025/11/02 12:29:02 [notice] 1#1: built by gcc 14.2.0 (Debian 14.2.0-19) 
2025/11/02 12:29:02 [notice] 1#1: OS: Linux 5.14.0-427.30.1.el9_4.x86_64
2025/11/02 12:29:02 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2025/11/02 12:29:02 [notice] 1#1: start worker processes
2025/11/02 12:29:02 [notice] 1#1: start worker process 29
2025/11/02 12:29:02 [notice] 1#1: start worker process 30
2025/11/02 12:29:02 [notice] 1#1: start worker process 31
2025/11/02 12:29:02 [notice] 1#1: start worker process 32
2025/11/02 12:29:02 [notice] 1#1: start worker process 33
2025/11/02 12:29:02 [notice] 1#1: start worker process 34
10.217.0.2 - - [02/Nov/2025:12:46:54 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.76.1" "192.168.130.1"

```
