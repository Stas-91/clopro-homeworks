###cloud vars

variable "cloud_id" {
  type        = string
  default     = "b1g8ta6qu7na0ir2khnv"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1g8kve3609ag8bp327e"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "zone" {
  type = object({
    zone-a = string
    zone-b = string
  })
  default = {
    zone-a = "ru-central1-a"
    zone-b = "ru-central1-b"
  }
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "cidr" {
  type = object({
    cidr0 = list(string)
    cidr1 = list(string)
  })
  default     = {
    cidr0 = ["192.168.10.0/24"]
    cidr1 = ["192.168.20.0/24"]
  }
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type = object({
    net      = string
    public   = string
    private  = string
  })
  default = {
    net     = "vpc"
    public  = "public"
    private = "private"
  }
  description = "VPC network & subnet name"
}

variable "image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "VM image family name"
}

variable "platform_id" {
  type        = string
  default     = "standard-v3"
  description = "VM platform id"
}

