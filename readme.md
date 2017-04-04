###  Obfuscating MySQL passwords with Hashicorp Vault

###  Assumptions
     MySQL and Hashicorp Vaul is installed
     
###  Technical Components
     Backend   : Spring Boot
     Database  : MySQL
     DAO       : Spring JDBCTemplate
     Testing   : JUnit

###  Staging MySQL : create user with privileges to create other users
    $ mysql -uroot -e "CREATE USER 'vaultadmin' IDENTIFIED by 'vaultpass';" -p
    $ mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'vaultadmin'@'%' WITH GRANT OPTION;" -p;

###  Completing Vault pre-reqs
    1. generate self-signed certificates(non-prod use only; for prod use CA certs)
       $ cd vault; ./generate_ss_certs.sh
    2. modify vault/vault.conf with appropriate cert names generates in previous step

###  Starting and Initializing Vault
    1. starting vault
        $cd vault; $ vault server -config=vault.conf
    2. initializing vault (IMP: save unseal keys and tokens generated during this step)
        $cd vault; $ vault init
    3. unseal vault 
        $cd vault; $ vault unseal key1 [key2, key3]
    4. (IMP)edit and source vault params 
        $cd vault;
        $edit sourceenv.sh and replace VAULT_TOKEN with token generated in step-2;
        $source source_env.sh

###  Configuring MySQL Secrect backend in Vault
    1. mount mysql backend
        $ vault mount mysql
    2. configure mysql backend
        $ vault write mysql/config/connection connection_url="vaultadmin:vaultpass@tcp(127.0.0.1:3306)/"
    3. create role
        $ vault write mysql/roles/readonly sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';"
    4. verify role
        $ vault read mysql/creds/readonly
    
###  Compiling and Starting application 
    $ cd vault; source source_env.sh
    $ mvn package;
    $ mvn spring-boot:run
