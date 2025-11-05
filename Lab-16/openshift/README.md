# OpenShift Deployment
### Manual Root Access Setup
```bash
# Create service account and RBAC
oc apply -f serviceaccount-and-rbac.yaml

# Create custom Security Context Constraint
oc apply -f scc-root-access.yaml

# Bind SCC to service account
oc adm policy add-scc-to-user three-tier-app-scc -z three-tier-app-sa

# Deploy with root access
oc apply -f database_deployment_root.yaml
oc apply -f backend_deployment_root.yaml
```

### 1. Deploy Database Tier

```bash
oc apply -f db-secret.yaml -f db-data-pvc.yaml -f database_deployment.yaml -f db-service.yaml
```

```bash

```

---

### 2. Deploy Backend Tier

```bash
oc apply -f backend_deployment.yaml -f backend_service.yaml
```

```bash

```

---

### 3. Deploy Frontend/Proxy Tier

```bash
oc apply -f nginx-configmap.yaml -f proxy_deployment.yaml -f proxy_service.yaml -f proxy_route.yaml
```

```bash

```

---

# Access the Application

### Get Route URL
```bash
oc get routes
```

```bash

```

---
### Test the Application
```bash
# Get the route hostname
ROUTE_HOST=$(oc get route proxy-route -o jsonpath='{.spec.host}')

# Test HTTP access
curl http://$ROUTE_HOST

# Test HTTPS access (if TLS is configured)
curl https://$ROUTE_HOST
```

```bash

```

---

## Monitoring

### Check Pod Status
```bash
oc get pods
```

### View Logs
```bash
# Backend logs
oc logs -l app=backend

# Database logs
oc logs -l app=database

# Proxy logs
oc logs -l app=proxy
```

## Cleanup
```bash
# Delete all resources
oc delete -f .

# Or delete in reverse order
oc delete -f proxy_route.yaml -f proxy_service.yaml -f proxy_deployment.yaml -f nginx-configmap.yaml
oc delete -f backend_service.yaml -f backend_deployment.yaml
oc delete -f db-service.yaml -f database_deployment.yaml -f db-data-pvc.yaml -f db-secret.yaml
```



## Troubleshooting

### Common Issues
1. **Image Pull Errors**: Ensure images are accessible from OpenShift cluster
2. **Storage Issues**: Verify storage class is available
3. **Route Access**: Check if routes are properly configured and DNS is resolving
4. **Security Context Warnings**: Use the updated manifests with seccompProfile settings
5. **Permission Denied**: Use root access deployment if containers need root privileges

### Debug Commands
```bash
# Describe resources
oc describe deployment database-deployment
oc describe pvc db-data-pvc
oc describe route proxy-route

# Check events
oc get events --sort-by=.metadata.creationTimestamp

# Check SCC assignments
oc describe scc three-tier-app-scc
oc get scc -o name | xargs -I {} oc describe {}
```