terraform {
  backend "gcs" {
    bucket  = "ouble-willow-464818-h4-bucket" # O nome do bucket que você criou
    prefix  = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- Variáveis ---
variable "gcp_project_id" {
  type        = string
  description = "O ID do projeto no Google Cloud."
}

variable "gcp_region" {
  type        = string
  description = "A região onde os recursos serão criados."
  default     = "us-central1"
}

variable "app_name" {
  type        = string
  description = "O nome da aplicação/serviço."
  default     = "my-java-app"
}

variable "db_password" {
  type        = string
  description = "A senha para os usuários do banco de dados."
  sensitive   = true
}
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com", "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com", "sqladmin.googleapis.com"
  ])
  service = each.key
  disable_dependency_handling = true
}

resource "google_artifact_registry_repository" "api_repo" {
  project       = var.gcp_project_id
  location      = var.gcp_region
  repository_id = "api-repo"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis]
}

resource "google_sql_database_instance" "mysql_instance" {
  project          = var.gcp_project_id
  name             = "${var.app_name}-mysql-db"
  database_version = "MYSQL_8_0"
  region           = var.gcp_region
  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10
    backup_configuration {
      enabled = false
    }
  }
  root_password = var.db_password
  depends_on    = [google_project_service.apis]
}

resource "google_sql_user" "app_user" {
  project  = var.gcp_project_id
  instance = google_sql_database_instance.mysql_instance.name
  name     = "db_app"
  password = var.db_password
}

resource "google_cloud_run_v2_service" "api_service" {
  project  = var.gcp_project_id
  location = var.gcp_region
  name     = var.app_name
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
  depends_on = [google_project_service.apis]
}