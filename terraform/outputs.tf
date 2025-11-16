output "keycloak_url" {
  description = "Keycloak service URL"
  value       = google_cloud_run_v2_service.keycloak.uri
}

output "backend_url" {
  description = "Backend service URL"
  value       = google_cloud_run_v2_service.backend.uri
}

output "dashboard_url" {
  description = "Dashboard service URL"
  value       = google_cloud_run_v2_service.dashboard.uri
}

output "postgres_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.postgres.connection_name
}

output "postgres_ip" {
  description = "Cloud SQL public IP"
  value       = google_sql_database_instance.postgres.public_ip_address
}

output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.sahabi_registry.repository_id}"
}

output "next_steps" {
  description = "Next steps after deployment"
  value = <<-EOT
  
  === DEPLOIEMENT REUSSI ! ===
  
  1. Keycloak Admin Console: ${google_cloud_run_v2_service.keycloak.uri}/admin
  
  2. Backend API: ${google_cloud_run_v2_service.backend.uri}
  
  3. Dashboard: ${google_cloud_run_v2_service.dashboard.uri}
  
  4. Configurer Keycloak:
     - Aller dans Realm 'sahabi' -> Clients -> 'sahabi-dashboard'
     - Ajouter Valid Redirect URIs: ${google_cloud_run_v2_service.dashboard.uri}/*
     - Ajouter Web Origins: ${google_cloud_run_v2_service.dashboard.uri}
  
  5. Build et push des images:
     - Backend: Voir sahabi-guide-api/README.md
     - Dashboard: Utiliser terraform/build-dashboard.ps1
     - Keycloak: Voir sahabi-guide-keycloak/README.md
  
  EOT
}

