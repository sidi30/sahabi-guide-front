# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "vpcaccess.googleapis.com"
  ])
  
  service            = each.value
  disable_on_destroy = false
}

# Artifact Registry
resource "google_artifact_registry_repository" "sahabi_registry" {
  location      = var.region
  repository_id = "sahabi-registry"
  description   = "Docker registry for Sahabi Guide"
  format        = "DOCKER"
  
  depends_on = [google_project_service.required_apis]
}

# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "postgres" {
  name             = "sahabi-postgres"
  database_version = "POSTGRES_15"
  region           = var.region
  
  settings {
    tier = "db-f1-micro"
    
    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }
    
    maintenance_window {
      day  = 7  # Sunday
      hour = 4
    }
    
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
  }
  
  deletion_protection = false
  
  depends_on = [google_project_service.required_apis]
}

# Database for application
resource "google_sql_database" "sahabi_db" {
  name     = "sahabi_db"
  instance = google_sql_database_instance.postgres.name
}

# Database for Keycloak
resource "google_sql_database" "keycloak_db" {
  name     = "keycloak_db"
  instance = google_sql_database_instance.postgres.name
}

# Database users
resource "google_sql_user" "sahabi_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

resource "google_sql_user" "keycloak_user" {
  name     = "keycloak"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

# Secret Manager Secrets
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

resource "google_secret_manager_secret" "jwt_secret" {
  secret_id = "jwt-secret"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "jwt_secret_version" {
  secret      = google_secret_manager_secret.jwt_secret.id
  secret_data = var.jwt_secret
}

resource "google_secret_manager_secret" "keycloak_admin_password" {
  secret_id = "keycloak-admin-password"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "keycloak_admin_password_version" {
  secret      = google_secret_manager_secret.keycloak_admin_password.id
  secret_data = var.keycloak_admin_password
}

# Twilio secrets (optional)
resource "google_secret_manager_secret" "twilio_account_sid" {
  count     = var.enable_twilio ? 1 : 0
  secret_id = "twilio-account-sid"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "twilio_account_sid_version" {
  count       = var.enable_twilio ? 1 : 0
  secret      = google_secret_manager_secret.twilio_account_sid[0].id
  secret_data = var.twilio_account_sid
}

resource "google_secret_manager_secret" "twilio_auth_token" {
  count     = var.enable_twilio ? 1 : 0
  secret_id = "twilio-auth-token"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "twilio_auth_token_version" {
  count       = var.enable_twilio ? 1 : 0
  secret      = google_secret_manager_secret.twilio_auth_token[0].id
  secret_data = var.twilio_auth_token
}

# Service Account for Cloud Run services
resource "google_service_account" "cloudrun_sa" {
  account_id   = "sahabi-cloudrun-sa"
  display_name = "Sahabi Cloud Run Service Account"
}

# IAM permissions
resource "google_project_iam_member" "cloudrun_sa_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "cloudrun_sa_secret_db" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "cloudrun_sa_secret_jwt" {
  secret_id = google_secret_manager_secret.jwt_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "cloudrun_sa_secret_keycloak" {
  secret_id = google_secret_manager_secret.keycloak_admin_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

# Cloud Run: Keycloak
resource "google_cloud_run_v2_service" "keycloak" {
  name     = "sahabi-keycloak"
  location = var.region
  deletion_protection = false
  
  template {
    service_account = google_service_account.cloudrun_sa.email
    
      timeout = "300s"
    
    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }
    
    containers {
      image = var.keycloak_image != "" ? var.keycloak_image : "${var.region}-docker.pkg.dev/${var.project_id}/sahabi-registry/keycloak:latest"
      
      resources {
        limits = {
          cpu    = "2"
          memory = "2Gi"
        }
        startup_cpu_boost = true
      }
      
      env {
        name  = "KEYCLOAK_ADMIN"
        value = "admin"
      }
      
      env {
        name = "KEYCLOAK_ADMIN_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.keycloak_admin_password.secret_id
            version = "latest"
          }
        }
      }
      
      env {
        name  = "KC_HOSTNAME_STRICT"
        value = "false"
      }
      
      env {
        name  = "KC_HOSTNAME_STRICT_HTTPS"
        value = "false"
      }
      
      env {
        name  = "KC_HTTP_ENABLED"
        value = "true"
      }
      
      env {
        name  = "KC_PROXY_HEADERS"
        value = "xforwarded"
      }
      
      env {
        name  = "KC_PROXY"
        value = "edge"
      }
      
      env {
        name  = "KC_DB"
        value = "postgres"
      }
      
      env {
        name  = "KC_DB_URL_HOST"
        value = google_sql_database_instance.postgres.public_ip_address
      }
      
      env {
        name  = "KC_DB_URL_PORT"
        value = "5432"
      }
      
      env {
        name  = "KC_DB_URL_DATABASE"
        value = google_sql_database.keycloak_db.name
      }
      
      env {
        name  = "KC_DB_USERNAME"
        value = "keycloak"
      }
      
      env {
        name = "KC_DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      
      env {
        name  = "KC_DB_SCHEMA"
        value = "public"
      }
      
      env {
        name  = "KC_HEALTH_ENABLED"
        value = "true"
      }
      
      env {
        name  = "KC_METRICS_ENABLED"
        value = "true"
      }
      
      env {
        name  = "KC_LOG_LEVEL"
        value = "INFO"
      }
      
      env {
        name  = "JAVA_OPTS_APPEND"
        value = "-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.net.preferIPv4Stack=true"
      }
    }
  }
  
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  
  depends_on = [
    google_sql_database.keycloak_db,
    google_sql_user.keycloak_user,
    google_project_service.required_apis,
  ]
}

# Cloud Run: Backend
resource "google_cloud_run_v2_service" "backend" {
  name     = "sahabi-backend"
  location = var.region
  
  template {
    service_account = google_service_account.cloudrun_sa.email
    
    scaling {
      min_instance_count = 1
      max_instance_count = 10
    }
    
    containers {
      image = var.backend_image != "" ? var.backend_image : "${var.region}-docker.pkg.dev/${var.project_id}/sahabi-registry/backend:latest"
      
      resources {
        limits = {
          cpu    = "2"
          memory = "768Mi"
        }
      }
      
      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = "prod"
      }
      
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.postgres.public_ip_address
      }
      
      env {
        name  = "DB_PORT"
        value = "5432"
      }
      
      env {
        name  = "DB_NAME"
        value = "sahabi_db"
      }
      
      env {
        name  = "DB_USERNAME"
        value = var.db_user
      }
      
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      
      env {
        name = "JWT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.jwt_secret.secret_id
            version = "latest"
          }
        }
      }
      
      env {
        name  = "JWT_EXPIRATION"
        value = "7776000"
      }
      
      env {
        name  = "JWT_ISSUER"
        value = "sahabi-guide"
      }
      
      env {
        name  = "OIDC_ISSUER_URI"
        value = "${google_cloud_run_v2_service.keycloak.uri}/realms/sahabi"
      }
      
      env {
        name  = "CORS_ALLOWED_ORIGINS"
        value = "*"
      }
      
      env {
        name  = "SMS_PROVIDER"
        value = var.sms_provider
      }
      
      env {
        name  = "TWILIO_ENABLED"
        value = var.enable_twilio ? "true" : "false"
      }
      
      env {
        name  = "TWILIO_ACCOUNT_SID"
        value = var.twilio_account_sid
      }
      
      env {
        name  = "TWILIO_AUTH_TOKEN"
        value = var.twilio_auth_token
      }
      
      env {
        name  = "TWILIO_PHONE_NUMBER"
        value = var.twilio_phone_number
      }
      
      env {
        name  = "PLIVO_ENABLED"
        value = var.enable_plivo ? "true" : "false"
      }
      
      env {
        name  = "PLIVO_AUTH_ID"
        value = var.plivo_auth_id
      }
      
      env {
        name  = "PLIVO_AUTH_TOKEN"
        value = var.plivo_auth_token
      }
      
      env {
        name  = "PLIVO_PHONE_NUMBER"
        value = var.plivo_phone_number
      }
      
      env {
        name  = "AIRALO_ENABLED"
        value = var.enable_airalo ? "true" : "false"
      }
      
      env {
        name  = "AIRALO_CLIENT_ID"
        value = var.airalo_client_id
      }
      
      env {
        name  = "AIRALO_CLIENT_SECRET"
        value = var.airalo_client_secret
      }
    }
  }
  
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  
  depends_on = [
    google_sql_database.sahabi_db,
    google_sql_user.sahabi_user,
    google_cloud_run_v2_service.keycloak,
    google_project_service.required_apis,
  ]
}

