variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "GCP Bucket Location"
  type        = string
  default     = "EU"
}

variable "bucket_name" {
  description = "Name of the GCS bucket (must match domain name for CNAME to work with GCS usually, but behind Cloudflare we can map it)"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "domain_name" {
  description = "Subdomain or root domain (e.g. 'test' or '@')"
  type        = string
}

variable "cname_target" {
  description = "Target for the CNAME record (e.g. c.storage.googleapis.com or an EdgeNext CNAME)"
  type        = string
  default     = "c.storage.googleapis.com"
}

variable "proxied" {
  description = "Whether the Cloudflare record should be proxied (Orange Cloud)"
  type        = bool
  default     = true
}
