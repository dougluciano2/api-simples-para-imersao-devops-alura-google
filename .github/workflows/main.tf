# Configura o provedor do Google Cloud
terraform {
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

# ------------------- Variáveis -------------------
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

# ------------------- Recursos da Aplicação -------------------

# Habilita as APIs necessárias no projeto
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "sqladmin.googleapis.com" # API do Cloud SQL
  ])
  service                    = each.key
  disable_dependency_handling = true
}

# Cria o repositório no Artifact Registry para as imagens Docker
resource "google_artifact_registry_repository" "api_repo" {
  project      = var.gcp_project_id
  location     = var.gcp_region
  repository_id = "api-repo"
  description  = "Repositório para a API da imersão"
  format       = "DOCKER"
  depends_on   = [google_project_service.apis]
}

# Cria o serviço no Cloud Run
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


# ------------------- RECURSOS DO BANCO DE DADOS (NOVOS) -------------------

# 1. Cria a instância do Cloud SQL para MySQL
resource "google_sql_database_instance" "mysql_instance" {
  project          = var.gcp_project_id
  name             = "${var.app_name}-mysql-instance" # Ex: my-java-app-mysql-instance
  database_version = "MYSQL_8_0"
  region           = var.gcp_region

  # Configurações da máquina e do disco
  settings {
    # AQUI ESTÁ A ESPECIFICAÇÃO DA MÁQUINA DO FREE TIER
    tier              = "db-f1-micro"
    availability_type = "ZONAL" # Única Zona
    disk_size         = 10      # 10 GB de SSD
    disk_autoresize   = false

    # Desabilita os backups automáticos para manter o custo no mínimo
    backup_configuration {
      enabled = false
    }
  }

  # Define a senha inicial do usuário 'root'.
  # Usamos a referência a um segredo que você criou no GitHub.
  root_password = var.db_password

  # Garante que a API do Cloud SQL esteja ativa antes de tentar criar a instância
  depends_on = [google_project_service.apis]
}

# 2. Cria o banco de dados (schema) dentro da instância
resource "google_sql_database" "database" {
  project  = var.gcp_project_id
  instance = google_sql_database_instance.mysql_instance.name
  name     = "sa" # O nome do banco que sua aplicação vai usar
}

# 3. Cria um usuário específico para a aplicação
resource "google_sql_user" "app_user" {
  project  = var.gcp_project_id
  instance = google_sql_database_instance.mysql_instance.name
  name     = "db_app" # O nome do usuário da aplicação
  password = var.db_password
}


variable "db_password" {
  type        = string
  description = "A senha para o usuário root e o usuário da aplicação no banco de dados."
  sensitive   = true # Marca a variável como sensível para não exibi-la nos logs
}