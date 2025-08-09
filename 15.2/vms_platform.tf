###vm vars web

# variable "vm_web_name" {
#   type        = string
#   default     = "netology-develop-platform-web"
#   description = "VM web instance name"
# }

variable "vm_web_resources" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }
  description = "VM web instance resources"
}

variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "VM web scheduling policy (preemptible)"
}

variable "vm_web_nat" {
  type        = bool
  default     = false
  description = "VM web external IP policy (nat)"
}

# variable "vm_web_user_name" {
#   type        = string
#   default     = "ubuntu"
#   description = "VM web instance user name"
# }

###vm vars db

# variable "vm_db_name" {
#   type        = string
#   default     = "netology-develop-platform-db"
#   description = "VM db instance name"
# }

variable "vm_db_resources" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  description = "VM db instance resources"
}

variable "vm_db_preemptible" {
  type        = bool
  default     = true
  description = "VM db scheduling policy (preemptible)"
}

variable "vm_db_nat" {
  type        = bool
  default     = false
  description = "VM db external IP policy (nat)"
}

# variable "vm_db_user_name" {
#   type        = string
#   default     = "ubuntu"
#   description = "VM db instance user name"
# }

###vm vars name

variable "company_name" {
  type        = string
  default     = "netology"
  description = "Company name prefix"
}

variable "vm_web_suffix" {
  type        = string
  default     = "platform-web"
  description = "Suffix for the web VM"
}

variable "vm_db_suffix" {
  type        = string
  default     = "platform-db"
  description = "Suffix for the database VM"
}