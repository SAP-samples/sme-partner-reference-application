# Connect a Tenant with *S/4HANA Cloud for Projects, collaborative project management*

In this chapter we connect an *S/4HANA Cloud for Projects, collaborative project management* tenant, the *SAP Identity and Authentication Service* (IAS) tenant of the S/4 system (acting as corporate identity provider), and the BTP consumer subaccount (with the customer subscription of the partner application).

Frontend integration:

1.  Launch the BTP application and C4P from the S/4 launchpad,
2.  Navigate from the BTP application to related C4P collaborative projects,
3.  Single sign-on for S/4, the BTP app and C4P using the same customer IAS tenant as IDP.

Back-channel integration:

4.  Create and read C4P collaborative projects from the BTP app using OData APIs with principal propagation.

## Preconditions

C4P setup...


## Configure Single Sign-on for *S/4HANA Cloud for Projects, collaborative project management*



>Note: You can explore and test the C4P OData services using Postman. Please find a Postman collection and a Postman environment in folder [api-samples](./api-samples/).


## Configure Single Sign-on for the BTP Application



## Configure Trust between the BTP Application and *S/4HANA Cloud for Projects, collaborative project management*



## Setup Destinations 



## Add the BTP Application and *S/4HANA Cloud for Projects, collaborative project management* to the S/4HANA Cloud Launchpad



## Create Users and Assign Authorizations