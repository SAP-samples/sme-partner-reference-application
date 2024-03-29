# Configure the Integration with *SAP Business ByDesign*

In this chapter we connect a *SAP Business ByDesign* tenant (representing the customers cloud ERP system), the *SAP Identity and Authentication Service* (IAS) tenant (acting as corporate IDP), and the BTP consumer subaccount (with the customer subscription of the partner application).

Frontend integration:

1. Launch the BTP app from the ByD launchpad,
2. Launch BTP administration applications such as the IAS admin application and the audit log viewer from the ByD launchpad,
3. Navigate from the BTP application to related ByD projects (ByD Project Management),
4. Single sign-on for ByD, the BTP app and all BTP admin apps using the same customer IAS tenant as IDP.

Back-channel integration:

5. Create and read ByD projects from the BTP app using OData APIs with principal propagation,

<img src="./images/mt_byd_integration.jpg" width="70%">

## Configure Single Sign-on for ByD

We use the *SAP Identity and Authentication Service* (IAS) as corporate identity provider (IDP) and establish a trust relationship between the service provider (our ByD tenant) and the IAS tenant. In result ByD delegates user authentications to the IAS tenant incl. single sign-on. 

We setup the trust relationship between ByD and IAS using SAML 2.0 and we use e-mail to identify the user.
Therefore, make sure the same e-mail addresses are entered for users in ByD as well as in the IAS tenant.

IAS Admin UI:

1. Download the **IDP SAML metadata file**: Open menu item *Tenant Settings* >> *SAML 2.0 Configuration* and click on *Download Metadata File* (the button in the lower left corner).

ByD:

2. Open work center *Application and User Management* and navigate to *Common Tasks* >> *Configure Single Sign-on*.
3. Go to the *Identity Provider* sheet, and in the list *Trusted Identity Provider*, click on the button *New Identity Provider*. 
4. Upload the **IDP SAML metadata file** which you downloaded from IAS tenant. 
5. Enter a suitable name for the IDP as *Alias*. The alias is displayed in the selection screen to choose an IDP in case you configure multiple identity provider in ByD.   
6. In the list under *Supported Name ID Formats*, add "E-Mail Address" as additional *Name Id Format* and use the *Actions*-button to select the e-mail address as *default name ID format*. 
7. Click on the *Save* button on the header of the UI. 
8. Click on the *Activate Single Sign-On* button on the header of the UI. 
9. Navigate to sheet *My System* and click on button *SP Metadata* to download the **ByD Service provider SAML metadata file**.

IAS Admin UI:

10. Open menu item *Applications* and create a new application of type *Bundled application*.
	- Enter the required information like application display name, application URL, … The display name appears on user login screen and the login applies to all applications linked to the IAS tenant (following the SSO principle). Choose some meaningful display name from an end-user point of view representing the scope of the IAS, for example "Almika Inc. - User login" or "Almika Inc. - ByD user authentication". As application URL you may use the ByD access URL for single sign-on, for example https://myXXXXXX-sso.sapbydesign.com.
	- Open section *SAML 2.0 Configuration* and upload the **ByD Service provider SAML metadata file** that you downloaded from ByD.
	- Open section *Subject Name identifier* and select "E-Mail" as basic attribute.
	- Open section *Default Name ID Format* and select "E-Mail".

Test the ByD user authentication with single sign-on:

