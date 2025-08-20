resource "yandex_kms_symmetric_key" "key-a" {
  name                = "exmple-key"
  description         = "example description"
  default_algorithm   = "AES_128"
  rotation_period     = "8760h" // 1 год
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id  = var.service_account_id
  description        = "static access key for object storage"
}