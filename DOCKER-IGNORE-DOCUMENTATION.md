# Docker Ignore Files Documentation

## Overview
This document explains the purpose and contents of all `.dockerignore` files in the bookstore application project. These files optimize Docker builds by excluding unnecessary files from the build context, reducing build times and image sizes.

## File Structure

### Root `.dockerignore`
**Location:** `/home/kenzy/Project-student-version/.dockerignore`

**Purpose:** Global exclusions that apply to all Docker contexts in the project.

**Key Exclusions:**
- Version control files (`.git/`, `.gitignore`)
- Documentation files (`README.md`, `*.md`, `docs/`)
- Security reports and SBOMs (`*.sarif`, `*.spdx.json`, `*.cyclonedx.json`, `trivy-*`)
- Docker-related files to prevent recursion (`Dockerfile*`, `docker-compose*.yml`, `.dockerignore`)
- IDE and editor files (`.vscode/`, `.idea/`, `*.swp`)
- OS-specific files (`.DS_Store`, `Thumbs.db`)
- Logs and temporary files (`*.log`, `logs/`, `tmp/`, `temp/`)
- CI/CD configuration files
- Testing directories and files
- Development artifacts (`node_modules/`, `npm-debug.log*`)

### Backend `.dockerignore`
**Location:** `backend/.dockerignore`

**Purpose:** Optimizes the backend Docker build context by excluding Node.js-specific and build artifacts.

**Key Exclusions:**
- `node_modules/` - Prevents copying installed dependencies (they're installed during build)
- `npm-debug.log*` - NPM error logs
- `logs/` - Application logs
- `.env*` - Environment files (should use Docker secrets or build args)
- `coverage/` - Test coverage reports
- `*.tgz` - NPM package archives
- `.nyc_output/` - NYC test coverage output

### Database `.dockerignore`
**Location:** `database/.dockerignore`

**Purpose:** Optimizes the MySQL database Docker build context.

**Key Exclusions:**
- Version control and documentation files
- Security reports
- Docker files (to prevent recursion)
- IDE and OS files
- Logs and temporary files
- Development artifacts

### Frontend `.dockerignore`
**Location:** `frontend/.dockerignore`

**Purpose:** Optimizes the Nginx frontend Docker build context.

**Key Exclusions:**
- Version control and documentation files
- Security reports
- Docker files (to prevent recursion)
- IDE and OS files
- Logs and temporary files
- Development artifacts
- Build artifacts (`dist/`, `build/`)

## Benefits

1. **Faster Builds:** Smaller build contexts mean faster Docker builds
2. **Smaller Images:** Excluding unnecessary files reduces final image size
3. **Security:** Prevents sensitive files (logs, environment files) from being included in images
4. **Efficiency:** Avoids copying large directories like `node_modules` that are recreated during build

## Usage Notes

- Each `.dockerignore` file is specific to its directory's Dockerfile
- The root `.dockerignore` provides global exclusions
- Component-specific files override or supplement the root exclusions
- Always test builds after modifying `.dockerignore` files to ensure no required files are excluded

## Validation

To validate that `.dockerignore` files are working correctly:

```bash
# Check build context size before and after
docker build --no-cache -t test-build .
docker build --no-cache -t test-build . --progress=plain | grep "Sending build context"

# Or use docker buildx for more detailed context info
docker buildx build --no-cache -t test-build .
```

## Maintenance

- Review `.dockerignore` files when adding new file types or directories
- Update when new security reports or artifacts are generated
- Ensure exclusions don't break the build process