# Integrate the BTP Application with *S/4HANA Cloud for Projects, collaborative project management*

In this chapter we enhance the BTP application to support *S/4HANA Cloud for Projects, collaborative project management* (C4P) as backend. 

Frontend integration:

1. Navigate from the BTP app to related C4P collaboration projects.
2. Navigate from C4P collaboration projects to related author reading instances of the BTP app.

Back-channel integration:

3. Create collaboration projects from the BTP app and display C4P project information on the web application of the BTP app using OData APIs with principal propagation.

## Enhance the BTP App to Consume C4P OData APIs

In this chapter we import the C4P OData services as "remote services" into our CAP project and use the OData service to create collaboration projects in C4P to plan and run author reading events.

### Import C4P OData Services

We use the C4P OData services for collaboration projects to create and read collaboration projects in context of user interactions. 

C4P: Create EDMX-file from C4P Odata services:

1. Search for the following OData APIs on the [SAP API Business Hub](https://api.sap.com/package/SAPProjectIntelligenceNetwork/all) and download the metadata files (edmx-files):
    - [*Project Service*, *Manage collaboration projects using OData API*](https://api.sap.com/api/ProjectService/overview) (OData v4)
    - [*Task Service*, *Manage tasks in a project*](https://api.sap.com/api/TaskService/overview) (OData v4)
    - [*Reference Service*, *Manage references in a project*](https://api.sap.com/api/ReferenceService/overview) (OData v4)
2. Rename the metadata files (edmx-files) and add the prefix "C4P_" to avoid naming conflicts:
    -  C4P_ProjectService.edmx
    -  C4P_TaskService.edmx
    -  C4P_ReferenceService.edmx

Business Application Studio (BAS): Import the C4P OData services into the CAP project:

3. Open the context menu on folder "./external_resources" and upload the edmx-files with the OData services as remote services.

4. Open a terminal, navigate to folder "./application/author-readings-mt", and import the remote service using the command:  
`cds import ./external_resources/C4P_ProjectService.edmx --as cds`. 

    Repeat the `cds import` command for other two services.

    In result the system created cds-files in folder "./srv/external" for all remote services and enhanced file "package.json" by a cds-configurations referring to the remote services.

    > Note: Do not use the cds import command parameter `--keep-namespace`, because it may lead to service name clashes if you import multiple odata services.

  5. Enhance the file [package.json](../Applications/author-readings-mt/package.json) by sandbox-configurations for local testing and to refer to the destinations used for productive setups:  

        ```json
        "cds": {
            "c4p_ProjectService": {
                "kind": "odata",
                "model": "srv/external/c4p_ProjectService",
                "[production]": {
                    "credentials": {
                        "destination": "c4p",
                        "path": "/ProjectService/v1"
                    }
                }
            },
            "c4p_TaskService": {
                "kind": "odata",
                "model": "srv/external/c4p_TaskService",
                "[production]": {
                    "credentials": {
                        "destination": "c4p",
                        "path": "/TaskService/v1"
                    }
                }
            }        
        },
        ```

        > Note: The *package.json* refers to the destination "c4p" that needs to be created in the consumer BTP subaccount. The destination "c4p" is used for remote service calls with principal propagation. Compare next chapter.

### Enhance the Service Model by the Remote Service

BAS: Extend the CAP service model by the remote entities:

1. Open file [service-models.cds](../Applications/author-readings-mt/srv/service-models.cds) with the service models.

2. Expose C4P project data throughout the CAP service model for principal propagation:
    ```javascript
    // -------------------------------------------------------------------------------
    // Extend service AuthorReadingManager by C4P Projects

    using { c4p_ProjectService as RemoteC4PProject } from './external/c4p_ProjectService';

    extend service AuthorReadingManager with {
        entity C4PProject as projection on RemoteC4PProject.Projects {
            key id as projectId,
            displayId as displayId,
            name as projectName,
            status as status,
            startDate as startDate,
            endDate as endDate,
            location as locationAdress,
            description as description
        }    
    };

    // -------------------------------------------------------------------------------
    // Extend service AuthorReadingManager by C4P Tasks

    using { c4p_TaskService as RemoteC4PTask } from './external/c4p_TaskService';

    extend service AuthorReadingManager with {
        entity C4PTask as projection on RemoteC4PTask.Tasks {
            key id as taskId,
            projectId as projectId,
            displayId as displayId,
            taskType as taskType,
            subject as subject,
            description as description,
            category as category,
            startDate as startDate,
            dueDate as dueDate,
            priority as priority,
            effortValue as effortValue,
            effortUnit as effortUnit
        }    
    }; 
    ```
    
2. Enhance the service model of service *AuthorReadingManager* by an association to the remote project in C4P (mix-in):
    ```javascript
    // Author readings (combined with remote project using mixin)
    @odata.draft.enabled
    entity AuthorReadings as select from armodels.AuthorReadings
        mixin {
            // C4P projects: Mix-in of C4P project data
            toC4PProject: Association to RemoteC4PProject.Projects on toC4PProject.displayId = $projection.projectID;
        } 
    ```

3. Enhance the service model of service *AuthorReadingManager* by virtual elements to control the visualization of actions and the coloring of status information:
    ```javascript
    // Author readings (combined with remote project using mixin)
    @odata.draft.enabled
    entity AuthorReadings as select from armodels.AuthorReadings
        mixin {
            // C4P projects: Mix-in of C4P project data
            toC4PProject: Association to RemoteC4PProject.Projects on toC4PProject.displayId = $projection.projectID;
        } 
        into  {
            *,
            virtual null as statusCriticality    : Integer @title : '{i18n>statusCriticality}',
            virtual null as projectSystemName    : String  @title : '{i18n>projectSystemName}' @odata.Type : 'Edm.String',

            // C4P projects: visibility of button "Create project in C4P"
            virtual null as createC4PProjectEnabled : Boolean  @title : '{i18n>createC4PProjectEnabled}'  @odata.Type : 'Edm.Boolean',
            toC4PProject,
        }
    ```
    
4. Enhance the service model of service *AuthorReadingManager* by an action to create remote projects:
    ```javascript
    // C4P projects: action to create a project in C4P
    @(
        Common.SideEffects              : {TargetEntities: ['_authorreading','_authorreading/toC4PProject']},
        cds.odata.bindingparameter.name : '_authorreading'
    )
    action createC4PProject() returns AuthorReadings;
    ```
    > Note: The side effect annotation refreshes the project data right after executing the action.

### Enhance the Authentication Model to cover Remote Projects

BAS: Extend the authorization annotation of the CAP service model by restrictions referring to the remote services:

1. Open file [service-auth.cds](../Applications/author-readings-mt/srv/service-auth.cds) with the authorization annotations.

2. Enhance the authorization model for the service entities `C4PProject` and `C4PTask`:
    ```javascript
    // C4P projects: Managers and Administrators can read and create remote projects
    annotate AuthorReadingManager.C4PProject with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grant : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);
    annotate AuthorReadingManager.C4PTask with @(restrict : [
        {
            grant : ['*'],
            to    : 'AuthorReadingManagerRole',
        },
        {
            grant : ['*'],
            to    : 'AuthorReadingAdminRole'
        }
    ]);    
    ```
    
### Create a file with Reuse Functions for C4P

Some reuse functions specific for C4P are defined in a separate file. 
Copy the C4P reuse functions in file [connector-c4p.js](../Applications/author-readings-mt/srv/connector-c4p.js) into your project.

### Enhance the Business Logic to operate on C4P Data

BAS: Enhance the implementation of the CAP services in file [service-implementation.js](../Applications/author-readings-mt/srv/service-implementation.js) to create and read C4P project data using the remote C4P OData services. 

1. Delegate requests to the remote OData service: 
    ```javascript
    // ----------------------------------------------------------------------------
    // Implementation of remote OData services (back-channel integration with C4P)

    // Delegate OData requests to C4P remote project entities
    srv.on("READ", "C4PProject", async (req) => {
        return await connectorC4P.delegateODataRequests(req,"c4p_ProjectService");
    });
    srv.on("READ", "C4PTask", async (req) => {
        return await connectorC4P.delegateODataRequests(req,"c4p_TaskService");
    });
    srv.on("CREATE", "C4PProject", async (req) => {
        return await connectorC4P.delegateODataRequests(req,"c4p_ProjectService");
    });
    srv.on("CREATE", "C4PTask", async (req) => {
        return await connectorC4P.delegateODataRequests(req,"c4p_TaskService");
    });
    srv.on("UPDATE", "C4PProject", async (req) => {
        return await connectorC4P.delegateODataRequests(req,"c4p_ProjectService");
    });
    srv.on("UPDATE", "C4PTask", async (req) => {
        return await connectorC4P.delegateODataRequests(req,"c4p_TaskService");
    });
    srv.on("DELETE", "C4PProject", async (req) => {
        return await connectorC4P.delegateODataRequests(req,"c4p_ProjectService");
    });
    srv.on("DELETE", "C4PTask", async (req) => {
        return await connectorC4P.delegateODataRequests(req,"c4p_TaskService");
    });
    ```
    > Note: Without delegation, the remote entities return the error code 500 with message "SQLITE_ERROR: no such table" (local testing).

2.  Determine the connected backend systems and get system name in the before-read event of author readings:
    ```javascript
    // Check connected backend systems
    srv.before("READ", "AuthorReadings", async (req) => {

        // C4P
        C4PIsConnectedIndicator  = await reuse.checkDestination(req,"c4p"); 
        C4PSystemName            = await reuse.getDestinationDescription(req,"c4p-url");
    });
    ```
    > Note: The reuse function *getDestinationDescription* in file [reuse.js](../Applications/author-readings-mt/srv/reuse.js), returns the destination description from BTP consumer subaccount.

3.  Set the virtual element `createByDProjectEnabled` to control the visualization of the action to create projects dynamically in the after-read event of author readings and pass on the project system name:
    ```javascript
    // Update project system name and visibility of the "Create Project"-button
    if (authorReading.projectID) {
        authorReading.createC4PProjectEnabled = false;   
        if(authorReading.projectSystem == 'C4P') authorReading.projectSystemName = C4PSystemName;        
    }else{            
        authorReading.createC4PProjectEnabled = C4PIsConnectedIndicator;
    }
    ```

3. Add implementation for action *CreateS4HCProject* as outlined in code block: 
    ```javascript
    // Entity action: Create C4P Enterprise Project
    srv.on("createC4PProject", async (req) => {
        // see code in file ./service-implementation.js
    }
    ```

4. Import the C4P reuse functions at the top of the file:
    ```javascript
    // Include cds libraries and reuse files
    const connectorC4P = require("./connector-c4p");
    ```
    Add two global varibales to buffer the status and the name of remote project management systems:
    ```javascript
    // Buffer status and name of project management systems
    var C4PIsConnectedIndicator;
    var C4PSystemName;
    ```

5. Add implementation to expand the author readings to remote projects (OData parameter `/AuthorReadings?$expand=toC4PProject`) as outlined in code block:
    ```javascript
    // Expand author readings to remote projects
    srv.on("READ", "AuthorReadings", async (req, next) => {

        // Read the AuthorReading instances
        let authorReadings = await next();
    
        // Check and Read C4P project related data 
        if ( C4PIsConnectedIndicator ){
            authorReadings =  await connectorC4P.readProject(authorReadings);  
        };

        // Return remote project data
        return authorReadings;
    });
    ```
    > Note: OData features like *$expand*, *$filter*, *$orderby*, ... need to be implemented in the service implementation.


