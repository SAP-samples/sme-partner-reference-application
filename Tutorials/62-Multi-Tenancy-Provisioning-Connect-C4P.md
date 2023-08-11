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
Open *Instances and Subscriptions* in the BTP cockpit of the C4P consumer subaccount and open the application *S/4HANA Cloud for Projects, collaborative project management*. Take note of the 
    - **C4P Application URL** (we use this URL to launch C4P from the S/4HANA launchpad later), and the 
    - **C4P Base URL**

2. You have an instance of the service *SAP S/4HANA Cloud for projects, collaborative project management - API* (service plan *default*) with a service key in the C4P consumer subaccount.
Open *Instances and Subscriptions* in the BTP cockpit of the C4P consumer subaccount and click on the service key of instance *SAP S/4HANA Cloud for projects, collaborative project management - API*. Check service key json and take note of the following element values
    - *apiUrl* (in the first line of the json) as **C4P API-URL**
    - *uaa.clientid* as **C4P UAA Client-ID**
    - *uaa.clientsecret* as **C4P UAA Client-Secret**
    - *uaa.url* as **C4P UAA-URL**

3. Open *Trust Configuration* in the BTP cockpit of the C4P consumer subaccount. Download the SAML Metadata of the C4P consumer subaccount (referred to as **C4P SAML Metadata**) using button "SAML metadata"; open the C4P SAML metadata xml-file and take note of the following xml element values: 
    - *EntityDescriptor.entityID* as **C4P Entity-ID** 
    - *AssertionConsumerService.Location* as **C4P Assertion Consumer Service Location**

4. Configure Single Sign-on for *S/4HANA Cloud for Projects, collaborative project management*:
In our scenario we reuse the *SAP Identity and Authentication Service* (IAS) tenant that is used by the *S/4HANA Cloud* tenant for authentication; but you can use some other IAS tenant as well.  
You can configure the trust relationship between the C4P consumer subaccount and the IAS tenant as described in chapter [Configure Trust using SAML 2.0](45-Multi-Tenancy-Provisioning.md). As typically both, the IAS tenant and the C4P consumer subaccount, are assigned to the customer, OIDC is the prefered approach to configure trust. Nevertheless, both both trust configurations using OIDC and SAML 2.0 are possible and do the job.

5. Open *Role Collections* in the BTP cockpit of the C4P consumer subaccount and assign the *User Group* "c4p" for the IAS tenant configured in the step before to the C4P role collections.

With these steps you are ready to launch C4P using single sign-on and you can explore and test the C4P OData services.


## Configure Single Sign-on for the BTP Application

