# Event-based Integration with SAP Business ByDesign

In this chapter we enhance the BTP application by event-based integration capabilties ustilizing the *SAP Event Mesh* for two use cases:

1. The BTP application shall emit event notifications similar to SAP ERP systems.

2. The BTP application shall subscribe to ByD event notifications and set the status of author readings inline with the corresponding projects in ByD.

The scenario will follow the publish/subscribe model. The event from ByD would be published as event mesh Topic. The CAP application would subscribe for this Topic programmatically. As a publisher of the event ByD doesn't know the consumer, hence it is published to a Topic. There could be multiple consumers to this Event. The Consuming CAP application, will receive this event via webhook. The Event Mesh will do a http POST call to the webhook url with the event payload.

## Setup the BTP provider subaccount

SAP BTP Cockpit (global acccount level): Open menu item *Entity Assignment* and add the service plans 
- *Event Mesh*, service plan *Default*
- *Event Mesh*, service plan *Standard (Application)*

BTP provider subaccount: Open menu item *Service Marketplace* and create an instance of the service *Event Mesh*, service plan *Standard (Application)*.

BTP provider subaccount: Open menu item *Security* > *Users*: Assign the role collections for the event mesh to your development user.   

BTP subaccount: Open menu item *Role Collections* and add the user group "author_reading_manager" to role collection "*Enterprise Messaging Administrator*".

## Setup project configurations

BAS: Open the project and add the following configurations:

Edit the file `package.json`: 

1. Add the dependency to package `@sap/xb-msg-amqp-v100`: 
    ```json
    "dependencies": {
        "@sap/xb-msg-amqp-v100": "^0.9.51"    
    },
    ```  

