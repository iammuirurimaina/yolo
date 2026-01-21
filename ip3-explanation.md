# IP3 Explanation

## Reasoning for Order of Execution

The playbook is structured to execute tasks in a logical dependency order:

1.  **Setup (Common & Clone)**:
    *   **Common Role**: This is the foundation. We first update the system and install necessary dependencies like Docker and Git. Without Docker, we cannot run our containers. Without Git, we cannot fetch the source code.
    *   **Clone Role**: Once the tools are installed, we clone the repository. This brings the application source code into the VM, which is required for building the Docker images in subsequent steps.

2.  **Database**:
    *   The backend depends on the database. Therefore, the MongoDB container must be up and running (or at least the service defined) before the backend attempts to connect. While Docker Compose handles `depends_on`, in Ansible, we explicitly ensure the database role runs first to establish the network and volume persistence.

3.  **Backend**:
    *   The backend API is the core logic provider. It needs the database to be ready.
    *   The frontend will need to talk to the backend. Thus, the backend should be deployed and accessible before the frontend is fully functional (though strictly speaking, they can start in parallel, but logical ordering helps in debugging).
    *   We build the backend image from the cloned source code to ensure the latest version is running.

4.  **Frontend**:
    *   The frontend is the user interface. It depends on the backend API.
    *   We build the frontend image from the cloned source code.
    *   It is the final step, completing the application stack.

## Roles and Functions

### 1. `common`
*   **Function**: Prepares the server environment.
*   **Tasks**:
    *   Updates `apt` cache.
    *   Installs system dependencies (`curl`, `git`, `python3-pip`).
    *   Installs Docker and the Docker Python SDK (required for Ansible's `docker_container` module).
    *   Creates the Docker network (`yolo-network`) to allow containers to communicate.

### 2. `clone`
*   **Function**: Fetches the application source code.
*   **Tasks**:
    *   Uses the `git` module to clone the repository from GitHub to a specified directory (`/home/vagrant/yolo`).

### 3. `database`
*   **Function**: Deploys the database service.
*   **Tasks**:
    *   Uses `docker_container` to run the official `mongo:7.0` image.
    *   Configures volumes for data persistence (`mongodb_data`, `mongodb_config`).
    *   Attaches to the `yolo-network`.

### 4. `backend`
*   **Function**: Deploys the backend API.
*   **Tasks**:
    *   Uses `docker_image` to build the image from the `backend` directory of the cloned repo.
    *   Uses `docker_container` to run the service.
    *   Sets environment variables (`MONGODB_URI`, `PORT`).
    *   Connects to `yolo-network` to reach the database.

### 5. `frontend`
*   **Function**: Deploys the client-side application.
*   **Tasks**:
    *   Uses `docker_image` to build the image from the `client` directory.
    *   Uses `docker_container` to run the service.
    *   Maps port 3000 to the host for browser access.

## Ansible Modules Applied

*   **`apt`**: Used for package management (installing Docker, Git, etc.).
*   **`pip`**: Used to install Python libraries (specifically `docker` for Ansible).
*   **`service`**: Ensures the Docker daemon is running.
*   **`user`**: Adds the `vagrant` user to the `docker` group.
*   **`git`**: Clones the repository.
*   **`docker_network`**: Manages Docker networks.
*   **`docker_image`**: Builds Docker images from a Dockerfile.
*   **`docker_container`**: Manages the lifecycle of Docker containers (start, stop, restart).
*   **`include_role`**: Used in the playbook to organize tasks into reusable roles.
