resource "google_compute_address" "this" {
  name   = local.resource_name
  region = local.region
}

locals {
  public_ip = google_compute_address.this.address
}
