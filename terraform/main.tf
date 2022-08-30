# aws iam create-role
resource "aws_iam_role" "this" {
  description = "IAM Anywhere Sample Role"
  max_session_duration = 3600
  name_prefix = "my-AnywhereRole"
  path = "/opsrole/"
  force_detach_policies = true

  assume_role_policy = jsonencpde({
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "Service": "rolesanywhere.amazonaws.com"
          },
          "Action": [
              "sts:AssumeRole",
              "sts:TagSession",
              "sts:SetSourceIdentity"
          ],
          "Condition": {
              "StringEquals": {
                  "aws:PrincipalTag/x509Subject/OU": "home"
              }
          }
      }
    ]
  }
  )
}

# attach_iam_policies
resource "aws_iam_role_policy_attachment" "this" {
  role = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# create_rolesanywhere_trust_anchor
resource "aws_rolesanywhere_trust_anchor" "name" {
  enabled = true
  name = "my-AnywhereRole-anchor"
  source {
    source_type = "CERTIFICATE_BUNDLE"
    source_data {
      x509_certificate_data = 
    }
  }
}

# create_rolesanywhere_profile

