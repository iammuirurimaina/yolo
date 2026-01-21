# Yolo E-Commerce Platform

A full-stack MERN (MongoDB, Express, React, Node.js) e-commerce application for managing products.

## Features

- Product listing and management
- Add, edit, and delete products
- Product detail views
- Persistent data storage with MongoDB
- RESTful API backend
- Modern React frontend

## Prerequisites

- Docker and Docker Compose installed
- Git (for cloning the repository)

## Quick Start with Docker

### 1. Clone the Repository

```bash
git clone <repository-url>
cd yolo
```

### 2. Build and Run with Docker Compose

```bash
# Build and start all services in detached mode
docker-compose up -d --build
```

### 3. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:4000
- **MongoDB**: localhost:27017

### 4. Stop the Application

```bash
# Stop containers
docker-compose down

# Stop and remove volumes (removes database data)
docker-compose down -v
```

## Docker Services

The application consists of three services:

1. **mongodb**: MongoDB database server (port 27017)
2. **backend**: Express.js API server (port 4000)
3. **frontend**: React development server (port 3000)

## Development

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Stop Services

```bash
# Stop containers (keeps data)
docker-compose down

# Stop and remove volumes (clears database)
docker-compose down -v
```

### Restart Services

```bash
docker-compose restart
```

### Rebuild After Code Changes

```bash
docker-compose up -d --build
```

## API Endpoints

- `GET /api/products` - Get all products
- `POST /api/products` - Create a product
- `PUT /api/products/:id` - Update a product
- `DELETE /api/products/:id` - Delete a product

## Troubleshooting

### Port Already in Use

If ports 3000, 4000, or 27017 are already in use, stop the conflicting services or modify port mappings in `docker-compose.yml`.

### Services Not Starting

```bash
# Check service status
docker-compose ps

# View error logs
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose up -d --build
```

### Database Connection Issues

Ensure MongoDB container is healthy:
```bash
docker-compose ps mongodb
docker-compose logs mongodb
```

## Deployment with Vagrant and Ansible

This project includes a fully automated deployment setup using Vagrant and Ansible.

### Prerequisites
- Vagrant installed
- VirtualBox installed

### Steps to Deploy

1. **Initialize the VM**:
   Navigate to the project root and run:
   ```bash
   vagrant up
   ```
   This command will:
   - Provision an Ubuntu 20.04 VM.
   - Install Docker, Git, and other dependencies.
   - Clone the repository inside the VM.
   - Build and run the MongoDB, Backend, and Frontend containers.

2. **Access the Application**:
   Once the provisioning is complete, the application will be available at:
   - **Frontend**: http://192.168.56.56:3000
   - **Backend API**: http://192.168.56.56:4000

3. **Reprovisioning**:
   If you make changes to the playbook or need to re-run the setup:
   ```bash
   vagrant provision
   ```

4. **SSH into the VM**:
   To access the virtual machine shell:
   ```bash
   vagrant ssh
   ```

## License

MIT
