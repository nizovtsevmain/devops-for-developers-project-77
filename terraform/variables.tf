variable "selectel_domain_name" {
  description = "Selectel Domain Name"
  type        = string
  default     = 327713
}

variable "selectel_username" {
  description = "Selectel Username"
  type        = string
  default     = "Myrtle"
}

variable "selectel_password" {
  type      = string
  sensitive = true
}
