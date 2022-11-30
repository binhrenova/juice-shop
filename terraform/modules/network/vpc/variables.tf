variable "cidr_block" {
  description = "The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using ipv4_netmask_length."
  type        = string
  default     = null
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC."
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type        = string
  default     = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  type        = string
  default     = false
}

variable "tags" {
  description = "Optional Tags"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name"
  type        = string
}

variable "igw_name" {
  type        = string
  description = "Name of Internet Gateway attached to VPC"
}