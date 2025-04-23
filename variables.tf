
variable "subscription_id" {
}

variable "client_id" {
}

variable "client_secret" {
}

variable "tenant_id" {
}

variable "environment" {
}

variable "nics" {
  type = list
default = [

    "172.18.0.4",
    "172.18.0.5",
    "172.18.0.6"
]
}

variable "tags" {
  type = map(string)
  default = {
    name = "test"
    ver  = "v0.1"
  }
}

variable "production" {
  type        = string
  description = "Whether is it a production CKA or Dev/Test CKA? Type 'prod' is for production."
  #nullable    = false
}

variable "resource_group_name" {
  description = "Resource Groups Name."
  type        = string
  default     = "ops_env_rg"
}

variable "vnet_name" {
  description = "vnet name."
  type        = string
  default     = "jack-vnet"
}

variable "vnet_namespace1" {
  description = "vnet namespace 1."
  type        = string
  default     = "192.168.0.0/18"
}

variable "vnet_namespace2" {
  description = "vnet namespace 2."
  type        = string
  default     = "172.18.0.0/22"
}

variable "web_subnet" {
  default = "web"
}

variable "web_subnet_address_space" {
  type    = string
  default = "172.18.0.0/24"
}

variable "db_subnet" {
  default = "db"
}

variable "db_subnet_address_space" {
  type    = string
  default = "192.168.0.0/24"
}

variable "gateway_subnet" {
  default = "GatewaySubnet"
}

variable "gateway_subnet_address_space" {
  type    = string
  default = "192.168.6.0/24"
}

variable "public_ip_name" {
  default = "jack-vm-pip"
}

variable "jack-nsg-name" {
  default = "jack-nsg"
}

variable "jack-nsg-home-rule" {
  default = "homework"
}

variable "jack-nsg-isp-rule-name" {
  default = "isp"
}

variable "jack_linux_nic1_name" {
  default = "nic1"
}

variable "jack_linux_nic1_setting_name" {
  default = "nic1conf"
}

variable "vm_name" {
  default = "ops-env"
}

variable "vmuser_name" {
  default = "hadoop"
}

variable "sshpwd" {
  default = "Cloud@123.com"
}

variable "countnum" {
  type        = number
  description = "The number that will be deployed vm:"
  default = 3
}

variable "avsetname" {
  default = "avsite"
}

variable "count_format" {
  default = "%02d"
}

variable "role" {
  default = "work"
}

variable "short_name" {
  default = "hi"
}
