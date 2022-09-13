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

(TODO: more details)

### Configure the Application Subdomain

1. Open the *BTP Cockpit* (provider subaccount), navigate to *Instances and Subscriptions*, and create a subscription for application *Custom Domain Service*, service plan *standard*.

(TODO: Configure domain)

### Setup the Subscription Management Dashboard

*Subscription Management Dashboard* will enable lifecycle management of multi-tenant applications. 

*Pre-requisite*: subscribe and create instance of subscription management service
Steps to follow : Open the *BTP Cockpit* (provider subaccount), navigate to *Instances and Subscriptions*, and create a subscription for application *Subscription Management Dashboard*, service plan *application*.

*Details of Subscription Management Dashboard* : 
The dashboard enables users to view the deployed multi-tenant applications with *status* like In-Process, Subscribed, Subscription Failed, UnSubscription failed, Update Failed and also *filtered by different time periods* like changed in the last 24 hours , changed in the last 7 days, changed in the last month, changed in the last 3 months, changed in the last 6 months and changed in the last 12 months.

Users can perform *Actions* like *unsubscribe*, *update* and track the status of subscription process in progress.

In the Overview section of the subscribed application user can view information like *subscription status*, *global account* , *consumer sub account*, *app name* , *app URL*, *License Type* ( Productive , Test tenant), *changed on* and *created on* details.

In the Dependencies section user could view the service dependencies in the application. There is *tree view* and *table view* of dependencies . the information helps the user to view the full list of dependencies among various services used in the application . for instance the application service module is having dependency on modules like destination, auditlog, html5-app-repo, connectivity services and the overview of the dependencies can be viewed in this section. 

> Note: in case of multi-tenant application with custom Approuter and mtx module being used in the application , make sure to make the destination service as the dependency ( the dependency can be declared by adding the destination service as requires in application deployment descriptor mta.yaml file)

