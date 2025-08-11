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

resource "yandex_storage_bucket" "test" {
  bucket     = var.bucket_name
  folder_id  = var.folder_id
  anonymous_access_flags {
    read        = true
  }  
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_object" "test-object" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket_name
  key        = var.object_key
  source     = "./test.jpg"
}

