provider "google" {
  region = "${var.region}"
  project = "${var.project_id}"
  credentials = "${file(var.account_file_path)}"
}

resource "google_compute_instance" "ctl-test-instance" {
  count = 1
  name = "${var.project_tag}-${count.index}"
  machine_type = "n1-standard-1"
  zone = "${var.region_zone}"
  tags = ["${var.project_tag}"]


  boot_disk {
    initialize_params {
      image = "${var.boot_disk_img_name}"
    }
  }
  network_interface {
    network = "default"
    access_config {
        # Ephemeral
    }
  }
  service_account {
    scopes = [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append"
      ]
  }

}
