module "kube_certs" {
  source = "github.com/coreos/tectonic-installer//modules/tls/kube/self-signed?ref=1.8.9-tectonic.1"

  ca_cert_pem        = "${var.tectonic_ca_cert}"
  ca_key_alg         = "${var.tectonic_ca_key_alg}"
  ca_key_pem         = "${var.tectonic_ca_key}"
  kube_apiserver_url = "https://${module.vnet.api_fqdn}:443"
  service_cidr       = "${var.tectonic_service_cidr}"
  validity_period    = "${var.tectonic_tls_validity_period}"
}

module "etcd_certs" {
  source = "github.com/coreos/tectonic-installer//modules/tls/etcd/signed?ref=1.8.9-tectonic.1"

  etcd_ca_cert_path     = "${var.tectonic_etcd_ca_cert_path}"
  etcd_cert_dns_names   = "${data.template_file.etcd_hostname_list.*.rendered}"
  etcd_client_cert_path = "${var.tectonic_etcd_client_cert_path}"
  etcd_client_key_path  = "${var.tectonic_etcd_client_key_path}"
  self_signed           = "${var.tectonic_self_hosted_etcd != "" ? "true" : length(compact(var.tectonic_etcd_servers)) == 0 ? "true" : "false"}"
  service_cidr          = "${var.tectonic_service_cidr}"
}

module "ingress_certs" {
  source = "github.com/coreos/tectonic-installer//modules/tls/ingress/self-signed?ref=1.8.9-tectonic.1"

  base_address    = "${module.vnet.ingress_fqdn}"
  ca_cert_pem     = "${module.kube_certs.ca_cert_pem}"
  ca_key_alg      = "${module.kube_certs.ca_key_alg}"
  ca_key_pem      = "${module.kube_certs.ca_key_pem}"
  validity_period = "${var.tectonic_tls_validity_period}"
}

module "identity_certs" {
  source = "github.com/coreos/tectonic-installer//modules/tls/identity/self-signed?ref=1.8.9-tectonic.1"

  ca_cert_pem     = "${module.kube_certs.ca_cert_pem}"
  ca_key_alg      = "${module.kube_certs.ca_key_alg}"
  ca_key_pem      = "${module.kube_certs.ca_key_pem}"
  validity_period = "${var.tectonic_tls_validity_period}"
}