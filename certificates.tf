data "local_file" "ca_private_key" {
  filename = "files/ca/ca-key.pem"
}

data "local_file" "ca_public_cert" {
  filename = "files/ca/ca.pem"
}

data "local_file" "domain_root_cert" {
  filename = "files/ca/domain-ca-certificate.pem"
}

# Kube-admin certificate
resource "tls_private_key" "kube_admin_key" {
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_admin_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_admin_key.private_key_pem

  subject {
    common_name         = "kube-admin"
    organizational_unit = "system:masters"
    organization        = var.certificate_params["organization"]
    locality            = var.certificate_params["locality"]
    province            = var.certificate_params["province"]
    country             = var.certificate_params["country"]
  }

  dns_names = concat(
    xenorchestra_vm.vm_master[*].name_description,
    ["localhost",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}",
    "controlplane.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"]
  )

  ip_addresses = concat(
    xenorchestra_vm.vm_master[*].ipv4_addresses[0],
    ["127.0.0.1",
    "172.16.0.1"]
  )
}

resource "tls_locally_signed_cert" "kube_admin_cert" {
  cert_request_pem   = tls_cert_request.kube_admin_csr.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_admin_cert" {
  filename = "files/certificates/kube-admin.pem"
  content  = "${tls_locally_signed_cert.kube_admin_cert.cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_admin_key" {
  filename = "files/certificates/kube-admin-key.pem"
  content  = tls_private_key.kube_admin_key.private_key_pem

}

# Kube-apiserver
resource "tls_private_key" "kube_apiserver_key" {
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_apiserver_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_apiserver_key.private_key_pem

  subject {
    common_name  = "kube-apiserver"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }

  dns_names = concat(
    xenorchestra_vm.vm_master[*].name_description,
    ["localhost",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}",
    "controlplane.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"]
  )

  ip_addresses = concat(
    xenorchestra_vm.vm_master[*].ipv4_addresses[0],
    ["127.0.0.1",
    "172.16.0.1"]
  )
}

