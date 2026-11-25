#!/bin/bash

# Docker Compose Verification Script
# This script helps validate and troubleshoot Docker Compose setup

echo "🔍 Docker Compose Setup Verification"
echo "====================================="
echo ""

# Check if Docker is running
echo "1️⃣  Checking Docker daemon..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi
echo "✅ Docker is running"
echo ""

# Check if docker-compose.yml exists
echo "2️⃣  Checking docker-compose.yml..."
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found"
    exit 1
fi
echo "✅ docker-compose.yml found"
echo ""

# Validate docker-compose.yml syntax
echo "3️⃣  Validating docker-compose.yml syntax..."
if ! docker compose -f docker-compose.yml config > /dev/null 2>&1; then
    echo "❌ docker-compose.yml has syntax errors:"
    docker compose -f docker-compose.yml config
    exit 1
fi
echo "✅ docker-compose.yml syntax is valid"
echo ""

# Check if Dockerfile exists
echo "4️⃣  Checking Dockerfile..."
if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile not found"
    exit 1
fi
echo "✅ Dockerfile found"
echo ""

# Check if port 3000 is available
echo "5️⃣  Checking if port 3000 is available..."
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port 3000 is already in use. You may need to:"
    echo "   - Stop the process using port 3000"
    echo "   - Or change the port mapping in docker-compose.yml"
    echo "   Current process using port 3000:"
    lsof -Pi :3000 -sTCP:LISTEN
else
    echo "✅ Port 3000 is available"
fi
echo ""

# Clean up old containers/images
echo "6️⃣  Cleaning up old containers and images..."
docker compose -f docker-compose.yml down -v --rmi local 2>/dev/null || true
echo "✅ Cleanup complete"
echo ""

# Build and start containers
echo "7️⃣  Building and starting containers..."
echo "   This may take a few minutes..."
if docker compose -f docker-compose.yml up -d --build; then
    echo "✅ Containers built and started successfully"
    echo ""
    echo "8️⃣  Container status:"
    docker compose -f docker-compose.yml ps
    echo ""
    echo "9️⃣  Waiting for health check (max 30 seconds)..."
    
    # Wait for health check
    for i in {1..30}; do
        if docker inspect nestjs-cicd-api --format='{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy"; then
            echo "✅ Container is healthy!"
            echo ""
            echo "🎉 Setup complete! Your API is running at:"
            echo "   http://localhost:3000/api"
            echo "   Health check: http://localhost:3000/api/health"
            echo ""
            echo "📋 Useful commands:"
            echo "   View logs: docker compose -f docker-compose.yml logs -f"
            echo "   Stop: docker compose -f docker-compose.yml down"
            echo "   Restart: docker compose -f docker-compose.yml restart"
            exit 0
        fi
        echo -n "."
        sleep 1
    done
    
    echo ""
    echo "⚠️  Container started but health check not passing yet."
    echo "   Check logs with: docker compose -f docker-compose.yml logs"
else
    echo "❌ Failed to build or start containers"
    echo "   Check the error messages above"
    exit 1
fi
