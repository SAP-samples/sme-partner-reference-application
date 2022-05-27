# Test and Debug

When developing a productive application further topics like finding and analysing issues become also important. For now these topics are only described high level to give an idea of the direction.

## Test

The application can be manually tested locally as long as no Event Mesh based integration has been added. 

1. Edit the sandbox credentials in file `package.json`:
    ```json
    "byd_khproject": {
        "kind": "odata-v2",
        "model": "srv/external/byd_khproject",
        "[sandbox]": {
            "credentials": {
                "url": "https://{{byd-hostname}}/sap/byd/odata/cust/v1/khproject/",
                "authentication": "BasicAuthentication",
                "username": "{{user}}",
                "password": "{{password}}"
            }
        }
    },
    "byd_khproject_tech_user": {
        "kind": "odata-v2",
        "model": "srv/external/byd_khproject_tech_user",
        "[sandbox]": {
            "credentials": {
                "url": "https://{{byd-hostname}}/sap/byd/odata/cust/v1/khproject/",
                "authentication": "BasicAuthentication",
                "username": "{{user}}",
                "password": "{{password}}"
            }
        }
    },
    ```

2. Run command `cds watch` or `cds watch profile --sandbox` on the command line interface. This will start a NodeJS-server including the web application.

After adding the event-based integration with ByD 

1. Run command `cf env author-readings-srv` to get the environment properties.

2. Add a new file `default-env.json` to the project root folder.
   
3. Copy the sections referring to the properties `VCAP_SERVICES` and `VCAP_APPLICATION` into the new file, enclose the two property names by double quotes, and embrace it all by curly brackets. In result the file content should look like
    ```javascript
            {
                "VCAP_SERVICES": {
                    //content            
                },
                "VCAP_APPLICATION": {
                    //content
                }
            }                
    ```

4. Now you can test in BAS using the command `cds watch profile --production`.

## Tracing

You may consider adding log statements to the service implementations, such as for example 
```javascript
console.log("Author reading " + authorReadingIdentifier +" is blocked via event message");
console.log("Event message log updated");
console.log("Internal error on processing ByD event notifications: " + error);
```

In result you can review your own and others log messages using command `cf logs author-readings-srv --recent` in the BAS terminal.

## Debug

Local debugging can be done with the standard nodeJS debugging tools.
See also [CAP Debugging](https://cap.cloud.sap/docs/tools/#debugging-with-cds-watch).
