resource "yandex_vpc_network" "VPC" {
  name = var.vpc_name.net
}
resource "yandex_vpc_subnet" "public" {
  name           = var.vpc_name.public
  zone           = var.zone.zone-a
  network_id     = yandex_vpc_network.VPC.id
  v4_cidr_blocks = var.cidr.cidr0
}

resource "yandex_vpc_subnet" "private" {
  name           = var.vpc_name.private
  zone           = var.zone.zone-b
  network_id     = yandex_vpc_network.VPC.id
  v4_cidr_blocks = var.cidr.cidr1
  route_table_id = yandex_vpc_route_table.rt.id  
}

resource "yandex_vpc_route_table" "rt" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.VPC.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}

data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "yandex_compute_instance" "nat-instance" {
  name                      = "nat-instance"
  platform_id = var.platform_id

  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      type     = "network-ssd"
      size     = "10"
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    nat        = true
  }

}

output "internal_ip_address_nat-instance" {
  value = "${yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address}"
}

resource "yandex_compute_instance" "vm-2" {
  name                      = "vm-2"
  platform_id = var.platform_id
  
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    nat        = true
  }

}

output "internal_ip_address_vm-2" {
  value = "${yandex_compute_instance.vm-2.network_interface.0.nat_ip_address}"
}

resource "yandex_compute_instance" "private-instance" {
  name        = "private-instance"
  platform_id = var.platform_id
  zone = var.zone.zone-b
  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = var.vm_web_nat
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}