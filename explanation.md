# Independent Project: GKE Deployment Explanation

## Phase 1: Containerization

### Docker Image Management
We have built and pushed the application images to Docker Hub to ensure accessibility from the GKE cluster.

**Repositories**:
- **Backend**: `ianmaina/yolo-backend`
- **Frontend**: `ianmaina/yolo-frontend`

**Tagging Strategy**:
We utilized the `v1` tag for our initial release:
- `ianmaina/yolo-backend:v1`
- `ianmaina/yolo-frontend:v1`

**Reasoning**:
Using semantic versioning (or at least explicit version tags like `v1`) is a best practice over using `latest`. It ensures that deployments are reproducible and that we can rollback to a specific version if needed.
