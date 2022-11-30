# variable "cidr" {
#   description = "CIDR block you use in your VPC"
#   type        = string
# }

variable "availability_zone" {
  description = "AZ to use for the subnet."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC where we want to deploy the subnet"
  type        = string
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

variable "cidr_block" {
  description = "(Optional) The IPv4 CIDR block for the subnet."
  type        = string
  default     = false
}

variable "route_table" {
  description = "Route table to attach the subnets to"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnets should be assigned a public IP address"
  type        = bool
  default     = false
}