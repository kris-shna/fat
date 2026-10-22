FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
# This invalid argument will cause the container to crash immediately
CMD ["nginx", "-g", "daemon off;", "--force-invalid-runtime-failure"]
