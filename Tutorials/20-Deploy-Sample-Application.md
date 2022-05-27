# Deploy the Sample Application in a Customer BTP Account

This tutorial guides you through the steps to deploy and configure the sample application in a dedicated BTP subaccount, representing an end-to-end provisioning process of a single-tenant partner application in a customer BTP account.

You can use the sample application `author-readings` provided in this Github repository, or your own version of the sample application that you created following the tutorial "*Build a full-stack BTP Application with One-off Deployment in a Customer BTP Account*".

## Setup BTP Subaccount

In this chapter we start the tutorial by setting up a BTP provider subaccount. 

We use this subaccount to host the *SAP Business Application Studio* (BAS), which we are using to clone and deploy the sample app (in real life you may have a development subaccount for this purpose, but we are using the same subaccount for simplicity), and to host the sample application runtime.

1. Open the *BTP Cockpit* and create a new *Multi-Environment*-Subaccount with name "*AuthorReadings*" and provider *Amazon Web Services (AWS)*.

2. BTP Cockpit (global account level): Assign the following entities to the subaccount:
    - *SAP Business Application Studio* (BAS), service plan *standard-edition (Application)* 
    - *Cloud Foundry Runtime* (3 units)
    - *SAP HANA Cloud*
    - *SAP HANA Schemas & HDI Containers*
    - *Launchpad Service*, service plan *standard (Application)*
    - *SAP Event Mesh*, service plan *Default*
    - *SAP Event Mesh*, service plan *Standard (Application)*
    - *Auditlog Service*, service plan *standard*
    - *Audit Log Viewer Service*, service plan *default (Application)*

3. BTP Cockpit (subaccount level): Enable Cloud Foundry using the proposed standard settings and:

    | Property       | Value                              |
    | :------------- | :--------------------------------- |
    | Environment:   | Cloud Foundry Runtime              |
    | Plan:          | *standard*                         |
    | Landscape:     | choose an appropiate AWS landscape |
    | Instance Name: | *authorreadings*                   |
    | Org Name:      | *authorreadings*                   |

4. BTP Cockpit (subaccount level): Create a Cloud Foundry space with name `runtime`. Keep standard roles and add the development user as CF org member and as CF space member. 

5. BTP Cockpit (subaccount level): Open the CF space and create a HANA database:
    - Choose CF Organization + Space
    - Instance Name: `authorreadings-db`

6. BTP Cockpit (subaccount level): Navigate to the *Service Marketplace* and subscribe/create instances of the following entities: 
    - *SAP Business Application Studio*, service plan *standard-edition (Application)*
    - *Event Mesh*, service plan *Standard (Application)*.
    - *Launchpad Service*, service plan *standard (Application)*

7. BTP Cockpit (subaccount level): Navigate to the *Security* > *Users* and assign the following role collections to the development user:
    - All 3 roles of *SAP Business Application Studio*
    - All role collections refering to the Event Mesh and Enterprise Messaging respectively
    - Role collection *Launchpad_Admin*
    - Role collection *AuditLog*

## Clone and deploy the Sample Application

BTP Cockpit (subaccount level): Navigate to *Instances and Subscriptions*, open the *SAP Business Application Studio* and create a new *Dev Space* with kind *Full Stack Cloud Application*.

Start and open the BAS dev space and use the tile "*Clone from Git*" on the *Welcome*-view to clone this GitHub repository (https://github.com/SAP-samples/sme-partner-reference-application).

Build and deploy your application:

1. Open a new terminal and login to cloud foundry: Run command `cf login`, enter your development user/password and select the BTP provider subaccount for the application.

2. Navigate to the sub-folder with the sample application using command `cd Applications/author-readings`.

3. Run command `npm install` to install the messaging npm packages.

4. Build the project by selecting `Build MTA Project` in the context menu of file `mta.yaml`. 

5. Deploy the application by selecting `Deploy MTA Archive` in the context menu of file `./mta_archives/author-readings_1.0.0.mtar`.

Observe, that the message client `authorreadings` is now available in the event mesh application.

> Note: The first deployment of the application with the event mesh creates event mesh artifacts (message client, queue and service instance) and may take some time (very likely more than 10 minutes).

## Configure the Event Mesh

Create and configure the message client for outbound messages of the BTP app as described in chapter [Configure the message client for outbound messages](05-ByD-Event-Integration.md#configure-the-message-client-for-outbound-messages).

Create and configure the message client for ByD as described in chapter [Create the message client for ByD](05-ByD-Event-Integration.md#create-the-message-client-for-byd).

Configure ByD to emit event notifications for projects as described in chapter [Configure ByD to emit event notifications for projects](05-ByD-Event-Integration.md#configure-byd-to-emit-event-notifications-for-projects).

## Configure the Launchpad

Create and configure a launchpad site as described in chapter [Configure the Launchpad](03-One-Off-Deployment.md#configure-the-launchpad).

> Note: The launchpad service has already been subscribed in chapter "*Setup BTP Subaccount*".

## Configure Authentication and Authorization

Setup trust between the BTP subaccount and the *SAP Identity Authentication Service* and setup end user authorizations following the steps in chapter [Configure Authentication and Authorization](03-One-Off-Deployment.md#configure-authentication-and-authorization).

BTP subaccount: Open menu item *Role Collections* and add the user group `Author_Reading_Admin` additionally to the role collections:
- *Enterprise Messaging Administrator*
- *Enterprise Messaging Developer* (required to test event notifications and to review the data payload of event notifications)
- *AuditLog*
- *Launchpad_Admin*

## Configure Single Sign-on for ByD

Configure single sign-on in ByD using the *SAP Identity Authentication Service* as identity provider as decribed in chapter [Configure Single Sign-on for ByD](04-ByD-Integration.md#configure-single-sign-on-for-byd).

## Configure ByD OData Services

Expose ByD projects as OData services by following the steps in chapter [Configure ByD OData Services](04-ByD-Integration.md#configure-byd-odata-services).

## Setup Destinations to connect to ByD

Setup destinations in the BTP subaccount to connect the BTP app with the ByD tenant. Follow the steps in chapter [Setup Destinations to connect to ByD](04-ByD-Integration.md#setup-destinations-to-connect-to-byd).

## Add BTP Applications to the ByD Launchpad

Add relevant BTP applications to the ByD launchpad as described in chapter [Add BTP Applications to the ByD Launchpad](04-ByD-Integration.md#add-btp-applications-to-the-byd-launchpad).

