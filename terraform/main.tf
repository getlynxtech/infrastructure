terraform {
  cloud {
    organization = "GetLynxTech"
    workspaces {
      tags = ["production"]
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.57"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}


resource "hcloud_ssh_key" "default" {
  name       = "${var.environment}_hetzner_key"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "getlynxtech_server" {
  name = "getlynxtech-server-${var.environment}"
  image = var.os_type
  server_type = var.server_type
  location = var.location
  ssh_keys = [hcloud_ssh_key.default.id]
  keep_disk = true
  labels = {
    type = "getlynxtech"
    environment = var.environment
  }
}

resource "hcloud_volume" "getlynxtech_server_volume" {
  name = "getlynxtech-server-volume-${var.environment}"
  size = var.disk_size
  location = var.location
  format = "xfs"
}

resource "hcloud_volume_attachment" "getlynxtech_volume_attachment" {
  volume_id = hcloud_volume.getlynxtech_server_volume.id
  server_id = hcloud_server.getlynxtech_server.id
  automount = true
}

resource "hcloud_floating_ip" "getlynxtech_floating_ip" {
  name = "getlynxtech-floating-ip-${var.environment}"
  type = "ipv4"
  server_id = hcloud_server.getlynxtech_server.id
}

resource "hcloud_floating_ip_assignment" "getlynxtech_floating_ip_assignment" {
  floating_ip_id = hcloud_floating_ip.getlynxtech_floating_ip.id
  server_id      = hcloud_server.getlynxtech_server.id
}

output "getlynxtech_server_ip" {
  value = hcloud_server.getlynxtech_server.ipv4_address
}

output "getlynxtech_floating_ip" {
  value = hcloud_floating_ip.getlynxtech_floating_ip.ip_address
}