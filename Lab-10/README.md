# Node.js Docker Jenkins Pipeline

This repository contains a Jenkins Pipeline configuration for automating the build and deployment of a Dockerized Node.js application.

### Plugins
- Docker
- Docker API
- Docker Pipline
- NodeJs

## Repository Structure
- `app.js` - Node.js application source code
- `Dockerfile` - Docker image configuration
- `Jenkinsfile` - Jenkins Pipeline configuration

## Jenkins Pipeline Setup

### Pre-Requirements
- Jenkins installed and running
- Docker installed on the same host as Jenkins
- Git plugin installed in Jenkins
- Docker Pipeline plugin installed in Jenkins
- Public GitHub repository access

### Task 1: Create Jenkins Pipeline Job

1. Open Jenkins dashboard
2. Click "New Item"
3. Enter item name: `nodejs-docker-pipeline`
4. Select "Pipeline" type
5. Click "OK"
6. Under "Pipeline" → "Definition", choose "Pipeline script from SCM"
7. Set SCM to "Git"
8. Add repository URL: `https://github.com/abdelrahmanonline4/sourcecode`
9. Set branch to `main`
10. Script Path: `Jenkinsfile`
11. Save the configuration

### Task 2: Pipeline Stages

The Jenkinsfile defines a pipeline with four stages:

#### 1. Checkout Stage
- Pulls source code from GitHub repository
- Uses the main branch

#### 2. Build Docker Image Stage
- Builds Docker image from Dockerfile
- Tags image with build number and 'latest'
- Uses environment variables for image naming

#### 3. Run Container Stage
- Stops and removes any existing container
- Starts new container from built image
- Maps port 3000 for application access
- Verifies container is running

#### 4. Verify Deployment Stage
- Waits for application to start
- Checks container logs
- Displays container status
- Confirms application accessibility

### Environment Variables
- `DOCKER_IMAGE`: nodejs-app
- `DOCKER_TAG`: Jenkins build number
- `CONTAINER_NAME`: nodejs-app-container
- `APP_PORT`: 3000

### Post-Build Actions
- **Success**: Displays success message and container info
- **Failure**: Cleans up failed containers
- **Always**: Removes unused Docker images

## Verification Steps

1. **Pipeline Execution**: All stages should complete successfully
2. **Container Status**: Verify container is running on port 3000
3. **Application Access**: Check `http://localhost:3000`
4. **Logs**: Review Jenkins console output and Docker logs

## Troubleshooting

### Common Issues
- **Docker permission errors**: Ensure Jenkins user has Docker permissions
- **Port conflicts**: Check if port 3000 is already in use
- **Git access**: Verify repository URL and branch name
- **Docker daemon**: Ensure Docker service is running

### Useful Commands
```bash
# Check running containers
docker ps

# View container logs
docker logs nodejs-app-container

# Stop container manually
docker stop nodejs-app-container

# Remove container
docker rm nodejs-app-container

# List Docker images
docker images
```

## Pipeline Features

- **Automated cleanup**: Removes old containers and unused images
- **Error handling**: Graceful failure management
- **Environment variables**: Configurable settings
- **Verification steps**: Ensures successful deployment
- **Detailed logging**: Comprehensive output for debugging

---

Previous lab reference: [Lab 9](https://github.com/DevOps-MLOps-Projects/Lab-9)