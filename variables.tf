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
}

variable "vm_count" {
    description = "The number of VMs to create"
    default = 2
}