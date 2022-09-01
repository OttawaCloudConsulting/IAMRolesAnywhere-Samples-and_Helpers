output "trust_anchor_arn" {
  value = aws_rolesanywhere_trust_anchor.name.arn
}

output "trust_profile_arn" {
  value = aws_rolesanywhere_profile.test.arn
}

output "iam_role" {
  value = aws_iam_role.this.arn
}