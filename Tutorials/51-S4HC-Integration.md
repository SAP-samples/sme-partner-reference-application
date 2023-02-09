# Integrate the BTP Application with *S/4HANA Cloud, public edition*

In this chapter we integrate the BTP application with the enterprise project management of *SAP S/4HANA Cloud, public edition* (S/4).

Frontend integration:
1. Launch the BTP app from the S/4 launchpad,
2. Launch BTP administration applications such as the IAS admin app from the S/4 launchpad,
3. Navigate from the BTP app to related S/4 enterprise projects,
4. Single sign-on for S/4, the BTP app and all BTP admin apps using the S/4 IAS tenant as IDP.

Back-channel integration:

5. Create S/4 enterprise projects from the BTP app and display S/4 project information in the BTP app using OData APIs with principal propagation.

**--- THIS PAGE IS WORK IN PROCESS. ---**

## Enhance the BTP App to Consume S/4 OData APIs

In this chapter we import the S/4 OData service as "remote service" into our CAP project and use the OData service to create S/4 enterprise projects to plan and run author reading events.

### Import S/4 OData Services

We will use the S/4 OData service for enterprise projects to read and write S/4 projects in context of a user interaction . We will consume the S/4 OData service using BTP destinations with a *OAuth 2.0 SAML Bearer authentication* to propagate the logged-in business user to S/4.

S/4: Create EDMX-file from S/4 Odata service:

1. Run the $metadata url of the S/4 OData service in a browser window or Postman: https://{{hostname}}/sap/opu/odata/sap/API_ENTERPRISE_PROJECT_SRV;v=0002/$metadata?sap-label=true&sap-language=en

2. Save the service response payload with the metadata in two files with file-extension ".edmx":
    - File "S4HC_API_ENTERPRISE_PROJECT_SRV_0002" for user propagation

BAS: Import the S/4 odata service into the CAP project:

3. Create a folder with name "external_resources" in the root folder of the application.

4. Open the context menu on folder "./external_resources" and upload both edmx-files with the OData services.

5. Open a terminal, navigate to folder "./application/author-readings", and import both edmx files using the commands `cds import ./external_resources/S4HC_API_ENTERPRISE_PROJECT_SRV_0002.edmx --as cds` . 

    > Note: Do not use the cds import command parameter `--keep-namespace`, because this results in a cds service name "cust", which would lead to service name clashes if you import multiple ByD custom odata services.

    After running the above command `cds import ...` the file *package.json* is updated with a cds configuration referring to the remote odata services, and a folder "./srv/external" with configuration files for the remote services has been created.
    
### Enhance the entity model to store key project information

BAS: Enhance the CAP entity models in file `./application/author-readings/db/entity-models.cds` by elements to store project key information to associate author readings to projects in remote ERP systems.

1. Enhance the entity `AuthorReadings` by the elements:
    ```javascript
    projectID               : String;
    projectObjectID         : String;
    projectURL              : String;
    projectSystem           : String;  
    ```  

2. Enhance the annotations of entity `AuthorReadings` by the elements:
    ```javascript
    projectID               @title : '{i18n>projectID}';
    projectObjectID         @title : '{i18n>projectObjectID}';
    projectURL              @title : '{i18n>projectURL}';
    projectSystem           @title : '{i18n>projectSystem}';
    ```  

3. Enhance the labels for entity AuthorReadings in file `./application/author-readings/db/i18n/i18n.properties` by the labels:
    ```javascript
    projectID               = Project
    projectObjectID         = Project UUID
    projectURL              = Project URL
    projectSystem           = Project System
    ```  

### Enhance the Service Model by the Remote Service

BAS: Extend the CAP service model by the remote entities:

1. Open file `./application/author-readings/srv/service-models.cds` with the service models.

2. Expose ByD project data throughout the CAP service model for principal propagation:
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
            virtual null as statusCriticality    : Integer  @title : '{i18n>statusCriticality}',
            // S4HC projects: visibility of button "Create project in S4HC"
            virtual null as createS4HCProjectEnabled : Boolean  @title : '{i18n>createS4HCProjectEnabled}'  @odata.Type : 'Edm.Boolean',
            toS4HCProject,
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

