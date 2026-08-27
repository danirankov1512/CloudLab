locals {
  # Централизирани тагове, които ще сложим на всеки ресурс
  common_tags = {
    Environment = "homelab"
    ManagedBy   = "terraform"
    Owner       = "User"
    Project     = "CloudLab"
  }
}
