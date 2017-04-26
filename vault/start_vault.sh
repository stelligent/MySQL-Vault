#!/bin/bash
clear

read -p "$ ./generate_ss_certs.sh;"
./generate_ss_certs.sh

read -p ""; clear

read -p "$ nohup consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -bind 127.0.0.1 &"
nohup consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -bind 127.0.0.1 &

read -p ""; clear

read -p "$ vault server -config=vault.conf"
vault server -config=vault.conf

exit $?
