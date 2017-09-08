provider "google" {
  region = "${var.region}"
  project = "${var.project_name}"
  credentials = "${file(var.account_file_path)}"
}

resource "google_compute_instance" "ctl-test-instance" {
  count = 3
  name = "ctl-test-instance-${count.index}"
  machine_type = "n1-standard-1"
  zone = "${var.region_zone}"
  tags = ["ctl-test-node"]


  boot_disk {
    initialize_params {
      image = "mule-runtime-380"
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

  metadata_startup_script = <<SCRIPT
echo helloworld ctl > test.txt
SCRIPT


}
