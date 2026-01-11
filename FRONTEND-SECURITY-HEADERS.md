# Frontend Security Headers Documentation

## Overview
This document explains the security headers implemented in the frontend Nginx configuration to protect against common web vulnerabilities and attacks.

## Security Headers Configuration

### File Location
- **Configuration File**: `frontend/security-headers.conf`
- **Include Location**: `/etc/nginx/nginx.conf` (included in server block)

### Headers Implemented

#### 1. Content Security Policy (CSP)
```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' http://backend:3000 https://backend:3000; frame-ancestors 'none';" always;
```

**Purpose**: Prevents XSS attacks by controlling which resources can be loaded and executed.

**Policy Breakdown**:
- `default-src 'self'`: Only allow resources from the same origin
- `script-src 'self' 'unsafe-inline' 'unsafe-eval'`: Allow scripts from same origin, inline scripts, and eval()
- `style-src 'self' 'unsafe-inline'`: Allow styles from same origin and inline styles
- `img-src 'self' data: https:`: Allow images from same origin, data URIs, and HTTPS
- `font-src 'self' data:`: Allow fonts from same origin and data URIs
- `connect-src 'self' http://backend:3000 https://backend:3000`: Allow connections to backend API
- `frame-ancestors 'none'`: Prevent embedding in frames (clickjacking protection)

#### 2. X-Frame-Options
```nginx
add_header X-Frame-Options "DENY" always;
```

**Purpose**: Prevents clickjacking attacks by controlling whether the page can be embedded in frames.

#### 3. X-Content-Type-Options
```nginx
add_header X-Content-Type-Options "nosniff" always;
```

**Purpose**: Prevents MIME type sniffing attacks by instructing browsers not to guess content types.

#### 4. X-XSS-Protection
```nginx
add_header X-XSS-Protection "1; mode=block" always;
```

**Purpose**: Enables XSS filtering in older browsers (defense in depth).

#### 5. Referrer-Policy
```nginx
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

**Purpose**: Controls how much referrer information is sent with requests.

**Policy**: Send full referrer for same-origin, origin only for cross-origin.

#### 6. Permissions-Policy (formerly Feature Policy)
```nginx
add_header Permissions-Policy "camera=(), microphone=(), geolocation=(), gyroscope=(), speaker=(), payment=()" always;
```

**Purpose**: Restricts access to sensitive browser features and APIs.

**Restrictions**: Disables camera, microphone, geolocation, gyroscope, speaker, and payment APIs.

#### 7. Cross-Origin Embedder Policy (COEP)
```nginx
add_header Cross-Origin-Embedder-Policy "require-corp" always;
```

**Purpose**: Enables cross-origin isolation for better security.

#### 8. Cross-Origin Opener Policy (COOP)
```nginx
add_header Cross-Origin-Opener-Policy "same-origin" always;
```

**Purpose**: Prevents certain cross-origin attacks by isolating the browsing context.

#### 9. Cross-Origin Resource Policy (CORP)
```nginx
add_header Cross-Origin-Resource-Policy "same-origin" always;
```

**Purpose**: Controls which origins can include resources from this origin.

#### 10. Server Header Removal
```nginx
more_clear_headers Server;
```

**Purpose**: Removes server information from HTTP headers to avoid information disclosure.

## CORS Configuration

### API Proxy CORS Headers
```nginx
# In /api/ location block
add_header Access-Control-Allow-Origin "*" always;
add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization" always;
add_header Access-Control-Expose-Headers "Content-Length,Content-Range" always;
```

**Purpose**: Enables cross-origin requests for API calls from the frontend to backend.

### Preflight Request Handling
```nginx
if ($request_method = 'OPTIONS') {
    # CORS headers for preflight requests
    return 204;
}
```

**Purpose**: Properly handles CORS preflight requests for complex API calls.

## Security Benefits

### Protection Against:
- **Cross-Site Scripting (XSS)**: CSP and X-XSS-Protection
- **Clickjacking**: X-Frame-Options and CSP frame-ancestors
- **MIME Sniffing Attacks**: X-Content-Type-Options
- **Information Disclosure**: Server header removal
- **Cross-Origin Attacks**: COEP, COOP, CORP
- **Feature Abuse**: Permissions-Policy

### Compliance:
- **OWASP Security Headers**: Implements most recommended headers
- **Modern Browser Support**: Uses current security standards
- **Defense in Depth**: Multiple layers of protection

## Configuration Notes

### Environment Considerations
- **Development**: Same headers applied for consistency
- **Production**: Headers are identical (no environment-specific differences)
- **HTTPS**: Headers work with both HTTP and HTTPS

### Browser Compatibility
- **Modern Browsers**: Full support for all headers
- **Legacy Browsers**: Graceful degradation (X-XSS-Protection fallback)
- **Mobile Browsers**: Supported across platforms

### Performance Impact
- **Minimal Overhead**: Headers add negligible latency
- **Caching**: Headers included in cacheable responses
- **Compression**: Headers are compressed with gzip

## Testing and Validation

### Manual Testing
```bash
# Check headers on main page
curl -I http://localhost:8080/

# Check headers on API calls
curl -I http://localhost:8080/api/books

# Test CORS preflight
curl -X OPTIONS -H "Origin: http://localhost:8080" http://localhost:8080/api/books
```

### Security Scanning
- Use tools like OWASP ZAP or Burp Suite to verify headers
- Check browser developer tools for security warnings
- Validate CSP with online CSP evaluators

### Monitoring
- Monitor for CSP violation reports (if report-uri is configured)
- Check access logs for blocked requests
- Alert on security header absence

## Maintenance

### Updates
- Review and update CSP policy when adding new resources
- Monitor browser support for new security headers
- Update CORS allowed origins for production deployments

### Troubleshooting
- **CSP Blocking Legitimate Resources**: Update CSP policy
- **CORS Issues**: Verify allowed origins and headers
- **Header Conflicts**: Check for duplicate headers in configuration

### Best Practices
- **Principle of Least Privilege**: Only allow necessary permissions
- **Regular Audits**: Review headers annually or when adding features
- **Documentation**: Keep security decisions documented and justified