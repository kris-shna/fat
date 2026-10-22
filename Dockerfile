FROM nginx:alpine
# Copy our monitoring interface into the default web serving directory
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
