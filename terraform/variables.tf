variable "iam" {
  description = "IAM variables"
  type = object({
    role_description = string
    session_duration = number
    name_prefix      = string
    path             = string
    x509Subject_OU   = string
    managed_policy   = string
  })
  sensitive = true
}

variable "tls" {
  description = "tls variables"
  type = object({
    algorithm             = string
    ecdsa_curve           = string
    common_name           = string
    country               = string
    locality              = string
    organization          = string
    organizational_unit   = string
    province              = string
    validity_period_hours = number
  })
  sensitive = true
}