# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "ca" {
  algorithm   = var.tls.algorithm
  ecdsa_curve = var.tls.ecdsa_curve
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  key_algorithm     = tls_private_key.ca.algorithm
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
# Store the CA public key in a file.
resource "local_file" "rootca_pem" {
  content  = tls_self_signed_cert.ca.cert_pem
  filename = "${path.module}/rootCA.pem"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A TLS CERTIFICATE SIGNED USING THE CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "cert" {
  algorithm   = var.tls.algorithm
  ecdsa_curve = var.tls.ecdsa_curve
}

resource "local_file" "server_key" {
  content  = tls_private_key.cert.private_key_pem
  filename = "${path.module}/server.key"
}

resource "tls_cert_request" "cert" {
  key_algorithm   = "tls_private_key.cert.algorithm
  private_key_pem = "tls_private_key.cert.private_key_pem

  subject {
    common_name         = var.tls.common_name
    country             = var.tls.country
    locality            = var.tls.locality
    organization        = var.tls.organization
    organizational_unit = var.tls.organizational_unit
    province            = var.tls.province
  }
}

resource "tls_locally_signed_cert" "cert" {
  cert_request_pem = tls_cert_request.cert.cert_request_pem

  ca_key_algorithm   = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.tls.validity_period_hours
  allowed_uses = [
    "digital_signature"
  ]
}
}

resource "local_file" "server_pem" {
  content  = tls_locally_signed_cert.cert.cert_pem
  filename = "${path.module}/server.pem"
}