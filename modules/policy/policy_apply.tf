variable "policy_directory" {
  description = "The path to the directory containing the policy JSON files"
  type        = string
}

locals {
  json_files = fileset(var.policy_directory, "*.json")
  json_data  = { for file in local.json_files : "${var.policy_directory}/${file}" => jsondecode(file("${var.policy_directory}/${file}")) }
}

resource "azurerm_policy_definition" "custom_policy" {
  for_each = local.json_data

  name         = try(each.value.name, each.value.properties.displayName)
  display_name = try(each.value.properties.displayName, null)
  description  = try(each.value.properties.description, null)
  policy_type  = "Custom"
  mode         = try(each.value.properties.mode, null)

  metadata = try(jsonencode(each.value.properties.metadata), null)
  policy_rule = try(jsonencode(each.value.properties.policyRule), null)
  parameters = try(jsonencode(each.value
  .properties.parameters), null)
}

output "policy_ids" {
  value = { for k, v in azurerm_policy_definition.custom_policy : k => v.id }
  description = "The IDs of the created policy definitions"
}