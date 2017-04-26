#!/bin/bash

clear

read -p "$ vault mount mysql"
vault mount mysql

read -p ""; clear

read -p "$ vault write mysql/config/connection connection_url=\"vaultadmin:vaultpass@tcp(127.0.0.1:3306)/\""
vault write mysql/config/connection connection_url="vaultadmin:vaultpass@tcp(127.0.0.1:3306)/"

read -p ""; clear

read -p "$ vault write mysql/roles/readonly sql=\"CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';\""
vault write mysql/roles/readonly sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';"

read -p ""; clear

read -p "$ vault policy-write mysql-readonly mysql-policy.conf"
vault policy-write mysql-readonly mysql-policy.conf

read -p ""; clear

read -p "$ vault read mysql/creds/readonly"
vault read mysql/creds/readonly

exit $?
