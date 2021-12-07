# Configure the DNS Provider
provider "dns" {
  update {
    server = var.dns_server
    gssapi {
      realm    = var.dns_realm
      username = var.dns_username
      password = var.dns_password
    }
  }

}

# Create a DNS A record set
resource "dns_a_record_set" "nodes" {
  count     = var.vm_count
  zone      = "NTMAX.ca."
  name      = "${xenorchestra_vm.vm[count.index].name_label}.k8s"
  addresses = xenorchestra_vm.vm[count.index].ipv4_addresses
  ttl = 300
}

resource "dns_cname_record" "nodes" {
  count = var.vm_count
  zone  = "NTMAX.ca."
  name  = "node-${count.index}.k8s"
  cname = "${xenorchestra_vm.vm[count.index].name_label}.k8s.NTMAX.ca."
  ttl = 300
}


# Create a DNS A record set
resource "dns_a_record_set" "masters" {
  count     = var.master_count
  zone      = "NTMAX.ca."
  name      = "${xenorchestra_vm.vm_master[count.index].name_label}.k8s"
  addresses = xenorchestra_vm.vm_master[count.index].ipv4_addresses
  ttl = 300
}

resource "dns_cname_record" "masters" {
  count = var.master_count
  zone  = "NTMAX.ca."
  name  = "master-${count.index}.k8s"
  cname = "${xenorchestra_vm.vm_master[count.index].name_label}.k8s.NTMAX.ca."
  ttl = 300
}