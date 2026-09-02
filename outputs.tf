output "resource_group_id" {
  value       = azurerm_resource_group.homelab_tf.id
  description = "Уникалното ID на ресурсната група в Azure"
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet_tf.id
  description = "Уникалното ID на виртуалната мрежа"
}

output "vm_public_ip" {
  value       = azurerm_linux_virtual_machine.web01_tf.public_ip_address
  description = "Публичният IP адрес на новата Ubuntu виртуалка"
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.ini"
  content  = <<EOT
[webservers]
web01_tf ansible_host=${azurerm_linux_virtual_machine.web01_tf.public_ip_address} ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa_azure
EOT
}
