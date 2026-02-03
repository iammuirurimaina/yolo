## GKE Deployment Explanation

## Phase 1: Containerization

### Docker Image Management
I have built and pushed the application images to Docker Hub to ensure accessibility from the GKE cluster.

**Repositories**:
- **Backend**: `ianmaina/yolo-backend`
- **Frontend**: `ianmaina/yolo-frontend`

**Tagging Strategy**:
I utilized the `v1` tag for our initial release:
- `ianmaina/yolo-backend:v1`
- `ianmaina/yolo-frontend:v1`


### Build Process
- **Backend**: Built from the `backend/` directory using the Node.js 18 Alpine image.
- **Frontend**: Built from the `client/` directory. (Note: The frontend will need to be rebuilt in Phase 3 with the live backend IP).

## Phase 2: Kubernetes Implementation

### Kubernetes Object Choices
To achieve a robust and scalable architecture, I implemented the following Kubernetes objects:

1.  **StatefulSet for MongoDB**:
    *   **Reasoning**: I chose a `StatefulSet` over a standard Deployment for the database. StatefulSets provide stable network identities (`mongo-0`) and stable persistent storage. This ensures that if the database pod restarts, it reattaches to the *same* storage volume, preventing data loss—a critical requirement for any storage solution.
    *   

2.  **Deployments for Application Layers**:
    *   **Reasoning**: For the Backend and Frontend, I used `Deployments`. These components are stateless; if a pod dies, it can be replaced by any new pod without losing data. This allows for easy scaling (just increase `replicas`).

3.  **Services for Networking**:
    *   **Headless Service (`ClusterIP: None`)**: Used for MongoDB to allow the backend to discover the specific pod `mongo-0` directly.
    *   **LoadBalancer Services**: Used for both Backend and Frontend to expose them to the internet. On GKE, this automatically provisions an external IP address.

### Persistent Storage
I utilized `volumeClaimTemplates` within the MongoDB StatefulSet. This requests a Persistent Volume (PV) from Google Cloud's storage provisioner. It ensures that the database data persists even if the pod is deleted and recreated.

---

## Phase 3: Deployment Workflow

### Prerequisite: Connect to GKE
You must first ensure your local terminal is authenticated with your Google Cloud cluster.
```bash
gcloud auth login
gcloud config set project <YOUR_PROJECT_ID>
gcloud container clusters get-credentials <YOUR_CLUSTER_NAME> --zone <YOUR_ZONE>
```

Since the Frontend needs to know the Backend's IP address (which is assigned dynamically by Google Cloud), I follow this specific deployment order:

### Step 1: Deploy Database & Backend
```bash
# Apply all manifests
kubectl apply -f k8s/
```

### Step 2: Get Backend IP
Wait for the external IP to be assigned:
```bash
kubectl get services
```
*   Look for the `EXTERNAL-IP` of `backend-service`.
*   Note this IP (e.g., `34.123.45.67`).

### Step 3: Rebuild Frontend with Live Backend IP
The React app needs the API URL baked into it at build time.
```bash
# Replace <BACKEND_IP> with the actual IP you got above
docker build --build-arg REACT_APP_API_URL=http://<BACKEND_IP>:4000 -t ianmaina/yolo-frontend:v1 -f client/Dockerfile ./client

# Push the updated image
docker push ianmaina/yolo-frontend:v1
```

### Step 4: Restart Frontend
Force the frontend deployment to pull the new image:
```bash
kubectl rollout restart deployment frontend
```

### Step 5: Final Access
Get the frontend's IP:
```bash
kubectl get service frontend-service
```
Visit this IP in your browser to see the live application.
