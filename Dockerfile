# ========================================================
# BISHE Car Wash Service - Production Web Container
# Serves the compiled Flutter Web application via Nginx
# ========================================================
FROM nginx:1.27-alpine

LABEL maintainer="BISHE Station Team"
LABEL description="BISHE Car Wash Multi-Role Flutter Web Application"

# Remove default nginx configurations
RUN rm -rf /etc/nginx/conf.d/*

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy production compiled Flutter Web bundle
COPY build/web /usr/share/nginx/html

# Expose HTTP port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=20s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/healthz || exit 1

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
