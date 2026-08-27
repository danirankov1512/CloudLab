output "resource_group_id" {
  value       = azurerm_resource_group.homelab_tf.id
  description = "Уникалното ID на ресурсната група в Azure"
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet_tf.id
  description = "Уникалното ID на виртуалната мрежа"
}
