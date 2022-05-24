# SAP-samples/repository-template
This default template for SAP Samples repositories includes files for README, LICENSE, and .reuse/dep5. All repositories on github.com/SAP-samples will be created based on this template.

# Containing Files

1. The LICENSE file:
In most cases, the license for SAP sample projects is `Apache 2.0`.

2. The .reuse/dep5 file: 
The [Reuse Tool](https://reuse.software/) must be used for your samples project. You can find the .reuse/dep5 in the project initial. Please replace the parts inside the single angle quotation marks < > by the specific information for your repository.

3. The README.md file (this file):
Please edit this file as it is the primary description file for your project. You can find some placeholder titles for sections below.

# SME Partner Reference Application

<!--- Register repository https://api.reuse.software/register, then add REUSE badge:
[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/REPO-NAME)](https://api.reuse.software/info/github.com/SAP-samples/REPO-NAME)
-->

## Description

The *SME Partner Reference Application* provides a "golden path" to build, run and integrate full-stack cloud applications on the *SAP Business Technology Platform* in the market for small and midsize enterprizes.

purpose of the ref. app

about the sample app


## Requirements

BTP account with entitlements for BAS, CF, ...

Github account

## Download and Installation

Deploy and run the sample application as provided.

Re-build the app following the tutorials.

## Tutorials

A guided tour to re-build the application from scratch following a progressive development approach.

1. Build a full-stack BTP Application with One-off Deployment in a Customer BTP Account
    1. [Prepare the BTP Account](Tutorials/1-Prepare-BTP-Account.md) 
    2. [Develop the Core of the BTP Application](Tutorials/2-Develop-Core-Application.md)
    3. [One-off Deployment](Tutorials/3-One-Off-Deployment.md)
    4. [Integration with SAP Business ByDesign](Tutorials/4-ByD-Integration.md)
    5. [Event-based Integration with SAP Business ByDesign](Tutorials/5-ByD-Event-Integration.md)
    6. [Manage Data Privacy](Tutorials/6-Manage-Data-Privacy.md)
    7. [Test, Trace and Debug](Tutorials/7-Test-Trace-Debug.md)

Related resources:
- [SAP Cloud Application Programming Model](https://cap.cloud.sap/docs/)
- Missions
- ...

## Known Issues

No known issues.

## How to obtain support

This repository is provided "as-is"; no support is available. For questions and comments, [join the SAP Community](https://answers.sap.com/questions/ask.html).

## License

Copyright (c) 2022 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSE) file.
