terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

variable "project_root" {
  type = string
  default = "/home/vagrant/yolo"
}

variable "server_ip" {
  type = string
  default = "192.168.56.56"
}

resource "docker_network" "yolo_network" {
  name = "yolo-network"
}

resource "docker_volume" "mongodb_data" {
  name = "mongodb_data"
}

resource "docker_volume" "mongodb_config" {
  name = "mongodb_config"
}

resource "docker_image" "mongo" {
  name         = "mongo:7.0"
  keep_locally = true
}

resource "docker_container" "mongodb" {
  name  = "yolo-mongodb"
  image = docker_image.mongo.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.yolo_network.name
  }
  
  ports {
    internal = 27017
    external = 27017
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
  name = "yolo-backend:latest"
  build {
    context = "${var.project_root}/backend"
  }
}

resource "docker_container" "backend" {
  name  = "yolo-backend"
  image = docker_image.backend.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.yolo_network.name
  }
  
  ports {
    internal = 4000
    external = 4000
  }
  
  env = [
    "PORT=4000",
    "MONGODB_URI=mongodb://yolo-mongodb:27017/yolo",
    "NODE_ENV=production"
  ]
  
  depends_on = [
    docker_container.mongodb
  ]
}

resource "docker_image" "frontend" {
  name = "yolo-frontend:latest"
  build {
    context = "${var.project_root}/client"
    build_args = {
      REACT_APP_API_URL = "http://${var.server_ip}:4000"
    }
  }
}

resource "docker_container" "frontend" {
  name  = "yolo-frontend"
  image = docker_image.frontend.image_id
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.yolo_network.name
  }
  
  ports {
    internal = 80
    external = 3000
  }
  
  env = [
    "REACT_APP_API_URL=http://${var.server_ip}:4000"
  ]
  
  depends_on = [
    docker_container.backend
  ]
}
