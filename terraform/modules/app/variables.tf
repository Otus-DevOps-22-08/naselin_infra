variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "app_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable "subnet_id" {
  description = "Subnets for modules"
}
variable "app_database_ip" {
  description = "IP address of the database server"
}
variable "auto_deploy_app" {
  description = "Auto deploy application"
  type = bool
  default = false
}
