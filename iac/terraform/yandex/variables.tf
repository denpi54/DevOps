variable "token"        { type = string }
variable "cloud_id"     { type = string }
variable "folder_id"    { type = string }
variable "zone"         { type = string  default = "ru-central1-a" }
variable "ssh_pub_key"  { type = string }
variable "vm_user"      { type = string  default = "deployer" }
variable "image_family" { type = string  default = "ubuntu-2204-lts" }
variable "vm_size"      { type = string  default = "standard-v2" }
