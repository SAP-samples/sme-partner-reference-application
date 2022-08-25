# Deploy the Multi-Tenant Application to a Provider Subaccount 

## Setup BTP Provider Subaccount

BTP Cockpit (Global account): Create a provider subaccount and assign required entitlements.

1. Create a provider subaccount to host the application runtime:
    - Enter a meaningful name, for example "AuthorReadings MT Provider"
    - Enter a subdomain and keep it short because the subdomain is used in the application URL; for example "armt"
    - In our example we used the data center of *Amazon Web Services (AWS)* and the region *Europe (Frankfurt)*). You can reuse the subaccount used for development for convience.
    - Optional: Assign subaccount to a directory as parent.

    > Note: In all following steps and descriptions we will refer to this subaccount as **"provider subaccount"**.

2. Open *Entity Assignments* and assign quotas for the following entities to your provider subaccount: 
    - *Cloud Foundry Runtime* (3 units of Application runtime)
    - *SAP HANA Cloud* (1 unit)
    - *SAP HANA Schemas & HDI Containers* (min. 3 units - for the provider and two tenants)
    - *Authorization and Trust Management Service*, service plan *broker* (1 unit)
    - *Auditlog Service*, service plan *oauth2* (1 unit)
    - *Audit Log Viewer Service*, service plan *default (Application)* (1 unit)

    > Note: Contact SAP if no sufficient service entotlements are available in your global account.

Relevant entity assigments defaulted at subaccount creation (no action required):
- *Service Manager*, service plan *container*
- *Destination Service*, service plan *lite*
- *SaaS Provisioning Service*, service plan *application*
- *HTML5 Application Repository Service*, service plans *app-runtime* and *app-host*

### Maintain Provider Subaccount Administrators

BTP Cockpit (provider subaccount): Maintain application administrators.

1. Open menu item *Security - Users* and enter users that should toke over the role of subaccount administrators. 

### Enable Cloud Foundry 

BTP Cockpit (provider subaccount): Create a Cloud Foundry space to host the database and the runtime.

1. Open the subaccount *Overview* and enable Cloud Foundry:
    - Plan: *standard*
    - Landscape: *cf-eu10*
    - Instance Name: *armt*
    - Org Name: *armt*

2. Create Space with space name *runtime*
    - keep standard roles
    - Add CF Org members
    - Add CF space members

> Note: While choosing the technical names, keep in mind that the application URL will be composed of the application name, the org name, the space name and the domain. Therefore, try to keep it short, unique and avoid duplicate URL components.

### Create a HANA database

BTP Cockpit (provider subaccount):

1. Open the Cloud Foundry space, navigate to menu item *SAP HANA Cloud* and create an SAP HANA Database: 
    - Choose CF Organization + Space
    - Instance Name: *authorreadings-db*
    - Enter a password
    - Save

### Deploy the Multi-Tenant Application

1. npm install
2. build
3. deploy
