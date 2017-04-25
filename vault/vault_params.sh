#!/bin/bash
export VAULT_ADDR=https://localhost:8200
export VAULT_SKIP_VERIFY=false # skip self-signed certificate validation
export VAULT_CAPATH=`pwd`/certificates/ca/certs/ca.cert.pem
