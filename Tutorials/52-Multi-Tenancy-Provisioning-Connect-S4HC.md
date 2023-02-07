# Configure the Integration with *SAP S/4HANA Cloud, public edition*

In this chapter we connect an *SAP S/4HANA Cloud* tenant (representing the customers cloud ERP system), the *SAP Identity and Authentication Service* (IAS) tenant of the S/4 system (acting as corporate IDP), and the BTP consumer subaccount (with the customer subscription of the partner application).

Frontend integration:

1. Launch the BTP app from the S/4 launchpad,
2. Launch BTP administration applications such as the IAS admin application and the audit log viewer from the S/4 launchpad,
3. Navigate from the BTP application to related S/4 enterprise projects,
4. Single sign-on for S/4, the BTP app and all BTP admin apps using the same customer IAS tenant as IDP.

Back-channel integration:

5. Create and read S/4 enterprise projects from the BTP app using OData APIs with principal propagation.

<img src="./images/mt_s4hc_integration.jpg" width="100%">

## Configure Single Sign-on for S/4HANA Cloud

In our scenario we reuse the *SAP Identity and Authentication Service* (IAS) tenant that is used by the S/4HANA Cloud tenant for authentication. Therefore the trust-relationship between the S/4 tenant and the IAS tenant is already established and no further activities are required here.

## Configure S/4HANA Cloud OData Services to create and read Enterprise Projects

