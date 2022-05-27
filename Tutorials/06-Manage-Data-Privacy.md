# Manage Data Privacy

Using the audit log you can ensure your application is compliant to data privacy requirements.
For more information see: [Cloud Application Programming - Managing Data Privacy](https://cap.cloud.sap/docs/guides/data-privacy).

## Application enablement (same for one-off and multi tenancy)

Open file `./srv/service-models.cds` and add the annotations for the audit log:
```javascript
// -------------------------------------------------------------------------------
// Annotations for data privacy

annotate AuthorReadingManager.AuthorReadings with @PersonalData : {
    DataSubjectRole : 'AuthorReadings',
    EntitySemantics : 'DataSubject'
}
{
    ID                      @PersonalData.FieldSemantics : 'DataSubjectID';
    identifier              @PersonalData.FieldSemantics : 'DataSubjectID'; 
    description             @PersonalData.FieldSemantics : 'DataSubjectID';       
    participantsFeeAmount   @PersonalData.IsPotentiallySensitive;
}

annotate AuthorReadingManager.Participants with @PersonalData : {
    DataSubjectRole : 'AuthorReadings',
    EntitySemantics : 'DataSubjectDetails'
}
{
    ID                      @PersonalData.FieldSemantics : 'DataSubjectID';
    identifier              @PersonalData.FieldSemantics : 'DataSubjectID'; 
    parent                  @PersonalData.FieldSemantics : 'DataSubjectID';
    name                    @PersonalData.IsPotentiallyPersonal;
    email                   @PersonalData.IsPotentiallySensitive;
    mobileNumber            @PersonalData.IsPotentiallySensitive;
}

// Annotations for audit logging
annotate AuthorReadingManager.AuthorReadings with @AuditLog.Operation : {
    Read   : true,
    Insert : true,
    Update : true,
    Delete : true
};
annotate AuthorReadingManager.Participants with @AuditLog.Operation : {
    Read   : true,
    Insert : true,
    Update : true,
    Delete : true
};
```

Open file `./package.json` and add the dependency to the audit log npm package, check the version of th cds dependency (should be at least 5.9.4), and the configuration for the audit log:
```json
"dependencies": {
    "@sap/cds": "^5.9.4",
    "@sap/audit-logging": "^5.1.0"
},
"cds": {
    "features": {
        "audit_personal_data": true
    },
    "requires": {
          "audit-log": {
            "[sandbox]": {
                "kind": "audit-log-to-console"
            },
            "[production]": {
                "kind": "audit-log-service"
            }
        }
    }
}
```

Open file `./mta.yaml` and add the module dependency and the audit log resource.
```yml
modules:
- name: author-readings-srv
  requires:
   - name: author-readings-auditlog

resources:
- name: author-readings-auditlog
  type: org.cloudfoundry.managed-service
  parameters:
    service: auditlog
    service-plan: standard 
```

## BTP Configuration

### One-off deployment

BTP provider subaccount:

Add the required entitlements to the BTP provider subaccount:
- Service `Auditlog Service` with plan `standard` to write audit logs
- Service `Audit Log Viewer Service` with plan `default (Application)` to view audit logs

Create an instance of the audit log viewer:
1. Open menu item *Service Marketplace* and create an instance of service `Audit Log Viewer Service` with plan `default (Application)`.

To actually be able to view logs additional authorizations must be added:
1. Open the menu item *Role Collections* and create a new role collection with name `AuditLog`.
2. Edit the role colection and 
    a. Add the roles *Auditlog_Auditor* for both applications: *Auditlog Management* and *Audit Log Viewer*.
    b. Add the user group "Author_Readings_Admin".

Run command `npm install` to install the audit log npm packages. 

Build and deploy the application and observe that an audit log service instance has been created.

See chapter [ByD Integration](../04-byd-integration/index.md) to add the audit log viewer to the ByD launchpad.

### Multi tenancy

Add entitlement to the BTP **Provider** Account:
- service `Auditlog Service` with plan `standard` to write logs

Add entitlement to the BTP **Subscriber** Account:
- service `Auditlog Service` with plan `standard` to write logs
- service `Audit Log Viewer Service` with plan `default (Application)` to view logs

To actually be able to view logs additional authorizations must be added. 
Use role template `Auditlog_Auditor` and add both roles `Auditlog Management` and `Audit Log Viewer` to the role collections.