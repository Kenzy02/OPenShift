# Backend Dockerfile - Node.js API with security hardening
# Multi-stage build for minimal image size and security

# ====================
# Build Stage
# ====================
FROM node:18.19.1-alpine3.19 AS builder

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Copy package files for dependency installation
COPY package*.json ./

# Install dependencies (including dev dependencies for build)
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY server.js ./

# ====================
# Runtime Stage
# ====================
FROM node:18.19.1-alpine3.19 AS runtime

# Metadata
LABEL maintainer="student@example.com" \
      version="1.0" \
      description="Bookstore Backend API" \
      security.scan="trivy"

# Install runtime dependencies only
RUN apk add --no-cache \
    dumb-init \
    && rm -rf /var/cache/apk/* \
    && addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Copy installed node_modules from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application source
COPY --from=builder /app/server.js ./

# Create directory for temporary files (for read-only root filesystem)
RUN mkdir -p /tmp && chown -R nodejs:nodejs /tmp /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (res) => { \
    process.exit(res.statusCode === 200 ? 0 : 1) \
  }).on('error', () => process.exit(1))"

# Use dumb-init for proper signal handling
#ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]