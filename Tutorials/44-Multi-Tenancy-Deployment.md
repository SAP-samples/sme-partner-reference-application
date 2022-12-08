# Deploy the Multi-Tenant Application to a Provider Subaccount 

## Setup BTP Provider Subaccount

BTP Cockpit (Global account): Create a provider subaccount and assign required entitlements.

1. Create a provider subaccount to host the application runtime:
    - Enter a meaningful name, for example "AuthorReadings MT Provider"
    - Enter a subdomain and keep it short because the subdomain is used in the application URL; for example "armt"
    - In our example we used the data center of *Amazon Web Services (AWS)* and the region *Europe (Frankfurt)*. You can reuse the subaccount used for development for convience.
    - Optional: Assign subaccount to a directory as parent.

    > Note: In all following steps and descriptions we will refer to this subaccount as **"provider subaccount"**.

2. Open *Entity Assignments* and assign quotas for the following entities to your provider subaccount: 
    - *Cloud Foundry Runtime* (3 units of Application runtime)
    - *SAP HANA Cloud* (1 unit)
    - *SAP HANA Schemas & HDI Containers* (min. 3 units - for the provider and two tenants)
    - *Authorization and Trust Management Service*, service plan *broker* (1 unit)
    - *Auditlog Service*, service plan *oauth2* (1 unit)
    - *Custom Domain Service*, service plan *standard (Application)* (1 unit)

    > Note: Contact SAP if no sufficient service entitlements are available in your global account.

Relevant entity assigments defaulted at subaccount creation (no action required):
- *Service Manager*, service plan *container*
- *Destination Service*, service plan *lite*
- *SaaS Provisioning Service*, service plan *application*
- *HTML5 Application Repository Service*, service plans *app-runtime* and *app-host*

### Maintain Provider Subaccount Administrators

BTP Cockpit (provider subaccount): Maintain application administrators.

1. Open menu item *Security - Users* and enter users that should take over the role of subaccount administrators. 

### Enable Cloud Foundry 

BTP Cockpit (provider subaccount): Create a Cloud Foundry space to host the database and the runtime.

1. Open the subaccount *Overview* and enable Cloud Foundry:
    - Plan: *standard*
    - Landscape: *cf-eu10*
    - Instance Name: "armt"
    - Org Name: "armt"

2. Create Space with space name "runtime"
    - keep standard roles
    - Add CF Org members
    - Add CF space members

> Note: While choosing the technical names, keep in mind that the application URL will be composed of the application name, the org name, the space name and the domain. Therefore, try to keep it short, unique and avoid duplicate URL components.

### Create a HANA database

BTP Cockpit (provider subaccount):

1. Open the Cloud Foundry space, navigate to menu item *SAP HANA Cloud* and create an SAP HANA Database: 
    - Choose CF Organization + Space
    - Instance Name: "authorreadings-db"
    - Enter a password
    - Save

### Deploy the Multi-Tenant Application

1. npm install
2. build
3. deploy

Build and deploy your application:

1. Open a new terminal and login to cloud foundry: Run command `cf login`, enter your development user/password and select the BTP provider subaccount for the application.

2. Navigate to the sub-folder with the sample application using command `cd Applications/author-readings-mt`.

3. Run command `npm install` to install the messaging npm packages.

4. Build the project by selecting `Build MTA Project` in the context menu of file `mta.yaml`. 

5. Deploy the application by selecting `Deploy MTA Archive` in the context menu of file `./mta_archives/author-readings_1.0.0.mtar`.

> Note: The first deployment of the application creates instances of BTP services in the provider subaccount , navigate to BTP provider subaccount and view the created services.

### Configure the Application Subdomain (Custom Domain)

*Custom Domain* :
The SAP Custom Domain service lets you configure your own custom domain to publicly expose your application.
With the SAP Custom Domain Service you can configure subdomains for your application and you have the possibility to expose your application using your own company specific domain. In our example we are using default domain provided by SAP and use the Custom Domain Service to configure the subdomains used by our multi-tenant application. 

*Pre-requisite*: subscribe and create instance of custom domain service.

*Details of Custom Domain Service*: 
1. Entitle to the Custom Domain Service:
    - Create entitlement for Custom Domain Manager in the SAP BTP Control Center ( Custom Domain Service  |   custom-domain-manager )
    - select the Custom Domain Service as applications, select standard as the plan.
    
