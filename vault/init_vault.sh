#!/bin/bash

export VAULT_ADDR="https://localhost:8200"

export VAULT_SKIP_VERIFY=true # skip self-signed certificate validation

vault init

exit $?
