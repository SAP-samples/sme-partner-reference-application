# Enabling API access of BTP applications using Service Broker
Service Broker is used to enable remote access to application OData services using tenant specific credentails and authorizations taking into account the tenant isolation in an multi-tenant application.

Service brokers are used to facilitate access to services on runtimes on the SAP Business Technology Platform.

The advent of the SAP Service Manager (SM) brought about the ability to connect multiple platforms and multiple service brokers together on the SAP Business Technology Platform (SAP BTP). Services exposed by brokers on different platforms can be instantiated wherever you need them.

For inbound API calls to BTP application like AuthorReading, it is required to use OAUTH Client credentials to access the the APIs. In addition it is required to determine for which tenant a API is called during the runtime.

The service broker gives the OAuth credentials specifically for a dedicated application and must be deployed for each application. The Application will need to provide the specific configuration for the Broker

## Enabling Service Broker in Provider sub-account of BTP applications

Service Broker in an application involves following steps:

1. Create a Service Broker Node.js application
    - Create a new directory in the project root folder [author-readings-mt](../Applications/author-readings-mt)
    - Run the command:  ` npm init ` in the project root folder

    > Note: You are prompted to answer several questions. Upon completion, this command creates a [package.json](../Applications/author-readings-mt/broker/package.json) file in the current directory. The presence of this file, indicates Cloud Foundry runtime that this is a Node.js application.

2. Add the Service Broker Framework
    - Download the @sap/sbf package and add it to your service broker by executing the command:
    `npm install @sap/sbf`

    > Note: Make sure you execute the aboce commands in the project root folder [author-readings-mt](../Applications/author-readings-mt)

3. Add the service broker start command
    - Edit the [package.json](../Applications/author-readings-mt/broker/package.json) file and add the start command in section scripts:
    ```json
        {
        "scripts": {
            "start": "start-broker"}
        }
    ```

4. Specify a required Node.js version
    - Add the following property in the package.json file to inform Cloud Foundry that the service broker requires Node with specific version
    ```json
        "engines": {
            "node": "^16.17.1"
        }
    ```

