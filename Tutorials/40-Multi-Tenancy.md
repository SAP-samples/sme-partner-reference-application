# Enhance the BTP Application for Multi-Tenancy

In our approach of progressive development from a customer-specific single-tenant application to multi-customer application, we keep the single-tenant application as is and start developing the multi-tenant version of the app based on a copy.

*SAP Business Application Studio* (BAS): 
1. Open a terminal and navigate to folder *Applications* using the command `cd Applications/`.
2. Copy the author readings application using the command `cp -R author-readings/ author-readings-mt/`.

In result you have a second (identical) application in folder `author-readings-mt/`. This application is using the same names and IDs as the single tenant version in folder `author-readings/` and therefore both apps cannot be deployed into the same BTP subaccount. Hence, in all following steps we create new subaccounts for the multi-tenant version of our author readings application to avoid name clashes.

## Enable Multi-Tenancy

The enablement of multi-tenancy basically requires 3 steps:
1. Replace the SAP Launchpad by a custom application router. 
2. Add and configure the multi-tenant extension module (mtx-module) and adopt service plans where needed.
3. Remove the event-based integration based on the SAP Event Mesh, which does not yet support multi-tenancy. 

### Add Custom Application Router 

For the multi-tenant application we will connect each tenant to the launchpad of the respective ERP solution respectively the central launchpad of the respective customer. 
In the light of this setup we simplify our application and replace the usage of the SAP Launchpad (which includes a managed application router) by a custom application router without launchpad.

> Note: This setup is a suitable setup for the single-tenant version of app as well, if no launchpad is required.

*SAP Business Application Studio*: 

1. Add the application router to the web application module. Create file `package.json` in folder `./author-readings-mt/app/` with the following content:
    ```json
    {
        "name": "approuter",
        "dependencies": {
            "@sap/approuter": "^10"
        },
        "engines": {
            "node": "^16"
        },
        "scripts": {
            "start": "node node_modules/@sap/approuter/approuter.js"
        }
    }
    ``` 

2. Add route configuration for the web application. Create file `xs-app.json` in folder `./author-readings-mt/app/` with the following content:
    ```json
    {
        "authenticationMethod": "route",
        "routes": [
            {
                "source": "^/app/(.*)$",
                "target": "$1",
                "localDir": ".",
                "authenticationType": "xsuaa",
                "cacheControl": "no-cache, no-store, must-revalidate"
            },
            {
                "source": "^/(.*)$",
                "target": "$1",
                "destination": "srv-api",
                "authenticationType": "xsuaa",
                "csrfProtection": true
            }
        ]
    }
    ``` 
    > Note: The destination `srv-api` refers to the application router module in file `mta.yaml` in the next step.

3. Add application router module to the project deployment configuration. Enhance file `mta.yaml` in the project root folder by the following content:
    ```yml
    # Application router module
    - name: author-readings
      type: approuter.nodejs
      path: app/ 
      parameters:
        keep-existing-routes: true
        disk-quota: 256M
        memory: 256M
      requires:
        - name: srv-api
          group: destinations
          properties:
            name: srv-api # Compare ./app/xs-app.json
            url: ~{srv-url}
            forwardAuthToken: true
        - name: author-readings-uaa
        - name: mtx-api
          group: destinations
          properties:
            name: mtx-api 
            url: ~{mtx-url}
      properties:
        TENANT_HOST_PATTERN: "^(.*)-${default-uri}"
    ```
    > Note: The application router module refers to the mtx module that we will add in the next step; dont't bother about the reference error here.

