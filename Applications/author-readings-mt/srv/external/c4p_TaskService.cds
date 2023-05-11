/* checksum : 63d8c2cad17eaa68760c7260ef078e96 */
/** Task */
@cds.external : true
@cds.persistence.skip : true
@Capabilities.SearchRestrictions.Searchable : false
@Capabilities.DeleteRestrictions.Deletable : false
@Capabilities.DeleteRestrictions.Description : 'Deletion of task is not allowed.'
@Capabilities.DeleteRestrictions.LongDescription : 'Manual deletion of task is not allowed. Up to now tasks are only deleted when a project itself is deleted.'
@Capabilities.ExpandRestrictions.Expandable : false
@Capabilities.InsertRestrictions.Description : 'Creates a new task for a project.'
@Capabilities.InsertRestrictions.LongDescription : 'The task displayId will be calculated and set.<br><br>The task type will be set to TASK, by default, if no other value is entered.<br>The status will be set to 20 (Open), by default, if no other value is entered.<br>The priority will be set to 10 (Low), by default, if no other value is entered.<br>The task creator will be entered as the assigned by person.<br>The task creator and the assigned by person will be registered as task watchers.<br><br>Requires the <i>User</i> role and the permission at the corresponding project to create tasks.'
@Capabilities.ReadRestrictions.Description : 'Reads all tasks the logged-in user is authorized for.'
@Capabilities.ReadRestrictions.LongDescription : 'Allows searching for tasks by providing corresponding request parameters.'
@Capabilities.ReadRestrictions.ReadByKeyRestrictions.Description : 'Reads a task by key.'
@Capabilities.ReadRestrictions.ReadByKeyRestrictions.LongDescription : 'Retrieves the details of a particular task by specifying the task ID that you may have received from a different API call.'
@Capabilities.UpdateRestrictions.Description : 'Updates the task header attributes.'
@Capabilities.UpdateRestrictions.LongDescription : 'Requires the _Full Control_ permission for the task. While updating the processorPersonID, the assigned by person ID is automatically updated with the current user ID.'
@Capabilities.NavigationRestrictions.RestrictedProperties : [ {![NavigationProperty]: toAuthorizations, ![TopSupported]: false, ![SkipSupported]: false, ![SortRestrictions]: {![Sortable]: false}, ![FilterRestrictions]: {![Filterable]: false}, ![InsertRestrictions]: {![Insertable]: false}} ]
entity c4p_TaskService.Tasks {
  /** Unique, technical identifier of the task */
  @Core.Computed : true
  key id : UUID not null;
  /** Unique, technical identifier of the project the task belongs to */
  @Core.Immutable : true
  @Common.FieldControl : #Mandatory
  projectId : UUID not null;
  /** Unique, human-readable identifier of the task */
  @Core.Immutable : true
  @Core.Computed : true
  displayId : String(255) not null;
  /** Type of Task */
  @Core.Immutable : true
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'ACTION', ![Value]: 'ACTION'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'CHECK', ![Value]: 'CHECK'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'TASK', ![Value]: 'TASK'} ]
  taskType : String(20) default 'TASK';
  /** Task subject */
  @Core.Example : {![$Type]: 'Core.PrimitiveExampleValue', ![Value]: 'My First Task'}
  @Common.FieldControl : #Mandatory
  subject : String(255) not null;
  /** Task description */
  description : LargeString;
  /** Task Category */
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'CONSTRUCTION', ![Value]: 'CONSTRUCTION'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'INSPECTION', ![Value]: 'INSPECTION'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'PLANNING_AND_DESIGN', ![Value]: 'PLANNING_AND_DESIGN'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'PROJECT_MANAGEMENT', ![Value]: 'PROJECT_MANAGEMENT'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'DOCUMENTATION', ![Value]: 'DOCUMENTATION'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'REWORK', ![Value]: 'REWORK'} ]
  category : String(20);
  /** Start date of the task */
  startDate : Date;
  /** Due date of the task */
  dueDate : Date;
  /** Task priority (0-None, 10-Low, 20-Medium, 30-High) */
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'EMPTY', ![Value]: 0}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'LOW', ![Value]: 10}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'MEDIUM', ![Value]: 20}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'HIGH', ![Value]: 30} ]
  priority : Integer default 10;
  /** Location of the task */
  location : String(2000);
  /** Effort value of the task */
  effortValue : Double;
  /** Effort unit of the task */
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'length-centimeter', ![Value]: 'length-centimeter'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'length-meter', ![Value]: 'length-meter'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'length-kilometer', ![Value]: 'length-kilometer'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'length-inch', ![Value]: 'length-inch'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'length-yard', ![Value]: 'length-yard'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'length-foot', ![Value]: 'length-foot'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'length-mile', ![Value]: 'length-mile'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'area-square-centimeter', ![Value]: 'area-square-centimeter'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'area-square-meter', ![Value]: 'area-square-meter'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'area-square-foot', ![Value]: 'area-square-foot'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'area-square-inch', ![Value]: 'area-square-inch'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'volume-cubic-centimeter', ![Value]: 'volume-cubic-centimeter'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'volume-cubic-meter', ![Value]: 'volume-cubic-meter'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'volume-cubic-yard', ![Value]: 'volume-cubic-yard'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'volume-cubic-foot', ![Value]: 'volume-cubic-foot'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'volume-cubic-inch', ![Value]: 'volume-cubic-inch'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'duration-hour', ![Value]: 'duration-hour'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'duration-day', ![Value]: 'duration-day'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'mass-metric-ton', ![Value]: 'mass-metric-ton'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'mass-kilogram', ![Value]: 'mass-kilogram'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'mass-gram', ![Value]: 'mass-gram'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'mass-ounce', ![Value]: 'mass-ounce'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'mass-pound', ![Value]: 'mass-pound'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'mass-ton', ![Value]: 'mass-ton'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'x-piece', ![Value]: 'x-piece'}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'x-unit', ![Value]: 'x-unit'} ]
  effortUnit : String(80);
  /** User ID of the user who processes the task */
  processorPersonId : UUID;
  /** User ID of the user who assigned the task to the processor */
  @Core.Computed : true
  assignedByPersonId : UUID;
  /**
   * Task status (10-Blocked, 20-Open, 30-In Process, 40-Completed, 50-Ok, 60-Not Ok, 70-N/A)
   * 
   * The Task status depends the type of Task:<br/>ACTION: 10-Blocked, 20-Open, 40-Completed, 70-N/A<br/>CHECK: 20-Open, 50-Ok, 60-Not Ok, 70-N/A<br/>TASK: 10-Blocked, 20-Open, 30-In Process, 40-Completed<br/>If the status is set to one of the following final status values 40 (Completed), 50 (Ok), 60 (Not Ok) the task completeness will set to 100%. If the status is set to 20 (Open) the task completeness will be set to 0%.
   */
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'NONE', ![Value]: 0}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'BLOCKED', ![Value]: 10}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'OPEN', ![Value]: 20}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'IN_PROCESS', ![Value]: 30}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'COMPLETED', ![Value]: 40}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'OK', ![Value]: 50}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'NOT_OK', ![Value]: 60}, {![$Type]: 'Validation.AllowedValue', ![@Core.SymbolicName]: 'NA', ![Value]: 70} ]
  status : Integer default 20;
  /** Date when the task was completed */
  @odata.Precision : 7
  @odata.Type : 'Edm.DateTimeOffset'
  @Core.Computed : true
  completedAt : Timestamp;
  /** User ID of the user who completed the task */
  @Core.Computed : true
  completedBy : UUID;
  /** Task completion in % (value between 0 and 100) */
  percentComplete : Integer;
  /** Timestamp when the task was created */
  @odata.Precision : 7
  @odata.Type : 'Edm.DateTimeOffset'
  @Core.Computed : true
  createdAt : Timestamp;
  /** User ID of the user who created the task */
  @Core.Computed : true
  createdBy : UUID;
  /** Timestamp when the task was last updated */
  @odata.Precision : 7
  @odata.Type : 'Edm.DateTimeOffset'
  @Core.Computed : true
  modifiedAt : Timestamp;
  /** User ID of the user who updated the task */
  @Core.Computed : true
  modifiedBy : UUID;
  @cds.ambiguous : 'missing on condition?'
  toAuthorizations : Association to many c4p_TaskService.Authorizations {  };
} actions {
  action Status(
    status : Integer,
    percentComplete : Integer
  ) returns c4p_TaskService.Tasks;
  action Processor(
    processorPersonId : UUID
  ) returns c4p_TaskService.Tasks;
};

