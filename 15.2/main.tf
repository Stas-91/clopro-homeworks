data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "yandex_storage_bucket" "iam-bucket" {
  bucket    = var.bucket_name
  folder_id = var.folder_id

  anonymous_access_flags {
    read        = true
  }  
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id  = var.service_account_id
  description        = "static access key for object storage"
}

resource "yandex_storage_object" "test-object" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket_name
  key        = var.object_key
  source     = "./test.jpg"
}

resource "yandex_compute_instance_group" "fixed-ig" {
  name                = "fixed-ig"
  folder_id           = var.folder_id
  service_account_id  = var.service_account_id
  deletion_protection = "false"

  instance_template {
    platform_id = var.platform_id
    resources {
      memory = var.vm_web_resources.memory
      cores  = var.vm_web_resources.cores
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        type     = "network-ssd"
        size     = "10"
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.VPC.id
      subnet_ids         = [yandex_vpc_subnet.public.id]
    }

    metadata = {
      user-data = templatefile("./web-data-group.yaml.tmpl", {
        user_vm = var.user_vm,
        ssh_key = var.ssh_public_key
        bucket_name = var.bucket_name,
        object_key  = var.object_key        
      })
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.zone.zone-a]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "Целевая группа Network Load Balancer"
  }
}

resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "network-load-balancer-1"

  listener {
    name = "network-load-balancer-1-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.fixed-ig.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}