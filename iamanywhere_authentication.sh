#!/bin/bash

VAR_TRUST_ANCHOR_ARN=""
VAR_PROFILE_ARN=""
VAR_ROLE_ARN=""

get-credentials () {
  ./aws_signing_helper credential-process \
    --certificate ./terraform/server.pem --private-key ./terraform/server.key \
    --trust-anchor-arn "$VAR_TRUST_ANCHOR_ARN" \
    --profile-arn "$VAR_PROFILE_ARN" \
    --role-arn "$VAR_ROLE_ARN"
}

echo-credentials () {
  echo "AWS_ACCESS_KEY_ID=$(echo "$1"| jq '.AccessKeyId' | sed  's/"//g')"
  echo "AWS_SECRET_ACCESS_KEY=$(echo "$1"| jq '.SecretAccessKey' | sed  's/"//g')"
  echo "AWS_SESSION_TOKEN=$(echo "$1"| jq '.SessionToken' | sed  's/"//g')"
}

export-credentials () {
  AWS_ACCESS_KEY_ID=$(echo "$1"| jq '.AccessKeyId' | sed  's/"//g') 
  AWS_SECRET_ACCESS_KEY=$(echo "$1"| jq '.SecretAccessKey' | sed  's/"//g')
  AWS_SESSION_TOKEN=$(echo "$1"| jq '.SessionToken' | sed  's/"//g')
  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN
}

ROLEJSON=$(get-credentials)
echo-credentials "$ROLEJSON"
# export-credentials "$ROLEJSON"
