# Configure the DNS Provider
provider "dns" {
  update {
    server    = var.dns_server
    transport = "udp"
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
  zone      = var.dns_zone
  name      = "${xenorchestra_vm.vm[count.index].name_label}.${var.dns_sub_zone}"
  addresses = xenorchestra_vm.vm[count.index].ipv4_addresses
  ttl       = 900
}

resource "dns_cname_record" "nodes" {
  count = var.vm_count
  zone  = var.dns_zone
  name  = "node-${count.index}.${var.dns_sub_zone}"
  cname = "${xenorchestra_vm.vm[count.index].name_label}.${var.dns_sub_zone}.${var.dns_zone}"
  ttl   = 900
}


# Create a DNS A record set
resource "dns_a_record_set" "masters" {
  count     = var.master_count
  zone      = var.dns_zone
  name      = "${xenorchestra_vm.vm_master[count.index].name_label}.${var.dns_sub_zone}"
  addresses = xenorchestra_vm.vm_master[count.index].ipv4_addresses
  ttl       = 900
}

resource "dns_cname_record" "masters" {
  count = var.master_count
  zone  = var.dns_zone
  name  = "master-${count.index}.${var.dns_sub_zone}"
  cname = "${xenorchestra_vm.vm_master[count.index].name_label}.${var.dns_sub_zone}.${var.dns_zone}"
  ttl   = 900
}

resource "dns_a_record_set" "controlplane" {
  zone      = var.dns_zone
  name      = "controlplane.${var.dns_sub_zone}"
  addresses = xenorchestra_vm.vm_master[*].ipv4_addresses[0]
  ttl       = 900
}