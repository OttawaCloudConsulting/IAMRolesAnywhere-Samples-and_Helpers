#!/bin/bash

VAR_FILESTOCLEAN=(rootCA.req root_request.config index rootCA.key root_certificate.config serial.txt 01.pem index.attr rootCA.srl server.csr server.pem server_request.config index.old rootCA.pem serial.txt.old server.key server_cert.config)

for file in "${VAR_FILESTOCLEAN[@]}"; do
  rm "$file"
done

