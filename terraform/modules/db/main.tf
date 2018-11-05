resource "google_compute_instance" "db" {
  name         = "reddit-app-db"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  # boot HDD
  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file("${var.public_key_path}")}"
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name        = "allow-mongo-default"
  network     = "default"
  source_tags = ["reddit-app"]
  target_tags = ["reddit-db"]

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
}