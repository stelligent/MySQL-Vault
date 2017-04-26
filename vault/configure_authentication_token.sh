#!/bin/bash

clear

read -p "$ vault token-create -policy=\"mysql-readonly\"";
vault token-create -policy="mysql-readonly"

read -p ""; clear

read -p "$ vault read mysql/creds/readonly"
vault read mysql/creds/readonly

exit $?
