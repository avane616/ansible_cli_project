#########################
# Input Variables
#########################
variable "country"     { default = "Denmark" }
variable "city"        { default = "Copenhagen" }
variable "pv"          { default = "Physical" }
variable "asset_type"  { default = "Virtual Host" }
variable "function"    { default = "" }       # Leave blank → APP
variable "environment" { default = "" } # Test
variable "number"      { default = "015" }

variable "prism" {
  description = "Secret for the Nutanix API."
  type        = string
}

variable "location" {
  description = "Secret for the Nutanix API."
  type        = string
}

variable "nutanix_subnet_name" {
  description = "The name of the Nutanix subnet to use for the VM."
  type        = string
}

variable "template_name" {
  description = "The name of the Nutanix template to use for the VM."
  type        = string
}


variable "cluster_name" {
  description = "The name of the cluster to use for the VM."
  type        = string
}

// variable "vm_name" {
//   description = "The name of the VM to be created."
//   type        = string
// }

variable "vm_memory_size_bytes" {
  description = "The memory size of the VM in bytes."
  type        = number
  default = 4294967296  # 4 GB
}

variable "vm_num_sockets" {
  description = "The number of CPU sockets for the VM."
  type        = number
  default = 2

}

variable "vm_num_cores_per_socket" {
  description = "The number of CPU cores per socket for the VM."
  type        = number
  default = 1
}

variable "vm_num_threads_per_core" {
  description = "The number of threads per CPU core for the VM."
  type        = number
  default = 1
}