2. Add the messaging service configuration for publishing events:
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
            }
        }
    }           
    ```    
    > Note: The format "cloudevents" ensures that the system emits events using the standardized SAP payload format of notification events.
 
3. Add the messaging service configuration to subscribe ByD events:
    ```json
    "cds": {
        "requires": {    
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

In environments like Cloud Foundry, it takes some time until the route of the application is accessible from outside. If a webhook is created too early, its handshake-request will not reach the application, therefore make sure that the webhook waiting period is high enough. The waiting period is specified in milliseconds.

The error strategy is specified in parameter "qos":

| qos value: | Description:                                                                            |
| :--------- | :-------------------------------------------------------------------------------------- |
| 0          | At most once, there is no retry. The message will be lost if the webhook is not active. |
| 1          | At least once, acknowledgement is expected from the webhook endpoint.                   |

Edit the file `xs-security.json`: 

4. Add scopes and role templates to enable enterprise messaging:
    ```json
    "scopes": [
        {
            "name": "$XSAPPNAME.emcallback",
            "description": "Event Mesh Callback Access",
            "grant-as-authority-to-apps": ["$XSSERVICENAME(author-readings-eventmesh)"]
        },
        {
            "name": "$XSAPPNAME.emmanagement",
            "description": "Event Mesh Management Access"
        }        
    ],
    "role-templates": [
        {
            "name": "emmanagement",
            "description": "Event Mesh Management Access",
            "scope-references": ["$XSAPPNAME.emmanagement"],
            "attribute-references": []
        }        
    ]    
    ```

Edit the file `mta.yaml`:

5. Add a resource for the event mesh:
    ```yml
    resources:
    - name: author-readings-eventmesh
      type: org.cloudfoundry.managed-service
      parameters:
        path: ./event-mesh.json
        config:
        emname: "authorreadings" 
        namespace: "sap/samples/authorreadings"
        service: enterprise-messaging
        service-plan: default
    ```
    > Note: The name of the resource must match the service name used in file `xs-security.json`. The namespace must match the publishPrefix used in file `package.json`. The namespace must be composed of exactly three segments, separated by slashes.

    > Note: The resource is pointing to a new configuration file *event-mesh.json* that we will create next.

    > Note: The parameter "*emname*" specifies the name of the message client in the Event Mesh application.

6. Add the dependency to the autor reading service:
    ```yml
    modules:
    - name: author-readings-srv
      requires:
      - name: author-readings-eventmesh  
    ``` 

Create a new file `event-mesh.json` in the root folder of the application with the following content:

7. Specify the metadata of the message client in file `event-mesh.json`:
    ```json
    {
        "options": {
            "management": true,
            "messagingrest": true,
            "messaging": true
        },
        "rules": {
            "queueRules": {
                "publishFilter": [
                    "sap/byd/project/*", 
                    "${namespace}/*" 
                ],
                "subscribeFilter": [
                    "sap/byd/project/*", 
                    "${namespace}/*"                
                ]
            },
            "topicRules": {
                "publishFilter": [
                    "sap/byd/project/*", 
                    "${namespace}/*"
                ],
                "subscribeFilter": [
                    "sap/byd/project/*", 
                    "${namespace}/*"
                ]
            }
        },
        "version": "1.1.0",
        "authorities": [
            "$ACCEPT_GRANTED_AUTHORITIES"
        ]
    }
    ```
    > Note: In result the BTP app can publish events with the namespace "*sap/samples/authorreadings*", and subscribe to events with the namespace "*sap/byd/project*".

8. Enable local testing using:
   
    1. Run command `cf env author-readings-srv` to get the environment properties.

    2. Add a new file `default-env.json` to the project root folder.
   
    3. Copy the sections referring to the properties `VCAP_SERVICES` and `VCAP_APPLICATION` into the new file, enclose the two property names by double quotes, and embrace it all by curly brackets. In result the file content should look like
        ```json
        {
            "VCAP_SERVICES": {
                //content            
            },
            "VCAP_APPLICATION": {
                //content
            }
        }                
        ```
    4. Now you can test locally in BAS using the command `cds watch profile --sandbox`.

## Enhance the service implementation to emit events

Enhance the implementation of service `AuthorReadingManager` to emit event notification if a author reading gets published or blocked.

> Note: The entity element `AuthorReadings.eventMeshMessage` to store the event messages for demonstration purposes have already been added when creating the entity models.

1. Add the reuse function `emitAuthorReadingEvent` to the file `reuse.js` (see section "*// Emit event message to event mesh*").

2. Enhance the implementation of entity action "block" in file `service-implementation.js` such that a message is emitted to the topic "AuthorReadingBlocked" if the action is processed successfully:
    ```javascript
    // emit event message to event mesh
    reuse.emitAuthorReadingEvent(req, id, "AuthorReadingBlocked")
    ```

3. Enhance the implementation of entity action "publish" in file `service-implementation.js` such that a message is emitted to the topic "AuthorReadingPublished" if the action is processed successfully:
    ```javascript
    // emit event message to event mesh
    reuse.emitAuthorReadingEvent(req, id, "AuthorReadingPublished")
    ```

## Enhance the service implementation to consume ByD events

Enhance the implementation of service `AuthorReadingManager` to subscribe to event notifications emitted by ByD, read adidtional ByD project data and update the status of the author reading.

> Note: The entity elements required have already been added when creating the entity models in previous chapters.

1. Enhance the service implementation in file `service-implementation.js` by the code in section "*// Event-based integration with ByD*".

## Build and deploy

Build and deploy your application:

1. Login to cloud foundry: Run command `cf login`, enter your user/password and select the BTP provider subaccount for the application.

2. Run command `npm install` to install the messaging npm packages.

3. Build the project by selecting `Build MTA Project` in the context menu of file `mta.yaml`. 

4. Deploy the application by selecting `Deploy MTA Archive` in the context menu of file `./mta_archives/author-readings_1.0.0.mtar`.

Observe, that the message client `authorreadings` is now available in the event mesh application.

> Note: The first deployment of the application with the event mesh creates event mesh artifacts (message client, queue and service instance) and may take some time (very likely more than 10 minutes).

## Configure the message client for outbound messages

Add the queue for the outbound messages emitted by the BTP application.

BTP provider subaccount: 
1. Open menu item *Instances and Subscriptions* and launch the *Event Mesh* application.
2. Open the message client *authorreadings* and navigate to tab *Queues*.
3. Create a new queue with the *Queue Name* "authorreadingevents".
4. On the queue use the action *Queue Subscriptions* and subscribe to the topics "*sap/samples/authorreadings/AuthorReadingPublished*" and "*sap/samples/authorreadings/AuthorReadingBlocked*".

## Create the message client for ByD

BTP provider subaccount: Open menu item *Instances and Subscriptions* and create a new instance of service *Event Mesh* with the following data:
- Service: *Event Mesh*
- Plan: *default*
- Runtime: *Cloud Foundry*
- Space: Choose the space created as runtime for the app
- Instance name: Something meaningful referring to the ByD tenant and event mesh, for exmaple "byd-eventmesh"
- As parameters use the following json:
    ```json
    {
        "options": {
            "management": true,
            "messagingrest": true,
            "messaging": true
        },
        "rules": {
            "topicRules": {
                "publishFilter": [
                    "${namespace}/*"
                ],
                "subscribeFilter": [
                    "${namespace}/*"
                ]
            },
            "queueRules": {
                "publishFilter": [
                    "${namespace}/*"
                ],
                "subscribeFilter": [
                    "${namespace}/*"
                ]
            }
        },
        "version": "1.1.0",
        "emname": "byd",
        "namespace": "sap/byd/project"
    }
    ```

Open the event mesh application and the message client "byd" and create a queue with the *Queue name* "*projectupdate*".

On the queue *sap/byd/project/projectupdate* use the action *Queue Subscriptions* and subscribe to the topic "*sap/byd/project/ProjectUpdated*".

## Configure ByD to emit event notifications for projects

BTP provider subaccount: Open menu item *Instances and Subscriptions* the event mesh instance `byd-eventmesh` and create a service key with *Service Key Name*: "*byd-eventmesh-key*".

Get required information from the event mesh instance to configure ByD event notifications:
1. Open the event mesh instance service key (the json document). 
2. In the json document navigate to node `messaging` and search for the entry with protocol `httprest`. 
3. Take note of the values of the elements **clientid**, **clientsecret**, **tokenendpoint** and **uri**.

Assemble the topic endpoint by the following steps:
1. Get the topic name (incl. namespace) from the Event Mesh Application: `sap/byd/project/ProjectUpdated`
2. Replace "/" by "%2f" and get `sap%2fbyd%2fproject%2fProjectUpdated`
3. Concatenate the uri and `messagingrest/v1/topics/{{topic_name}}/messages` and get  
`https://enterprise-messaging-pubsub.cfapps.eu10.hana.ondemand.com/messagingrest/v1/topics/{{topics_name}}/messages`
4. Replace *{{topics_name}}* by the queue name incl. the "%2f"-syntax and get the topic endpoint.

Take note of the **topic endpoint**: 
`https://enterprise-messaging-pubsub.cfapps.eu10.hana.ondemand.com/messagingrest/v1/topics/sap%2fbyd%2fproject%2fProjectUpdated/messages`

> Note: Why Topic and not queue? Typically an events publishing system emits event notifications into a topic. One or more queues can subscribe to a topic. Messages in a queue are consumed, whereas messages in a topic stay available for multiple subscribers (they are deleted after a retention time).

Configure event notification in ByD:

Open ByD work center view *Application and User Management - Event Notification* and create an event notification with the following information:

Subscriber is the SAP Event Mesh instance for the ByD system:
- Name: Some meaningful name, e.g. "BTP app Author Readings"
- Endpoint: **topic endpoint**
- Authentication Method: *OAuth 2.0*
    - Grant Type: *Client Credentials*
    - Access Token URL: **tokenendpoint**
    - Client ID: **clientid** 
    - Client Secret: **clientsecret** 
- Additional http-headers:
    - *x-qos = 0*

Add a subscription for
- Business Object: *Project*
- Business Object Node: *Root*
- Select *Update* to subscribe to all project updates
