variable "resource_group_name" {
  type        = string
  description = "Името на ресурсната група"
  default     = "rg-homelab-tf"
}

variable "location" {
  type        = string
  description = "Регионът в Azure, където ще се създават ресурсите"
  default     = "polandcentral"
}

variable "vnet_name" {
  type        = string
  description = "Името на виртуалната мрежа"
  default     = "vnet2-homelab-tf"
}

variable "my_public_ip" {
  type        = string
  description = "Моят личен публичен IP адрес за сигурен SSH достъп"
}
