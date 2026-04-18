# Use Nginx to serve the pre-built React app
FROM nginx:alpine

# Copy the built dist folder to Nginx html directory
COPY dist/ /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
