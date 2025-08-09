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

resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id      = var.folder_id
  name = "gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  folder_id      = var.folder_id
  name       = "route-table"
  network_id = yandex_vpc_network.VPC.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}