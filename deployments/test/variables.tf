variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west3"
}

variable "location" {
  type    = string
  default = "europe-west3"
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "GCS bucket name for the website"
  default     = "test.getpp.app"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the website"
  default     = "test.getpp.app"
}

variable "vpn_ip" {
  type        = string
  description = "IP address allowed to access the test environment"
  default     = "20.218.139.109"
}

