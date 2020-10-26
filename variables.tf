variable "prefix" {
    description = "The prefix used for all resources in this project"
    default = "iass-web-server"
}

variable "location" {
    description = "The location of the resources in this project"
    default = "West US"
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

variable "environment" {
    description = "Environment"
    default = "dev"
}

variable "image_name" {
    description = "Name of the image deployed with packer"
    default = "iaas-web-packer-image"
}

variable "image_rg_name" {
    description = "Name of the resource group associated with the packer image"
    default = "iass-web-packer-resources"
}