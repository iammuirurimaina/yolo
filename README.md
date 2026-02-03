# Yolo E-Commerce Platform


## Overview
A full-stack MERN (MongoDB, Express, React, Node.js) e-commerce application for managing products. This repository contains the source code and Kubernetes manifests for deploying the application on Google Kubernetes Engine (GKE) using proper orchestration practices.

## Features
- **Orchestration**: Fully deployed on Kubernetes (GKE).
- **Persistence**: MongoDB utilizes `StatefulSets` with persistent storage to ensure data safety.
- **Exposure**: LoadBalancers used for public access.
- **Microservices**: Decoupled Frontend, Backend, and Database.

## Repository Structure
- `k8s/`: Kubernetes manifest files (YAML).
- `backend/`: Node.js/Express API source code.
- `client/`: React Frontend source code.
- `ip4explanation.md`: Detailed documentation of the Kubernetes implementation and design choices.

## GKE Deployment
To deploy this application to your own GKE cluster, see the detailed instructions in [ip4explanation.md](./ip4explanation.md).

### Quick Summary
1.  **Deploy Manifests**:
    ```bash
    kubectl apply -f k8s/
    ```
2.  **Get Backend IP**:
    ```bash
    kubectl get svc backend-service
    ```
3.  **Build Frontend with IP**:
    ```bash
    docker build --build-arg REACT_APP_API_URL=http://<BACKEND_IP>:4000 -t <your-repo>/yolo-frontend:v1 ./client
    docker push <your-repo>/yolo-frontend:v1
    ```
4.  **Restart Frontend**:
    ```bash
    kubectl rollout restart deployment frontend
    ```

## Local Development (Docker Compose)
1. **Build and Run**:
   ```bash
   docker-compose up -d --build
   ```
2. **Access**:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:4000

## License
MIT
