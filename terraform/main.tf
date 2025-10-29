resource "selectel_vpc_project_v2" "project_1" {
  name = "project"
}

resource "selectel_iam_serviceuser_v1" "serviceuser_1" {
  name     = "hexlet"
  password = "K.l:,FyGvQr<xDx9z^7%"
  role {
    role_name  = "member"
    scope      = "project"
    project_id = selectel_vpc_project_v2.project_1.id
  }
}

resource "selectel_vpc_keypair_v2" "keypair_1" {
  name       = "keypair"
  public_key = file("~/.ssh/id_ed25519.pub")
  user_id    = selectel_iam_serviceuser_v1.serviceuser_1.id
}

resource "openstack_compute_flavor_v2" "flavor_1" {
  name      = "hexlet"
  vcpus     = 2
  ram       = 2048
  disk      = 0
  is_public = false

  lifecycle {
    create_before_destroy = true
  }

}

resource "openstack_networking_network_v2" "network_1" {
  name           = "private-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "private-subnet"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.199.0/24"
}

resource "openstack_networking_port_v2" "port_1" {
  name       = "port"
  network_id = openstack_networking_network_v2.network_1.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}

data "openstack_images_image_v2" "image_1" {
  name        = "Ubuntu 20.04 LTS 64-bit"
  most_recent = true
  visibility  = "public"
}

resource "openstack_blockstorage_volume_v3" "volume_1" {
  name                 = "boot-volume-for-server"
  size                 = "5"
  image_id             = data.openstack_images_image_v2.image_1.id
  volume_type          = "fast.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }

}

resource "openstack_blockstorage_volume_v3" "volume_2" {
  name                 = "additional-volume-for-server"
  size                 = "7"
  volume_type          = "universal.ru-9a"
  availability_zone    = "ru-9a"
  enable_online_resize = true
}

resource "openstack_compute_instance_v2" "server_1" {
  name              = "server"
  flavor_id         = openstack_compute_flavor_v2.flavor_1.id
  key_pair          = selectel_vpc_keypair_v2.keypair_1.name
  availability_zone = "ru-9a"

  network {
    port = openstack_networking_port_v2.port_1.id
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_1.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_2.id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = -1
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

resource "openstack_networking_floatingip_v2" "floatingip_1" {
  pool = "external-network"
}