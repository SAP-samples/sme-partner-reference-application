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

## Enhance the BTP App to Consume ByD OData APIs

In this chapter we import the ByD OData service as "remore service" into our CAP project and use the OData service to create ByD projects to plan and run author reading events.

### Import ByD OData Services

We will use the ByD OData service for projects to read and write ByD projects in context of a user interaction and to pull additional data in context of the event-based integration. Therefore we will consume the ByD OData service using two destinations with different authentication methods. Because of the one-to-one binding of remote services and destinations in CAP, we will import the ByD OData service for projects twice: once for a *OAuth 2.0 SAML Bearer authentication* to propagate the logged-in business user to ByD, and once for authentication by the technical user created with the *Communication Arrangement* in ByD.

ByD: Create EDMX-file from ByD Odata service:

1. Run the $metadata url of the ByD OData service in a browser window or Postman: https://{{ByDTenantHostname}}/sap/byd/odata/cust/v1/khproject/$metadata?sap-label=true&sap-language=en.

2. Save the service response payload with the metadata in two files with file-extension ".edmx":
    - File "byd_khproject.edmx" for user propagation,
    - File "byd_khproject_tech_user.edmx" for authentication by technical users.
    > Note: Ensure a unique file names without special chars except "_".

BAS: Import the ByD odata service into the CAP project:

3. Create a folder with name "external_resources" in the root folder of the application.

4. Open the context menu on folder "./external_resources" and upload both edmx-files with the OData services.

