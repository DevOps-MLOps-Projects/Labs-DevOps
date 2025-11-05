# OpenShift Deployment

### 1. Deploy Database Tier
```bash
oc apply -f db-secret.yaml -f db-data-pvc.yaml -f database_deployment.yaml -f db-service.yaml
```

### 2. Deploy Backend Tier
```bash
oc apply -f backend_deployment.yaml -f backend_service.yaml
```

### 3. Deploy Frontend/Proxy Tier
```bash
oc apply -f nginx-configmap.yaml -f proxy_deployment.yaml -f proxy_service.yaml -f proxy_route.yaml
```

## Access the Application

### Get Route URL
```bash
oc get routes
```

### Test the Application
```bash
# Get the route hostname
ROUTE_HOST=$(oc get route proxy-route -o jsonpath='{.spec.host}')

# Test HTTP access
curl http://$ROUTE_HOST

# Test HTTPS access (if TLS is configured)
curl https://$ROUTE_HOST
```

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

### Debug Commands
```bash
# Describe resources
oc describe deployment database-deployment
oc describe pvc db-data-pvc
oc describe route proxy-route

# Check events
oc get events --sort-by=.metadata.creationTimestamp
```