# IAM RolesAnywhere Examples

- [IAM RolesAnywhere Examples](#iam-rolesanywhere-examples)
  - [Code Coverage](#code-coverage)
  - [Repo Structure](#repo-structure)
    - [AWS CLI](#aws-cli)
    - [Custom Trust Policy | custom_trust_policy.json](#custom-trust-policy--custom_trust_policyjson)
    - [IAM Anywhere deployment script | iam_anywhere.sh](#iam-anywhere-deployment-script--iam_anywheresh)
      - [Variables](#variables)

## Code Coverage 

This repo will include code examples for IAM RolesAnywhere deployment with:

+ OpenSSL Bash Scripts to generate Certificates
+ AWS CLI Deployment Sample
+ ~~AWS CloudFormation Sample~~
+ ~~Terraform AWS Provider Sample~~
+ Bash IAM RolesAnywhere Authentication Sample
+ Sample Sign-In Helper script



## Repo Structure

This repo is created to provide a set of sample code and scripts, that can be copied and repurposed for use within environments, and pipelines.

For this reason, there is no basic "install process", only guidelines for use.

| Directory               | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| aws_cli                 | AWS CLI scripts for creating IAM RolesAnywhere Resources     |
| cloudformation          | AWS Cloudformation Template to create IAM RolesAnywhere Resources |
| create_cert             | Bash script to create Certificates for IAM RolesAnywhere Authentication |
| download_signing_helper | Bash script to dowload Sign-In Helper app                    |
| terraform               | Terraform AWS Provider configuration files to create IAM RolesAnywhere Resources |



### AWS CLI

Q: Why do we include AWS CLI, when our preferred method is using IaC?

A: There are many reasons why we include CLI, but primarily our IaC development process with new (or new to us) API's/Services is to experiment with CLI first, and then create Cloudformation/Terraform templates.  This way our testing is abstracted from potential tooling issues, and coverage from IaC. At times coverage is lacking from IaC, and although CLI does not provide management of deployed resources, it does at least provide a versioned approach with consistant and repeatable use.

### Custom Trust Policy | custom_trust_policy.json

IAM RolesAnywhere requires a custom trust policy to be used. 

For our example, we have added a Condition for StringEquals to ensure our certificate for use contains the `OU:home` as an example of how we can lock down acccess based on certificate content. This example is specific to our test case, is not required, and can be easily customized to meet your requirements.

```json
{
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
```

### IAM Anywhere deployment script | iam_anywhere.sh

This is a simple deployment script, for deployment.  It accepts a small set of variables to generate the requried resources.

#### Variables

| Variables              | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| VAR_IAMROLENAME        | Role-name to be used. This is repurposed with suffixes add for reference in the script |
| VAR_509CERT            | This should contain your rootCA Private Certificate. It should start with the -----BEGIN CERTIFICATE----- statement and end with -----END CERTIFICATE----- |
| VAR_IAMPOLICIES_LIST   | A list of managed IAM Policies to attach to the IAM Role     |
| VAR_IAMPATH            | The path for the role. It must begin and end with a forward slash |
| VAR_IAMROLEDESCRIPTION | A short, friendly desription for the Role. i.e. "Dev Pipeline Role" |



