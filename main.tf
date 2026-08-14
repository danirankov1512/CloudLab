# 1. Дефинираме кой провайдър ни трябва (в случая Azure)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Ползваме стабилна 3.х версия
    }
  }
}

# 2. Конфигурираме провайдъра
provider "azurerm" {
  features {} # Този празен блок е задължителен за Azure
}

# 3. Създаваме първия си ресурс - Resource Group
resource "azurerm_resource_group" "homelab_tf" {
  name     = "rg-homelab-tf"
  location = "polandcentral" # Избери същия регион, в който е ръчната ти група
}

# 4. Създаваме виртуална мрежа (VNet)
resource "azurerm_virtual_network" "vnet_tf" {
  name                = "vnet2-homelab-tf"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.homelab_tf.location
  resource_group_name = azurerm_resource_group.homelab_tf.name
}

# 5. Създаваме подмрежа (Subnet) вътре във VNet
resource "azurerm_subnet" "subnet_tf" {
  name                 = "internal-subnet-tf"
  resource_group_name  = azurerm_resource_group.homelab_tf.name
  virtual_network_name = azurerm_virtual_network.vnet_tf.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 6. Създаваме Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg_tf" {
  name                = "nsg2-web-tf"
  location            = azurerm_resource_group.homelab_tf.location
  resource_group_name = azurerm_resource_group.homelab_tf.name
}

# 7. Добавяме правило в NSG за достъп до HTTP (Порт 80)
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "Allow-HTTP-80"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.homelab_tf.name
  network_security_group_name = azurerm_network_security_group.nsg_tf.name
}

# 8. Асоциираме (свързваме) NSG-то към нашата подмрежа
resource "azurerm_subnet_network_security_group_association" "association_tf" {
  subnet_id                 = azurerm_subnet.subnet_tf.id
  network_security_group_id = azurerm_network_security_group.nsg_tf.id
}
