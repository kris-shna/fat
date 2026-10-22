FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
# This invalid flag forces the web server to crash on startup
CMD ["nginx", "-g", "daemon off;", "--force-invalid-runtime-failure"]
