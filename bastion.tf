locals {
  ssh_keys = join("\n", [for username, public_key in var.ssh_public_keys : "${username}:${public_key}"])
}

resource "google_compute_instance" "this" {
  name         = local.resource_name
  machine_type = "e2-medium"
  zone         = local.available_zones[0]
  tags         = ["bastion"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20240319"
    }
  }

  network_interface {
    network    = local.vpc_name
    subnetwork = local.public_subnet_names[0]

    access_config {
      nat_ip = local.public_ip
    }
  }

  metadata = {
    ssh-keys = local.ssh_keys
  }
}

resource "google_compute_firewall" "bastion-ssh" {
  name          = "${local.resource_name}-allow-ssh"
  network       = local.vpc_name
  source_ranges = concat(var.allowed_cidr_blocks, var.allowed_ipv6_cidr_blocks)
  target_tags   = ["bastion"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