5. Open a terminal, navigate to folder "./application/author-readings", and import both edmx files using the commands `cds import ./external_resources/byd_khproject.edmx --as cds` and `cds import ./external_resources/byd_khproject_tech_user.edmx --as cds`. 

    > Note: Do not use the cds import command parameter `--keep-namespace`, because this results in a cds service name "cust", which would lead to service name clashes if you import multiple ByD custom odata services.

    After running the above command `cds import ...` the file *package.json* is updated with a cds configuration referring to the remote odata services, and a folder "./srv/external" with configuration files for the remote services has been created.
    
    > Note: Typically, remote services do not require any persistency. Make sure the entities in the corresponding ".cds"-files in folder `./srv/external` are annotated with `@cds.persistence.skip : true`. You may encounter errors during deployment with db-deployer service if the persistency-skip-annotation is missing.

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
    // Extend service AuthorReadingManager by ByD projects (principal propagation)

    using { byd_khproject as RemoteByDProject } from './external/byd_khproject';

    extend service AuthorReadingManager with {
        entity ByDProjects as projection on RemoteByDProject.ProjectCollection {
            key ObjectID as ID,
            ProjectID as projectID,
            ResponsibleCostCentreID as costCenter,
            ProjectTypeCode as typeCode,
            ProjectTypeCodeText as typeCodeText,
            ProjectLifeCycleStatusCode as statusCode,
            ProjectLifeCycleStatusCodeText as statusCodeText,
            BlockingStatusCode as blockingStatusCode,
            PlannedStartDateTime as startDateTime,
            PlannedEndDateTime as endDateTime,
            ProjectSummaryTask as summaryTask : redirected to ByDProjectSummaryTasks,
            Task as task : redirected to ByDProjectTasks                     
        }
        entity ByDProjectSummaryTasks as projection on RemoteByDProject.ProjectSummaryTaskCollection {
            key ObjectID as ID,
            ParentObjectID as parentID,
            ID as taskID,
            ProjectName as projectName,
            ResponsibleEmployeeID as responsibleEmployee,
            ResponsibleEmployeeFormattedName as responsibleEmployeeName
        }
        entity ByDProjectTasks as projection on RemoteByDProject.TaskCollection {
            key ObjectID as ID,
            ParentObjectID as parentID,
            TaskID as taskID,
            TaskName as taskName,
            PlannedDuration as duration,
            ResponsibleEmployeeID as responsibleEmployee,
            ResponsibleEmployeeFormattedName as responsibleEmployeeName
        }
    };
    ```
    
2. Enhance the service model of service *AuthorReadingManager* by an association to the remote project in ByD:
    ```javascript
    // Author readings (combined with remote project using mixin)
    @odata.draft.enabled
    entity AuthorReadings as select from armodels.AuthorReadings
        mixin {
            // ByD projects: Mix-in of ByD project data
            toByDProject: Association to RemoteByDProject.ProjectCollection on toByDProject.ProjectID = $projection.projectID
        } 
    ```

3. Enhance the service model of service *AuthorReadingManager* by virtual elements to control the visualization of actions and the coloring of status information:
    ```javascript
    // Author readings (combined with remote project using mixin)
    @odata.draft.enabled
    entity AuthorReadings as select from armodels.AuthorReadings
        mixin {
            // ByD projects: Mix-in of ByD project data
            toByDProject: Association to RemoteByDProject.ProjectCollection on toByDProject.ProjectID = $projection.projectID
        } 
        into  {
            *,
            virtual null as statusCriticality    : Integer  @title : '{i18n>statusCriticality}',
            // ByD projects: visibility of button "Create project in ByD"
            virtual null as createByDProjectEnabled : Boolean  @title : '{i18n>createByDProjectEnabled}'  @odata.Type : 'Edm.Boolean',
            toByDProject,
        }
    ```
    
4. Enhance the service model of service *AuthorReadingManager* by an action to create remote projects:
    ```javascript
    // ByD projects: action to create a project in ByD
    @(
        Common.SideEffects              : {TargetEntities: ['_authorreading','_authorreading/toByDProject']},
        cds.odata.bindingparameter.name : '_authorreading'
    )
    action createByDProject() returns AuthorReadings;
    ```
    > Note: The side effect annotation refreshes the project data right after executing the action.

5. Expose ByD project data throughout the CAP service model for technical users:
    ```javascript
    // -------------------------------------------------------------------------------
    // Extend service AuthorReadingManager by ByD projects (technical users)

    using { byd_khproject_tech_user as RemoteByDProjectTechUser } from './external/byd_khproject_tech_user';

    extend service AuthorReadingManager with {
        entity ByDProjectsTechUser as projection on RemoteByDProjectTechUser.ProjectCollection {
            key ObjectID as ID,
            ProjectID as projectID,
            ResponsibleCostCentreID as costCenter,
            ProjectTypeCode as typeCode,
            ProjectTypeCodeText as typeCodeText,
            ProjectLifeCycleStatusCode as statusCode,
            ProjectLifeCycleStatusCodeText as statusCodeText,
            BlockingStatusCode as blockingStatusCode,
            PlannedStartDateTime as startDateTime,
            PlannedEndDateTime as endDateTime                    
        }
    };
    ```
    > Note: The remote access to projects via technical user is used for asynchronous processes such as event-based integrations only. Therefore, it is not required to mix-in the remote project entity for technical users into the the main entity *AuthorReadings*. Furthermore, for our example project header data is sufficient and therefore we do not include project tasks into the project model for technical users.

### Enhance the Authentication Model to cover Remote Projects

BAS: Extend the authorization annotation of the CAP service model by restrictions referring to the remote services:

1. Open file `./application/author-readings/srv/service-auth.cds` with the authorization annotations.

2. Enhance the authorization model for the service entities `ByDProjects`, `ByDProjectSummaryTasks`, `ByDProjectTasks` and `ByDProjectsTechUser`:
    ```javascript
    // ByD projects: Managers and Administrators can read and create remote projects
    annotate AuthorReadingManager.ByDProjects with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grand : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    annotate AuthorReadingManager.ByDProjectSummaryTasks with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grand : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    annotate AuthorReadingManager.ByDProjectTasks with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grand : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    annotate AuthorReadingManager.ByDProjectsTechUser with @(restrict : [
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

Some reuse functions specific for ByD have been defined in a separate file. 
Copy the ByD reuse functions in file [connector-byd.js](../Applications/author-readings/srv/connector-byd.js) into your project.

### Enhance the Business Logic to operate on ByD Data

BAS: Enhance the implementation of the CAP services in file `./application/author-readings/srv/service-implementation.js` to create and read ByD project data using the remote ByD OData service. 

1. Delegate requests to the remote OData service: 
    ```javascript
    // Delegate OData requests to remote project entities
    srv.on("READ", "ByDProjects", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("READ", "ByDProjectSummaryTasks", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("READ", "ByDProjectTasks", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("CREATE", "ByDProjects", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("CREATE", "ByDProjectSummaryTasks", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("CREATE", "ByDProjectTasks", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("UPDATE", "ByDProjects", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("UPDATE", "ByDProjectSummaryTasks", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("UPDATE", "ByDProjectTasks", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("DELETE", "ByDProjects", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("DELETE", "ByDProjectSummaryTasks", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("DELETE", "ByDProjectTasks", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject");
    });
    srv.on("READ", "ByDProjectsTechUser", async (req) => {
        return await connectorByD.delegateODataRequests(req,"byd_khproject_tech_user");
    });
    ```
    > Note: Without delegation, the remote entities return the error code 500 with message "SQLITE_ERROR: no such table" (local testing).

2. Set the virtual element `createByDProjectEnabled` to control the visualization of the action to create projects dynamically in the read-event of author readings:
    ```javascript
    if (each.projectID) {
        each.createByDProjectEnabled = false;
    } else {
        each.createByDProjectEnabled = true;
    }
    ```

3. Add implementation for action *CreateByDProject* as outlined in code block: 
    ```javascript
    // Entity action "createByDProject"
    srv.on("createByDProject", async (req) => {
        // see code in file ./service-implementation.js
    }
    ```
    Add two lines to import the reuse functions in the beginning of the file:
    ```javascript
     const reuse = require("./reuse");
     const connectorByD = require("./connector-byd");
    ```
    > Note: The code block *Read the ByD system URL dynamically from BTP destination "byd-url"* reads the URL of the ByD system used to navigate to the ByD project overview screen. We are using the reuse function *getDestinationURL* to read dynamically the BTP destination (refer to file `./srv/reuse.js` for details of the reusable function getDestinationURL).
    
    > Note: The code block *Set URL of ByD project overview screen for UI navigation* assembles the URL of the ByD project overview screen used for UI navigations lateron. 

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

7. Add implementation to expand the author readings to remote projects (OData parameter `/AuthorReadings?$expand=toByDProject`) as outlined in code block:
    ```javascript
    // Expand author readings to remote projects (OData parameter "/AuthorReadings?$expand=toByDProject")
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
                $Type : 'UI.DataField',
                Value : projectSystem,
                @UI.Hidden : false
            },
                    {
                $Type : 'UI.DataFieldWithUrl',
                Value : projectID,
                Url   : projectURL,
                @UI.Hidden : false
            },
            // SAP Business ByDesign specific fields
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
            }
        ]},
        ```

3. Add a button to the identification area:
    ```javascript
    {
        $Type  : 'UI.DataFieldForAction',
        Label  : '{i18n>createByDProject}',
        Action : 'AuthorReadingManager.createByDProject',            
        @UI.Hidden : { $edmJson : 
            { $If : 
                [
                    { $Eq : [ {$Path : 'createByDProjectEnabled'}, false ] },
                    true,
                    false
                ]
            }   
        }
    }
    ```
    > Note: We dynamically control the visibility of the button *Create Project in ByD* based on the value of the transient field *createByDProjectEnabled*.    

BAS: Edit language dependend labels in file `./db/i18n/i18n.properties`:

4. Add labels for project fields and the button to create projects:
    ```
    # -------------------------------------------------------------------------------------
    # Service Actions

    createByDProject        = Create Project in ByD

    # -------------------------------------------------------------------------------------
    # Remote Project Elements

    projectTypeCodeText     = Project Type
    projectStatusCodeText   = Project Status
    projectCostCenter       = Cost Center
    projectStartDateTime    = Start Date
    projectEndDateTime      = End Date

    # -------------------------------------------------------------------------------------
    # Web Application Titles

    projectData             = Project Data
    ```        

### Enhance the Configuration of the CAP Project

Enhance the file `package.json` by sandbox-configurations for local testing and productive configurations:
```json
"byd_khproject": {
    "kind": "odata-v2",
    "model": "srv/external/byd_khproject",
    "[sandbox]": {
        "credentials": {
            "url": "https://{{ByD-hostname}}/sap/byd/odata/cust/v1/khproject/",
            "authentication": "BasicAuthentication",
            "username": "{{ByD-business-user}}",
            "password": "{{password}}"
        }
    },
    "[production]": {
        "credentials": {
            "destination": "byd",
            "path": "/sap/byd/odata/cust/v1/khproject"
        }
    }        
},
"byd_khproject_tech_user": {
    "kind": "odata-v2",
    "model": "srv/external/byd_khproject_tech_user",
    "[sandbox]": {
        "credentials": {
            "url": "https://{{ByD-hostname}}/sap/byd/odata/cust/v1/khproject/",
            "authentication": "BasicAuthentication",
            "username": "{{ByD-business-user}}",
            "password": "{{password}}"
        }
    },
    "[production]": {
        "credentials": {
            "destination": "byd-tech-user",
            "path": "/sap/byd/odata/cust/v1/khproject"
        }
    }        
}
```
> Note: The *package.json* refers to two destinations `byd` and `byd-tech-user` that need to be created in the consumer BTP subaccount. The destinations `byd` should refer to business users with principal propagation, and the destination `byd-tech-user` should refer to a technical user. Compare next chapter.

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
