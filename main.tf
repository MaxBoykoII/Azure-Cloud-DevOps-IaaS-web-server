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

# Create a public ip address
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

# Create a load balancer
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-public-ip-address"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

# Create the backend ip address pool
resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-backend-address-pool"
}

# Create network interfaces
resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${var.prefix}-nic-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "iaas-server-configuration"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create an availability set
resource "azurerm_availability_set" "avset" {
  name                         = "${var.prefix}-avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = var.vm_count
  platform_update_domain_count = var.vm_count
  managed                      = true
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_count
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  availability_set_id             = azurerm_availability_set.avset.id
  location                        = azurerm_resource_group.main.location
  network_interface_ids           = [element(azurerm_network_interface.main.*.id, count.index)]
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




