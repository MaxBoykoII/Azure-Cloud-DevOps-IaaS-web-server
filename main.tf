# Configure the Azure Provider
provider "azurerm" {
  version = "=2.20.0"
  features {}
}

# Add a datasource for the current subscription
data "azurerm_subscription" "current" {
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

# Create a policy definition to enforce tagging resources
resource "azurerm_policy_definition" "tagging_policy" {
  name         = "deny-indexed-resources-without-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Deny Creation of Indexed Resources without Tags"
  description  = "Ensures that all indexed resources are tagged. This will help us with organization and tracking, and make it easier to log when things go wrong."
  policy_rule  = <<POLICY_RULE
  {
      "if": {
          "field": "tags",
          "exists": "false"
      },
      "then": {
          "effect": "deny"
      }
  }
  POLICY_RULE
}

# Create a policy assignment for the tagging policy
resource "azurerm_policy_assignment" "tagging_policy_assignment" {
  name                 = "tagging-policy"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.tagging_policy.id
  description          = "Assignment of the tagging policy"
  display_name         = "tagging-policy"
}

# Create a virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create a subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a network interface
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "iaas-server-configuration"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  network_interface_ids           = [azurerm_network_interface.main.id]
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = var.source_image_id
}