In our scenario we reuse the *SAP Identity and Authentication Service* (IAS) tenant that is used by the *S/4HANA Cloud* tenant for authentication.  
Therefore configure a trust relationship between the BTP consumer subaccount and the IAS tenant of *S/4HANA Cloud* as described in chapter [Configure Trust using SAML 2.0](45-Multi-Tenancy-Provisioning.md#configure-trust-using-saml-20).


## Configure Trust between the BTP Application and *S/4HANA Cloud for Projects, collaborative project management*

In our scenario the partner BTP application shall consume the OData services of C4P using an OAuth 2 SAML bearer authentication flow and we need to confure a trust relationship between the BTP app consumer subaccount and the C4P consumer subaccount.

Steps to be taken:
1. Open the BTP app consumer subaccount and navigate to *Destinations*. Click on *Download IDP Metadata* and save the IDP metadata xml file (referred to as **BTP app IDP Metadata**).
2. Open the C4P consumer subaccount, navigate to *Trust Configuration* and create a new custom identity provider using button *New Trust Configuration*. Upload the **BTP app IDP Metadata**-file and enter the following parameter values:
    | Parameter name: | Value:                                                                                 |
    | :-------------- | :------------------------------------------------------------------------------------- |
    | *IDP Name*:     | Choose a name that identifies the BTP app consumer account, for example the BTP app consumer subaccount name such as"armt-s2" |
    | *IDP Description*: | Enter the description referring to the BTP app consumer account, for example "Author Reading Manager - Tenant 2 IDP" |
    | *Status*:                   | active |
    | *Available for user logon*: | no     |
    | *Create shadow users*:      | yes    |

## Setup Destinations 

Open the BTP app consumer subaccount, navigate to *Destinations*. 

1. Create a destination "c4p" for the OData connection with the following parameter values:

    | Parameter name:           | Value:                                                                        |
    | :------------------------ | :---------------------------------------------------------------------------- |
    | *Name*:                   | *c4p*                                                                         |
    | *Type*:                   | *HTTP*                                                                        |
    | *Description*:            | Destination description, for example "C4P XXXXXX with principal propagation"  |
    | *URL*:                    | API endpoint of C4P; enter the **C4P API-URL**                                |
    | *Proxy Type*:             | *Internet*                                                                    |
    | *Authentication*:         | *OAuth2SAMLBearerAssertion*                                                   |
    | *Audience*:               | Enter the **C4P UAA-URL**                                                     |
    | *AuthnContextClassRef*:   | *urn:oasis:names:tc:SAML:2.0:ac:classes:PreviousSession*                      |
    | *Client Key*:             | Enter the **C4P UAA Client-ID**                                               |
    | *Token Service URL*:      | Enter the **C4P Assertion Consumer Service Location**                         |
    | *Token Service User*:     | Enter the **C4P UAA Client-ID**                                               |
    | *Token Service Password*: | Enter the **C4P UAA Client-Secret**                                           |

    Enter the additional properties:
    
    | Property name:  | Value:                                                          |
    | :-------------- | :-------------------------------------------------------------- |
    | *nameIdFormat*: | *urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress*        |
    | *userIdSource*: | *email*                                                         |

2. Create a destination "c4p-url" with the following parameter values. 

    | Parameter name:   | Value:                                                                                  |
    | :---------------- | :-------------------------------------------------------------------------------------- |
    | *Name*:           | *c4p-url*                                                                               |
    | *Type*:           | *HTTP*                                                                                  |
    | *Description*:    | Enter the name of your C4P system used by your buisness users, <br> for example "My System for Collaboration Project" |
    | *URL*:            | Enter the **C4P Base URL** (base URL of the C4P UI)                                     |
    | *Proxy Type*:     | *Internet*                                                                              |
    | *Authentication*: | *NoAuthentication*                                                                      |

    > Note: The destination URL is used to store the base URL of the C4P tenant. By storing the base-URL in a destination, we make sure that connecting the BTP web application to the C4P Cloud systems is a pure configuration task and does not require any code changes. <br> At runtime we dynamically assemble the parameterized URL to launch the project view of the C4P tenant by concatenating this base-URL with the floorplan-specific path and the object-specific parameters (for example the project ID). The authentication method is not relevant in this destination and therefore we choose "NoAuthentication" for simplicity (of course this destination cannot be used to use any C4P Cloud service directly).

    > Note: The destination description is used to store the name of the C4P system used by business users. At runtime we use this description to refer to the C4P system on the UI of the BTP application.


## Add the BTP Application and *S/4HANA Cloud for Projects, collaborative project management* to the S/4HANA Cloud Launchpad

Create custom tiles for the *S/4HANA Cloud* launchpad following the steps as described in chapter [Add the BTP Applications to the S/4HANA Cloud Launchpad](52-Multi-Tenancy-Provisioning-Connect-S4HC.md#add-the-btp-applications-to-the-s4hana-cloud-launchpad). 


## Create Users and Assign Authorizations

Open the C4P consumer subaccount, navigate to *Users* and create user with the same e-mail as used for UI login on partner BTP app for the identity provider created in section "Configure Trust between the BTP Application and *S/4HANA Cloud for Projects, collaborative project management*" (in my example I used the description "Author Reading Manager - Tenant 2 IDP"). Assign all role collections required to access the C4P APIs and to read and create collaboration projects to this user.

Open the administration app of the *SAP Identity and Authentication Service* (IAS) tenant that is used for authentication by the all applications *S/4HANA Cloud*, C4P and the partner BTP app, create a *User Group* with name "c4p", and assign this user group to the users that should have access to C4P.

