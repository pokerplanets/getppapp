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

resource "google_storage_bucket" "website" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html" # SPA fallback
  }

  uniform_bucket_level_access = true

  # CORS to allow Cloudflare if needed, generally useful for fonts/assets
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Make bucket public so Cloudflare can fetch it
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Cloudflare CNAME Record
resource "cloudflare_record" "website_cname" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  content = var.cname_target
  type    = "CNAME"
  proxied = var.proxied
}
