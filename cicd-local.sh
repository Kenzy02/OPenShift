#!/bin/bash

# Bookstore Local CI/CD Simulation Script
# This script runs local security scans and prepares reports.

PROJECT_ROOT=$(pwd)
SECURITY_DIR="$PROJECT_ROOT/security-reports"
IMAGE_TAG=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")

# Ensure security directory exists
mkdir -p "$SECURITY_DIR"

echo "🛡️ Starting local security scans for tag: $IMAGE_TAG"

# 1. Trivy Scan for Backend
echo "🔍 Running Trivy scan on Backend..."
trivy fs "$PROJECT_ROOT/backend" --severity HIGH,CRITICAL --format json --output "$SECURITY_DIR/backend-fs-report.json"
trivy fs "$PROJECT_ROOT/backend" --severity HIGH,CRITICAL --format table

# 2. Trivy Scan for Frontend
echo "🔍 Running Trivy scan on Frontend..."
trivy fs "$PROJECT_ROOT/frontend" --severity HIGH,CRITICAL --format json --output "$SECURITY_DIR/frontend-fs-report.json"
trivy fs "$PROJECT_ROOT/frontend" --severity HIGH,CRITICAL --format table

# 3. SonarQube Simulation Note
echo "📝 Note: SonarQube scan should be run via 'sonar-scanner' if installed locally."
if command -v sonar-scanner &> /dev/null; then
    echo "🔍 Running local SonarQube analysis..."
    # You can uncomment these if sonar-scanner is configured
    # sonar-scanner -Dproject.settings=backend/sonar-project.properties
    # sonar-scanner -Dproject.settings=frontend/sonar-project.properties
else
    echo "⚠️  sonar-scanner not found. Skipping local SonarQube scan."
fi

echo "✅ Local scans complete. Reports available in $SECURITY_DIR"
