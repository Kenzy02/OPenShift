#!/bin/bash

# Configuration
OUTPUT_DIR="security-reports"
mkdir -p "$OUTPUT_DIR"

echo "🛡️ Starting Trivy Security Scans..."

# Function to get image from cluster
get_image() {
    local namespace=$1
    local label=$2
    local fallback=$3
    local image=$(kubectl get pods -n "$namespace" -l "$label" -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null)
    if [ -z "$image" ]; then
        echo "$fallback"
    else
        # If it's a local storage image, ensure it has a tag
        if [[ "$image" != *":"* ]]; then
            image="${image}:latest"
        fi
        echo "$image"
    fi
}

# Image definitions
declare -A IMAGES
IMAGES=(
    ["frontend"]=$(get_image "frontend" "app=fe-frontend" "bookstore-frontend:b830dbd-fixed8")
    ["backend"]=$(get_image "backend" "app.kubernetes.io/name=backend" "bookstore-backend:b830dbd")
    ["mysql"]=$(get_image "database" "app.kubernetes.io/name=mysql" "mysql:8.0")
    ["redis"]=$(get_image "database" "app.kubernetes.io/name=redis" "redis:7.0-alpine")
)

echo "--------------------------------------------------"
echo "📋 Scanning the following images:"
for KEY in "frontend" "backend" "mysql" "redis"; do
    echo "  - $KEY: ${IMAGES[$KEY]}"
done
echo "--------------------------------------------------"

# Check if trivy is as snap and warn about confinement
if snap list trivy &>/dev/null; then
    echo "ℹ️ Trivy detected as a snap. If scans fail with 'permission denied' on /var/run/docker.sock,"
    echo "   run: sudo snap connect trivy:docker-host-daemon"
    echo "--------------------------------------------------"
fi

# Scan function
perform_scan() {
    local name=$1
    local image=$2
    local md_report="$OUTPUT_DIR/${name}-report.md"
    local txt_report="$OUTPUT_DIR/${name}-report.txt"

    echo "🔍 Scanning $name ($image)..."

    # Run trivy and capture output
    # Using the exit code is safer than grepping "error"
    trivy image --format table --quiet "$image" > "$txt_report" 2>/tmp/trivy_err
    local exit_code=$?
    
    # Start MD report
    echo "# Security Scan Report: $name" > "$md_report"
    echo "- **Image**: \`$image\`" >> "$md_report"
    echo "- **Date**: $(date)" >> "$md_report"
    echo "" >> "$md_report"
    echo "## Vulnerability Table" >> "$md_report"
    
    if [ $exit_code -eq 0 ]; then
        echo '```text' >> "$md_report"
        cat "$txt_report" >> "$md_report"
        echo '```' >> "$md_report"
        echo "✅ Scan completed for $name."
    else
        echo "❌ Scan failed for $name (Exit code: $exit_code)"
        echo "> [!CAUTION]" >> "$md_report"
        echo "> Scan failed with exit code $exit_code." >> "$md_report"
        echo "" >> "$md_report"
        echo "### Error Output" >> "$md_report"
        echo '```text' >> "$md_report"
        cat /tmp/trivy_err >> "$md_report"
        cat "$txt_report" >> "$md_report"
        echo '```' >> "$md_report"
        
        # Also copy the error to the txt report for consistency
        cat /tmp/trivy_err >> "$txt_report"
    fi
}

# Iterate and scan
for KEY in "frontend" "backend" "mysql" "redis"; do
    perform_scan "$KEY" "${IMAGES[$KEY]}"
done

echo "--------------------------------------------------"
echo "Security scans finished."
echo "Markdown reports: $OUTPUT_DIR/*.md"
echo "Plain text reports: $OUTPUT_DIR/*.txt"
echo "--------------------------------------------------"
rm -f /tmp/trivy_err
