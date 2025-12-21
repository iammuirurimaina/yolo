#Backend Dockerfile

FROM node:18-alpine
WORKDIR /app

#Copy package files first (Docker layer caching optimization)
COPY package*.json ./
# Step 4: Install only production dependencies
RUN npm ci --only=production
COPY . .

EXPOSE 4000
ENV PORT=4000

CMD ["node", "server.js"]