2. Create an instance of Custom Domain Service in provier BTP subaccount
    - In the Provider BTP subaccount navigate to  *Entitlements* -> *Entity Assignments* ->  select standard ( Application ) -> *Save* the changes 
    - Goto to *Service* -> *Service Market Place* -> select Custom Domain Services -> click on *Create* -> select service *Custom Domain service* and plan *standard*
    - Goto to *Security* -> *Role collection* -> create new role collection "custom domain manager" -> *Edit* the new role collection -> chose the new role name "customDomainAdmin" -> *Save* 
    - Goto *Users* -> assign new role collection "custom domain manager" to existing users 

3. Create an Custom Domain
    - Goto *Service* -> *Instances and Subscriptions* -> click on *Subscriptions* -> select application "Custom Domain service" to launch the domain service to create new custom domain along with server certificate
    - Launch the *Server Certificates* application (manage server certificate) and create a server certificate for multi-tenant application by the following steps:
        - In the General Information section enter the *Alias* and select the *Key Size* and click on *Next Step*
        - In the Select Landscape section,  please select the desired landscape to continue and click on *Next Step*  . Note: the landscape refers to the cloud foundry instance.
        - In the *Select Alternative Names* section select the entry with wildcard and click on *Next Step* . Note the sample entry looks like *.{alias name}.{cloud foundry endpoint}
        - In the *Set Subject* section enter the Common Name (CN) *.{alias name}.{cloud foundry endpoint} and click on *Finish* 
        - The above steps will initiate the creation of Certificate Signing Request (CSR) and the status would be *CSR in progress* 
        - Once the server certificate status is changed to *CSR created* ( status change would take few seconds to a minute)
        - Open the server certificate, note the Automation is set to *disabled*, it would be recommended to set the Automated Certificate Lifecycle Management is set to *Automated*
        - Click on the button *Automate* to enable Automated Certificate Lifecycle Management. Note: automation will enable the certificate to be created using DigiCert as certificate provider and as long as automation is enabled , the certificate will be automatically renewed before the expiration date
        - After clicking on the *Atomate* button , in the enable automation popup ui , click on the button *Enable* . Note: the automation process would start, the message *automation process in progress, this may take few hours* , but ideally the automation takes few minutes
        
        > Note: the Automation would be set to enabled and Status is *Inactive* ,  **user have to activate the certificate**

        - To activate the server certificate click on the *Activate* button
        - Activation is a multi step process
            - In the first step *Subject Alternative Names* select the entry with wildcard *.{alias name}.{cloud foundry endpoint} and click on *Next step*
            - In the second step *Select TLS Configuration* select the entry *Default_without_Client_authentication* and click on *Next step*
            - In the *Summary and confirmation* step , review the configuration and click on *Finish* button
        > Note: the status of the server certificate would be set to *In Progress* and the **process might take few seconds to a minutes**
        - Once the above process is complete the status of the server certificate would change to *Active*
    - In result after performing above steps related to *Server Certificates* would create an *Custom Domain* with status *Active*  
    - Goto the *Domains* application (manage reserved and custom doamins), navigate to **Custom Domains**, user should view a custom domain with name {alias name}.{cloud foundry endpoint} and with  **active** status
    > Note: sample custom domain would look like armt-runtime.{cloud foundry endpoint}
    

### Setup the Subscription Management Dashboard

The *Subscription Management Dashboard* supports the lifecycle management of multi-tenant applications. 

The *Subscription Management Dashboard* is available as application in your provider subaccount (*BTP Cockpit - Instances and Subscriptions*) after deployment of the multi-tenant application.

Capabilities of the *Subscription Management Dashboard*: 
- The dashboard enables application providers to review the deployment of multi-tenant applications including the application- and subscription status and the change history respectively subscription history.
- Application providers can perform subscription actions like *unsubscribe* and *update*, and track the status of subscriptions in progress.
- In the overview section of the subscribed application, application owners can review information like the *Subscription status*, *Global accounts*, *Consumer subaccounts*, *Application name*, *Application URL*, *License Type* (Productive, Test tenant), *changed on* and *created on* details.
- In the *Dependencies*-section application providers can review the service dependencies of the application. There is a tree view and a table view of dependencies. The information helps the user to view the full list of dependencies among various services used in the application. It outlines for example the dependencies between the application service module and modules for destinations, audit log, html5 application repository, connectivity services. 

> Note: Make sure to add the destination service as the dependency, if your multi-tenant application is using a custom application router along with the mtx module (the dependency can be added and declared by adding the destination service as requires-property in the application deployment descriptor mta.yaml file).
