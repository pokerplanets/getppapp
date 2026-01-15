output "bucket_name" {
  value = google_storage_bucket.website.name
}

output "website_url" {
  value = "https://${var.bucket_name}"
}
