variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "sahabiguide-478323"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west1"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "sahabi"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret for backend"
  type        = string
  sensitive   = true
}

variable "sms_provider" {
  description = "SMS provider to use (twilio or plivo)"
  type        = string
  default     = "twilio"
}

variable "enable_twilio" {
  description = "Enable Twilio SMS integration"
  type        = bool
  default     = false
}

variable "twilio_account_sid" {
  description = "Twilio Account SID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "twilio_auth_token" {
  description = "Twilio Auth Token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "twilio_phone_number" {
  description = "Twilio Phone Number"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_plivo" {
  description = "Enable Plivo SMS integration (alternative, ~40% cheaper)"
  type        = bool
  default     = false
}

variable "plivo_auth_id" {
  description = "Plivo Auth ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "plivo_auth_token" {
  description = "Plivo Auth Token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "plivo_phone_number" {
  description = "Plivo Phone Number"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_airalo" {
  description = "Enable Airalo eSIM integration"
  type        = bool
  default     = false
}

variable "airalo_client_id" {
  description = "Airalo API Client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "airalo_client_secret" {
  description = "Airalo API Client Secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "backend_image" {
  description = "Backend Docker image"
  type        = string
  default     = ""
}

variable "frontend_image" {
  description = "Frontend Docker image"
  type        = string
  default     = ""
}

variable "keycloak_image" {
  description = "Keycloak Docker image"
  type        = string
  default     = ""
}

