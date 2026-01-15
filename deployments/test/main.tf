terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "static_site" {
  source = "../modules/static_site"

  project_id         = var.project_id
  location           = var.location
  bucket_name        = var.bucket_name
  domain_name        = "test" # Subdomain prefix is fine to keep, or could be var.subdomain
  cloudflare_zone_id = var.cloudflare_zone_id

  # Direct CNAME to GCS
  cname_target       = "c.storage.googleapis.com"

  # Enable Cloudflare Proxy
  proxied            = true
}

# WAF Rule to restrict access to VPN IP (Migrated to cloudflare_ruleset)
resource "cloudflare_ruleset" "vpn_only" {
  zone_id     = var.cloudflare_zone_id
  name        = "Block non-VPN access to test"
  description = "Block non-VPN access to test subdomain"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules {
    action      = "block"
    expression  = "(http.host eq \"${var.domain_name}\" and ip.src ne ${var.vpn_ip})"
    description = "Allow only VPN IP for test subdomain"
    enabled     = true
  }
}
