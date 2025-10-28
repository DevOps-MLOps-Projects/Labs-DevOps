# Lab 11 - ArgoCD Installation and Configuration


## Task 1 – Install ArgoCD


### Step 1: Create ArgoCD Namespace
```bash
kubectl create namespace argocd
```

### Step 2: Install ArgoCD
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Step 3: Wait for Pods to be Ready
```bash
kubectl get pods -n argocd
```
Wait until all pods show `Running` status (may take 2-3 minutes).

---

## Task 2 – Access ArgoCD Web UI

### Step 1: Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### Step 2: Set Up Port Forwarding
```bash
kubectl port-forward svc/argocd-server -n argocd 9090:443
```
Keep this terminal open.

### Step 3: Access Web UI
- Open browser and navigate to: **https://localhost:9090**
- Accept the self-signed certificate warning
- Login with:
  - **Username**: `admin`
  - **Password**: Use the password from Step 1

### Troubleshooting Login Issues
If you get "Invalid username or password":

1. **Reset the password**:
```bash
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa","admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
```

2. **Restart ArgoCD server**:
```bash
kubectl rollout restart deployment/argocd-server -n argocd
kubectl rollout status deployment/argocd-server -n argocd
```

3. **Use new credentials**:
   - **Username**: `admin`
   - **Password**: `password`

---

## Task 3 – Create an Application (GUI Only)

### Step 1: Access ArgoCD Dashboard
- Navigate to: https://localhost:9090
- Login with admin credentials

### Step 2: Create New Application
1. Click the **"NEW APP"** button (+ icon)
2. Fill in the application details:

**General Settings:**
- **Application Name**: `nginx-app`
- **Project**: `default`
- **Sync Policy**: `Manual`

**Source Settings:**
- **Repository URL**: `https://github.com/abdelrahmanonline4/lab-seniorLab`
- **Revision**: `HEAD`
- **Path**: `.` (root directory)

**Destination Settings:**
- **Cluster URL**: `https://kubernetes.default.svc`
- **Namespace**: `default`

### Step 3: Create the Application
- Click **"CREATE"** button
- The application will appear in the dashboard with "OutOfSync" status

---

## Task 4 – Sync the Application

### Step 1: Select Your Application
- Click on the `nginx-app` application card in the dashboard

### Step 2: Review Application Details
- You'll see the application overview with resources to be deployed
- Status should show "OutOfSync"

### Step 3: Sync the Application
1. Click the **"SYNC"** button
2. Review the resources that will be created
3. Click **"SYNCHRONIZE"** to confirm

### Step 4: Monitor Sync Progress
- Watch the sync operation progress
- Resources will be created in the Kubernetes cluster

---

## Task 5 – Verify the Deployment

### Step 1: Check Application Status (GUI)
- Application status should change to **"Synced"** and **"Healthy"**
- All resources should show green status

### Step 2: View Resources in GUI
- Click on the application to see detailed view
- Verify Deployment and Service resources are present
- Check pod status (should be running)

### Step 3: Verify via Command Line
```bash
# Check deployed resources
kubectl get all -n default

# Check NGINX deployment
kubectl get deployment nginx -n default

# Check NGINX service
kubectl get service nginx -n default
```

### Step 4: Access NGINX Service
```bash
# Port forward to access NGINX
kubectl port-forward service/nginx 8080:80 -n default
```
Then visit: http://localhost:8080

---

## Verification Commands

### Check ArgoCD Status
```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

### Check Applications
```bash
kubectl get applications -n argocd
```

### Check Deployed Resources
```bash
kubectl get all -n default
```

### View ArgoCD Server Logs (if needed)
```bash
kubectl logs -n argocd deployment/argocd-server --tail=20
```

---

## Expected Results

### Successful Deployment Indicators:
- ✅ Application status: "Synced" and "Healthy"
- ✅ All resources showing green status in GUI
- ✅ NGINX pods running
- ✅ Service accessible via port forwarding

### Final Status Check
```bash
# Verify everything is working
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl get all -n default
```

---

## Troubleshooting

### If ArgoCD Pods Don't Start
```bash
kubectl describe pods -n argocd
kubectl logs -n argocd <pod-name>
```

### If Login Fails
1. Check if all pods are running
2. Restart the ArgoCD server
3. Reset the admin password (see Task 2 troubleshooting)

### If Application Sync Fails
1. Check the repository URL is accessible
2. Verify the path contains valid Kubernetes manifests
3. Check ArgoCD application logs in the GUI

### If NGINX Isn't Accessible
```bash
kubectl get pods -n default
kubectl describe service nginx -n default
kubectl logs <nginx-pod-name> -n default
```
