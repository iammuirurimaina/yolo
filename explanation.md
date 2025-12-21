# Docker Containerization Implementation Explanation

## 1. Image Selection

- Used `node:18-alpine` for both backend and frontend
- Alpine Linux is much smaller than regular Linux distributions
- This minimizes the final image size, helping achieve the goal of keeping total image size under 400MB

## 2. Backend Dockerfile Explanation

- Base image: `node:18-alpine` - chosen because Alpine Linux is much smaller than regular Linux distributions.
- Copy `package.json` files first before copying application code. This enables Docker layer caching thus making rebuilds much faster when only code changes
- Run `npm ci --only=production` - installs only production dependencies, excluding dev dependencies to minimize image size.

- Command: `node server.js` - runs the Express API server when the container starts, making it available inside the Docker container

## 3. Frontend Dockerfile Explanation

- Uses a multi-stage build with two stages: build stage and production stage
- **Build stage:**
  - Uses `node:18-alpine` to build the React app into static files
  - Runs `npm run build` which creates optimized production files in the `/app/build` directory
- **Production stage:**
  - Uses `nginx:alpine` which is a lightweight web server.
  - Copies only the built static files from the first stage thus creating a final image that's much smaller since it only includes the web server and static files and excludes Node.js and all build tools from the final image
- This multi-stage approach helps achieve the goal of keeping total image size minimal while still serving the React app efficiently

## 4. Docker Compose Considerations

### Service Orchestration
- **MongoDB Service**: Uses official `mongo:7.0` image with health checks to ensure database is ready before other services start
- **Backend Service**: Built from `./backend/Dockerfile` and depends on MongoDB being healthy before starting
- **Frontend Service**: Built from `./client/Dockerfile` and depends on backend being available

### Network Configuration
- All services are connected via a custom bridge network (`yolo-network`)
- This allows services to communicate using service names (e.g., `mongodb`, `backend`) instead of IP addresses
- Frontend can reach backend at `http://backend:4000` within the Docker network
- Backend connects to MongoDB at `mongodb://mongodb:27017/yolo`

### Dependency Management
- **Health Checks**: MongoDB has a health check that runs every 10 seconds to verify it's ready
- **depends_on with condition**: Backend waits for MongoDB to be healthy before starting, preventing connection errors
- **Service Dependencies**: Frontend depends on backend, ensuring API is available before serving the React app

### Port Mapping
- **MongoDB**: Exposes port 27017 for direct database access if needed
- **Backend**: Maps container port 4000 to host port 4000
- **Frontend**: Maps container port 80 (nginx) to host port 3000 for consistency with development setup

### Data Persistence
- **Named Volumes**: MongoDB data is stored in persistent volumes (`mongodb_data` and `mongodb_config`)
- Data survives container restarts and removals
- Volumes are only removed when explicitly using `docker-compose down -v`

### Restart Policies
- All services use `restart: unless-stopped` policy
- Containers automatically restart if they crash or the system reboots
- Provides high availability without manual intervention

### Environment Variables
- **Backend**: Receives `MONGODB_URI` pointing to the MongoDB service name, `PORT`, and `NODE_ENV`
- **Frontend**: Receives `REACT_APP_API_URL` pointing to backend service name for API calls
- Environment variables are set at container startup, allowing configuration without rebuilding images

### Build Context
- Each service specifies its build context (e.g., `./backend`, `./client`)
- This ensures Docker only has access to necessary files for each service
- Reduces build context size and improves build performance

## 5. Docker Hub Image Management



### Building Images

**Build individual service images:**
```bash
# Build backend image
docker build -t <username>/yolomy-backend:latest ./backend

# Build frontend image
docker build -t <username>/yolomy-frontend:latest ./client
```

```


### Docker Hub Repository Structure



### Using Images from Docker Hub

**Pull and run images:**
```bash
# Pull image
docker pull ianmaina/yolo-backend:2.0.0

# Run container
docker run -d -p 4000:4000 yolo-backend:2.0.0
```

**Update docker-compose.yml to use Docker Hub images:**
```yaml
services:
  backend:
    image: <username>/yolomy-backend:latest
    # Remove build section when using pre-built images
    # build:
    #   context: ./backend
    #   dockerfile: Dockerfile
```


Key considerations:
- **Alpine-based images**: Significantly smaller than standard images
- **Multi-stage builds**: Reduce final image size by excluding build tools
- **Production dependencies only**: Using `npm ci --omit=dev` excludes dev dependencies
- **Layer caching**: Optimized Dockerfile structure enables efficient layer reuse




