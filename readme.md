###  Obfuscating MySQL passwords with Hashicorp Vault

###  Assumptions
     MySQL, Hashicorp Vault and Consul are installed
     
###  Technical Components
     Backend   : Spring Boot
     Database  : MySQL
     DAO       : Spring JDBCTemplate
     Testing   : JUnit

###  Staging MySQL : create user with privileges to create other users
    $ mysql -uroot -e "CREATE USER 'vaultadmin' IDENTIFIED by 'vaultpass';" -p
    $ mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'vaultadmin'@'%' WITH GRANT OPTION;" -p;

###  Vault Workflow
    Workflow steps for using Vault in production mode.
    
    1. ./start_vault.sh
       This will :
          #Generate server and client certificates for the server on which vault will be running
          #Start consul to serve as vault backend/storage. 
          #Start vault server. 
    
    2. ./init_vault.sh
       This will initialize vault and generate root/master token and unseal keys - save these keys.
       Vault initialization must me performed only once if you;re using a persistent store/backend like consul. 
       If backend in memory("inmem"); vault init must be performed every time vault is started 
    
    3. Unseal vaul. This is performed everytime vault is started
          $ vault unseal key1 [key2, [key3]]
    
    4. Configure secret backend. For each of the "secret backend", we need to do the following
    
       4.1 Use root token or generated a token with root-policy using unseal keys
          $ export VAULT_TOKEN=########################### 
       
       4.2 ./configure_mysql_secretbackend.sh
           This will - 
           configure connection endpoint so that vault can connect to the secret backend
           create role so that vault can create appropriate users/policies inside of the secret backend
           create a policy for mysql user to deny all access to connection endpoints 
           verify that the connection works
    
    5. Creating Authentication for secret backend(mysql developers/users)
    
       5.1 ./configure_authentication_token.sh
           This will create token-authentication which is then distributed to developer community.
           Users can now use the token to connect to mysql. 
           Rotation policies set for the token(step 8.2) will force the refresh of user/pass.
    
        More Info : https://www.hashicorp.com/blog/codifying-vault-policies-and-configuration/
    
###  Compiling and Starting application 
    $ edit src/main/resources/bootstrap.properties. 
      Replace spring.cloud.vault.token=###### with the token created in step 8.2 above
    $ cd vault; source source_env.sh
    $ mvn package;
    $ mvn spring-boot:run
