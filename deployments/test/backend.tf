terraform {
  backend "gcs" {
    bucket = "pokerplanets-terraform-state"
    prefix = "getpp-app/test"
  }
}