1. Open file `./application/author-readings/srv/service-auth.cds` with the authorization annotations.

2. Enhance the authorization model for the service entities `ByDProjects`, `ByDProjectSummaryTasks`, `ByDProjectTasks` and `ByDProjectsTechUser`:
    ```javascript
    // ByD projects: Managers and Administrators can read and create remote projects
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
    ```

### Create a file with Reuse Functions for ByD

Some reuse functions specific for S/4 have been defined in a separate file. 
Copy the S/4 reuse functions in file [connector-s4hc.js](../Applications/author-readings/srv/connector-s4hc.js) into your project.

### Enhance the Business Logic to operate on ByD Data

BAS: Enhance the implementation of the CAP services in file `./application/author-readings/srv/service-implementation.js` to create and read S/4 enterprise project data using the remote S/4 OData service. 

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

2. Set the virtual element `createS4HCProjectEnabled` to control the visualization of the action to create projects dynamically in the read-event of author readings:
    ```javascript
    if (each.projectID) {
        each.createS4HCProjectEnabled = false;
    } else {
        each.createS4HCProjectEnabled = true;
    }
    ```

3. Add implementation for action *CreateS4HCProject* as outlined in code block: 
    ```javascript
    // Entity action "createS4HCProject"
    srv.on("createS4HCProject", async (req) => {
        // see code in file ./service-implementation.js
    }
    ```
    Add two lines to import the reuse functions in the beginning of the file:
    ```javascript
     const reuse = require("./reuse");
     const connectorS4HC = require("./connector-s4hc");
    ```
    > Note: The code block *Read the S/4 system URL dynamically from BTP destination "byd-sh4c"* reads the URL of the S/4 system used to navigate to the S/4 enterprise project screen. We are using the reuse function *getDestinationURL* to read dynamically the BTP destination (refer to file `./srv/reuse.js` for details of the reusable function getDestinationURL).
    
    > Note: The code block *Set URL of S/4 enterprise project screen for UI navigation* assembles the URL of the S/4 project screen used for UI navigations lateron. 

4. Add a new function *getDestinationURL* in the file `reuse.js` in folder `./srv` (Refer to the file to check the required code). 

    > Note: The reuse function *getDestinationURL* is designed such that it works for single-tenant as well as for multi-tenant applications. For single-tenant deployments it reads the destination from the BTP subaccount that hosts the app, for multi-tenant deployments it reads the destination from the subscriber subaccount. We achieve this system behavior by pasing the JWT-token of the logged-in user to the function to get the destination. The JWT-token contains the tenant information.

5. Since we are using the npm module *@sap-cloud-sdk/connectivity* in file *reuse.js*, we need to add the corresponding npm module to the dependencies in the `package.json` file:
    ```json
    "dependencies": {
        "@sap-cloud-sdk/connectivity": "^2.8.0"
    },
    ```

6. Add system message in file `./application/author-readings/srv/i18n/messages.properties`: 
    ```javascript
    ACTION_CREATE_PROJECT_DRAFT=Projects cannot be created for draft author readings
    ```

7. Add implementation to expand the author readings to remote projects (OData parameter `/AuthorReadings?$expand=toS4HCProject`) as outlined in code block:
    ```javascript
    // Expand author readings to remote projects (OData parameter "/AuthorReadings?$expand=toS4HCProject")
    srv.on("READ", "AuthorReadings", async (req, next) => {     
        // see code in file ./service-implementation.js        
    }
    ```
    > Note: OData features like *$expand*, *$filter*, *$orderby*, ... need to be implemented in the service implementation.

### Enhance the Web App to display ByD Data and navigate to the ByD Project Overview

BAS: Edit the Fiori Element annotations of the web app in file `./app/authorreadingmanager/annotations.cds`:

