resource "tls_private_key" "rootCA_key" {
  algorithm   = var.tls.algorithm
  ecdsa_curve = var.tls.ecdsa_curve
}

resource "tls_cert_request" "rootCA_req" {
  private_key_pem = tls_private_key.rootCA_key.private_key_pem
  subject {
    common_name         = var.tls.common_name
    country             = var.tls.country
    locality            = var.tls.locality
    organization        = var.tls.organization
    organizational_unit = var.tls.organizational_unit
    province            = var.tls.province
  }
}

resource "tls_self_signed_cert" "rootCA_pem" {
  private_key_pem       = tls_private_key.rootCA_key.private_key_pem
  is_ca_certificate     = true
  set_authority_key_id  = true
  set_subject_key_id    = true
  validity_period_hours = var.tls.validity_period_hours
  subject {
    common_name         = var.tls.common_name
    country             = var.tls.country
    locality            = var.tls.locality
    organization        = var.tls.organization
    organizational_unit = var.tls.organizational_unit
    province            = var.tls.province
  }
  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "crl_signing"
  ]
}

resource "local_file" "rootca_pem" {
  content  = tls_self_signed_cert.rootCA_pem.cert_pem
  filename = "${path.module}/rootCA.pem"
}

# 8. Create the client key:
# openssl ecparam -genkey -name secp384r1 -out server.key

resource "tls_private_key" "server_key" {
  algorithm   = var.tls.algorithm
  ecdsa_curve = var.tls.ecdsa_curve
}

# 10. Create the client CSR:
# openssl req -new -sha512 -nodes -key server.key -out server.csr -config server_request.config
resource "tls_cert_request" "server_csr" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name         = "Acme.com"
    country             = "US"
    organization        = "Acme Inc."
    organizational_unit = "Innovation"
  }
}

# 12. Create the CA signed client certificate: + create server.pem output file
# openssl x509 -req -sha512 -days 365 -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.pem -extfile server_cert.config
resource "tls_locally_signed_cert" "server_pem" {
  cert_request_pem   = tls_cert_request.server_csr.cert_request_pem
  ca_private_key_pem = tls_self_signed_cert.rootCA_pem.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.rootCA_pem.cert_pem
  #tls_cert_request.server_csr.private_key_pem

  validity_period_hours = var.tls.validity_period_hours

  allowed_uses = [
    "digital_signature"
  ]
}

resource "local_file" "server_pem" {
  content  = tls_locally_signed_cert.server_pem.ca_cert_pem
  filename = "${path.module}/server.pem"
}

resource "local_file" "server_key" {
  content  = tls_private_key.server_key.private_key_pem
  filename = "${path.module}/server.key"
}