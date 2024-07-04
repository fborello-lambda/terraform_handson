variable "backend_bucket" {
  type = string
  sensitive = true
}

variable "backend_prefix" {
  type = string
  sensitive = true
}

terraform {
  backend "gcs" {
    bucket = var.backend_bucket
    prefix = var.backend_prefix
  }
}
