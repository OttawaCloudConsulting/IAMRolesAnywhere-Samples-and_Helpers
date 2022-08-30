resource "tls_private_key" "authority_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "ca_cert" {
  private_key_pem = tls_private_key.authority_key.private_key_pem
  subject {
    country             = "CA"
    province            = "Ontario"
    locality            = "Ottawa"
    organization        = "My Company Inc"
    organizational_unit = "home"
    common_name         = "example.com"
  }
}

# resource "tls_locally_signed_cert" "this" {
#   # cert_request_pem   = tls_cert_request.this.cert_request_pem
#   # ca_private_key_pem = tls_cert_request.this.private_key_pem
#   ca_cert_pem        = tls_cert_request.this.

#   validity_period_hours = 26280
#   is_ca_certificate     = true
#   allowed_uses = [
#     "cert_signing",
#     "crl_signing",
#     "digital_signature"
#   ]
# }

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem       = tls_cert_request.ca_cert.private_key_pem
  validity_period_hours = 26280
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature"
  ]
  subject {
    country             = "CA"
    province            = "Ontario"
    locality            = "Ottawa"
    organization        = "My Company Inc"
    organizational_unit = "home"
    common_name         = "example.com"
  }
}

# output to server.key
resource "tls_private_key" "client_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "client_cert" {
  private_key_pem = tls_private_key.client_key.private_key_pem
  subject {
    country             = "CA"
    province            = "Ontario"
    locality            = "Ottawa"
    organization        = "My Company Inc"
    organizational_unit = "home"
    common_name         = "example.com"
  }
}

# output to server.pem
resource "tls_locally_signed_cert" "client_cert" {
  cert_request_pem   = tls_cert_request.client_cert.cert_request_pem
  ca_private_key_pem = tls_private_key.authority_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 26280

  allowed_uses = [
    "digital_signature"
  ]
}

# output "server_key" {
#   value = tls_private_key.client_key.public_key_pem
# }

# output "server_pem" {
#   value = tls_locally_signed_cert.client_cert.cert_pem
# }

resource "local_file" "server_key" {
  content  = tls_private_key.client_key.public_key_pem
  filename = "${path.module}/server.key"
}

resource "local_file" "server_pem" {
  content  = tls_private_key.client_key.public_key_pem
  filename = "${path.module}/server.pem"
}

resource "local_file" "rootca_pem" {
  content = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.module}/rootCA.pem"
}