1. Add project elements to the Author readings floorplan (already done in previous steps):
    - Selection fields:
        ```javascript
        SelectionFields : [
            identifier,
            date,
            maxParticipantsNumber,
            availableFreeSlots,
            statusCode_code,
            participantsFeeAmount,
            projectID,
            projectSystem        
        ],
        ```  
    - Table columns:
        ```javascript
        {
            $Type : 'UI.DataFieldWithUrl',
            Value : projectID,
            Url   : projectURL
        },
        {
            $Type : 'UI.DataField',
            Value : projectSystem
        },
    	```
    - Header facet, field group *#Values*:
        ```javascript
        {
            $Type : 'UI.DataFieldWithUrl',
            Value : projectID,
            Url   : projectURL
        }        
        ```

2. Add a facet *Project Data* to display information from the remote service by following the *toByDProject*-association:
    - Add facet:
        ```javascript
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>projectData}',
            ID     : 'ProjectData',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#ProjectData],
                ID     : 'ProjectData'
            }],
        },         
        ```
    - Add a field group *#ProjectData*:         
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
            
            // SAP Business ByDesign specific fields
            {
                $Type : 'UI.DataField',
                Value : toByDProject.projectID,
                @UI.Hidden : true 
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectTypeCodeText}',
                Value : toByDProject.typeCodeText,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectStatusCodeText}',
                Value : toByDProject.statusCodeText,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectCostCenter}',
                Value : toByDProject.costCenter,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectStartDateTime}',
                Value : toByDProject.startDateTime,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>projectEndDateTime}',
                Value : toByDProject.endDateTime,
                @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
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
        Action : 'AuthorReadingManager.createS4HcProject',            
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
    > Note: We dynamically control the visibility of the button *Create Project in S4HC* based on the value of the transient field *createS4HCProjectEnabled*.    

BAS: Edit language dependend labels in file `./db/i18n/i18n.properties`:

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


    # -------------------------------------------------------------------------------------
    # Web Application Titles

    projectData             = Project Data
    ```        

### Enhance the Configuration of the CAP Project

Enhance the file `package.json` by sandbox-configurations for local testing and productive configurations:
```json
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
      }
```
> Note: The *package.json* refers to two destinations `s4hc` that need to be created in the consumer BTP subaccount. The destinations `s4hc` should refer to business users with principal propagation. Compare next chapter.

Add a new cds-feature `fetch_csrf` in file *package.json* to enable the management of cross site request forgery tokens (required for POST-requests at runtime using destinations of type *BasicAuthentication*):
```json
"cds": {
    "features": {
        "fetch_csrf": true
    },
}      
```
> Note: By default CAP does not handle csrf-tokens for POST requests. Remote services may fail if csrf-tokens are required.

### Local Test

BAS: Open a terminal and start the app with the sandbox profile using the run command `cds watch --profile sandbox`. 
Use the test users as listed in file `.cdsrc.json`. Test the critical connection points to ByD.

1. Test the *Service Endpoints* for `Projects`, `ProjectSummaryTasks`, `ProjectTasks` and `ProjectsTechUser`: The system should return the respective data from ByD (without filtering).

2. Open the *Web Application* `/authorreadingmanager/webapp/index.html` and open one of the author readings. Click on `Create Project`. The system should create a project in ByD and display the details in section *Project Details*.
Click on the project link and the system should open a browser window with the ByD project overview.

3. Test the *Service Endpoints* for `AuthorReadings` and note the ID of the author reading for whwich you created the ByD project in test 2 as **author-reading-ID**.
Append `(ID={{author-reading-ID}},IsActiveEntity=true)?$select=toProject&$expand=toProject($select=ID,costCenter,endDateTime,startDateTime,statusCodeText,typeCodeText)` to the service endpoint URL, replace the place holder "{{author-reading-ID}}" by the **author-reading-ID** and run again.
The system should return the record with the project ID and the ByD project details as sub-node.

> Note: If you would like to switch users, the browser cache needs to be cleared before. This can be for example done in Chrome by pressing CTRL+SHIFT+DEL (or in German: STRG+SHIFT+ENTF), go to `Advanced` and choose a time range and `Passwords and other sign-in data`.

### Deploy the application

See [Deploy to Cloud Foundry](03-One-Off-Deployment.md#deploy-to-cloud-foundry).
