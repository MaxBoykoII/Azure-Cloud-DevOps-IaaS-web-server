variable "prefix" {
    description = "The prefix used for all resources in this project"
    default = "iass-web-server"
}

variable "location" {
    description = "The location of the resources in this project"
    default = "West US"
}

variable "source_image_id" {
    description = "The source image id of the packer template"
    default = "/subscriptions/52c9f91d-c477-43c5-82bf-8c99b0dd262e/resourceGroups/iass-web-packer-resources/providers/Microsoft.Compute/images/ubuntuImage"
}

variable "vm_count" {
    description = "The number of VMs to create"
    default = 2
}

variable "vm_username" {
    description = "Username for VMs"
    default ="adminuser"
}

variable "vm_password" {
    description = "Password for VMs"
    default = "P@ssw0rd1234!"
}