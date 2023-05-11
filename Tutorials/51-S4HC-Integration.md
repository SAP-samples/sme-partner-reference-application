# Integrate the BTP Application with *S/4HANA Cloud, public edition*

In this chapter we enhance the BTP application to support *SAP S/4HANA Cloud, public edition* (S/4) as backend. 

Frontend integration:
1. Navigate from the BTP app to related S/4 enterprise projects.

Back-channel integration:

2. Create S/4 enterprise projects from the BTP app and display S/4 project information on the web application of the BTP app using OData APIs with principal propagation.

## Enhance the BTP App to Consume S/4 OData APIs

In this chapter we import the S/4 OData service as "remote service" into our CAP project and use the OData service to create S/4 enterprise projects to plan and run author reading events.

### Import S/4 OData Services

We use the S/4 OData service for enterprise projects to read and write S/4 projects in context of a user interaction. 

S/4: Create EDMX-file from S/4 Odata service:

1. Search for the following OData APIs on the [SAP API Business Hub](https://api.sap.com/package/SAPS4HANACloud/all) and download the metadata files (edmx-files):
    - [*Enterprise Project*](https://api.sap.com/api/API_ENTERPRISE_PROJECT_SRV_0002/overview) (OData v2)
    - [*Enterprise Project - Read Project Processing Status*](https://api.sap.com/api/ENTPROJECTPROCESSINGSTATUS_0001/overview) (OData v4)
    - [*Enterprise Project - Read Project Profile*](https://api.sap.com/api/ENTPROJECTPROFILECODE_0001/overview) (OData v4)
2. Rename the metadata files (edmx-files) Add the prefix "S4HC_" to avoid future naming conflicts:
    -  S4HC_API_ENTERPRISE_PROJECT_SRV_0002.edmx
    -  S4HC_ENTPROJECTPROCESSINGSTATUS_0001.edmx
    -  S4HC_ENTPROJECTPROFILECODE_0001.edmx

Business Application Studio (BAS): Import the S/4 odata service into the CAP project:

3. Open the context menu on folder "./external_resources" and upload the edmx-files with the OData services as remote services.

4. Open a terminal, navigate to folder "./application/author-readings-mt", and import the remote service using the command:  
`cds import ./external_resources/S4HC_API_ENTERPRISE_PROJECT_SRV_0002.edmx --as cds`. 

    Repeat the `cds import` command for other two services.

    In result the system created cds-files in folder "./srv/external" for all remote services and enhanced file "package.json" by a cds-configurations referring to the remote services.

    > Note: Do not use the cds import command parameter `--keep-namespace`, because it may lead to service name clashes if you import multiple S/4 odata services.

  5. Enhance the file [package.json](../Applications/author-readings-mt/package.json) by sandbox-configurations for local testing and to refer to the destinations used for productive setups:  

        ```json
        "cds": {
            "S4HC_API_ENTERPRISE_PROJECT_SRV_0002": {
                "kind": "odata-v2",
                "model": "srv/external/S4HC_API_ENTERPRISE_PROJECT_SRV_0002",
                "[sandbox]": {
                "credentials": {
                    "url": "https://{{S4HC-hostname}}/sap/opu/odata/sap/API_ENTERPRISE_PROJECT_SRV;v=0002",
                    "authentication": "BasicAuthentication",
                    "username": "{{test-user}}",
                    "password": "{{test-password}}"
                }
                },
                "[production]": {
                "credentials": {
                    "destination": "s4hc",
                    "path": "/sap/opu/odata/sap/API_ENTERPRISE_PROJECT_SRV;v=0002"
                }
                }
            },
            "audit-log": {
                "[sandbox]": {
                "kind": "audit-log-to-console"
                },
                "[production]": {
                "kind": "audit-log-service"
                }
            },
            "S4HC_ENTPROJECTPROCESSINGSTATUS_0001": {
                "kind": "odata",
                "model": "srv/external/S4HC_ENTPROJECTPROCESSINGSTATUS_0001",
                "[sandbox]": {
                "credentials": {
                    "url": "https://{{S4HC-hostname}}/sap/opu/odata4/sap/api_entprojprocessingstat/srvd_a2x/sap/entprojectprocessingstatus/0001",
                    "authentication": "BasicAuthentication",
                    "username": "{{test-user}}",
                    "password": "{{test-password}}"
                }
                },
                "[production]": {
                "credentials": {
                    "destination": "s4hc-tech-user",
                    "path": "/sap/opu/odata4/sap/api_entprojprocessingstat/srvd_a2x/sap/entprojectprocessingstatus/0001"
                }
                }
            },
            "S4HC_ENTPROJECTPROFILECODE_0001": {
                "kind": "odata",
                "model": "srv/external/S4HC_ENTPROJECTPROFILECODE_0001",
                "[sandbox]": {
                "credentials": {
                    "url": "https://{{S4HC-hostname}}/sap/opu/odata4/sap/api_entprojectprofilecode/srvd_a2x/sap/entprojectprofilecode/0001",
                    "authentication": "BasicAuthentication",
                    "username": "{{test-user}}",
                    "password": "{{test-password}}"
                }
                },
                "[production]": {
                "credentials": {
                    "destination": "s4hc-tech-user",
                    "path": "/sap/opu/odata4/sap/api_entprojectprofilecode/srvd_a2x/sap/entprojectprofilecode/0001"
                }
                }
            }
        },
        ```

        > Note: The *package.json* refers to two destinations "s4hc" and "s4hc-tech-user" that need to be created in the consumer BTP subaccount. The destinations "s4hc" is used for remote service calls with principal propagation. Compare next chapter.

### Enhance the Service Model by the Remote Service

BAS: Extend the CAP service model by the remote entities:

1. Open file [service-models.cds](../Applications/author-readings-mt/srv/service-models.cds) with the service models.

2. Expose S/4 project data throughout the CAP service model for principal propagation:
    ```javascript
    // -------------------------------------------------------------------------------
    // Extend service AuthorReadingManager by S/4 projects (principal propagation)

    using { S4HC_API_ENTERPRISE_PROJECT_SRV_0002 as RemoteS4HCProject } from './external/S4HC_API_ENTERPRISE_PROJECT_SRV_0002';

    extend service AuthorReadingManager with {
        entity S4HCProjects as projection on RemoteS4HCProject.A_EnterpriseProject {
            key ProjectUUID as ProjectUUID,
            ProjectInternalID as ProjectInternalID,
            Project as Project,
            ProjectDescription as ProjectDescription,
            EnterpriseProjectType as EnterpriseProjectType,
            ProjectStartDate as ProjectStartDate,
            ProjectEndDate  as ProjectEndDate,
            ProcessingStatus as ProcessingStatus,
            ResponsibleCostCenter as ResponsibleCostCenter,
            ProfitCenter as ProfitCenter,
            ProjectProfileCode as ProjectProfileCode,
            CompanyCode as CompanyCode,
            ProjectCurrency as ProjectCurrency,
            EntProjectIsConfidential as EntProjectIsConfidential,
            to_EnterpriseProjectElement as to_EnterpriseProjectElement : redirected to S4HCEnterpriseProjectElement ,                
            to_EntProjTeamMember as to_EntProjTeamMember : redirected to S4HCEntProjTeamMember    
        }
        entity S4HCEnterpriseProjectElement as projection on RemoteS4HCProject.A_EnterpriseProjectElement {
            key ProjectElementUUID as ProjectElementUUID,
            ProjectUUID as ProjectUUID,
            ProjectElement as ProjectElement,
            ProjectElementDescription as ProjectElementDescription,
            PlannedStartDate as PlannedStartDate,
            PlannedEndDate as PlannedEndDate
        }

        entity S4HCEntProjTeamMember as projection on RemoteS4HCProject.A_EnterpriseProjectTeamMember {
            key TeamMemberUUID as TeamMemberUUID,        
            ProjectUUID as ProjectUUID,
            BusinessPartnerUUID as BusinessPartnerUUID,
            to_EntProjEntitlement as to_EntProjEntitlement : redirected to S4HCEntProjEntitlement     
        }

        entity S4HCEntProjEntitlement as projection on RemoteS4HCProject.A_EntTeamMemberEntitlement {
            key ProjectEntitlementUUID as ProjectEntitlementUUID,
            TeamMemberUUID as TeamMemberUUID,
            ProjectRoleType as ProjectRoleType        
        }
    
    };

    // Extend service AuthorReadingManager by S4HC Projects ProjectProfileCode
    using { S4HC_ENTPROJECTPROCESSINGSTATUS_0001 as RemoteS4HCProjectProcessingStatus } from './external/S4HC_ENTPROJECTPROCESSINGSTATUS_0001';

    extend service AuthorReadingManager with {
        entity S4HCProjectsProcessingStatus as projection on RemoteS4HCProjectProcessingStatus.ProcessingStatus {
            key ProcessingStatus as ProcessingStatus,
            ProcessingStatusText as ProcessingStatusText    
        }    
    };

    // Extend service AuthorReadingManager by S4HC Projects ProcessingStatus
    using { S4HC_ENTPROJECTPROFILECODE_0001 as RemoteS4HCProjectProjectProfileCode } from './external/S4HC_ENTPROJECTPROFILECODE_0001';

    extend service AuthorReadingManager with {
        entity S4HCProjectsProjectProfileCode as projection on RemoteS4HCProjectProjectProfileCode.ProjectProfileCode {
            key ProjectProfileCode as ProjectProfileCode,
            ProjectProfileCodeText as ProjectProfileCodeText    
        }    
    };

    ```
    
2. Enhance the service model of service *AuthorReadingManager* by an association to the remote project in S/4:
    ```javascript
    // Author readings (combined with remote project using mixin)
    @odata.draft.enabled
    entity AuthorReadings as select from armodels.AuthorReadings
        mixin {
            // S4HC projects: Mix-in of S4HC project data
            toS4HCProject: Association to RemoteS4HCProject.A_EnterpriseProject on toS4HCProject.Project = $projection.projectID
        } 
    ```

3. Enhance the service model of service *AuthorReadingManager* by virtual elements to control the visualization of actions and the coloring of status information:
    ```javascript
    // Author readings (combined with remote project using mixin)
    @odata.draft.enabled
    entity AuthorReadings as select from armodels.AuthorReadings
        mixin {
            // S4HC projects: Mix-in of S4HC project data
            toS4HCProject: Association to RemoteS4HCProject.A_EnterpriseProject on toS4HCProject.Project = $projection.projectID
        } 
        into  {
            *,
            virtual null as statusCriticality    : Integer @title : '{i18n>statusCriticality}',
            virtual null as projectSystemName    : String  @title : '{i18n>projectSystemName}' @odata.Type : 'Edm.String',

            // S4HC projects: visibility of button "Create project in S4HC", code texts
            virtual null as createS4HCProjectEnabled : Boolean  @title : '{i18n>createS4HCProjectEnabled}'  @odata.Type : 'Edm.Boolean',
            toS4HCProject,
            virtual null as projectProfileCodeText : String @title : '{i18n>projectProfile}' @odata.Type : 'Edm.String',
            virtual null as processingStatusText   : String @title : '{i18n>processingStatus}' @odata.Type : 'Edm.String',
        }
    ```
    
4. Enhance the service model of service *AuthorReadingManager* by an action to create remote projects:
    ```javascript
    // S4HC projects: action to create a project in S4HC
    @(
        Common.SideEffects              : {TargetEntities: ['_authorreading','_authorreading/toS4HCProject']},
        cds.odata.bindingparameter.name : '_authorreading'
    )
    action createS4HCProject() returns AuthorReadings;
    ```
    > Note: The side effect annotation refreshes the project data right after executing the action.


### Enhance the Authentication Model to cover Remote Projects

BAS: Extend the authorization annotation of the CAP service model by restrictions referring to the remote services:

1. Open file [service-auth.cds](../Applications/author-readings-mt/srv/service-auth.cds) with the authorization annotations.

2. Enhance the authorization model for the service entities `S4HCProjects`, `S4HCEnterpriseProjectElement`, `S4HCEntProjTeamMember` and `S4HCEntProjEntitlement`:
    ```javascript
    // S/4 projects: Managers and Administrators can read and create remote projects
    annotate AuthorReadingManager.S4HCProjects with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grand : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    annotate AuthorReadingManager.S4HCEnterpriseProjectElement with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grand : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    annotate AuthorReadingManager.S4HCEntProjTeamMember with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grand : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    annotate AuthorReadingManager.S4HCEntProjEntitlement with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grand : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    annotate AuthorReadingManager.S4HCProjectsProjectProfileCode with @(restrict : [
    {
        grant : ['*'],
        to    : 'AuthorReadingManagerRole',
    },
    {
        grand : ['*'],
        to    : 'AuthorReadingAdminRole'
    }
    ]);
    annotate AuthorReadingManager.S4HCProjectsProcessingStatus with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grand : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    ```
    
### Create a file with Reuse Functions for S/4

Some reuse functions specific for S/4 are defined in a separate file. 
Copy the S/4 reuse functions in file [connector-s4hc.js](../Applications/author-readings-mt/srv/connector-s4hc.js) into your project.

### Enhance the Business Logic to operate on S/4 Data

BAS: Enhance the implementation of the CAP services in file [service-implementation.js](../Applications/author-readings-mt/srv/service-implementation.js) to create and read S/4 enterprise project data using the remote S/4 OData service. 

1. Delegate requests to the remote OData service: 
    ```javascript
    // Implementation of remote OData services (back-channel integration with S4HC)
    // Delegate OData requests to S4HC remote project entities
    srv.on("READ", "S4HCProjects", async (req) => {
    return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("READ", "S4HCEnterpriseProjectElement", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("READ", "S4HCEntProjEntitlement", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("READ", "S4HCEntProjTeamMember", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("READ", "S4HCProjectsProcessingStatus", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_ENTPROJECTPROCESSINGSTATUS_0001");
    });
    srv.on("READ", "S4HCProjectsProjectProfileCode", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_ENTPROJECTPROFILECODE_0001");
    });
    srv.on("CREATE", "S4HCProjects", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("CREATE", "S4HCEnterpriseProjectElement", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("CREATE", "S4HCEntProjEntitlement", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("CREATE", "S4HCEntProjTeamMember", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("CREATE", "S4HCProjectsProcessingStatus", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_ENTPROJECTPROCESSINGSTATUS_0001");
    });
    srv.on("CREATE", "S4HCProjectsProjectProfileCode", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_ENTPROJECTPROFILECODE_0001");
    });
    srv.on("UPDATE", "S4HCProjects", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("UPDATE", "S4HCEnterpriseProjectElement", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("UPDATE", "S4HCEntProjEntitlement", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("UPDATE", "S4HCEntProjTeamMember", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("UPDATE", "S4HCProjectsProcessingStatus", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_ENTPROJECTPROCESSINGSTATUS_0001");
    });
    srv.on("UPDATE", "S4HCProjectsProjectProfileCode", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_ENTPROJECTPROFILECODE_0001");
    });
    srv.on("DELETE", "S4HCProjects", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("DELETE", "S4HCEnterpriseProjectElement", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("DELETE", "S4HCEntProjEntitlement", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("DELETE", "S4HCEntProjTeamMember", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_API_ENTERPRISE_PROJECT_SRV_0002");
    });
    srv.on("DELETE", "S4HCProjectsProcessingStatus", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_ENTPROJECTPROCESSINGSTATUS_0001");
    });
    srv.on("DELETE", "S4HCProjectsProjectProfileCode", async (req) => {
        return await connectorS4HC.delegateODataRequests(req,"S4HC_ENTPROJECTPROFILECODE_0001");
    });
    ```
    > Note: Without delegation, the remote entities return the error code 500 with message "SQLITE_ERROR: no such table" (local testing).

2.  Determine the connected backend systems and get system name in the before-read event of author readings:
    ```javascript
    // Check connected backend systems
    srv.before("READ", "AuthorReadings", async (req) => {
        // S4HC
        S4HCIsConnectedIndicator = await reuse.checkDestination(req,"s4hc");  
        S4HCSystemName           = await reuse.getDestinationDescription(req,"s4hc-url");
    });
    ```
    > Note: The reuse function *getDestinationDescription* in file [reuse.js](../Applications/author-readings-mt/srv/reuse.js), returns the destination description from BTP consumer subaccount.

3.  Set the virtual element `createByDProjectEnabled` to control the visualization of the action to create projects dynamically in the after-read event of author readings and pass on the project system name:
    ```javascript
    // Update project system name and visibility of the "Create Project"-button
    if (authorReading.projectID) {
        authorReading.createS4HCProjectEnabled = false;   
        if(authorReading.projectSystem == 'S4HC') authorReading.projectSystemName = S4HCSystemName;        
    }else{            
        authorReading.createS4HCProjectEnabled = S4HCIsConnectedIndicator;
    }
    ```

3. Add implementation for action *CreateS4HCProject* as outlined in code block: 
    ```javascript
    // Entity action "createS4HCProject"
    srv.on("createS4HCProject", async (req) => {
        // see code in file ./service-implementation.js
    }
    ```

4. Add two lines to import the reuse functions in the beginning of the file:
    ```javascript
        const reuse = require("./reuse");
        const connectorS4HC = require("./connector-s4hc");
    ```
    Add two global varibales to buffer the status and the name of remote project management systems:
    ```javascript
    // Buffer status and name of project management systems
    var S4HCIsConnectedIndicator;
    var S4HCSystemName;
    ```

5. Add implementation to expand the author readings to remote projects (OData parameter `/AuthorReadings?$expand=toS4HCProject`) as outlined in code block:
    ```javascript
    // Expand author readings to remote projects
    srv.on("READ", "AuthorReadings", async (req, next) => {

        // Read the AuthorReading instances
        let authorReadings = await next();
    
        // Check and Read S4HC project related data 
        if ( S4HCIsConnectedIndicator ){
            authorReadings =  await connectorS4HC.readProject(authorReadings);  
        };

        // Return remote project data
        return authorReadings;
    });
    ```
    > Note: OData features like *$expand*, *$filter*, *$orderby*, ... need to be implemented in the service implementation.

### Enhance the Web App to display S/4 Data and navigate to the S/4 Project Overview

BAS: Edit the Fiori Elements annotations of the web app in file [annotations.cds](../Applications/author-readings-mt/app/authorreadingmanager/annotations.cds).

1. Add a facet "Project Data" to display information from the remote service by following the "toS4HCProject"-association:

    - Add S/4 project specific fields to field group *#ProjectData*:         
        ```javascript
        FieldGroup #ProjectData : {Data : [
            // Project system independend fields:
            {
                $Type : 'UI.DataFieldWithUrl',
                Value : projectID,
                Url   : projectURL,
                @UI.Hidden : false
            },
            {
                $Type : 'UI.DataField',
                Value : projectSystemName,
                @UI.Hidden : false
            },
            {
                $Type : 'UI.DataField',
                Value : projectSystem,
                @UI.Hidden : false
            },
            
            // S4HC specific fields
            {
                $Type : 'UI.DataField',
                Value : toS4HCProject.Project,
                @UI.Hidden : true 
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectDescription}',
                Value : toS4HCProject.ProjectDescription,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'S4HC' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectProfile}',
                Value : projectProfileCodeText,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'S4HC' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>responsibleCostCenter}',
                Value : toS4HCProject.ResponsibleCostCenter,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'S4HC' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>processingStatus}',
                Value : processingStatusText,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'S4HC' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectStartDateTime}',
                Value : toS4HCProject.ProjectStartDate,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'S4HC' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectEndDateTime}',
                Value : toS4HCProject.ProjectEndDate,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'S4HC' ] }, false, true ] } }
            }
        ]}
        ```

3. Add a button to the identification area:
    ```javascript
    {
        $Type  : 'UI.DataFieldForAction',
        Label  : '{i18n>createS4HCProject}',
        Action : 'AuthorReadingManager.createS4HCProject',            
        @UI.Hidden : { $edmJson : 
            { $If : 
                [
                    { $Eq : [ {$Path : 'createS4HCProjectEnabled'}, false ] },
                    true,
                    false
                ]
            }   
        }
    }
    ```
    > Note: We dynamically control the visibility of the button "Create Project in S4HC" based on the value of the transient field "createS4HCProjectEnabled".    

BAS: Edit language dependend labels in file [i18n.properties](./db/i18n/i18n.properties):

4. Add labels for project fields and the button to create projects:
    ```
    # -------------------------------------------------------------------------------------
    # Service Actions

    createS4HCProject        = Create Project in S4HC

    # -------------------------------------------------------------------------------------
    # Remote Project Elements

    projectTypeCodeText     = Project Type
    projectStatusCodeText   = Project Status
    projectCostCenter       = Cost Center
    projectStartDateTime    = Start Date
    projectEndDateTime      = End Date
    projectDescription      = Project Description
    projectProfile          = Project Profile
    responsibleCostCenter   = Responsible Cost Center
    processingStatus        = Processing Status
    ```        

### Deploy the application

Update your application in the provider sub-account and for detailed instructions refer to the section [Deploy the Multi-Tenant Application to a Provider Subaccount](44-Multi-Tenancy-Deployment.md#Deploy-the-Multi-Tenant-Application).
