# Connect a Tenant with *S/4HANA Cloud for Projects, collaborative project management*

In this chapter we connect an *S/4HANA Cloud for Projects, collaborative project management* tenant, the *SAP Identity and Authentication Service* (IAS) tenant of the S/4 system (acting as corporate identity provider), and the BTP consumer subaccount (with the customer subscription of the partner application).

Frontend integration:

1.  Launch the BTP application and C4P from the S/4 launchpad,
2.  Navigate from the BTP application to related C4P collaborative projects,
3.  Single sign-on for S/4, the BTP app and C4P using the same customer IAS tenant as IDP.

Back-channel integration:

4.  Create and read C4P collaborative projects from the BTP app using OData APIs with principal propagation.

## Setup *S/4HANA Cloud for Projects, collaborative project management*

Preconditions and preparations:

1. You have a BTP subaccount with a subscription of the application *S/4HANA Cloud for Projects, collaborative project management* (service plan *standard-user*). I refer to this subaccount as "C4P consumer subaccount". 
Open the *Instances and Subscriptions* in the BTP cockpit of the C4P consumer subaccount and open the application *S/4HANA Cloud for Projects, collaborative project management*. Take note of the 
    - **C4P Application URL** (we use this URL to launch C4P from the S/4HANA launchpad later), and the 
    - **C4P Base URL**

2. You have an instance of the service *SAP S/4HANA Cloud for projects, collaborative project management - API* (service plan *default*) with a service key in the C4P consumer subaccount.
Open the *Instances and Subscriptions* in the BTP cockpit of the C4P consumer subaccount and click on the service key of instance *SAP S/4HANA Cloud for projects, collaborative project management - API*. Check service key json and take note of the following element values
    - *apiUrl* (in the first line of the json) as **C4P API-URL**
    - *uaa.clientid* as **C4P UAA Client-ID**
    - *uaa.clientsecret* as **C4P UAA Client-Secret**
    - *uaa.url* as **C4P UAA-URL**

3. Open the *Trust Configuration* in the BTP cockpit of the C4P consumer subaccount. Download the SAML Metadata of the C4P consumer subaccount using button "SAML metadata"; open the SAML metadata xml-file and take note of the following xml element values: 
    - *EntityDescriptor.entityID* as **C4P Entity-ID** 
    - *AssertionConsumerService.Location* as **C4P Assertion Consumer Service Location**

4. Configure Single Sign-on for *S/4HANA Cloud for Projects, collaborative project management*:
In our scenario we reuse the *SAP Identity and Authentication Service* (IAS) tenant that is used by the *S/4HANA Cloud* tenant for authentication; but you can use some other IAS tenant as well.  
You can configure the trust relationship between the C4P consumer subaccount and the IAS tenant as described in chapter [Configure Trust using SAML 2.0](45-Multi-Tenancy-Provisioning.md). As typically both, the IAS tenant and the C4P consumer subaccount, are assigned to the customer, OIDC is the prefered approach to configure trust. Nevertheless, both both trust configurations using OIDC and SAML 2.0 are possible and do the job.

With these steps you are ready to launch C4P using single sign-on and you can explore and test the C4P OData services using Postman. In folder [api-samples](./api-samples/) you find a Postman collection and a Postman environment with some examples. Check the documentation of the Postman collection for further details about how to run the examples.


## Configure Single Sign-on for the BTP Application



## Configure Trust between the BTP Application and *S/4HANA Cloud for Projects, collaborative project management*



## Setup Destinations 



## Add the BTP Application and *S/4HANA Cloud for Projects, collaborative project management* to the S/4HANA Cloud Launchpad



## Create Users and Assign Authorizations