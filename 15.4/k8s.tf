resource "yandex_kubernetes_cluster" "my_cluster" {
 network_id = yandex_vpc_network.VPC.id

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.public.zone
        subnet_id = yandex_vpc_subnet.public.id
      }

      location {
        zone      = yandex_vpc_subnet.public2.zone
        subnet_id = yandex_vpc_subnet.public2.id
      }

      location {
        zone      = yandex_vpc_subnet.public3.zone
        subnet_id = yandex_vpc_subnet.public3.id
      }
    }

    version   = "1.32"
    public_ip = true    

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }
    }
    master_logging {
      enabled                    = true
      folder_id                  = var.folder_id
      kube_apiserver_enabled     = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      audit_enabled              = true
    }

    scale_policy {
      auto_scale {
        min_resource_preset_id = "s-c4-m16"
      }
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id

  labels = {
    my_key       = "my_value"
    my_other_key = "my_other_value"
  }

  release_channel = "STABLE"

  network_policy_provider = "CALICO"

  kms_provider {
    key_id = yandex_kms_symmetric_key.key-a.id
  }

}

resource "yandex_kubernetes_node_group" "mynodegroup" {
  cluster_id  = yandex_kubernetes_cluster.my_cluster.id
  name        = "mynodegroup"
  description = "description"
  version     = "1.32"

  labels = {
    "key" = "value"
  }

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.public.id]  # подсеть из зоны ru-central1-a
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      initial = 3
      min = 3
      max = 6
    }
  }

  allocation_policy {
    location { zone = "ru-central1-a" }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }
  }
}