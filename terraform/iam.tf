# aws iam create-role
resource "aws_iam_role" "this" {
  description           = var.iam.role_description
  max_session_duration  = var.iam.session_duration
  name_prefix           = var.iam.name_prefix
  path                  = var.iam.path
  force_detach_policies = true

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "rolesanywhere.amazonaws.com"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession",
          "sts:SetSourceIdentity"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:PrincipalTag/x509Subject/OU" : "${var.iam.x509Subject_OU}"
          }
        }
      }
    ]
    }
  )
}

# attach_iam_policies
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = var.iam.managed_policy
}

# create_rolesanywhere_trust_anchor
resource "aws_rolesanywhere_trust_anchor" "name" {
  enabled = true
  name    = "${var.iam.name_prefix}-anchor"
  source {
    source_type = "CERTIFICATE_BUNDLE"
    source_data {
      x509_certificate_data = local_file.server_pem.content
    }
  }
}

# create_rolesanywhere_profile
resource "aws_rolesanywhere_profile" "test" {
  name      = "${var.iam.name_prefix}-profile"
  enabled   = true
  role_arns = [aws_iam_role.this.arn]
}