Obfuscating MySQL passwords with Hashicorp Vault
================================================

1. Staging MySQL data

$ mysql -uroot -e "CREATE USER 'vaultadmin' IDENTIFIED by 'vaultpass';" -p
$ mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'vaultadmin'@'%' WITH GRANT OPTION;" -p;

2. Generate self-signed certificates(for non-prod use only)

$ cd vault; ./generate_ss_certs.sh

3. Modify vault/vault.conf with appropriate cert names

4. Start vault server

$ vault server -config=vault.conf

5. Initialize vault  (IMP: save unseal keys and tokens generated during this step)

$ vault init 

6. Unseal vault 

$vault unseal key1 [key2, key3]

7. Configure backend MySQL
    
    vault mount mysql
    vault write mysql/config/connection connection_url="vaultadmin:vaultpass@tcp(127.0.0.1:3306)/"
    vault write mysql/roles/readonly sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';"
    vault read mysql/creds/readonly
    


