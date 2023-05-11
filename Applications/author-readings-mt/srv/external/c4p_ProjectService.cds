/* checksum : 8f49e09dc57c27c4750b823a68aa5305 */
/**
 * Copy a source project.
 * 
 * This operation takes considerable time to complete as it is a heavy and asynchronous process.<br>During the copy process, the project will have COPY_IN_PROCESS status. After the copy process is completed, the project status will be NEW.<br>The following elements from the source project are copied:<br>- Documents repository folder structure (folder name, folder description and folder authorizations)<br>Please note that Project partner group and individual user authorizations are not copied.<br>- Legal documents associated with the source project<br>- User groups without the assigned users, defined for the source project<br>- Project authorizations assigned to user groups, defined for the source project
 */
@cds.external : true
action c4p_ProjectService.copyProject(
  sourceProjectId : UUID not null,
  newDisplayId : LargeString not null,
  newName : LargeString not null,
  sendNotification : Boolean not null
);

/** Project */
@cds.external : true
@cds.persistence.skip : true
@Capabilities.SearchRestrictions.Searchable : false
@Capabilities.ExpandRestrictions.Expandable : false
@Capabilities.InsertRestrictions.Description : 'Creates a new project.'
@Capabilities.InsertRestrictions.LongDescription : 'The collaboration owner will be set to the company of the logged-in user.<br>The project is created with default authorizations and the logged-on user as the only member.<br><br>Requires the _BusinessAdmin_ role.'
@Capabilities.ReadRestrictions.Description : 'Reads projects for the logged-in user.'
@Capabilities.ReadRestrictions.LongDescription : 'Allows searching for projects by providing corresponding request parameters.'
@Capabilities.ReadRestrictions.ReadByKeyRestrictions.Description : 'Reads a project by key.'
@Capabilities.ReadRestrictions.ReadByKeyRestrictions.LongDescription : 'Retrieves the details of a specific project by specifying its project Id, that you may have received from a different API call. '
@Capabilities.UpdateRestrictions.Description : 'Updates the project header attributes.'
@Capabilities.UpdateRestrictions.LongDescription : 'Requires the _Edit Project Header_ permission for the project.'
@Capabilities.DeleteRestrictions.Description : 'Deletes a project.'
@Capabilities.DeleteRestrictions.LongDescription : 'Requires the _Edit Project Header_ permission for the project. Only projects with status "to be deleted" can be deleted permanently. All objects related to the project will be deleted permanently as well.'
@Capabilities.NavigationRestrictions.RestrictedProperties : [ {![NavigationProperty]: toAuthorizations, ![TopSupported]: false, ![SkipSupported]: false, ![SortRestrictions]: {![Sortable]: false}, ![InsertRestrictions]: {![Insertable]: false}} ]
entity c4p_ProjectService.Projects {
  /** Unique, technical identifier of the project */
  @Core.Computed : true
  key id : UUID not null;
  /** For a specific company account, the unique and human-readable identifier of the project. */
  @Core.Example : {![$Type]: 'Core.PrimitiveExampleValue', ![Value]: 'PROJECT1'}
  @Common.FieldControl : #Mandatory
  displayId : String(40) not null;
  /** Project name */
  @Core.Example : {![$Type]: 'Core.PrimitiveExampleValue', ![Value]: 'My First Project'}
  @Common.FieldControl : #Mandatory
  name : String(255) not null;
  /** Project status */
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![Value]: 'NEW'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'IN_PROCESS'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'COMPLETED'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'ARCHIVED'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'TO_BE_DELETED'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'COPY_IN_PROCESS'} ]
  status : String(16) not null default 'NEW';
  /** Start date of the project */
  startDate : Date;
  /** End date of the project */
  endDate : Date;
  /** Address or coordinates where the project is taking place */
  @Core.Example : {![$Type]: 'Core.PrimitiveExampleValue', ![Value]: 'Dietmar-Hopp-Allee 16, Walldorf, Germany'}
  location : String(255);
  /** Description of project */
  @Core.Example : {![$Type]: 'Core.PrimitiveExampleValue', ![Value]: 'Some more information about the project'}
  description : String(500);
  /** Coordinates of the project location */
  geoCoordinates : String(2000);
  /** Company ID of the owner of the project */
  @Core.Computed : true
  collaborationOwnerId : UUID;
  /** Timestamp of when the project was created */
  @odata.Precision : 7
  @odata.Type : 'Edm.DateTimeOffset'
  @Core.Computed : true
  @Core.ComputedDefaultValue : true
  createdAt : Timestamp;
  /** User ID of the user who created the project */
  @Core.Computed : true
  createdBy : UUID;
  /** Timestamp of when the project was last updated */
  @odata.Precision : 7
  @odata.Type : 'Edm.DateTimeOffset'
  @Core.Computed : true
  @Core.ComputedDefaultValue : true
  modifiedAt : Timestamp;
  /** User ID of the user who last updated the project */
  @Core.Computed : true
  modifiedBy : UUID;
  @cds.ambiguous : 'missing on condition?'
  toAuthorizations : Association to many c4p_ProjectService.Authorizations {  };
};

@cds.external : true
@cds.persistence.skip : true
@Capabilities.SelectSupport.Supported : false
@Capabilities.InsertRestrictions.Description : 'Creates a single project authorization by specifying projectId, user/group ID (principalId), type (principalType) and the permission ID (permission).'
@Capabilities.DeleteRestrictions.Description : 'Delete a project authorization from the defined project.'
@Capabilities.ReadRestrictions.ReadByKeyRestrictions.Description : 'Read a single project authorization for a defined project, selected by user/group ID (principalId), type (principalType), and the permission ID (permission).'
@Capabilities.UpdateRestrictions.Updatable : false
entity c4p_ProjectService.Authorizations {
  /** Unique, technical identifier of the project */
  key projectId : UUID not null;
  /** Unique, technical identifier of the principal */
  key principalId : UUID not null;
  /** Type of the principal */
  @Core.Example : {![$Type]: 'Core.PrimitiveExampleValue', ![Value]: 'PERSON'}
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![Value]: 'PERSON'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'GROUP'} ]
  key principalType : String(10) not null;
  /** Permission granted to the principal */
  @Core.Example : {![$Type]: 'Core.PrimitiveExampleValue', ![Value]: 'MAINTAIN_PROJECT_AUTHORIZATIONS'}
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![Value]: 'VIEW_PROJECT'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'EDIT_PROJECT_HEADER'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'MAINTAIN_PROJECT_AUTHORIZATIONS'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'DELETE_PROJECT'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'CREATE_GROUP'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'VIEW_DIGITAL_TWIN'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'CREATE_DIGITAL_TWIN'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'CREATE_FINANCE_VIEW'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'CREATE_ISSUE'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'INVITE_PROJECT_PARTNER'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'CREATE_PROJECT_PLAN'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'CREATE_TASK'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'DELETE_TASK'} ]
  key permission : String(50) not null;
};

/**
 * Project Service
 * 
 * This API allows you to work with collaboration projects in SAP S/4HANA Cloud for projects, collaborative project management. All operations require the _User_ role and are executed in the context of the logged in user.
 */
@cds.external : true
service c4p_ProjectService {};

