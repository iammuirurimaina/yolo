# Frontend Dockerfile 

# STAGE 1: Build Stage
# This stage builds the React app into static files
FROM node:18-alpine AS builder

# Set working directory for the build
WORKDIR /app

# Copy package files first (Docker layer caching optimization)
COPY package*.json ./
# Install all dependencies 
RUN npm ci

ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL

COPY . .
# Build the React application for production
RUN NODE_OPTIONS=--openssl-legacy-provider npm run build


# STAGE 2: Production Stage

# This stage creates the final, small image that only serves static files
FROM nginx:alpine

# Copy the built static files from the builder stage

COPY --from=builder /app/build /usr/share/nginx/html


# Expose port 80 
EXPOSE 80
# Start nginx 
CMD ["nginx", "-g", "daemon off;"]