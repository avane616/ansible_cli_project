#########################
# Outputs
#########################
output "vm_name" {
  value = local.vm_name
}


output "New_VM_info" {
  value = {
    ip = data.nutanix_virtual_machines_v2.filtered-vms.vms[0].nics[0].network_info[0].ipv4_config[0].ip_address[0].value
  }
}
