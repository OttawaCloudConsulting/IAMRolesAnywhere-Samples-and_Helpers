#!/bin/bash
## source: https://medium.com/cyberark-engineering/calling-aws-services-from-your-on-premises-servers-using-iam-roles-anywhere-3e335ed648be

################
## Variables  ##
################

VAR_PREREQ_SOFTWARE=(openssl)
VAR_CERT_COUNTRYNAME=""
VAR_CERT_STATEPROVINCE=""
VAR_CERT_LOCALITY=""
VAR_CERT_ORGNAME=""
VAR_CERT_OU=""
VAR_CERT_COMMONNAME=""
VAR_CERT_CN=""
VAR_CERT_OU2="home"

################
## Functions  ##
################

test_pause () {
read -n 1 -r -s -p $'Press enter to continue...\n'
}

software_presence () {
  which "$1" > /dev/null
  local VAR_RESULT=$?
  if [ $VAR_RESULT -eq 0 ]
  then
    echo "Package $1 present"
  else
    echo "Package $1 not present"
    install_package "$1"
    # exit 1
  fi
}
haveProg() {
  [ -x "$(which "$1")" ]
  }

install_package () {
    if haveProg apt-get ; then apt-get -y install "$1"
    elif haveProg yum ; then sudo yum -y install "$1"
    elif haveProg brew ; then brew install "$1"
    else
        echo 'No package manager found!'
        exit 2
    fi
}

software_check () {
  for req in "${VAR_PREREQ_SOFTWARE[@]}"; do
    software_presence "$req"
  done
  echo "Script completed with SUCCESS"
}

generate_certificate_authority_key (){
  openssl ecparam \
    -genkey \
    -name secp384r1 \
    -out rootCA.key
}

create_csr_config () {
  cat > root_request.config << EOF
[req]
prompt             = no
string_mask        = default
distinguished_name = req_dn

[req_dn]
countryName = "$VAR_CERT_COUNTRYNAME"
stateOrProvinceName = "$VAR_CERT_STATEPROVINCE"
localityName = "$VAR_CERT_LOCALITY"
organizationName = "$VAR_CERT_ORGNAME"
organizationalUnitName = "$VAR_CERT_OU"
commonName = "$VAR_CERT_COMMONNAME"
EOF
}

create_csr_for_ca_cert () {
  openssl req \
    -new \
    -key rootCA.key \
    -out rootCA.req \
    -nodes \
    -config root_request.config
}

create_database_and_serial_files () {
  touch index
  echo 01 > serial.txt
}

create_ca_certificate_config_file () {
  cat > root_certificate.config << 'EOF'
# This is used with the 'openssl ca' command to sign a request

[ca]
default_ca = CA

[CA]
# Where OpenSSL stores information
dir             = .
certs           = $dir
crldir          = $dir

new_certs_dir   = $certs
database        = $dir/index
certificate     = $certs/rootcrt.pem
private_key     = $dir/rootprivkey.pem
crl             = $crldir/crl.pem   
serial          = $dir/serial.txt
RANDFILE        = $dir/.rand

# How OpenSSL will display certificate after signing
name_opt    = ca_default
cert_opt    = ca_default

# How long the CA certificate is valid for
default_days = 3650

# The message digest for self-signing the certificate
default_md = sha256

# Subjects don't have to be unique in this CA's database
unique_subject    = no

# What to do with CSR extensions
copy_extensions    = copy

# Rules on mandatory or optional DN components
policy      = simple_policy

# Extensions added while singing with the `openssl ca` command
x509_extensions = x509_ext

[simple_policy]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = optional
domainComponent         = optional
emailAddress            = optional
name                    = optional
surname                 = optional
givenName               = optional
dnQualifier             = optional

[ x509_ext ]
# These extensions are for a CA certificate
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always

basicConstraints            = critical, CA:TRUE

keyUsage = critical, keyCertSign, cRLSign, digitalSignature
EOF
}

create_ca_certificate () {
  openssl ca \
    -batch \
    -out rootCA.pem \
    -keyfile rootCA.key \
    -selfsign \
    -config root_certificate.config  \
    -in rootCA.req
}

examine_ca_certificate () {
  openssl x509 \
    -noout \
    -text \
    -in rootCA.pem
}

create_client_key () {
  openssl ecparam \
    -genkey \
    -name secp384r1 \
    -out server.key
}

create_client_csr_config_file () {
  cat > server_request.config <<EOF
[ req ]
prompt = no
distinguished_name = dn

[ dn ]
C = $VAR_CERT_COUNTRYNAME
ST = $VAR_CERT_STATEPROVINCE
O = $VAR_CERT_ORGNAME
CN = $VAR_CERT_CN
OU = $VAR_CERT_OU2
EOF
}

create_client_csr () {
  openssl req \
    -new \
    -sha512 \
    -nodes \
    -key server.key \
    -out server.csr \
    -config server_request.config
}

create_client_certificate_config_file () {
  cat > server_cert.config <<'EOF'
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
EOF
}

create_ca_signed_client_certificate () {
  openssl x509 \
    -req \
    -sha512 \
    -days 365 \
    -in server.csr \
    -CA rootCA.pem \
    -CAkey rootCA.key \
    -CAcreateserial \
    -out server.pem \
    -extfile server_cert.config
}

verify_client_certificate () {
  openssl verify \
    -verbose \
    -CAfile rootCA.pem server.pem
}

################
## Executions ##
################

## "Checking for openssl"
software_check
## "Generate certificate authority key"
generate_certificate_authority_key
## "Create CSR Config"
create_csr_config
##  "Create CSR for CA Certificate"
create_csr_for_ca_cert
##  "Create database and serial files"
create_database_and_serial_files
##  "Create CA Certificate Config file"
create_ca_certificate_config_file
##  "Create CA Certificate"
create_ca_certificate
##  "Examine CA Certificate"
examine_ca_certificate
##  "Create Client Key"
create_client_key
##  "Create Client CSR Config File"
create_client_csr_config_file
##  "Create Client CSR"
create_client_csr
##  "Create Client Certificate Config File"
create_client_certificate_config_file
##  "Create CA Signed Client Certificate"
create_ca_signed_client_certificate
##  "Verify Client Certificate"
verify_client_certificate