5. Create the service catalog
   - Create a file called [catalog.json](../Applications/author-readings-mt/broker/catalog.json) in the current directory and describe in it the service catalog. 
   > Note:  The service catalog describes the services offered by this service broker. It is defined in a JSON format as described in [Cloud Foundry documentation](https://docs.cloudfoundry.org/services/api.html#catalog-management).
   - Sample catalog is given below
   ```json
        {
        "services": [{
            "name": "my-service",
            "description": "A simple service",
            "bindable": true,
            "plans": [{
            "name": "my-plan",
            "description": "The only plan"}]
        }]
        }
    ```
    - Execute the command `npx gen-catalog-ids` to generate unique IDs for the services and their plans in the [catalog.json](../Applications/author-readings-mt/broker/catalog.json) file
    - Sample  [catalog.json](../Applications/author-readings-mt/broker/catalog.json) after generation of ID:
    ```json
        {
            "services": [
                {
                    "name": "authorreadings",
                    "id": "1aac0de3-bc10-42bc-a950-00a9fbec536e",
                    "description": "Author Readings Integration Credentials",
                    "bindable": true,
                    "plans": [
                        {
                        "name": "authorreadingsintegration",
                        "id": "358813f4-6ed2-47e1-90b1-dd9fefda4b1f",
                        "description": "Author Readings Integration Credentials"          
                        }
                    ]                
                }
            ]
        }
    ```
    > Note: Unique *Service ID* and *Service Plan ID* both are generated

6. Create XSUAA service instance
    - The service broker can use different services to generate and store credentials needed later on by applications to access your reusable service. In this example we use the *XSUAA service* as a credentials provider.
    - An *XSUAA service* instance with *service-plan: broker* is configured to be created via configuration in project deployment descriptor file [mta.yaml](../Applications/author-readings-mt/mta.yaml) 
    > Note: Its *"prefferred"* to create XSUAA instance via [mta.yaml](../Applications/author-readings-mt/mta.yaml) deployment descriptor, but XSUAA instance can also be created manually using command `cf create-service xsuaa broker author-readings-uaa`

7. Create an instance of the Audit Log service (Optional Step)
    - The service broker is configured by default to audit log every operation. It needs information to connect to the Audit log service.
    - An *service: auditlog* instance with *service-plan: oauth2* is configured to be created via configuration in project deployment descriptor file [mta.yaml](../Applications/author-readings-mt/mta.yaml) 
    > Note:  Its *"prefferred"* to create AuditLog service instance via [mta.yaml](../Applications/author-readings-mt/mta.yaml) deployment descriptor, but AuditLog service instance can also be created manually using command `cf create-service auditlog oauth2 author-readings-auditlog`

8. Add a authorreadings service API specific role in the xs-security
    - Add the new role *authorreadingsapi* in the [xs-security.json](../Applications/author-readings-mt/xs-security.json) and also add the new role *authorreadingsapi*  to role-templates *AuthorReadingManagerRole* and *AuthorReadingAdminRole*
    - Sample configuration in [xs-security.json](../Applications/author-readings-mt/xs-security.json)
    ```json
    {
        "scopes": [
        {
            "name": "$XSAPPNAME.authorreadingsapi"
        }
        ]
        "role-templates": [
        {
            "name": "AuthorReadingManagerRole",
            "scope-references": [
                "$XSAPPNAME.authorreadingsapi"
            ]
        },
        {
            "name": "AuthorReadingAdminRole",
            "scope-references": [
                "$XSAPPNAME.authorreadingsapi"
            ]
        },
    }
    ```

9.  Generate a secure broker password
    - Execute the command `npx hash-broker-password -b` 
    - The command will generates a random password and hashes it
    - As shown in the next step *"Create an application manifest"*, add the above generated *<BrokerPassword>* with relevant *<BrokerUser>* into the service broker configuration *author-readings-servicebroker* in [mta.yaml](../Applications/author-readings-mt/mta.yaml) 
10. Create an service broker application manifest
    - Add a module in *author-readings-servicebroker* in deployment descriptor [mta.yaml](../Applications/author-readings-mt/mta.yaml) file.
    - Sample configuration :
    ```json
        name: author-readings-servicebroker
        type: nodejs
        path: broker
        parameters:
            disk-quota: 1024M
            memory: 128M
            health-check-timeout: 180    
        requires:
            - name: author-readings-uaa
            - name: srv-api
        build-parameters:
            builder: npm
        properties:
            SBF_CATALOG_SUFFIX: ${space}  # Make the service broker unique in the deployed space
            SBF_ENABLE_AUDITLOG: false
            # TO-DO: Enter service broker user and password 
            #SBF_BROKER_CREDENTIALS: '{ "<BrokerUser>": "<BrokerPassword>" }'           # use command  "npx hash-broker-password -b" and generate a random password and hashes it ( use the plain password in mta.yaml ) 
            SBF_SERVICE_CONFIG: 
                authorreadings:             
                    extend_xssecurity: 
                        per_plan: 
                            authorreadingsintegration: 
                                authorities: 
                                    - "$XSMASTERAPPNAME.authorreadingsapi"
                    extend_credentials:
                        per_plan:
                            authorreadingsintegration:
                                endpoints:
                                    authorreadings: "~{srv-api/srv-url}" # Tenant-specific OData endpoint for remote integrations   


    ```
    - Additional Service Configuration (SBF_SERVICE_CONFIG) is a JSON object that provides additional deploy-time configuration. Usually this is used for configurations which are not known in advance like URLs. Each key in this object should match a service name in the [catalog.json](../Applications/author-readings-mt/broker/catalog.json). Its value should be an object with the following properties:
        - *extend_xssecurity* An object, containing these properties
            - *per_plan* An object where the *authorities* name should match the configuration as in [xs-security.json](../Applications/author-readings-mt/xs-security.json). 
        - *extend_credentials* An object, containing these properties
            - *per_plan* An object where service end points are defined, the service name *authorreadings* should match with the name of the service in [catalog.json](../Applications/author-readings-mt/broker/catalog.json)
    > Note: the service name and plan name in [mta.yaml](../Applications/author-readings-mt/mta.yaml) should match with the configuration in [catalog.json](../Applications/author-readings-mt/broker/catalog.json)

11. Build and Deploy the multi-tenant application to provider BTP sub-account

> Note: In the Next step user will create instance of service broker in subscriber BTP sub-account, as described in [Multi-Tenancy-Provisioning-Service-Broker](../Tutorials/72-Multi-Tenancy-Provisioning-Service-Broker.md)
    


 



