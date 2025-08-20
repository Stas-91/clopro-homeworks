resource "yandex_mdb_mysql_cluster" "mysql" {
  name                = "mysql"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.VPC.id
  version             = "8.0"
  deletion_protection = true

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = "20"
  }

  host {
    zone      = var.zone.zone-a
    subnet_id = yandex_vpc_subnet.public.id
  }

  host {
    zone      = var.zone.zone-b
    subnet_id = yandex_vpc_subnet.private.id
  }

  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

}

resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "netology_db"
}

resource "yandex_mdb_mysql_user" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "netology"
  password   = "netology"
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}


