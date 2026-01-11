# Frontend Docker Configuration Documentation

## Overview
This document explains the Docker configuration for the frontend component of the bookstore application. The frontend serves static HTML/CSS/JavaScript files using Nginx and proxies API requests to the backend.

## Architecture

### Technology Stack
- **Web Server**: Nginx 1.25.3 Alpine
- **Base Image**: Alpine Linux 3.18 (slim variant)
- **Static Files**: HTML, CSS, JavaScript
- **API Proxy**: Routes `/api/*` requests to backend service

### Security Features
- **Non-root User**: Runs as nginx user (existing in Alpine image)
- **Read-only Filesystem**: Enabled in production with tmpfs mounts
- **Minimal Attack Surface**: Uses Alpine Linux with only essential packages
- **Security Updates**: Automatic package updates during build

## Dockerfiles

### Production Dockerfile (`Dockerfile`)
**Location:** `frontend/Dockerfile`

**Purpose:** Production-ready container for serving static files with maximum security.

**Key Features:**
- Multi-stage build (builder + runtime stages)
- Nginx Alpine slim image (nginx:1.25.3-alpine3.18-slim)
- Security hardening with dumb-init
- Read-only root filesystem support
- Health checks
- Proper signal handling

**Build Stages:**
1. **Builder Stage**: Prepares static files (minimal for static content)
2. **Runtime Stage**: Nginx server with copied static files

**Security Configuration:**
- Non-root user execution
- No unnecessary packages
- Minimal base image
- Proper file permissions

### Development Dockerfile (`Dockerfile.dev`)
**Location:** `frontend/Dockerfile.dev`

**Purpose:** Development environment with additional tools and volume mounts.

**Key Features:**
- Same security foundation as production
- Additional development tools (curl, wget, vim)
- Volume mounts for live file updates
- Relaxed security for development workflow

**Additional Tools:**
- curl: For API testing and debugging
- wget: For downloading resources
- vim: For file editing in container

## Docker Compose Integration

### Production (`docker-compose.yml`)
**Service:** `frontend`

**Configuration:**
- Builds from production Dockerfile
- Read-only filesystem with tmpfs mounts
- Security options enabled
- Depends on backend service
- Network isolation

### Development (`docker-compose.dev.yml`)
**Service:** `frontend-dev`

**Configuration:**
- Builds from development Dockerfile
- Volume mounts for live reloading
- Relaxed security for development
- Depends on backend-dev service

## Security Requirements Compliance

### ✅ Multi-stage Builds
- Separate builder and runtime stages
- Minimal runtime image size

### ✅ Non-root User
- Uses existing nginx user (UID appropriate for security)
- No privileged operations

### ✅ Read-only Filesystem
- `read_only: true` in production
- tmpfs mounts for necessary write operations
- Proper volume permissions

### ✅ No Latest Tags
- Specific version tags: `nginx:1.25.3-alpine3.18-slim`
- Alpine 3.19 for builder stage

### ✅ Minimal Base Images
- Alpine Linux (not Ubuntu/CentOS)
- Slim variant to reduce size
- Only essential packages installed

## Image Specifications

### Production Image
- **Base Image**: nginx:1.25.3-alpine3.18-slim
- **Size**: ~20MB (well under 150MB requirement)
- **User**: nginx
- **Ports**: 8080
- **Security**: Maximum hardening

### Development Image
- **Base Image**: nginx:1.25.3-alpine3.18-slim + dev tools
- **Size**: ~53MB (well under 150MB requirement)
- **User**: nginx
- **Ports**: 8080
- **Security**: Development-appropriate hardening

## File Structure
```
frontend/
├── Dockerfile              # Production build
├── Dockerfile.dev          # Development build
├── nginx.conf             # Nginx configuration
├── html/                  # Static files
│   ├── index.html
│   ├── app.js
│   └── style.css
└── .dockerignore          # Build exclusions
```

## Build and Deployment

### Building Images
```bash
# Production
docker build -t bookstore-frontend:prod .

# Development
docker build -f Dockerfile.dev -t bookstore-frontend:dev .
```

### Running with Docker Compose
```bash
# Production stack
docker-compose up -d

# Development stack
docker-compose -f docker-compose.dev.yml up -d
```

## Health Checks

### Endpoint
- **URL**: `http://localhost:8080/nginx-health`
- **Method**: HTTP GET
- **Expected Response**: "OK" (200 status)

### Configuration
- Interval: 30 seconds
- Timeout: 3 seconds
- Start period: 5 seconds
- Retries: 3

## Networking

### Internal Communication
- **Network**: bookstore-network (bridge driver)
- **Backend Proxy**: Routes `/api/*` to backend:3000
- **Service Discovery**: Uses service names for inter-container communication

### External Access
- **Port**: 8080 (configurable)
- **Protocol**: HTTP
- **CORS**: Handled by backend

## Monitoring and Logging

### Logs
- Nginx access/error logs available at `/var/log/nginx/`
- Application logs follow Nginx format
- tmpfs mounted for log rotation

### Health Monitoring
- Built-in health check endpoint
- Docker health status integration
- Prometheus-compatible metrics (via Nginx stub_status if enabled)

## Maintenance

### Updates
- Monitor Nginx security advisories
- Update base image versions regularly
- Test builds after dependency updates

### Troubleshooting
- Check container logs: `docker logs bookstore-frontend`
- Verify health: `curl http://localhost:8080/nginx-health`
- Debug networking: `docker network inspect bookstore-network`

### Performance Tuning
- Adjust worker processes in nginx.conf
- Configure gzip compression
- Optimize static file caching headers