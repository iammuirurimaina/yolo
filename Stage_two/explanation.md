# Stage 2: Terraform and Ansible Instrumentation

This directory contains the implementation for Stage 2, where we combine Ansible and Terraform to achieve a fully automated deployment.

## Architecture

In this stage, we leverage the strengths of both tools:
- **Ansible**: Used for **Configuration Management**. It provisions the server environment (installing Docker, Git, Terraform) and acts as the orchestrator.
- **Terraform**: Used for **Infrastructure Provisioning**. It manages the Docker resources (networks, volumes, images, containers) as code.

## Workflow

The deployment process is orchestrated by the `Stage_two/playbook.yml` Ansible playbook, which executes the following roles in order:

1.  **`common`**:
    -   Updates system packages.
    -   Installs Docker and Git.
    -   Ensures the Docker service is running.

2.  **`clone`**:
    -   Clones the application repository from GitHub to the VM.

3.  **`terraform_install`**:
    -   Adds the HashiCorp GPG key and repository.
    -   Installs the `terraform` binary on the VM.

4.  **`deploy`**:
    -   Copies the Terraform configuration files (`Stage_two/terraform/`) from the host to the VM.
    -   Uses the `community.general.terraform` Ansible module to run `terraform init` and `terraform apply`.
    -   Passes dynamic variables (like `server_ip`, `project_root`, ports) from Ansible to Terraform.

## Terraform Resources

The Terraform configuration (`main.tf`) defines the following resources:

-   **Docker Network**: `yolo-network` for container communication.
-   **Docker Volumes**: `mongodb_data` and `mongodb_config` for data persistence.
-   **MongoDB Container**: Runs the database service.
-   **Backend Container**: Builds the image from the source code and connects to MongoDB.
-   **Frontend Container**: Builds the image from the source code, configured with the backend API URL.

## Why this approach?

-   **Separation of Concerns**: Terraform excels at state management and resource lifecycle (creating/destroying containers), while Ansible excels at server configuration and procedural tasks.
-   **Automation**: The entire stack is deployed with a single `vagrant up` command.
-   **Idempotency**: Both Ansible and Terraform are idempotent, meaning running the provisioner multiple times will not break the system but rather ensure it matches the desired state.
