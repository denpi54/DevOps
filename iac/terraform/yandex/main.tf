terraform {
  required_providers {
    yandex = { source = "yandex-cloud/yandex", version = "~> 0.120" }
  }
  required_version = ">= 1.6.0"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_vpc_network" "net" { name = "devops-net" }

resource "yandex_vpc_subnet"  "sub" {
  name           = "devops-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_security_group" "sg" {
  name       = "devops-sg"
  network_id = yandex_vpc_network.net.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { protocol="TCP" port=80  v4_cidr_blocks=["0.0.0.0/0"] }
  ingress { protocol="TCP" port=443 v4_cidr_blocks=["0.0.0.0/0"] }
  ingress { protocol="TCP" port=3000 v4_cidr_blocks=["0.0.0.0/0"] } # Grafana
  ingress { protocol="TCP" port=9090 v4_cidr_blocks=["0.0.0.0/0"] } # Prometheus
  ingress { protocol="TCP" port=9093 v4_cidr_blocks=["0.0.0.0/0"] } # Alertmanager
  ingress { protocol="TCP" port=9000 v4_cidr_blocks=["0.0.0.0/0"] } # Graylog UI
  ingress { protocol="UDP" port=12201 v4_cidr_blocks=["0.0.0.0/0"] } # GELF
  egress  { protocol = "ANY" v4_cidr_blocks = ["0.0.0.0/0"] }
}

locals {
  meta = <<-EOF
    #cloud-config
    users:
      - name: ${var.vm_user}
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh-authorized-keys:
          - ${var.ssh_pub_key}
    package_update: true
    package_upgrade: true
    runcmd:
      - timedatectl set-timezone Europe/Berlin
  EOF
}

resource "yandex_compute_instance" "k8s_master" {
  name        = "k8s-master"
  platform_id = var.vm_size
  resources { cores = 2 memory = 4 }
  boot_disk { initialize_params { image_family = var.image_family type = "network-ssd" size = 30 } }
  network_interface {
    subnet_id = yandex_vpc_subnet.sub.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }
  metadata = { user-data = local.meta }
}

resource "yandex_compute_instance" "k8s_worker" {
  name        = "k8s-worker"
  platform_id = var.vm_size
  resources { cores = 2 memory = 4 }
  boot_disk { initialize_params { image_family = var.image_family type = "network-ssd" size = 40 } }
  network_interface {
    subnet_id = yandex_vpc_subnet.sub.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }
  metadata = { user-data = local.meta }
}

resource "yandex_compute_instance" "srv" {
  name        = "srv"
  platform_id = var.vm_size
  resources { cores = 2 memory = 4 }
  boot_disk { initialize_params { image_family = var.image_family type = "network-ssd" size = 60 } }
  network_interface {
    subnet_id = yandex_vpc_subnet.sub.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }
  metadata = { user-data = local.meta }
}
