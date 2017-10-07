provider "google" {
  region = "${var.region}"
  project = "${var.project_id}"
  credentials = "${file(var.account_file_path)}"
}

resource "google_compute_instance" "ctl-test-instance" {
  count = "${var.vm_count}"
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
  
  metadata {
        key = "ssh-keys",
        value = "appadm:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVFDFccxfy8VdLSjs7+m6/w1DcLjPVFzK+IPI0pTH+lj6aKR2AkB2oroEBcBnG5G4Y0c1XrWF9zabSiYylBgRXoQ1oUZKAWpzgzFfGgpNlwTcIrcwcQCa76Z+16m/98thdT3Ho6NX+XxnTkKvHca1uyArSkkKTDbXRZA61MZ0sjys7z7F5l9I90hgwgrI+Lw8g7vCo2Aa+AByzbFAGWhjkLQ9gjAlK/X969Wd0RSItF7GFSn9v+D9cfEY9f/3sfzRh1PRJW9tvvec0wj6BzllbMwKhSYIUrdKrEJgLo3M/C7ck5ccO8ilOdylSKQSL99MyPb8W+2ZQc94KaFgmLziiQA2RQ3Q7Zds9gfJbGaRtucdcbuEhtWbkye+S3Qh56pSBLZRpBlXGsINnGJBzEq81yvM4/W5r71Rp4boebKuvssENRGv8Si80JMbRITSdm71j4ekuK4MbcCp8Qy3gRB1NQGFD3gOX1xAdmtbK5+LDJvW+nx/urh3EX71c90PT5UBvMWF6CIkSQ9g+3kat/xdxvrzj58/bCSyQEt3NDqbLf7e1kAH8pGM/AHFVft8xP3spmz+Ve6TLKt0gbn3lO2HkxPT5rKBqh/un9qftdkF5VpJXhDjRA1rncDUjXF2FADAENxjzsxiUsrdL9LzqfINOGA//2kzTmfUgbkV3v8VLqQ== appadm"
  }

}
