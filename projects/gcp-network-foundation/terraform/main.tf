terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type    = string
  default = "example-network-host-project"
}

variable "region" {
  type    = string
  default = "us-central1"
}

resource "google_compute_network" "shared" {
  name                    = "shared-vpc-foundation"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "production" {
  name                     = "subnet-production"
  ip_cidr_range            = "10.60.10.0/24"
  region                   = var.region
  network                  = google_compute_network.shared.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "nonproduction" {
  name                     = "subnet-nonproduction"
  ip_cidr_range            = "10.60.20.0/24"
  region                   = var.region
  network                  = google_compute_network.shared.id
  private_ip_google_access = true
}

resource "google_compute_router" "hybrid" {
  name    = "cr-hybrid-foundation"
  network = google_compute_network.shared.id
  region  = var.region

  bgp {
    asn = 64514
  }
}

output "network_id" {
  value = google_compute_network.shared.id
}

output "subnet_ids" {
  value = [
    google_compute_subnetwork.production.id,
    google_compute_subnetwork.nonproduction.id
  ]
}
