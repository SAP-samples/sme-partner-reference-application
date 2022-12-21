using {sap.samples.authorreadings as armodels} from '../db/entity-models';
using sap from '@sap/cds/common';

// ----------------------------------------------------------------------------
// Service for "author reading managers"

service AuthorReadingManager @(
    path : 'authorreadingmanager',
    impl : './service-implementation.js'
) {

    // ----------------------------------------------------------------------------
    // Entity inclusions

    // Currencies
    entity Currencies     as projection on sap.common.Currencies;

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
        actions {
            @(
                Common.SideEffects              : {TargetEntities : ['_authorreading']},
                cds.odata.bindingparameter.name : '_authorreading'
            )
            action block()   returns AuthorReadings;

            @(
                Common.SideEffects              : {TargetEntities : ['_authorreading']},
                cds.odata.bindingparameter.name : '_authorreading'
            )
            action publish() returns AuthorReadings;

            // ByD projects: action to create a project in ByD
            @(
                Common.SideEffects              : {TargetEntities: ['_authorreading','_authorreading/toByDProject']},
                cds.odata.bindingparameter.name : '_authorreading'
            )
            action createByDProject() returns AuthorReadings;
        };

    // Participants
    entity Participants as projection on armodels.Participants {
        *,
        virtual null as statusCriticality : Integer @title : '{i18n>statusCriticality}',
    } actions {
        @(
            Common.SideEffects              : {TargetEntities : [
                '_participant',
                '_participant/parent'
            ]},
            cds.odata.bindingparameter.name : '_participant'
        )
        action cancelParticipation()  returns Participants;

        @(
            Common.SideEffects              : {TargetEntities : [
                '_participant',
                '_participant/parent'
            ]},
            cds.odata.bindingparameter.name : '_participant'
        )
        action confirmParticipation() returns Participants;
    };

    // ----------------------------------------------------------------------------
    // Function to get user information (example for entity-independend function)

    type userRoles {
        identified    : Boolean;
        authenticated : Boolean;
    };

    type user {
        user   : String;
        locale : String;
        roles  : userRoles
    };

    function userInfo() returns user;   
};


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
