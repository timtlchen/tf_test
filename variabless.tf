variable "region" {
	default = "asia-southeast1"
}

variable "region_zone" {
	default = "asia-southeast1-a"
}

variable "project_id" {
	description = "The ID of the Google Cloud project"
}

variable "service_account" {
        description = "Service account email address"
}

variable "project_tag" {
	description = "The project tag, which is also used as a prefix for project name, VM name, etc."
}

variable "account_file_path" {
	description = "Path to the JSON file used to describe your account credentials"
}

variable "boot_disk_img" {
	description = "boot disk image"
}

variable "port_range" {
	description = "Port range for firewall rules"
}

