// terraform {
//   backend "azurerm" {
//     use_azuread_auth     = true
//     container_name       = "tfstate"
//     key                  = "test.terraform.tfstate"
//     storage_account_name = "azuwevelcrstor076"
//   }
// }

#########################
# Locals for Name Parts
#########################
locals {
  # --- UID: Country (3 letters) + City (2 letters) ---
  country_code  = upper(substr(var.country, 0, 3)) # "Denmark" → "DEN"
  city_code     = upper(substr(var.city, 0, 2))    # "Copenhagen" → "CO" 
  uid           = "${local.country_code}${local.city_code}" # → "DENCO"
 
  # --- P/V ---
  pv_code       = upper(substr(var.pv, 0, 1))       # Physical → P
 
  # --- TYPE ---
  type_words = split(" ", trim(var.asset_type, " "))
  type_code = (
    length(local.type_words) > 1 ?
    upper("${substr(local.type_words[0], 0, 1)}${substr(local.type_words[1], 0, 1)}") :
    upper(substr(local.type_words[0], 0, 2))
  )

  # --- FUNCTION ---
  function_clean = trim(var.function, " ")
  function_code = (
    local.function_clean != "" ? upper(substr(local.function_clean, 0, 3)) : "APP"
  )
 
  # --- CRITICALITY ---
  crit_code     = upper(substr(var.environment, 0, 1))    # Production → P
 
  # --- NUMBER ---
  num_padded    = format("%03d", tonumber(var.number))    # Always 3 digits

  # --- Final VM Name ---
  #vm_name       = "poc-${local.uid}${local.pv_code}${local.type_code}${local.function_code}${local.crit_code}${local.num_padded}"
  vm_name       = "poc-${var.location}${local.pv_code}${local.type_code}${local.function_code}${local.crit_code}${local.num_padded}"
}

data "nutanix_subnet" "subnet" {
  subnet_name = var.nutanix_subnet_name
}

data "nutanix_cluster" "cluster" {
   name = var.cluster_name
}

data "nutanix_templates_v2" "filtered_templates" {
  filter = "templateName eq '${var.template_name}'"
  page   = 0
  limit  = 1
}

resource "nutanix_deploy_templates_v2" "deploy-temp" {
  ext_id            = data.nutanix_templates_v2.filtered_templates.templates[0].ext_id
  number_of_vms     = 1
  cluster_reference = data.nutanix_cluster.cluster.id
  override_vm_config_map {
    name                 = local.vm_name
    memory_size_bytes    = var.vm_memory_size_bytes
    num_sockets          = var.vm_num_sockets
    num_cores_per_socket = var.vm_num_cores_per_socket
    num_threads_per_core = var.vm_num_threads_per_core
    nics {
      network_info {
        subnet {
          ext_id = data.nutanix_subnet.subnet.id
        }
      }
    }
  }
}

data "nutanix_virtual_machines_v2" "filtered-vms"{
depends_on = [nutanix_deploy_templates_v2.deploy-temp]
    filter = "name eq '${local.vm_name}'"
}

resource "null_resource" "power_on_vm" {
  depends_on = [nutanix_deploy_templates_v2.deploy-temp, data.nutanix_virtual_machines_v2.filtered-vms]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = "curl -s -X GET -u \"automation:${var.prism}\" -k https://10.45.203.90:9440/api/nutanix/v3/vms/${data.nutanix_virtual_machines_v2.filtered-vms.vms[0].ext_id} -H \"Content-Type: application/json\" | jq 'del(.status) | .spec.resources.power_state = \"ON\"' > updated_vm_payload.json; curl -s -X PUT -u \"automation:${var.prism}\" -k https://10.45.203.90:9440/api/nutanix/v3/vms/${data.nutanix_virtual_machines_v2.filtered-vms.vms[0].ext_id} -H \"Content-Type: application/json\" -d @updated_vm_payload.json"
  }
}
