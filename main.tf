# docs : https://github.com/terra-farm/terraform-provider-xenorchestra/blob/master/docs/resources/vm.md
terraform {
  required_providers {
    xenorchestra = {
      source  = "terra-farm/xenorchestra"
      version = "0.21.0"
    }
  }
}

provider "xenorchestra" {
  # Configuration options
  # Must be ws or wss
  url = "wss://xen-orchestra.ntmax.ca" # Or set XOA_URL environment variable
  #username = "root"              # Or set XOA_USER environment variable
  #password = "<password>"              # Or set XOA_PASSWORD environment variable

  # This is false by default and
  # will disable ssl verification if true.
  # This is useful if your deployment uses
  # a self signed certificate but should be
  # used sparingly!
  insecure = true # Or set XOA_INSECURE environment variable to any value
}

data "local_file" "cloud_config" {
  filename = "files/cloud_config_full.txt"
}

data "local_file" "cloud_network_config" {
  filename = "files/cloud_network_config.txt"
}

resource "random_uuid" "vm_id" {
  count = var.vm_count
}

resource "random_uuid" "vm_master_id" {
  count = var.vm_count
}

resource "xenorchestra_cloud_config" "ansible_base" {
  name     = "cloud-centos-base-for-ansible"
  template = data.local_file.cloud_config.content
}

# docs : https://github.com/terra-farm/terraform-provider-xenorchestra/blob/master/docs/resources/vm.md
data "xenorchestra_pool" "pool" {
  name_label = "Cluster-XCP"
}

data "xenorchestra_network" "net" {
  name_label = "k8s.ntmax.ca"
  pool_id    = data.xenorchestra_pool.pool.id
}

data "xenorchestra_template" "centos" {
  name_label = "Cloud-init - CentOS"
}

data "xenorchestra_sr" "truenas_fast" {
  name_label = "[NFS] TrueNAS Fast"
}

data "xenorchestra_sr" "truenas_slow" {
  name_label = "[NFS] TrueNAS Slow"
}

data "xenorchestra_sr" "truenas_ssd" {
  name_label = "[NFS] TrueNAS SSD"
}

data "xenorchestra_sr" "iscsi_ssd" {
  name_label = "[iSCSI] SSD VM Storage"
}

data "xenorchestra_sr" "iscsi_hdd" {
  name_label = "[iSCSI] HDD VM Storage"
}

resource "xenorchestra_vm" "vm" {
  count = var.vm_count

  name_label           = "${var.vm_prefix}-${random_uuid.vm_id[count.index].result}"
  cloud_config         = xenorchestra_cloud_config.ansible_base.template
  cloud_network_config = data.local_file.cloud_network_config.content
  template             = data.xenorchestra_template.centos.id
  auto_poweron         = true

  name_description = "${var.vm_prefix}-${random_uuid.vm_id[count.index].result}.k8s.ntmax.ca"

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.truenas_ssd.id
    name_label = "${var.vm_prefix}-${random_uuid.vm_id[count.index].result}"
    size       = var.vm_disk_size_gb * 1024 * 1024 * 1024 # GB to B
  }

  cpus       = var.vm_cpu_count
  memory_max = var.vm_memory_size_gb * 1024 * 1024 * 1024 # GB to B

  wait_for_ip = true

  tags = [
    "centos",
    "kubernetes",
    "ansible",
    "terraform-managed",
    "kubernetes.io/role:worker"
  ]
}

resource "xenorchestra_vm" "vm_master" {
  count = var.master_count

  name_label           = "${var.master_prefix}-${random_uuid.vm_master_id[count.index].result}"
  cloud_config         = xenorchestra_cloud_config.ansible_base.template
  cloud_network_config = data.local_file.cloud_network_config.content
  template             = data.xenorchestra_template.centos.id
  auto_poweron         = true

  name_description = "${var.master_prefix}-${random_uuid.vm_master_id[count.index].result}.k8s.ntmax.ca"

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.truenas_ssd.id
    name_label = "${var.master_prefix}-${random_uuid.vm_master_id[count.index].result}"
    size       = var.master_disk_size_gb * 1024 * 1024 * 1024 # GB to B
  }

  cpus       = var.master_cpu_count
  memory_max = var.master_memory_size_gb * 1024 * 1024 * 1024 # GB to B

  wait_for_ip = true

  tags = [
    "centos",
    "kubernetes",
    "ansible",
    "terraform-managed",
    "kubernetes.io/role:master"
  ]
}


resource "local_file" "ansible_inventory" {
  filename = "files/hosts.yaml"
  content = yamlencode({
    "all" : {
      "vars" : {
        "ansible_user" : "ansible",
        "ansible_ssh_private_key_file" : "~/.ssh/id_rsa"
      },
      "children" : {
        "k8s-nodes" : {
          "hosts" : zipmap(xenorchestra_vm.vm[*].name_description, [for e in xenorchestra_vm.vm[*].name_description : {}]) # zipmap(xenorchestra_vm.vm[*].name_description,[for 0..${var.vm_count} : o.id])
        },
        "k8s-masters" : {
          "hosts" : zipmap(xenorchestra_vm.vm_master[*].name_description, [for e in xenorchestra_vm.vm_master[*].name_description : {}]) #zipmap(xenorchestra_vm.vm_master[*].name_description,[for o in var.list : o.id])
        }
      }
  } })
}

