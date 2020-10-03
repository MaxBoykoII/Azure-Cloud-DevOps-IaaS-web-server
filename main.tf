# Configure the Azure Provider
provider "azurerm" {
    version = "=2.20.0"
    features {}
}

# Create a resource group
resource "azurerm_resource_group" "iaas-web-server" {
    name = "iass-web-server-resources"
    location = "West US"
}