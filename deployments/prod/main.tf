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

# EdgeNext is now managed manually.
# Cloudflare points to this hardcoded CNAME.
# The EdgeNext distribution should be configured to point to the GCS bucket: pokerplanets-ru-com (via c.storage.googleapis.com)
# Host header in EdgeNext must be set to: pokerplanets-ru-com

module "static_site" {
  source = "../modules/static_site"

  project_id         = var.project_id
  location           = var.location
  bucket_name        = var.bucket_name
  domain_name        = "@" # Root domain
  cloudflare_zone_id = var.cloudflare_zone_id

  # Hardcoded EdgeNext CNAME (Manual Setup)
  cname_target       = var.edgenext_cname

  # Enable Cloudflare Proxy to match "Cloudflare -> EdgeNext -> GCS" architecture
  proxied            = false
}

resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = var.edgenext_cname
  type    = "CNAME"
  proxied = true
}

# Redirect www to root - Cloudflare handles this, EdgeNext is never hit.
resource "cloudflare_ruleset" "www_redirect" {
  zone_id     = var.cloudflare_zone_id
  name        = "Redirect www to root"
  description = "Redirect www.${var.domain_name} to root domain"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 301
        target_url {
          expression = "concat(\"https://${var.domain_name}\", http.request.uri.path)"
        }
        preserve_query_string = true
      }
    }
    expression  = "(http.host eq \"www.${var.domain_name}\")"
    description = "Redirect www to root"
    enabled     = true
  }
}
