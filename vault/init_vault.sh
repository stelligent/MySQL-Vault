#!/bin/bash

source vault_params.sh

read -p "$ vault init -key-shares=1 -key-threshold=1"
vault init -key-shares=1 -key-threshold=1

exit $?