# Cloud Run: Dashboard (React Frontend)
resource "google_cloud_run_v2_service" "dashboard" {
  name     = "sahabi-dashboard"
  location = var.region
  
  template {
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
    
    containers {
      image = var.frontend_image != "" ? var.frontend_image : "${var.region}-docker.pkg.dev/${var.project_id}/sahabi-registry/dashboard:latest"
      
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
      
      startup_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 0
        timeout_seconds      = 3
        period_seconds       = 3
        failure_threshold    = 3
      }
      
      liveness_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 0
        timeout_seconds      = 3
        period_seconds       = 10
        failure_threshold    = 3
      }
    }
  }
  
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  
  depends_on = [
    google_cloud_run_v2_service.backend,
    google_cloud_run_v2_service.keycloak,
    google_project_service.required_apis,
  ]
}

# IAM Policy for public access
resource "google_cloud_run_v2_service_iam_member" "keycloak_public" {
  name   = google_cloud_run_v2_service.keycloak.name
  location = google_cloud_run_v2_service.keycloak.location
  role   = "roles/run.invoker"
  member = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  name   = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role   = "roles/run.invoker"
  member = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "dashboard_public" {
  name     = google_cloud_run_v2_service.dashboard.name
  location = google_cloud_run_v2_service.dashboard.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}


