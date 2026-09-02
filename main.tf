# # 1. Дефинираме кой провайдър ни трябва (в случая Azure)
# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 3.0" # Ползваме стабилна 3.х версия
#     }
#   }
# }

# # 2. Конфигурираме провайдъра
# provider "azurerm" {
#   features {} # Този празен блок е задължителен за Azure
# }

# # 3. Създаваме първия си ресурс - Resource Group
# resource "azurerm_resource_group" "homelab_tf" {
#   name     = "rg-homelab-tf"
#   location = var.location
# }

# # 4. Създаваме виртуална мрежа (VNet)
# resource "azurerm_virtual_network" "vnet_tf" {
#   name                = "vnet2-homelab-tf"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.homelab_tf.location
#   resource_group_name = azurerm_resource_group.homelab_tf.name
# }

# # 5. Създаваме подмрежа (Subnet) вътре във VNet
# resource "azurerm_subnet" "subnet_tf" {
#   name                 = "internal-subnet-tf"
#   resource_group_name  = azurerm_resource_group.homelab_tf.name
#   virtual_network_name = azurerm_virtual_network.vnet_tf.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# # 6. Създаваме Network Security Group (NSG)
# resource "azurerm_network_security_group" "nsg_tf" {
#   name                = "nsg2-web-tf"
#   location            = azurerm_resource_group.homelab_tf.location
#   resource_group_name = azurerm_resource_group.homelab_tf.name
# }

# # 7. Добавяме правило в NSG за достъп до HTTP (Порт 80)
# resource "azurerm_network_security_rule" "allow_http" {
#   name                        = "Allow-HTTP-80"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "80"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.homelab_tf.name
#   network_security_group_name = azurerm_network_security_group.nsg_tf.name
# }

# # 8. Асоциираме (свързваме) NSG-то към нашата подмрежа
# resource "azurerm_subnet_network_security_group_association" "association_tf" {
#   subnet_id                 = azurerm_subnet.subnet_tf.id
#   network_security_group_id = azurerm_network_security_group.nsg_tf.id
# }


# Създаваме Resource Group чрез променливи
resource "azurerm_resource_group" "homelab_tf" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Създаваме виртуална мрежа (VNet)
resource "azurerm_virtual_network" "vnet_tf" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.homelab_tf.location
  resource_group_name = azurerm_resource_group.homelab_tf.name
  tags                = local.common_tags
}

# Създаваме подмрежа (Subnet)
resource "azurerm_subnet" "subnet_tf" {
  name                 = "internal-subnet-tf"
  resource_group_name  = azurerm_resource_group.homelab_tf.name
  virtual_network_name = azurerm_virtual_network.vnet_tf.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Създаваме Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg_tf" {
  name                = "nsg2-web-tf"
  location            = azurerm_resource_group.homelab_tf.location
  resource_group_name = azurerm_resource_group.homelab_tf.name
  tags                = local.common_tags
}

# Добавяме правило в NSG за достъп до HTTP (Порт 80)
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

# Асоциираме NSG-то към подмрежата
resource "azurerm_subnet_network_security_group_association" "association_tf" {
  subnet_id                 = azurerm_subnet.subnet_tf.id
  network_security_group_id = azurerm_network_security_group.nsg_tf.id
}


# 9. Създаваме Public IP за виртуалната машина
resource "azurerm_public_ip" "vm_pip" {
  name                = "web01-pip-tf"
  resource_group_name = azurerm_resource_group.homelab_tf.name
  location            = azurerm_resource_group.homelab_tf.location
  allocation_method   = "Static"   # Променено от Dynamic на Static
  sku                 = "Standard" # Добавено - задължително за нови акаунти
  tags                = local.common_tags
}


# 10. Създаваме Мрежова карта (NIC) и я връзваме с подмрежата и Public IP-то
resource "azurerm_network_interface" "vm_nic" {
  name                = "web01-nic-tf"
  location            = azurerm_resource_group.homelab_tf.location
  resource_group_name = azurerm_resource_group.homelab_tf.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_tf.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

# 11. Създаваме самата Ubuntu виртуална машина
resource "azurerm_linux_virtual_machine" "web01_tf" {
  name                = "web01-tf"
  resource_group_name = azurerm_resource_group.homelab_tf.name
  location            = azurerm_resource_group.homelab_tf.location
  size                = "Standard_B2ats_v2" # Изключително евтина/безплатна машина (1 vCPU, 1GB RAM)
  admin_username      = "azureuser"
  tags                = local.common_tags

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  # Казваме на Azure да инжектира новия RSA ключ
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa_azure.pub")
  }

  # Избираме операционна система - Ubuntu 22.04 LTS
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Стандартно HDD/SSD за ниска цена
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


# 12. Сигурно правило за SSH (Порт 22) - САМО от твоето IP
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH-22-MyIP"
  priority                    = 110 # Различен приоритет от HTTP
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.homelab_tf.name
  network_security_group_name = azurerm_network_security_group.nsg_tf.name
}
