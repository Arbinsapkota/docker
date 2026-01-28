# Use Nginx (stable Alpine)
FROM nginx:stable-alpine

# Copy your server block into the default vhost location
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy ONLY the public web files (avoid copying Jenkinsfile, .git, etc.)
# Rely on .dockerignore to exclude CI/VCS files.
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# If you have more assets later, add COPY lines or a folder (e.g., assets/)
# COPY assets/ /usr/share/nginx/html/assets/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]