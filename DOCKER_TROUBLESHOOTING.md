# Docker Compose Troubleshooting Guide

## Fixed Issues

### 1. Missing Version Field
**Problem:** Docker Compose file was missing the `version` field at the top.

**Solution:** Added `version: '3.8'` to the docker-compose.yml file.

### 2. Healthcheck Using Unsupported `fetch()`
**Problem:** The healthcheck was using `fetch()` which may not be available in all Node.js versions or requires experimental flags.

**Solution:** Replaced with native `http` module:
```yaml
healthcheck:
  test: ["CMD", "node", "-e", "require('http').get('http://127.0.0.1:3000/api/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1));"]
```

---

## Quick Start

### Option 1: Using the Verification Script (Recommended)
```bash
cd nestjs-cicd-api
chmod +x docker-verify.sh
./docker-verify.sh
```

### Option 2: Manual Commands
```bash
# Navigate to the project directory
cd nestjs-cicd-api

# Clean up any existing containers/images
docker compose -f docker-compose.yml down -v --rmi local

# Build and start containers
docker compose -f docker-compose.yml up -d --build

# Check container status
docker compose -f docker-compose.yml ps

# View logs
docker compose -f docker-compose.yml logs -f
```

---

## Common Issues & Solutions

### Issue 1: Port Already in Use
**Error:** `Bind for 0.0.0.0:3000 failed: port is already allocated`

**Solution:**
```bash
# Find what's using port 3000
lsof -i :3000

# Kill the process (replace PID with actual process ID)
kill -9 PID

# Or change the port in docker-compose.yml
ports:
  - "3001:3000"  # Use port 3001 instead
```

### Issue 2: Docker Daemon Not Running
**Error:** `Cannot connect to the Docker daemon`

**Solution:**
- Start Docker Desktop application
- Wait for Docker to fully start (look for the Docker icon in your system tray/menu bar)
- Retry the command

### Issue 3: Build Cache Issues
**Error:** Build fails with outdated dependencies or cached layers

**Solution:**
```bash
# Remove all containers, volumes, and images
docker compose -f docker-compose.yml down -v --rmi all

# Build without cache
docker compose -f docker-compose.yml build --no-cache

# Start containers
docker compose -f docker-compose.yml up -d
```

### Issue 4: Permission Denied (Linux/Mac)
**Error:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# Add your user to the docker group (Linux)
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker

# Or run with sudo (not recommended for regular use)
sudo docker compose -f docker-compose.yml up -d --build
```

### Issue 5: Container Starts But Crashes Immediately
**Error:** Container status shows "Exited (1)"

**Solution:**
```bash
# Check container logs
docker compose -f docker-compose.yml logs nestjs-api

# Common causes:
# - Missing dependencies in package.json
# - Incorrect CMD in Dockerfile
# - Application errors on startup

# Check if dist folder was built correctly
docker compose -f docker-compose.yml run --rm nestjs-api ls -la dist/
```

### Issue 6: Health Check Failing
**Error:** Container status shows "unhealthy"

**Solution:**
```bash
# Check if the app is actually running
docker exec -it nestjs-cicd-api node -e "require('http').get('http://127.0.0.1:3000/api/health', (r) => console.log('Status:', r.statusCode))"

# Check application logs
docker compose -f docker-compose.yml logs -f nestjs-api

# Verify the health endpoint exists
curl http://localhost:3000/api/health
```

### Issue 7: Module Not Found During Build
**Error:** `Error: Cannot find module 'xyz'`

**Solution:**
```bash
# Ensure package.json and package-lock.json are present
ls -la package*.json

# Check .dockerignore isn't excluding necessary files
cat .dockerignore

# Rebuild with no cache
docker compose -f docker-compose.yml build --no-cache
```

### Issue 8: Network Issues
**Error:** Container can't reach external services

**Solution:**
```bash
# Check Docker network
docker network ls

# Inspect the network
docker network inspect nestjs-cicd-api_default

# Test connectivity from inside container
docker exec -it nestjs-cicd-api ping google.com
```

---

## Useful Commands

### Container Management
```bash
# Start containers
docker compose -f docker-compose.yml up -d

# Stop containers
docker compose -f docker-compose.yml down

# Restart containers
docker compose -f docker-compose.yml restart

# View running containers
docker compose -f docker-compose.yml ps

# View all containers (including stopped)
docker ps -a
```

### Logs & Debugging
```bash
# View logs (all services)
docker compose -f docker-compose.yml logs

# Follow logs (live)
docker compose -f docker-compose.yml logs -f

# View logs for specific service
docker compose -f docker-compose.yml logs nestjs-api

# Last 100 lines
docker compose -f docker-compose.yml logs --tail=100

# Execute command in running container
docker exec -it nestjs-cicd-api sh

# Check container health
docker inspect nestjs-cicd-api --format='{{.State.Health.Status}}'
```

### Cleanup
```bash
# Stop and remove containers
docker compose -f docker-compose.yml down

# Remove containers and volumes
docker compose -f docker-compose.yml down -v

# Remove containers, volumes, and images
docker compose -f docker-compose.yml down -v --rmi all

# Remove all unused Docker resources
docker system prune -a --volumes
```

### Image Management
```bash
# List images
docker images

# Remove specific image
docker rmi nestjs-cicd-api-nestjs-api

# Build without starting
docker compose -f docker-compose.yml build

# Force rebuild
docker compose -f docker-compose.yml build --no-cache
```

---

## Testing Your API

Once the container is running:

```bash
# Health check
curl http://localhost:3000/api/health

# Using httpie (if installed)
http GET localhost:3000/api/health

# Or open in browser
open http://localhost:3000/api/health
```

---

## Production Checklist

Before deploying to production:

- [ ] All environment variables are properly configured
- [ ] Secrets are not hardcoded in docker-compose.yml
- [ ] Health checks are working correctly
- [ ] Proper resource limits are set (CPU, memory)
- [ ] Logs are configured for log aggregation
- [ ] Container runs as non-root user (already configured as `node`)
- [ ] Security scanning completed (use `docker scan`)
- [ ] Multi-stage build optimizes image size
- [ ] .dockerignore excludes unnecessary files

---

## Need More Help?

1. Check the logs: `docker compose -f docker-compose.yml logs -f`
2. Inspect the container: `docker inspect nestjs-cicd-api`
3. Execute shell in container: `docker exec -it nestjs-cicd-api sh`
4. Validate config: `docker compose -f docker-compose.yml config`
