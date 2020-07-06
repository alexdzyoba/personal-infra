// =============================================================================
//  Required params
// =============================================================================
variable "ssh_key_pair_name" {
  description = "SSH key pair name"
  type        = string
}

// =============================================================================
//  Optional params
// =============================================================================
variable "instance_type" {
  description = "Instance type for VPN host"
  type        = string
  default     = "t3.micro"
}

variable "name" {
  description = "Name for the VPN configuration. Used for VPC and instance"
  type        = string
  default     = "vpn"
}

variable "wireguard_port" {
  description = "Port for WireGuard connections"
  type        = number
  default     = 51820
}

variable "instance_disk_size" {
  description = "Size of the instance disk in GBs"
  type        = number
  default     = 8
}
