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
  default     = "getpp.app"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the website"
  default     = "getpp.app"
}

variable "edgenext_cname" {
  type        = string
  description = "EdgeNext CNAME target"
  default     = "a0205d1f.getpp.app.cname.edgenextcname.com"
}

