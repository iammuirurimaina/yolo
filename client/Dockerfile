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

COPY . .
# Build the React application for production
RUN NODE_OPTIONS=--openssl-legacy-provider npm run build



