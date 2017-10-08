provider "google" {
  region = "${var.region}"
  project = "${var.project_id}"
  credentials = "${file(var.account_file_path)}"
}

resource "google_compute_http_health_check" "auto-health-check" {
  name                = "${var.project_tag}-health-check"
  request_path        = "/hello"
  port                = 8081
  timeout_sec         = 10
  check_interval_sec  = 60
  unhealthy_threshold = 5
  healthy_threshold   = 1
}


resource "google_compute_instance_template" "auto-instance-template" {
  name        = "${var.project_tag}-instance-template"
  description = "Instance Template: Auto created by Terraform"

  tags = ["${var.project_tag}-instance-template"]

  instance_description = "Standard instance from template"
  machine_type         = "n1-standard-1"
  can_ip_forward       = true

  disk {
    source_image = "${var.boot_disk_img}"
    auto_delete  = true
    boot         = true
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
 
  scheduling {
    preemptible         = false
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata {
        key = "ssh-keys",
        value = "appadm:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVFDFccxfy8VdLSjs7+m6/w1DcLjPVFzK+IPI0pTH+lj6aKR2AkB2oroEBcBnG5G4Y0c1XrWF9zabSiYylBgRXoQ1oUZKAWpzgzFfGgpNlwTcIrcwcQCa76Z+16m/98thdT3Ho6NX+XxnTkKvHca1uyArSkkKTDbXRZA61MZ0sjys7z7F5l9I90hgwgrI+Lw8g7vCo2Aa+AByzbFAGWhjkLQ9gjAlK/X969Wd0RSItF7GFSn9v+D9cfEY9f/3sfzRh1PRJW9tvvec0wj6BzllbMwKhSYIUrdKrEJgLo3M/C7ck5ccO8ilOdylSKQSL99MyPb8W+2ZQc94KaFgmLziiQA2RQ3Q7Zds9gfJbGaRtucdcbuEhtWbkye+S3Qh56pSBLZRpBlXGsINnGJBzEq81yvM4/W5r71Rp4boebKuvssENRGv8Si80JMbRITSdm71j4ekuK4MbcCp8Qy3gRB1NQGFD3gOX1xAdmtbK5+LDJvW+nx/urh3EX71c90PT5UBvMWF6CIkSQ9g+3kat/xdxvrzj58/bCSyQEt3NDqbLf7e1kAH8pGM/AHFVft8xP3spmz+Ve6TLKt0gbn3lO2HkxPT5rKBqh/un9qftdkF5VpJXhDjRA1rncDUjXF2FADAENxjzsxiUsrdL9LzqfINOGA//2kzTmfUgbkV3v8VLqQ== appadm"
  }

}


resource "google_compute_instance_group_manager" "auto-appserver-groupmgr" {
  name        = "${var.project_tag}-appserver-groupmgr"

  base_instance_name = "${var.project_tag}-appserver"
  instance_template  = "${google_compute_instance_template.auto-instance-template.self_link}"
  update_strategy    = "NONE"
  zone               = "${var.region_zone}"

  target_pools = ["${google_compute_target_pool.auto-target-pool.self_link}"]
  //autoscale does not need a target_size. Otherwise specify it here.
  //target_size  = 2
  
  auto_healing_policies {
    health_check      = "${google_compute_http_health_check.auto-health-check.self_link}"
    initial_delay_sec = 300
  }

}


resource "google_compute_autoscaler" "auto-scaler" {
  name   = "${var.project_tag}-scaler"
  zone   = "${var.region_zone}"
  target = "${google_compute_instance_group_manager.auto-appserver-groupmgr.self_link}"

  autoscaling_policy = {
    max_replicas    = 4
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}



resource "google_compute_firewall" "auto-firewall-rule" {
  name    = "${var.project_tag}-allow-8081"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["${var.port_range}"]
  }
}


resource "google_compute_target_pool" "auto-target-pool" {
  name = "${var.project_tag}-target-pool"

  // not configuring instances here, coz in instance group manager we already add new instances in this target pool.
  
  health_checks = ["${google_compute_http_health_check.auto-health-check.name}"]
}


resource "google_compute_forwarding_rule" "auto-forwarding-rule" {
  name       = "${var.project_tag}-forwarding-rule"
  target     = "${google_compute_target_pool.auto-target-pool.self_link}"
  port_range = "${var.port_range}"
}