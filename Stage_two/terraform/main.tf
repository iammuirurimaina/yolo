terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# Variables
variable "project_root" {
  type = string
}

variable "server_ip" {
  type = string
}

variable "mongo_image" {
  type    = string
  default = "mongo:7.0"
}

variable "mongo_container_name" {
  type    = string
  default = "yolo-mongodb"
}

variable "mongo_port" {
  type    = number
  default = 27017
}

variable "backend_image_name" {
  type    = string
  default = "yolo-backend:latest"
}

variable "backend_container_name" {
  type    = string
  default = "yolo-backend"
}

variable "backend_port" {
  type    = number
  default = 4000
}

variable "frontend_image_name" {
  type    = string
  default = "yolo-frontend:latest"
}

variable "frontend_container_name" {
  type    = string
  default = "yolo-frontend"
}

variable "frontend_port" {
  type    = number
  default = 3000
}

variable "network_name" {
  type    = string
  default = "yolo-network"
}

# Resources

resource "docker_network" "yolo_network" {
  name = var.network_name
}

resource "docker_volume" "mongodb_data" {
  name = "mongodb_data"
}

resource "docker_volume" "mongodb_config" {
  name = "mongodb_config"
}

resource "docker_image" "mongo" {
  name         = var.mongo_image
  keep_locally = true
}

resource "docker_container" "mongodb" {
  name  = var.mongo_container_name
  image = docker_image.mongo.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.yolo_network.name
  }
  
  ports {
    internal = 27017
    external = var.mongo_port
  }
  
  volumes {
    volume_name = docker_volume.mongodb_data.name
    container_path = "/data/db"
  }
  
  volumes {
    volume_name = docker_volume.mongodb_config.name
    container_path = "/data/configdb"
  }
  
  env = [
    "MONGO_INITDB_DATABASE=yolo"
  ]
}

resource "docker_image" "backend" {
  name = var.backend_image_name
  build {
    context = "${var.project_root}/backend"
  }
}

resource "docker_container" "backend" {
  name  = var.backend_container_name
  image = docker_image.backend.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.yolo_network.name
  }
  
  ports {
    internal = 4000
    external = var.backend_port
  }
  
  env = [
    "PORT=4000",
    "MONGODB_URI=mongodb://${var.mongo_container_name}:27017/yolo",
    "NODE_ENV=production"
  ]
  
  depends_on = [
    docker_container.mongodb
  ]
}

resource "docker_image" "frontend" {
  name = var.frontend_image_name
  build {
    context = "${var.project_root}/client"
    build_args = {
      REACT_APP_API_URL = "http://${var.server_ip}:${var.backend_port}"
    }
  }
}

resource "docker_container" "frontend" {
  name  = var.frontend_container_name
  image = docker_image.frontend.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.yolo_network.name
  }
  
  ports {
    internal = 80
    external = var.frontend_port
  }
  
  env = [
    "REACT_APP_API_URL=http://${var.server_ip}:${var.backend_port}"
  ]
  
  depends_on = [
    docker_container.backend
  ]
}