11. Open the SSO access URL of ByD (for example https://myXXXXXX-sso.sapbydesign.com) in an incognito browser window and check if ByD redirects to the IAS login screen for user authentication. Use your e-mail and the IAS-password and check if the login to ByD is processed successfully.

## Expose ByD Projects as OData Service

In our sample BTP application we read and write ByD projects using the *Custom OData Service* "khproject".

Create the *Custom OData Service* "khproject":
1. Download the sample *Custom OData Service* "khproject" from GitHub repository [SAP Business ByDesign - API Samples](https://github.com/SAP-samples/byd-api-samples). 
2. Open the ByD work center view *Application and User Management - OData Services*, select *Custom OData Services* and upload the *Custom OData Service*.
3. Refresh the table of custom OData services and open the OData service "khproject" by clicking on *Edit*.
4. Take note of the *Service URL* which provides the service metadata as **ByD khproject metadata** for later reference. 

> Note: The GitHub repository mentioned above offers a Postman collection with examples to explore and test the ByD OData service as well.

## Configure OAuth-Authentication for OData Services

We are using *OAuth 2.0 SAML Bearer authentication* to access the ByD OData service to read and write ByD projects with the user-context initiated by the user on the UI of the BTP application. In result ByD user authorizations apply on the BTP application as well. Users without the permission to manage projects in ByD can still open the BTP application, but ByD project data is not retrieved and projects cannot be created.

Steps to configure ByD for *OAuth 2.0 SAML Bearer authentications*:

BTP consumer subaccount: Get the signing certificate of the BTP UAA service as OAuth Identity provider:

1. Open the menu item *Connectivity* >> *Destinations*, click on *Download Trust* and save the file with the signing certificate. Change the file name using ".cer" as file extension, for example "btp-signing-certificate.cer".
2. Open the file with the signing certificate and take note of the "Issued by"-name.

> Note: In result you have a file with the **BTP subaccount signing certificate** (with file extension ".cer") and the **BTP subaccount service provider name**, referred to as "Issued by" in the BTP subaccount signing certificate. Keep them both for later reference.

ByD: Configure an *OAuth 2.0 Identity Provider*:

3. Open the ByD work center *Application and User Management* and the common task *Configure OAuth 2.0 Identity Providers*.
4. Create new *OAuth 2.0 Identity Provider*:
	- *Issuing Entity Name*: Enter the **BTP subaccount service provider name** noted in step 1
	- *Primary Signing Certificate*: Browse and upload the **BTP subaccount signing certificate** (".cer"-file)
	- Check indicator *Email Address*
5. Enter an *Alias* for the new *OAuth 2.0 Identity Provider*, for example "Author Reading Runtime"
6. Save

ByD: Add an *OAuth2.0 Client Registration*:

7. Open the ByD work center view *Application and User Management – OAuth2.0 Client Registration* and create a new *OAuth2.0 Client Registration*:
	- *Client ID*: Note the *Client ID* generated by the system as **ByD OAuth Client ID**.
	- *Client Secret*: Enter a secure password and note the password as **ByD OAuth Client Secret**.
	- *Description*:  Enter some meaningful description.
	- *Issuer Name*: Select the *OAuth 2.0 Identity provider* created just before. 
	- *Scope*: Selecting scope ID “UIWC:CC_HOME” should be sufficient for most use cases. Note the scope as **ByD OAuth Scope**

ByD: Get ByD service provider name:

8. Open the ByD work center *Application and User Management* and common task *Configure Single Sign-On*. On sheet *My System* take note of the *Local Service Provider* as **ByD service provider name**.

ByD: Download the ByD server certificate:

9. Open the ByD UI (here using Chrome as browser) and click on the lock icon *View site information* on the left side of the URL and export the **ByD server certificate** as Base-64 encoded "X.-509"-file

> Note: Keep your notes and the ByD server certificate file; you will need them when configuring the destinations in the BTP provider subaccount after completing the code enhancements of your BTP application.

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

    > Note: You may need to upload the ByD server certificate into the destination service for SSL authentication using the link *Upload and Delete Certificates* on the destinations screen. You can download the ByD server certificate from the browser (Open the ByD UI and view the site information; then display and export the certificate details into a ".cer"-file).

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


## Create Users and Assign Authorizations

In our app design we rely on the business users and authorizations being created and managed in the Cloud ERP solution (here: *SAP Business ByDesign*) and the customers identity provider (here: *Identity Authentication Service*).
As a general approach you create the user in the ERP solution and the IdP, and then assign the user group that includes the authorization to the partner application to the user.

Step for *SAP Business ByDesign* as Cloud ERP:
1. ByD: Hire an *Employee* or create a *Service Agent* in the *SAP Business ByDesign* system (for service agents, you need to trigger the creation of a user). Make sure to maintain the e-mail address for in-house communication of the employee or service agent (this e-mail is used as user identifying attribute for single sign-on).
2. ByD: Edit the business user and assign relevant work centers (incl. the work center *Project Management*).
3. IAS: Create the same user in the *Identity Authentication Service* system and enter the same e-mail address used in the ByD system.
4. IAS: Assign the user group with the authorization for BTP application (for example the user group *Admin* or *AuthorReadingManager*) to the user.

> Note: Make sure to maintain the same e-mail address for users in the Cloud ERP and the IAS tenant. Otherwise single sign-on and the API-led integration using OAuth SAML bearer does not work.
