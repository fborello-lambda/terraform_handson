variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "value"
}

variable "ssh_key_file" {
  description = "ssh key"
  type        = string
  default     = "./ssh_keys/gcp.pub"
}

variable "db_user1" {
  description = "db user"
  type        = string
  sensitive   = true
  default     = "dev"
}

variable "db_password1" {
  description = "db password"
  type        = string
  sensitive   = true
  default     = "password"
}