Search for the following OData APIs on the [SAP API Business Hub](https://api.sap.com/package/SAPS4HANACloud/all) and take note of the communication scenarios per API:
- [*Enterprise Project*](https://api.sap.com/api/API_ENTERPRISE_PROJECT_SRV_0002/overview) (OData v2): Communication scenario *Enterprise Project Integration* (SAP_COM_0308)
- [*Enterprise Project - Read Project Processing Status*](https://api.sap.com/api/ENTPROJECTPROCESSINGSTATUS_0001/overview) (OData v4): Communication scenario: *Enterprise Project - Project Processing Status Integration* (SAP_COM_0725)
- [*Enterprise Project - Read Project Profile*](https://api.sap.com/api/ENTPROJECTPROFILECODE_0001/overview) (OData v4): Communication scenario: *Enterprise Project - Project Profile Integration* (SAP_COM_0724)

Create a new *Communication System* that represents the BTP consumer subaccount:
| Parameter name: | Value:                                                                                 |
| :-------------- | :------------------------------------------------------------------------------------- |
| *System ID*:    | "PRA-ARMT-S2" (here, I reuse the sub-domain "armt-s2" of the consumer subaccount)      |
| *System Name*:  | "Partner Applications - Author Reading Management Tenant 2"
| *Host Name*:    | Enter the hostname of the subscription of the partner reference application (for example: "armt-s2.{cloud foundry endpoint}") |

Add a user for inbound communication to the *Communication System* (create a new user):
| Parameter name: | Value:                                                                                 |
| :-------------- | :------------------------------------------------------------------------------------- |
| *User Name*:    | "PRA-ARMT-S2-USER" (here, I reuse the sub-domain "armt-s2" of the consumer subaccount) |
| *Description*:  | "Technical user for Author Reading Management"                                         |
| *Password*:     | Choose a secure password                                                               |

Create a new *Communication Arrangement*: Open *Communication Scenario* "SAP_COM_0308" and start the configuration using bottom "Create Comm. Arrangement":
| Parameter name:         | Value:                                                                       |
| :---------------------- | :--------------------------------------------------------------------------- |
| *Arrangement Name*:     | Choose a meaningful name, for example "Author Reading Management - Projects" |
| *Communication System*: | Choose the communication system created above                                |
| *Inbound Communication - User Name*: | Choose the user for inbound communication created above         |
| *Inbound Communication - Authentication Method*: | "User ID and Password"                              |

Create further communication arrangements for the other two OData services using the same communication system and communication user:
- Communication arrangement "Author Reading Management - Project Profile" for communication scenario "SAP_COM_0724"
- Communication arrangement "Author Reading Management - Project Status" for communication scenario "SAP_COM_0725"

You can now consume the OData service using the technical user and basic authentication (user/password).


## Configure OAuth-Authentication for OData Services

We are using *OAuth 2.0 SAML Bearer authentication* to access the S/4HANA Cloud OData service to read and write ByD projects with the user-context initiated by the user on the UI of the BTP application. In result S/4HANA Cloud user authorizations apply on the BTP application as well. Users without the permission to manage projects in S/4HANA Cloud can still open the BTP application, but S/4 enterprise project data is not retrieved and projects cannot be created.

Steps to configure S/4HANA Cloud for *OAuth 2.0 SAML Bearer authentications*:

BTP consumer subaccount: Get the signing certificate of the BTP UAA service as OAuth Identity provider:

1. Open the menu item *Connectivity* >> *Destinations*, click on *Download Trust* and save the file with the signing certificate. Change the file name using ".cer" as file extension, for example "btp-signing-certificate.cer".

> Note: In result you have a file with the **BTP subaccount signing certificate** (with file extension ".cer"). Keep the file for later reference.

S/4HANA Cloud: Configure an *OAuth 2.0 Identity Provider*:

2. Open the *Communication System* "Partner Applications - Author Reading Management Tenant 2" created above
3. Activate "OAuth 2.0 Identity Provider"
4. Upload the **BTP subaccount signing certificate** via bottom "Upload Signing Certificate"
5. Copy the "CN"-property of the "Signing Certificate Issuer" into field "OAuth 2.0 SAML Issuer"
6. Keep the "User ID Mapping Mode" = "User Name"

S/4HANA Cloud: Change the authentication method of the communication arrangement to OAuth 2.0:

7. Open the *Communication Arrangement* "Author Reading Management - Projects" created above 
8. Navigate to "Inbound Communication": Reselect the user for inbound communication and choose the same user with authentication method "OAuth 2.0".
9. Take note of the **OData Service URL** (Service URL of service Enterprise Project) and the OAuth 2.0 Details: **Client ID, Client Secrete**, **User Name**, **Token Service URL**, **SAML2 Audience**, and the **Scope** "API_ENTERPRISE_PROJECT_SRV_0002".

Open the S/4HANA Cloud UI (here using Chrome as browser) and click on the lock icon *View site information* on the left side of the URL and export the **S/4HANA Cloud server certificate** as Base-64 encoded "X.-509"-file.

> Note: Keep your notes and the S/4HANA Cloud server certificate file; you will need them when configuring the destinations in the BTP consumer subaccount.


**--- THIS PAGE IS WORK IN PROCESS. ---**


## Setup Destinations to connect the BTP App to ByD 

BTP consumer subaccount: Create destination "byd" to connect to ByD with principal propagation:

1. Open the menu item *Connectivity* of the BTP consumer subaccount, click on *Destinations* and create a *New Destination* with the following field values:

    | Parameter name:           | Value:                                                                                 |
    | :------------------------ | :------------------------------------------------------------------------------------- |
    | *Name*:                   | *byd*                                                                                  |
    | *Type*:                   | *HTTP*                                                                                 |
    | *Description*:            | Enter a destination description, for example "*ByD 123456 with principal propagation*" |
    | *URL*:                    | *https://{{ByD-hostname}}* for example “*https://my123456.sapbydesign.com*”            |
    | *Proxy Type*:             | *Internet*                                                                             |
    | *Authentication*:         | *OAuth2SAMLBearerAssertion*                                                            |
    | *Audience*:               | Enter the **ByD service provider name**                                                |
    | *AuthnContextClassRef*:   | *urn:none*                                                                             |
    | *Client Key*:             | Enter the **ByD OAuth Client ID**                                                      |
    | *Token Service URL*:      | *https://{{ByD-hostname}}/sap/bc/sec/oauth2/token*                                     |
    | *Token Service User*:     | Enter the **ByD OAuth Client ID**                                                      |
    | *Token Service Password*: | Enter the **ByD OAuth Client Secret**                                                  |

    Enter the Additional Properties:
    
    | Property name:  | Value:                                                   |
    | :-------------- | :------------------------------------------------------- |
    | *nameIdFormat*: | *urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress* |
    | *scope*:        | Enter the **ByD OAuth Scope** (*UIWC:CC_HOME*)           |
    | *userIdSource*: | *email*                                                  |

    > Note: You may need to upload the ByD server certificate into the destination service for SSL authentication using the link *Upload and Delete Certificates* on the destinations screen. You can download the ByD server certificate from the brower (Open the ByD UI and view the site information; then display and export the certificate details into a ".cer"-file).

BTP consumer subaccount: Create destination "byd-url" to launch ByD screens. 

The destination "byd-url" is used to store the single sign-on URL of the ByD system. By storing the base-URL in a destination, we make sure that connecting the BTP web application to ByD systems is a pure configuration task and does not require any code changes.

At runtime we dynamically assemble the parameterized URL to launch the ByD project overview ("referred to as *external object-based navigation* in ByD) by concatenating this base-URL with the ByD-floorplan-specific path and the object-specific parameters (for example the project ID). The authentication method is not relevant in this destination and therefore we choose "NoAuthentication" for simplicity (of course this destination cannot be used to use any ByD service directly).

4. Open the menu item *Connectivity* of the BTP consumer subaccount, click on *Destinations* and create a *New Destination* with the following field values:

    | Parameter name:   | Value:                                                                                  |
    | :---------------- | :-------------------------------------------------------------------------------------- |
    | *Name*:           | *byd-url*                                                                               |
    | *Type*:           | *HTTP*                                                                                  |
    | *Description*:    | Enter a destination description, for example "*ByD 123456 URL*"                         |
    | *URL*:            | *https://{{ByD-hostname-for-SSO}}*, for example “*https://my123456-sso.sapbydesign.com*” |
    | *Proxy Type*:     | *Internet*                                                                              |
    | *Authentication*: | *NoAuthentication*                                                                      |
    
## Add BTP Applications to the ByD Launchpad

As last step we add the BTP application subscription for author readings and BTP admin apps to the ByD launchpad such that author reading managers as well as system administrators can launch all relevant apps from a single launchpad.

Create mashup for the BTP application subscription "Author Readings":

1. Launch the **BTP Application Tenant URL** and copy the link address of the application "Manage Author Readings" (we want to launch the app directly w/o the BTP launchpad). 

2. ByD: Open work center view *Application and User Management - Mashup Authoring* and create a new URL mashup with the following data:
	- *Port Binding Type*: Select *1 - Without Port Binding*
	- *Mashup Name*: "Author Readings"
	- *Description*: "Manage author readings and poetry slams"
	- *URL*: Enter the URL of the web application from step 1
	- *HTTP Method*: Select *Get*

Create a mashup for the IAS Admin application:

3. ByD: Open work center view *Application and User Management - Mashup Authoring* and create a new URL mashup with the following data:
	- *Port Binding Type*: Select *1 - Without Port Binding*
	- *Mashup Name*: "Identity Authentication Service"
	- *Description*: "Manage user authorizations and user groups"
	- *URL*: Enter the URL of the IAS admin UI following the pattern https://<IAS hostname>/admin/
	- *HTTP Method*: Select *Get*

Create a mashup for the Audit Log Viewer:

6. BTP consumer subaccount: Get the URL of the Audit log viewer: Open menu item *Instances and Subscriptions* and pick the URL of the *Application* "Audit Log Viewer Service".

7. ByD: Open work center view *Application and User Management - Mashup Authoring* and create a new URL mashup with the following data:
	- *Port Binding Type*: Select *1 - Without Port Binding*
	- *Mashup Name*: "Audit Log Viewer"
	- *Description*: "View audit logs"
	- *URL*: Enter the URL of the Audit log viewer application. 
	- *HTTP Method*: Select *Get*
	
Add the BTP apps to the ByD Launchpad:
	
8. ByD: Open work center view *Home - My Launchpad* and start the personalization mode by selecting *Start Personalization Mode* from the *Me Area* menu in the top shell bar. Choose the best fitting launchpad group (or create a new group), click on "+", and pin the tiles refering to the mashups created above from the mashup gallery to the launchpad. Finally, save and stop the peronalization mode.

9. Test frontend SSO: Open ByD using the SSO-URL (following the pattern https://myXXXXXX-sso.sapbydesign.com/) and login using your IAS user. Then launch the BTP application via the ByD launchpad. No additional authentication should be required.

<img src="./images/mt_byd_launchpad.jpg" width="80%">

> Note: If the SAP Launchpad raises the error message *"[…] refuse to connect"* or *"Refused to display '[…]' in a frame because it set 'X-Frame-Options' to 'sameorigin'"* on opening the web app (click on the app tile), then add the property `httpHeaders: "[{ \"Content-Security-Policy\": \"frame-ancestors 'self' https://*.hana.ondemand.com\" }]"` to the application router module in your `mta.yaml` file. See tutorial [Enhance the BTP Application for Multi-Tenancy](Tutorials/40-Multi-Tenancy.md) for more details.


## Create Users and Assign Authorizations

In our app design we rely on the business users and authorizations being created and managed in the Cloud ERP solution (here: *SAP Business ByDesign*) and the customers identity provisioning provider (here: *Identity Authentication Service*).
As a general approach you create the user in the ERP solution and the IdP, and then assign the user group that includes the authorization to the partner application to the user.

Step for *SAP Business ByDesign* as Cloud ERP:
1. ByD: Hire an *Employee* or create a *Service Agent* in the *SAP Business ByDesign* system (for service agents, you need to trigger the creation of a user). Make sure to maintain the e-mail address for in-house communication of the employee or service agent (this e-mail is used as user identifying attribute for single sign-on).
2. ByD: Edit the business user and assign relevant work centers (incl. the work center *Project Management*).
3. IAS: Create the same user in the *Identity Authentication Service* system and enter the same e-mail address used in the ByD system.
4. IAS: Assign the user group with the authorization for BTP application (for example the user group *Admin* or *AuthorReadingManager*) to the user.

> Note: Make sure to maintain the same e-mail address for users in the Cloud ERP and the IAS tenant. Otherwise single sign-on and the API-led integration using OAuth SAML bearer does not work.
