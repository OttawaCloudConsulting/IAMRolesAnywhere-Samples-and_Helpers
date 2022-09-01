# Terraform IAM RolesAnywhere Deployment

Generates resources:
+ aws_iam_role.this
+ aws_iam_role_policy_attachment.this
+ aws_rolesanywhere_trust_anchor.name
+ aws_rolesanywhere_profile.test

Execution:
+ Create copy of my.tfvars.sample
+ Update your own tfvars values
+ ```terraform plan -var-file="newlycreated.tfvars"```
+ Review your Terraform Plan
+ + ```terraform apply -var-file="newlycreated.tfvars"```