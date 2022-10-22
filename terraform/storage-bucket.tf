terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "your-bucket-name"
    region     = "ru-central1"
    key        = "yourpath/terraform.tfstate"
    access_key = "YourAccessKey"
    secret_key = "YourSecretKey"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
