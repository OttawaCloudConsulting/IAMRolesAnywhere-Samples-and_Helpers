#!/bin/bash

VAR_IAMROLENAME=""
VAR_509CERT=$(openssl x509 -in ../create_cert/rootCA.pem)
VAR_IAMPOLICIES_LIST="ReadOnlyAccess"
VAR_IAMPATH="/automation/"
VAR_IAMROLEDESCRIPTION="IAM Anywhere role for Pipeline"

awscli_command_check () {
  aws rolesanywhere help > /dev/null
  local RESULT="$?"
  if [ $RESULT != 0 ]
  then
    echo "IAM RolesAnywhere command not found. Pleae update AWSLCI to latest version"
  fi
}

create_iam_role () {
  aws iam create-role \
    --path "$VAR_IAMPATH" \
    --role-name "$VAR_IAMROLENAME" \
    --assume-role-policy-document file://custom_trust_policy.json \
    --description "$VAR_IAMROLEDESCRIPTION" \
    --max-session-duration 3600 
}

attach_iam_policies () {
  for policy in "${VAR_IAMPOLICIES_LIST[@]}"; do
    aws iam attach-role-policy \
      --policy-arn arn:aws:iam::aws:policy/$policy \
      --role-name "$VAR_IAMROLENAME"
  done
}

create_rolesanywhere_trust_anchor () {
  aws rolesanywhere create-trust-anchor \
    --name "$VAR_IAMROLENAME-anchor" \
    --enabled \
    --source sourceData={x509CertificateData="$VAR_509CERT"},sourceType=CERTIFICATE_BUNDLE
}

create_rolesanywhere_profile () {
  aws rolesanywhere create-profile \
    --name "$VAR_IAMROLENAME-profile" \
    --role-arns "$ROLE_ARN"
}

echo "Creating IAM Role"
ROLE_ARN=$(create_iam_role | jq --raw-output '.Role.Arn')
echo "Attaching IAM Policies to Role"
attach_iam_policies
echo "Creating RolesAnywhere Trust Anchor"
create_rolesanywhere_trust_anchor
echo "Creating RolesAnywhere Profile"
create_rolesanywhere_profile