# SME Partner Reference Application

<!--- Register repository https://api.reuse.software/register, then add REUSE badge:
[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/REPO-NAME)](https://api.reuse.software/info/github.com/SAP-samples/REPO-NAME)
-->

## Description

The *SME Partner Reference Application* provides a "golden path" to build, run and integrate full-stack cloud applications on the *SAP Business Technology Platform* .

With this repository we want to provide guidance for SAP partners in the market for small and midsize enterprizes (SME) to extend SAP ERP solutions by side-by-side cloud applications running on the *SAP Business Technology Platform* (BTP). This guidance comprises
- an opinionated pre-selection of BTP components with architecture guidance tailored for the SME market, 
- best practices ("golden paths") to build, deploy and provision full-stack BTP applications, and
- we pay special attention to the interoperability and integration with cloud ERP solutions such as *SAP Business ByDesign* and *S/4HANA Cloud*.

The repository includes a sample application that is ready to deploy and run, and tutorials to re-build the sample application from scratch following a progressive development approach. 

**About the sample application "Author Readings":**

Assume you are an event manager and your job is to organize and run author readings and poetry slams for reading clubs, book fairs and other occasions. 

Your company is running its business on an cloud ERP system provided by SAP and you mostly use the project management work center to plan and staff events, to collect costs and to purchase required equipment. 
Additionally an SAP partner provided a side-by-side application named "Author Reading Management" to publish author reading events and to register event participants and visitors. 

It was in particular important for you to separate the event publishing and participant registration from your ERP system for security and compliance reasons. Nevertheless, as a power user working in both systems you asked the partner to ensure a seamless user experience and navigation between the SAP system and the partner application.

Features of the author reading application:

1. Create and change author reading events; publish and block author readings
2. Add and remove participants; confirm and cancel participations
3. Calculate the number of free seats and block overbookings
4. One-click creation of projects for reading events and a preview of project information on the author reading UI (here, ERP authorizations must apply in the partner application as well!)
5. ERP users shall be able to launch the author reading app on their ERP launchpad, and it shall be possible to navigate from author readings to the associated project in the ERP system
6. Synchronize the status of the author reading event with the status of the associated project

Additionally, the sample showcases qualities relevant for enterprise-grade partner applications, supported by BTP services and programming models:

7. Standardized online development environment using the *Business Application Studio*
8. State-of-the-art web application architecture based on HTML5, NodeJS and HANA Cloud
9. Model-driven development based on the *SAP Cloud Application Programming Model* (CAP), *SAP Core Data Services* (CDS) and *Fiori Elements*
10. User experiences that fit to the SAP standard based on standard SAP floorplan patterns, and out-of-the-box theming and personalization
11. A draft concept to allow users to change data in multiple steps without publishing incomplete changes
12. Enterprise-grade security by authentication and role-based authorizations in line with SAP product standards and technology alignments
13. Enterprise-ready compliance by personal data management and audit log
14. Seamless and secure frontend and back-channel integration with SAP ERP solutions
15.	Delivering “open solutions” by integration-ready OData APIs and business events following SAP technology alignments
16. Extensible by citizen user tools (AppGyver) to add web apps and mobile apps for customer specific use cases and user groups (planned)
17. Deployment as one-off and multi-customer solution (planned) 

## Requirements

The application is based on the *SAP Business Technology Platform* (BTP) and SAP Cloud ERP Solutions. Therefore you need 
- administrative access to a BTP account with entitlements for *SAP Business Application Studio*, *Cloud Foundry Runtime*, *SAP HANA Cloud*, *SAP HANA Schemas & HDI Containers*, *Launchpad Service*, *SAP Event Mesh*, *Auditlog Service*, *Audit Log Viewer Service*,
- access to a *SAP Business ByDesign* tenant and authorizations for work centers *Application and User Management* and *Project Management*,
- admin access to an *SAP Identity Authentication Service* tenant (IAS) that is assigned to the same customer ID as the BTP global account.

We are using the *Business Application Studio* as standardized development environment and *Github* as code repository.

## Download and Installation

You can start your journey following two paths:

1. Deploy and run the sample application as provided in this respository following the tutorial "*Deploy the Sample Application as provided in a Customer BTP Account*".

2. Re-build the application from scratch following tutorial "*Build a full-stack BTP Application with One-off Deployment in a Customer BTP Account*".

After deployment of the application you may follow the tutorial "*A Guided Tour to explore the Capabilities of the Sample Application*" to visit the sample scenario end-to-end.

## Tutorials

Re-build the application from scratch following a guided tour and a progressive development approach.

1. Build a full-stack BTP Application with One-off Deployment in a Customer BTP Account
    1. [Prepare the BTP Account](Tutorials/01-Prepare-BTP-Account.md) 
    2. [Develop the Core of the BTP Application](Tutorials/02-Develop-Core-Application.md)
    3. [One-off Deployment](Tutorials/03-One-Off-Deployment.md)
    4. [Integration with SAP Business ByDesign](Tutorials/04-ByD-Integration.md)
    5. [Event-based Integration with SAP Business ByDesign](Tutorials/05-ByD-Event-Integration.md)
    6. [Manage Data Privacy](Tutorials/06-Manage-Data-Privacy.md)
    7. [Test, Trace and Debug](Tutorials/07-Test-Trace-Debug.md)

2. [Deploy the Sample Application in a Customer BTP Account](Tutorials/20-Deploy-Sample-Application.md)

3. [A Guided Tour to explore the Capabilities of the Sample Application](Tutorials/30-Guided-Tour.md)

Related resources:
- [SAP Cloud Application Programming Model](https://cap.cloud.sap/docs/)
- [SAP Discovery Center](https://discovery-center.cloud.sap/missionssearch)
- [ByD API Overview](https://blogs.sap.com/2019/09/26/sap-business-bydesign-an-api-overview/)
- [ByD OData API Usage Samples](https://blogs.sap.com/2019/02/27/sap-business-bydesign-api-usage-samples/)

## Known Issues

No known issues.

## How to obtain support

This repository is provided "as-is"; no support is available. For questions and comments, [join the SAP Community](https://answers.sap.com/questions/ask.html).

## License

Copyright (c) 2022 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSE) file.
