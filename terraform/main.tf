provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region = "${var.region}"
}

resource "google_compute_instance" "app" {
    name = "reddit-app"
    machine_type = "g1-small"
    zone = "europe-west1-d"
    tags = ["reddit-app"]
    # boot HDD
    boot_disk {
        initialize_params {
            image = "${var.disk_image}"
        }
    }

    network_interface {
        network = "default"
        access_config = {}
    }

    metadata {
        ssh-keys = "appuser:${file("${var.public_key_path}")}"
    }  

    connection {
        type = "ssh"
        user = "appuser"
        agent = false
        private_key = "${file("../gce-key")}"
    }
    provisioner "file" {
        source = "files/puma.service"
        destination = "/tmp/puma.service"
    }

    provisioner "remote-exec" {
        script = "files/deploy.sh"
    }

}

resource "google_compute_firewall" "firewall-puma" {
  name = "allow-puma-default"
  network = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["reddit-app"]
  allow {
      protocol = "tcp"
      ports = ["9292"]
  }
}
