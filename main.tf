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
  url = var.xen_xoa_url # Or set XOA_URL environment variable
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
  filename = "files/cloud_config_full.yaml"
}

data "local_file" "cloud_network_config" {
  filename = "files/cloud_network_config.yaml"
}

data "local_file" "rke_template_config" {
  filename = "files/rke_template.yaml"
}

resource "random_uuid" "vm_id" {
  count = var.vm_count
}

resource "random_uuid" "vm_master_id" {
  count = var.master_count
}

resource "xenorchestra_cloud_config" "ansible_base" {
  count = var.vm_count
  name  = "centos-base-config-node-${count.index}"
  #template = data.local_file.cloud_config.content
  template = <<EOF
#cloud-config
hostname: "${var.vm_prefix}-${random_uuid.vm_id[count.index].result}.${var.dns_sub_zone}.${lower(var.dns_zone)}"

users:
  - name: cloud-user
    gecos: cloud-user
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${var.vm_rsa_ssh_key}
EOF
}

resource "xenorchestra_cloud_config" "ansible_base_master" {
  count = var.master_count
  name  = "centos-base-config-master-${count.index}"
  #template = data.local_file.cloud_config.content
  template = <<EOF
#cloud-config
hostname: "${var.vm_prefix}-${random_uuid.vm_master_id[count.index].result}.${var.dns_sub_zone}.${lower(var.dns_zone)}"

users:
  - name: cloud-user
    gecos: cloud-user
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${var.vm_rsa_ssh_key}
EOF
}

resource "xenorchestra_cloud_config" "cloud_network_config" {
  name     = "Network Cloud Config"
  template = data.local_file.cloud_network_config.content
}

# docs : https://github.com/terra-farm/terraform-provider-xenorchestra/blob/master/docs/resources/vm.md
data "xenorchestra_pool" "pool" {
  name_label = var.xen_pool_name
}

data "xenorchestra_network" "net" {
  name_label = var.xen_network_name
  pool_id    = data.xenorchestra_pool.pool.id
}

data "xenorchestra_template" "centos" {
  name_label = var.xen_template_name
}

data "xenorchestra_sr" "truenas_ssd" {
  name_label = var.xen_sr_name
}

resource "xenorchestra_vm" "vm" {
  count = var.vm_count

  name_label           = "${var.vm_prefix}-${random_uuid.vm_id[count.index].result}"
  cloud_config         = xenorchestra_cloud_config.ansible_base[count.index].template
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config.template
  template             = data.xenorchestra_template.centos.id
  auto_poweron         = true

  name_description = "${var.vm_prefix}-${random_uuid.vm_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"

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

  tags = var.node_vm_tags
}

resource "xenorchestra_vm" "vm_master" {
  count = var.master_count

  name_label           = "${var.master_prefix}-${random_uuid.vm_master_id[count.index].result}"
  cloud_config         = xenorchestra_cloud_config.ansible_base_master[count.index].template
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config.template
  template             = data.xenorchestra_template.centos.id
  auto_poweron         = true

  name_description = "${var.master_prefix}-${random_uuid.vm_master_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"

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

  tags = var.master_vm_tags
}

resource "local_file" "ansible_inventory" {
  filename = "files/hosts.yaml"
  content = yamlencode({
    "all" : {
      "vars" : {
        "ansible_user" : "cloud-user",
        "ansible_ssh_private_key_file" : "~/.ssh/id_rsa"
      },
      "children" : {
        "k8s-nodes" : {
          "hosts" : zipmap(xenorchestra_vm.vm[*].name_description, [for e in xenorchestra_vm.vm[*].name_description : {}])
        },
        "k8s-masters" : {
          "hosts" : zipmap(xenorchestra_vm.vm_master[*].name_description, [for e in xenorchestra_vm.vm_master[*].name_description : {}])
        }
      }
  } })
}


resource "local_file" "rke_config" {
  filename = "files/rke_cluster_config.yml"
  content = join("", [yamlencode({
    "nodes" : concat([for e in xenorchestra_vm.vm[*].name_description : {
      "address" : e,
      "internal_address" : e,
      "port" : "22",
      "role" : ["worker"],
      "user" : "cloud-user",
      "docker_socket" : "/run/docker.sock"
      "ssh_key_path" : "~/.ssh/id_rsa"
      "labels" : var.node_labels
      }
      ],
      [for e in xenorchestra_vm.vm_master[*].name_description : {
        "address" : e,
        "internal_address" : e,
        "port" : "22",
        "role" : ["controlplane", "etcd"],
        "user" : "cloud-user",
        "docker_socket" : "/run/docker.sock"
        "ssh_key_path" : "~/.ssh/id_rsa"
        "labels" : var.master_labels
        }
    ])
    }),
    data.local_file.rke_template_config.content]
  )
}
