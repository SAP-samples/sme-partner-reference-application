# Enabling API access of BTP applications using Service Broker
Service brokers are used to facilitate access to services on runtimes on the SAP Business Technology Platform.

The advent of the SAP Service Manager (SM) brought about the ability to connect multiple platforms and multiple service brokers together on the SAP Business Technology Platform (SAP BTP). Services exposed by brokers on different platforms can be instantiated wherever you need them.

For inbound API calls to BTP application like AuthorReading it is required to use OAUTH Client credentials to access the the APIs. In addition it is required to determine for which tenant a API is called during the runtime.

The service broker gives the AOuth credentials specifically for a dedicated application and must be deployed for each application. The Application will need to provide the specific configuration for the Broker

## Using Service Broker in BTP applications

Service Broker in an application involves few steps:

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
    > Note: XSUAA instance can also be created manually using command `cf create-service xsuaa broker xsuaa-broker` , but its prefferred to create XSUAA instance via mta.yaml deployment descriptor.
    

 



