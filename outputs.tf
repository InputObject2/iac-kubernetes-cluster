output "nodes_ips" {
  value = xenorchestra_vm.vm[*].ipv4_addresses[0]
}

output "nodes" {
  value = xenorchestra_vm.vm[*].name_label
}

output "masters_ips" {
  value = xenorchestra_vm.vm_master[*].ipv4_addresses[0]
}

output "masters" {
  value = xenorchestra_vm.vm_master[*].name_label
}