4. Create new folder `approuter` on root level of project `author-readings-mt`. Move files `./app/package.json` and `./app/xs-app.json` to folder ./approuter`. 
    > Note: By this step we run and configure the application router centrally such that it can be **reused** by multiple web applications (for example if you create a second app for author reading participants later on). Furthermore the appplication router is now ready for **exit implementations** (for example to set specific environment variables, properties, URL header properties like access origins for CORS checks, write log for tracing, ...).

5. Open file `./approuter/xs-app.json` and remove the routes. The xs-app.json only contains generic routes that apply for all web applications. In our example, we have app specific routes only. However, we have to keep the xs-app.json for the application router for project consistency.

6. Adopt file `./app/authorreadingmanager/xs-app.json`. 
**TODO**


### Add Configuration for Multi-Tenancy 

In this step we refactor the project deployment configuration to run a multi-tenant application with subscriptions.

*SAP Business Application Studio*: 

1. Open file `package.json` on the project root level and apply the following changes:
    
    1. Remove the node module dependency to the event mesh:
        ```json
        "dependencies": {
            "@sap/xb-msg-amqp-v100": "^0.9.51",
        }
        ```
    
    2. Add the mtx node module:
        ```json
        "dependencies": {
            "@sap/cds-mtx": "^2"
        }
        ```

    3. Remove the cds-consfiguration related to the event mesh: 
        ```json
        "cds": {
            "requires": {
                "outbound_messaging": {
                    "kind": "enterprise-messaging-shared",
                    "format": "cloudevents",
                    "publishPrefix": "sap/samples/authorreadings/",
                    "webhook": {
                        "waitingPeriod": 60000,
                        "qos": 0
                    }
                },
                "byd_messaging": {
                    "kind": "enterprise-messaging-shared",
                    "queue": {
                        "name": "sap/samples/authorreadings/bydprojectevents"
                    },
                    "webhook": {
                        "waitingPeriod": 60000,
                        "qos": 0
                    }
                }
            }
        }        
         ```
    4. Add the production cds configuration for multi-tenancy:
        ```json
        "cds": {
            "requires": {
                "[production]": {
                    "db": {
                        "kind": "hana-mt"
                    },
                    "auth": {
                        "kind": "xsuaa"
                    },
                    "approuter": {
                        "kind": "cloudfoundry"
                    }
                },
                "multitenancy": true,
            }
        }
        ```

    5. Add the cds configuration for the mtx module:
        ```json
        "cds": {
            "mtx": {
                "element-prefix": "Z_",
                "namespace-blocklist": [],
                "extension-allowlist": []
            }      
        }
        ```
2. Open file `mta.yaml` on the project root level and apply the following changes:

    1. Adopt the *Application service module*: Remove the event mesh, add the registry and add the properties for the mtx-module and the application subscription:
        ```yml
        # Service module
        - name: author-readings-srv
          type: nodejs
          path: gen/srv
          requires:
            - name: author-readings-db
            - name: author-readings-uaa
            - name: author-readings-destination-service
            - name: author-readings-auditlog 
            - name: author-readings-registry 
          provides:
            - name: srv-api
              properties:
                srv-url: ${default-url}
            - name: mtx-api
              properties:
                mtx-url: ${default-url}
          parameters:
            buildpack: nodejs_buildpack
          properties:
            SUBSCRIPTION_URL: ${protocol}://\${tenant_subdomain}-${default-uri}
            SUBSCRIPTION_URL_REPLACEMENT_RULES: [ [ '-srv', '' ] ]        
        ```

    2. Adopt the *Application router module* for multi-tenancy (Already done when adding the custom application router).

    3. Remove the *DB deployer module*, the *App UI content deployer module* and *App UI resources module* because we don't need the html5 application and launchpad in the provider subaccount, and the DB schema is created at subscription (not at deployment).

    4. Adopt the *Destination content module* and remove the content and parameters refering to the html5 repo host. The resulting *Destination content module* looks like:
        ```yml
        modules:
          # Destination content module (define destinations with service keys)
          - name: author-readings-destination-content
            type: com.sap.application.content
            requires:
            - name: author-readings-destination-service
              parameters:
                content-target: true
            - name: author-readings-uaa
              parameters:
                service-key:
                  name: author-readings-uaa-key
            parameters:
              content:
                instance:
                  destinations:
                  - Authentication: OAuth2UserTokenExchange
                    Name: authorreadingmanager-uaa-fiori-dest
                    ServiceInstanceName: author-readings-uaa
                    ServiceKeyName: author-readings-uaa-key
                    sap.cloud.service: authorreadingmanager
                  existing_destinations_policy: ignore
            build-parameters:
              no-source: true        
        ```

    5. Adopt the *Database resource* for multi-tenancy such that database schemas are created on subscription by the service manager:
        ```yml
        resources: 
          # Database
          - name: author-readings-db
            type: org.cloudfoundry.managed-service
            parameters:
              service: service-manager
              service-plan: container
            properties:
              hdi-service-name: ${service-name}        
        ```    

    6. Adopt the *UUA service resource* for multi-tenancy (tenant-mode): 
        ```yml
        resource:        
          # UAA service
          - name: author-readings-uaa
            type: org.cloudfoundry.managed-service
            parameters:
              config:
              tenant-mode: shared
            xsappname: author-readings-${space}  # App name + CF space name
            path: ./xs-security.json
            service: xsuaa
            service-name: author-readings-uaa
            service-plan: application        
        ```    

    7. The are no changes to the resource *Audit log service* - nothing to do here.

    8. Add the *Service registry* as new resource, which is required for subscription and tenant provisioning:
        ```yml
        resource:
          # Service registry
          - name: author-readings-registry
            type: org.cloudfoundry.managed-service
            requires:
              - name: mtx-api
            parameters:
              service: saas-registry
              service-plan: application
              config:
              xsappname: author-readings-${space}
              appName: author-readings-${space}
              displayName: author-readings
              description: SAP Sample Application.
              category: 'Category'
              appUrls:
                getDependencies: ~{mtx-api/mtx-url}/mtx/v1/provisioning/dependencies
                onSubscription: ~{mtx-api/mtx-url}/mtx/v1/provisioning/tenant/{tenantId}
                onSubscriptionAsync: false
                onUnSubscriptionAsync: false
                callbackTimeoutMillis: 300000        
        ```

    9. Remove the resources *HTML5 app repository* (author-readings-repo-host) and *Event Mesh service* (author-readings-eventmesh).    

    10. Define mtx as separate node module such that tenant lifecycle operations to be done on a separate application to not interfere with the work load of app users.
    Goal: Separating workloads: 1. frontend workload, 2. backend workload, 3. tenant lifecycle operations.


3. Open file `xs-security.json` on the project root level and apply the following changes:

    1. The scopes, role-templates and role-collections for the application user roles for *athor reading managers* and *author reading administrators* do not change.

    2. Remove the scopes and role-templates for the event-based integration:
        - Scopes: *emcallback*, *emmanagement*
        - Role-template: *emmanagement*

    3. Add scope definitions for multi-tenant lifecycle management (*MtxDiagnose*, *mtcallback*, *mtdeployment*) and for cds model extensions (*ExtendCDS*, *ExtendCDSdelete*):
        ```json
        "scopes": [
            {
                "name": "$XSAPPNAME.MtxDiagnose",
                "description": "Diagnose MTX"
            },
            {
                "name": "$XSAPPNAME.mtcallback",
                "description": "Subscribe to applications",
                "grant-as-authority-to-apps": [
                "$XSAPPNAME(application,sap-provisioning,tenant-onboarding)"
                ]
            },
            {
                "name": "$XSAPPNAME.mtdeployment",
                "description": "Deploy applications"
            },
            {
                "name": "$XSAPPNAME.ExtendCDS",
                "description": "Extend CDS applications"
            },
            {
                "name": "$XSAPPNAME.ExtendCDSdelete",
                "description": "Extend CDS applications with undeployments"
            }        
        ]
        ```

    4. Add role-templates for tenant administration (*MultitenancyAdministrator*) and extension deployment (*ExtensionDeveloper*, *ExtensionDeveloperUndeploy*):
        ```json
        "role-templates": [
            {
                "name": "MultitenancyAdministrator",
                "description": "Administrate multitenant applications",
                "scope-references": [
                "$XSAPPNAME.MtxDiagnose",
                "$XSAPPNAME.mtdeployment",
                "$XSAPPNAME.mtcallback"
                ]
            },
            {
                "name": "ExtensionDeveloper",
                "description": "Extend application",
                "scope-references": [
                "$XSAPPNAME.ExtendCDS"
                ]
            },
            {
                "name": "ExtensionDeveloperUndeploy",
                "description": "Undeploy extension",
                "scope-references": [
                "$XSAPPNAME.ExtendCDSdelete"
                ]
            }     
        ]
        ```

    5. Add authorities for tenant lifecycle operations:
        ```json
        "authorities": [
            "$XSAPPNAME.MtxDiagnose",
            "$XSAPPNAME.mtdeployment",
            "$XSAPPNAME.mtcallback"
        ]            
        ```

4. Delete file `event-mesh.json` from the project root folder.

To verify your modifications check the files in the samle application:
- [package.json](../Applications/author-readings-mt/package.json)
- [mta.yaml](../Applications/author-readings-mt/mta.yaml)
- [xs-security.json](../Applications/author-readings-mt/xs-security.json)


### Remove business logic for the event-based Integration

Remove the service implementation to emit event notifications and to implement ERP events.

*SAP Business Application Studio*: 

1. Open file `./author-readings-mt/srv/service-implementation.js` and comment out the code section *"Event-based integration with ByD"*.

2. Open file `./author-readings-mt/srv/reuse.js` and comment out the code within function `emitAuthorReadingEvent` (see code section *"Emit event message to event mesh"*). Keep the fucntion definition itself, because the function is used in the service implementation.

To verify your modifications check the files in the samle application:
- [service-implementation.js](../Applications/author-readings-mt/srv/service-implementation.js)
- [reuse.js](../Applications/author-readings-mt/srv/reuse.js)


## Multi-Tenant Deployment

### Prepare BTP Provider Subaccount

### Deploy the Multi-Tenant Application


## Provisioning of BTP Consumer Tenant

### Prepare a BTP Consumer Subaccount

### Subscribe the BTP Multi-Tenant Application

### Configure the Consumer Subaccount 

(trust, SSO, destinations, ERP launchpad)

### Testing


## Patch multi-tenant applications

### Code changes

### Entity changes (database changes)