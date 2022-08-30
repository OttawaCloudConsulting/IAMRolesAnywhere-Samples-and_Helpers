#!/bin/bash

VAR_HELPER_LINUX="https://s3.amazonaws.com/roles-anywhere-credential-helper/CredentialHelper/latest/linux_amd64/aws_signing_helper"
VAR_HELPER_DARWIN="https://s3.amazonaws.com/roles-anywhere-credential-helper/CredentialHelper/latest/darwin_amd64/aws_signing_helper"

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "$machine"

if [ "$machine" == "Mac" ]
then
  curl -L $VAR_HELPER_DARWIN --output aws_signing_helper 
  chmod +x ./aws_signing_helper
  VERSION=$(./aws_signing_helper version)
  echo "Installed AWS IAM RolesAnywhere Sign-In Helper version $VERSION"
elif [ "$machine" == "Linux" ]
then 
  curl -L $VAR_HELPER_LINUX --output aws_signing_helper 
  chmod +x ./aws_signing_helper
  VERSION=$(./aws_signing_helper version)
  echo "Installed AWS IAM RolesAnywhere Sign-In Helper version $VERSION"
else 
  echo "Unsupported OS"
  exit 1
fi
