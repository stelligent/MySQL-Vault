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

###  Vault Workflow
    Its important to understand the workflow steps for using Vault in production
    1. Generate server and client certificates for the server on which vault will be running
          $ ./generate_ss_certs.sh

    2. Start consul to serve as vault backend/storage. 
          $ consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -bind 127.0.0.1
    
    3. Start vault server. Options such as consul backend and certificates are need to be provided at this stage. See vault.conf
          $ vault server -config=vault.conf
    
    4. Initialize vault - this will generate root/master token and unseal keys - save these keys.
       Vault initialization must me performed only once if you;re using a persistent store/backend like consul. 
       If backend in memory("inmem"); vault init must be performed every time vault is started 
          $ vault init
    
    5. Unseal vaul. This is performed everytime vault is started
          $ vault unseal key1 [key2, [key3]]
    
    6. At this stage vault is started in encrypted mode, initialized and using consul as backend(persistent storage) 
          $ edit sourceenv.sh and replace VAULT_TOKEN with token generated in step-2;
          $ source source_env.sh
    
    7. Configure secret backend. For each of the "secret backend", we need to do the following
    
       7.1 Use root token or generated a token with root-policy using unseal keys
          $ export VAULT_TOKEN=########################### 
       
       7.2 Mount secret backend
          $ vault mount mysql
       
       7.2 Configure connection endpoint so that vault can connect to the secret backend
          $ vault write mysql/config/connection connection_url="vaultadmin:vaultpass@tcp(127.0.0.1:3306)/"
       
       7.3 Create appropriate role so that upon connection(step 7.2) 
           vault can create appropriate users/policies inside of the secret backend
           $ vault write mysql/roles/readonly sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';\
             GRANT SELECT ON *.* TO '{{name}}'@'%';"
       
       7.4 Verify the connection works
           $ vault read mysql/creds/readonly
    
    8. Creating Authentication for secret backend(mysql developers/users)
    
       8.1 Create a policy for mysql user. 
           This policy must deny all access to connection endpoints created for vault in step 7.2 above. See mysql-policy.conf
           $ vault policy-write mysql-readonly mysql-policy.conf
       
       8.2 Creat authentication mechanism with this policy. 
           In our case we will create token-authentication which is then distributed to developer community.
           $ vault token-create -policy="mysql-readonly"
       
       8.3 verify connection/policy works. Use the new limited privileges token created in step 8.2 above.
           $ export VAULT_TOKEN=########################### 
           $ vault read mysql/creds/readonly
    
    9. Users can now use the token to connect to mysql. 
       Rotation policies set for the token(step 8.2) will force the refresh of user/pass.
    
    10. Shutdown Vault
       10.1 Seal the vault. This will flush all vault data(encrypted) to consul
       10.2 Kill the vault server(if needed). 


        $ edit sourceenv.sh and replace VAULT_TOKEN with token generated in step-2;
        $ source source_env.sh
    
###  Compiling and Starting application 
    $ edit src/main/resources/bootstrap.properties. 
      Replace spring.cloud.vault.token=###### with the token created in step 8.2 above
    $ cd vault; source source_env.sh
    $ mvn package;
    $ mvn spring-boot:run
