# Configure the Azure Provider
provider "azurerm" {
  version = "=2.20.0"
  features {}
}

# Add a datasource for the current subscription
data "azurerm_subscription" "current" {
}

# Create a resource group
resource "azurerm_resource_group" "iaas-web-server" {
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
