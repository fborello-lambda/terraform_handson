resource "google_compute_address" "static" {
  name = "static-ipv4-address"
}

resource "google_compute_network" "net_instance1" {
  name                    = "tf-network-instance"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_instance1" {
  name          = "subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.net_instance1.self_link
}

resource "google_compute_global_address" "reserved_peering_range" {
  project       = var.project_id
  name          = "reserved-peering-range"
  address_type  = "INTERNAL"
  prefix_length = 16
  purpose       = "VPC_PEERING"
  network       = google_compute_network.net_instance1.name
}

resource "google_service_networking_connection" "tf_network" {
  depends_on              = [google_compute_global_address.reserved_peering_range]
  network                 = google_compute_network.net_instance1.name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.reserved_peering_range.name]
}

// ############################ VM ############################
resource "google_compute_instance" "vm_instance1" {
  name         = "tf-vm-instance"
  machine_type = "f1-micro"
  tags         = ["test", "dev", "ssh-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.net_instance1.self_link
    subnetwork = google_compute_subnetwork.subnet_instance1.self_link
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys = "${var.db_user1}:${file(var.ssh_key_file)}"
  }

  depends_on = [google_compute_network.net_instance1]
}

resource "google_compute_firewall" "fw_instance1" {
  name      = "tf-firewall-instance"
  network   = google_compute_network.net_instance1.name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}

output "compute_instance_public_ip" {
  value = google_compute_instance.vm_instance1.network_interface.0.access_config.0.nat_ip
}

// ############################ DB ############################
resource "google_sql_database_instance" "pg_instance1" {
  name             = "db-instance1"
  region           = "us-central1"
  database_version = "POSTGRES_14"
  depends_on       = [google_service_networking_connection.tf_network]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.net_instance1.self_link
    }
  }
  deletion_protection = false
}

resource "google_sql_database" "db_policy1" {
  name            = "db_policy1"
  instance        = google_sql_database_instance.pg_instance1.name
  deletion_policy = "DELETE"
}

resource "google_sql_user" "db_user1" {
  name     = var.db_user1
  instance = google_sql_database_instance.pg_instance1.name
  password = var.db_password1
}

output "internal_ipv4" {
  value = google_sql_database_instance.pg_instance1.private_ip_address
}