resource "tls_locally_signed_cert" "kube_apiserver_cert" {
  cert_request_pem   = tls_cert_request.kube_apiserver_csr.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_apiserver_cert" {
  filename = "files/certificates/kube-apiserver.pem"
  content  = "${tls_locally_signed_cert.kube_apiserver_cert.cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_apiserver_key" {
  filename = "files/certificates/kube-apiserver-key.pem"
  content  = tls_private_key.kube_apiserver_key.private_key_pem

}

# Kube_apiserver_proxy_client
resource "tls_private_key" "kube_apiserver_proxy_client_key" {
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_apiserver_proxy_client_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_apiserver_proxy_client_key.private_key_pem

  subject {
    common_name  = "kube-apiserver-proxy-client"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }
}

resource "tls_locally_signed_cert" "kube_apiserver_proxy_client_cert" {
  cert_request_pem   = tls_cert_request.kube_apiserver_proxy_client_csr.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_apiserver_proxy_client_cert" {
  filename = "files/certificates/kube-apiserver-proxy-client.pem"
  content  = "${tls_locally_signed_cert.kube_apiserver_proxy_client_cert.cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_apiserver_proxy_client_key" {
  filename = "files/certificates/kube-apiserver-proxy-client-key.pem"
  content  = tls_private_key.kube_apiserver_proxy_client_key.private_key_pem

}

# kube-controller-manager
resource "tls_private_key" "kube-controller-manager_key" {
  algorithm = "RSA"

}

resource "tls_cert_request" "kube-controller-manager_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube-controller-manager_key.private_key_pem

  subject {
    common_name  = "system:kube-controller-manager"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }
}

resource "tls_locally_signed_cert" "kube-controller-manager_cert" {
  cert_request_pem   = tls_cert_request.kube-controller-manager_csr.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube-controller-manager_cert" {
  filename = "files/certificates/kube-controller-manager.pem"
  content  = "${tls_locally_signed_cert.kube-controller-manager_cert.cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube-controller-manager_key" {
  filename = "files/certificates/kube-controller-manager-key.pem"
  content  = tls_private_key.kube-controller-manager_key.private_key_pem

}

# kube-etcd
resource "tls_private_key" "kube_etcd_key" {
  count     = var.master_count
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_etcd_csr" {
  count           = var.master_count
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_etcd_key[count.index].private_key_pem

  subject {
    common_name  = "kube-etcd"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }

  dns_names = [
    "${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}",
    "controlplane.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}",
    "controlplane.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}",
    xenorchestra_vm.vm_master[count.index].name_description
  ]
}

resource "tls_locally_signed_cert" "kube_etcd_cert" {
  count              = var.master_count
  cert_request_pem   = tls_cert_request.kube_etcd_csr[count.index].cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_etcd_cert" {
  count    = var.master_count
  filename = "files/certificates/kube-etcd-${replace(xenorchestra_vm.vm_master[count.index].name_description, ".", "-")}.pem"
  content  = "${tls_locally_signed_cert.kube_etcd_cert[count.index].cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_etcd_key" {
  count    = var.master_count
  filename = "files/certificates/kube-etcd-${replace(xenorchestra_vm.vm_master[count.index].name_description, ".", "-")}-key.pem"
  content  = tls_private_key.kube_etcd_key[count.index].private_key_pem

}

# kube-kubelet-master
resource "tls_private_key" "kube_kubelet_master_key" {
  count     = var.master_count
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_kubelet_master_csr" {
  count           = var.master_count
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_kubelet_master_key[count.index].private_key_pem

  subject {
    common_name  = "kube-kubelet"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }

  dns_names = [
    xenorchestra_vm.vm_master[count.index].name_description
  ]
}

resource "tls_locally_signed_cert" "kube_kubelet_master_cert" {
  count              = var.master_count
  cert_request_pem   = tls_cert_request.kube_kubelet_master_csr[count.index].cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_kubelet_master_cert" {
  count    = var.master_count
  filename = "files/certificates/kube-kubelet-${replace(xenorchestra_vm.vm_master[count.index].name_description, ".", "-")}.pem"
  content  = "${tls_locally_signed_cert.kube_kubelet_master_cert[count.index].cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_kubelet_master_key" {
  count    = var.master_count
  filename = "files/certificates/kube-kubelet-${replace(xenorchestra_vm.vm_master[count.index].name_description, ".", "-")}-key.pem"
  content  = tls_private_key.kube_kubelet_master_key[count.index].private_key_pem

}

# kube-kubelet-nodes
resource "tls_private_key" "kube_kubelet_node_key" {
  count     = var.vm_count
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_kubelet_node_csr" {
  count           = var.vm_count
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_kubelet_node_key[count.index].private_key_pem

  subject {
    common_name  = "kube-kubelet"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }

  dns_names = [
    xenorchestra_vm.vm[count.index].name_description
  ]
}

resource "tls_locally_signed_cert" "kube_kubelet_node_cert" {
  count              = var.vm_count
  cert_request_pem   = tls_cert_request.kube_kubelet_node_csr[count.index].cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_kubelet_node_cert" {
  count    = var.vm_count
  filename = "files/certificates/kube-kubelet-${replace(xenorchestra_vm.vm[count.index].name_description, ".", "-")}.pem"
  content  = "${tls_locally_signed_cert.kube_kubelet_node_cert[count.index].cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}" # 

}

resource "local_file" "kube_kubelet_node_key" {
  count    = var.vm_count
  filename = "files/certificates/kube-kubelet-${replace(xenorchestra_vm.vm[count.index].name_description, ".", "-")}-key.pem"
  content  = tls_private_key.kube_kubelet_node_key[count.index].private_key_pem

}

# kube-node
resource "tls_private_key" "kube_node_key" {
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_node_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_node_key.private_key_pem

  subject {
    common_name         = "system:node"
    organizational_unit = "system:nodes"
    organization        = var.certificate_params["organization"]
    locality            = var.certificate_params["locality"]
    province            = var.certificate_params["province"]
    country             = var.certificate_params["country"]
  }
}

resource "tls_locally_signed_cert" "kube_node_cert" {
  cert_request_pem   = tls_cert_request.kube_node_csr.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_node_cert" {
  filename = "files/certificates/kube-node.pem"
  content  = "${tls_locally_signed_cert.kube_node_cert.cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_node_key" {
  filename = "files/certificates/kube-node-key.pem"
  content  = tls_private_key.kube_node_key.private_key_pem

}

# kube-proxy
resource "tls_private_key" "kube_proxy_key" {
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_proxy_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_proxy_key.private_key_pem

  subject {
    common_name  = "system:kube-proxy"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }
}

resource "tls_locally_signed_cert" "kube_proxy_cert" {
  cert_request_pem   = tls_cert_request.kube_proxy_csr.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_proxy_cert" {
  filename = "files/certificates/kube-proxy.pem"
  content  = "${tls_locally_signed_cert.kube_proxy_cert.cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_proxy_key" {
  filename = "files/certificates/kube-proxy-key.pem"
  content  = tls_private_key.kube_proxy_key.private_key_pem

}

# kube-scheduler
resource "tls_private_key" "kube_scheduler_key" {
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_scheduler_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_scheduler_key.private_key_pem

  subject {
    common_name  = "system:kube-scheduler"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }
}

resource "tls_locally_signed_cert" "kube_scheduler_cert" {
  cert_request_pem   = tls_cert_request.kube_scheduler_csr.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_scheduler_cert" {
  filename = "files/certificates/kube-scheduler.pem"
  content  = "${tls_locally_signed_cert.kube_scheduler_cert.cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_scheduler_key" {
  filename = "files/certificates/kube-scheduler-key.pem"
  content  = tls_private_key.kube_scheduler_key.private_key_pem

}

# kube-service-account-token
resource "tls_private_key" "kube_service_account_token_key" {
  algorithm = "RSA"

}

resource "tls_cert_request" "kube_service_account_token_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.kube_service_account_token_key.private_key_pem

  subject {
    common_name  = "k8s.${var.dns_zone}"
    organization = var.certificate_params["organization"]
    locality     = var.certificate_params["locality"]
    province     = var.certificate_params["province"]
    country      = var.certificate_params["country"]
  }
}

resource "tls_locally_signed_cert" "kube_service_account_token_cert" {
  cert_request_pem   = tls_cert_request.kube_service_account_token_csr.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = data.local_file.ca_private_key.content
  ca_cert_pem        = "${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "any_extended"
  ]
}

resource "local_file" "kube_service_account_token_cert" {
  filename = "files/certificates/kube-service-account-token.pem"
  content  = "${tls_locally_signed_cert.kube_service_account_token_cert.cert_pem}${data.local_file.ca_public_cert.content}\n${data.local_file.domain_root_cert.content}"

}

resource "local_file" "kube_service_account_token_key" {
  filename = "files/certificates/kube-service-account-token-key.pem"
  content  = tls_private_key.kube_service_account_token_key.private_key_pem

}