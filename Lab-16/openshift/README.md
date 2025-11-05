# OpenShift Deployment

### Manual Root Access Setup

- Create service account and RBAC

```bash
oc apply -f serviceaccount-and-rbac.yaml
```

```bash
serviceaccount/three-tier-app-sa created
clusterrole.rbac.authorization.k8s.io/three-tier-app-role created
clusterrolebinding.rbac.authorization.k8s.io/three-tier-app-binding created
```

---

- Create custom Security Context Constraint

```bash
oc apply -f scc-root-access.yaml
```

```bash
securitycontextconstraints.security.openshift.io/three-tier-app-scc created
```

---

- Bind SCC to service account

```bash
oc adm policy add-scc-to-user three-tier-app-scc -z three-tier-app-sa
```

```bash
clusterrole.rbac.authorization.k8s.io/system:openshift:scc:three-tier-app-scc added: "three-tier-app-sa"
```

---

- Deploy with root access

```bash
oc apply -f database_deployment_root.yaml
```

```bash
deployment.apps/database-deployment created
```

---

```bash
oc apply -f backend_deployment_root.yaml
```

```bash
deployment.apps/backend-deployment created
```

---

### 1. Deploy Database Tier

```bash
oc apply -f db-secret.yaml -f db-data-pvc.yaml -f database_deployment.yaml -f db-service.yaml
```

```bash
secret/db-secret created
persistentvolumeclaim/db-data-pvc created
deployment.apps/database-deployment configured
service/db created
```

---

### 2. Deploy Backend Tier

```bash
oc apply -f backend_deployment.yaml -f backend_service.yaml
```

```bash
deployment.apps/backend-deployment configured
service/go-backend created
```

---

### 3. Deploy Frontend/Proxy Tier

```bash
oc apply -f nginx-configmap.yaml -f proxy_deployment.yaml -f proxy_service.yaml -f proxy_route.yaml
```

```bash
configmap/nginx-config created
deployment.apps/proxy-deployment created
service/proxy-service created
route.route.openshift.io/proxy-route created
```

---

# Access the Application

### Get Route URL

```bash
oc get pods
```

```bash
NAME                    READY   STATUS    RESTARTS   AGE
backend-image-1-build   1/1     Running     0        12m
```

```bash
oc get routes
```

```bash
NAME          HOST/PORT                                 PATH   SERVICES        PORT   TERMINATION     WILDCARD
proxy-route   proxy-route-three-tier.apps-crc.testing          proxy-service   http   edge/Redirect   None
```

---

### Test the Application

- Get the route hostname

```bash
oc get route proxy-route
```

```bash
NAME          HOST/PORT                                 PATH   SERVICES        PORT   TERMINATION     WILDCARD
proxy-route   proxy-route-three-tier.apps-crc.testing          proxy-service   http   edge/Redirect   None
```

```bash
curl -k https://proxy-route-three-tier.apps-crc.testing
```

```bash
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style type="text/css">
      body {
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        line-height: 1.66666667;
        font-size: 16px;
        color: #333;
        background-color: #fff;
        margin: 2em 1em;
      }
      h1 {
        font-size: 28px;
        font-weight: 400;
      }
      p {
        margin: 0 0 10px;
      }
      .alert.alert-info {
        background-color: #F0F0F0;
        margin-top: 30px;
        padding: 30px;
      }
      .alert p {
        padding-left: 35px;
      }
      ul {
        padding-left: 51px;
        position: relative;
      }
      li {
        font-size: 14px;
        margin-bottom: 1em;
      }
      p.info {
        position: relative;
        font-size: 20px;
      }
      p.info:before, p.info:after {
        content: "";
        left: 0;
        position: absolute;
        top: 0;
      }
      p.info:before {
        background: #0066CC;
        border-radius: 16px;
        color: #fff;
        content: "i";
        font: bold 16px/24px serif;
        height: 24px;
        left: 0px;
        text-align: center;
        top: 4px;
        width: 24px;
      }

      @media (min-width: 768px) {
        body {
          margin: 6em;
        }
      }
    </style>
  </head>
  <body>
    <div>
      <h1>Application is not available</h1>
      <p>The application is currently not serving requests at this endpoint. It may not have been started or is still starting.</p>

      <div class="alert alert-info">
        <p class="info">
          Possible reasons you are seeing this page:
        </p>
        <ul>
          <li>
            <strong>The host doesn't exist.</strong>
            Make sure the hostname was typed correctly and that a route matching this hostname exists.
          </li>
          <li>
            <strong>The host exists, but doesn't have a matching path.</strong>
            Check if the URL path was typed correctly and that the route was created using the desired path.
          </li>
          <li>
            <strong>Route and path matches, but all pods are down.</strong>
            Make sure that the resources exposed by this route (pods, services, deployment configs, etc) have at least one pod running.
          </li>
        </ul>
      </div>
    </div>
  </body>
</html>
```

---

### Cleanup

- Delete all resources

```bash
oc delete -f .
```

Or delete in reverse order

```bash
oc delete -f proxy_route.yaml -f proxy_service.yaml -f proxy_deployment.yaml -f nginx-configmap.yaml
oc delete -f backend_service.yaml -f backend_deployment.yaml
oc delete -f db-service.yaml -f database_deployment.yaml -f db-data-pvc.yaml -f db-secret.yaml
```

```bash
deployment.apps "backend-deployment" deleted
service "go-backend" deleted
deployment.apps "database-deployment" deleted
persistentvolumeclaim "db-data-pvc" deleted
secret "db-secret" deleted
service "db" deleted
configmap "nginx-config" deleted
deployment.apps "proxy-deployment" deleted
route.route.openshift.io "proxy-route" deleted
service "proxy-service" deleted
securitycontextconstraints.security.openshift.io "three-tier-app-scc" deleted
serviceaccount "three-tier-app-sa" deleted
clusterrole.rbac.authorization.k8s.io "three-tier-app-role" deleted
clusterrolebinding.rbac.authorization.k8s.io "three-tier-app-binding" deleted
```