@cds.external : true
@cds.persistence.skip : true
@Capabilities.FilterRestrictions.Filterable : false
@Capabilities.FilterRestrictions.NonFilterableProperties : [ 'permission', 'principalType' ]
@Capabilities.SortRestrictions.Sortable : false
@Capabilities.SortRestrictions.NonSortableProperties : [ 'permission' ]
@Capabilities.TopSupported : false
@Capabilities.SkipSupported : false
@Capabilities.CountRestrictions.Countable : false
@Capabilities.SearchRestrictions.Searchable : false
@Capabilities.SelectSupport.Supported : false
@Capabilities.InsertRestrictions.Description : 'Creates a single task authorization by specifying taskId, user/group ID (principalId), type (principalType), and the permission ID (permission).'
@Capabilities.InsertRestrictions.LongDescription : 'Requires _FULL CONTROL_ permission for the task.'
@Capabilities.ReadRestrictions.Description : 'Reads all task authorizations for the defined task.'
@Capabilities.ReadRestrictions.LongDescription : 'Requires _VIEW ONLY_ permission for the task.'
@Capabilities.ReadRestrictions.ReadByKeyRestrictions.Description : 'Reads a single task authorization for a defined task, selected by user/group ID (principalId), type (principalType), and the permission ID (permission).'
@Capabilities.ReadRestrictions.ReadByKeyRestrictions.LongDescription : 'Requires _VIEW ONLY_ permission for the task.'
@Capabilities.UpdateRestrictions.Description : 'Updates a task authorization for the defined task.'
@Capabilities.UpdateRestrictions.LongDescription : 'Requires _FULL CONTROL_ permission for the task.'
@Capabilities.DeleteRestrictions.Description : 'Deletes a task authorization from the defined task.'
@Capabilities.DeleteRestrictions.LongDescription : 'Requires _FULL CONTROL_ permission for the task.'
entity c4p_TaskService.Authorizations {
  key taskId : UUID not null;
  /** The type of the principalId */
  @Core.Immutable : true
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![Value]: 'PERSON'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'GROUP'} ]
  @Common.FieldControl : #Mandatory
  principalType : String(10) not null;
  /**
   * The principalId specifies the owner of the permissions
   * 
   * If the principalType is &quot;GROUP&quot; then the principalId is a groupMembershipId. In case of &quot;PERSON&quot; the principalId is a personMembershipId
   */
  key principalId : UUID not null;
  /** The permission granted to the principal */
  @Validation.AllowedValues : [ {![$Type]: 'Validation.AllowedValue', ![Value]: 'VIEW_ONLY'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'PROCESS'}, {![$Type]: 'Validation.AllowedValue', ![Value]: 'FULL_CONTROL'} ]
  @Common.FieldControl : #Mandatory
  permission : String(30) not null;
};

/**
 * Task Service
 * 
 * This API allows you to work with tasks for collaboration projects in SAP S/4HANA Cloud for projects, collaborative project management. All operations require the _User_ role and are executed in the context of the logged-in user.
 */
@cds.external : true
service c4p_TaskService {};

