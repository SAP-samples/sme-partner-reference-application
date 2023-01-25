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
            toByDProject: Association to RemoteByDProject.ProjectCollection on toByDProject.ProjectID = $projection.projectID;

            // S4HC projects: Mix-in of S4HC project data
            toS4HCProject: Association to RemoteS4HCProject.A_EnterpriseProject on toS4HCProject.Project = $projection.projectID
        } 
        into  {
            *,
            virtual null as statusCriticality    : Integer  @title : '{i18n>statusCriticality}',
            // ByD projects: visibility of button "Create project in ByD"
            virtual null as createByDProjectEnabled : Boolean  @title : '{i18n>createByDProjectEnabled}'  @odata.Type : 'Edm.Boolean',
            toByDProject,

            // S4HC projects: visibility of button "Create project in S4HC"
            virtual null as createS4HCProjectEnabled : Boolean  @title : '{i18n>createS4HCProjectEnabled}'  @odata.Type : 'Edm.Boolean',
            toS4HCProject,

            virtual null as projectSystemName      : String @title : '{i18n>projectSystemName}' @odata.Type : 'Edm.String',
            virtual null as projectProfileCodeText : String @title : '{i18n>projectSystemName}' @odata.Type : 'Edm.String',
            virtual null as processingStatusText    : String @title : '{i18n>projectSystemName}' @odata.Type : 'Edm.String',
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

            // S4HC projects: action to create a project in S4HC
            @(
                Common.SideEffects              : {TargetEntities: ['_authorreading','_authorreading/toS4HCProject']},
                cds.odata.bindingparameter.name : '_authorreading'
            )
            action createS4HCProject() returns AuthorReadings;
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

// Extend service AuthorReadingManager by S4HC projects (principal propagation)

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

// Extend service AuthorReadingManager by S4HC Projects ProjectProfileCode

using { S4HC_ENTPROJECTPROCESSINGSTATUS_0001 as RemoteS4HCProjectProcessingStatus } from './external/S4HC_ENTPROJECTPROCESSINGSTATUS_0001';

extend service AuthorReadingManager with {
    entity S4HCProjectsProcessingStatus as projection on RemoteS4HCProjectProcessingStatus.ProcessingStatus {
        key ProcessingStatus as ProcessingStatus,
        ProcessingStatusText as ProcessingStatusText    
    }    
};

// Extend service AuthorReadingManager by S4HC Projects ProcessingStatus

using { S4HC_ENTPROJECTPROFILECODE_0001 as RemoteS4HCProjectProjectProfileCode } from './external/S4HC_ENTPROJECTPROFILECODE_0001';

extend service AuthorReadingManager with {
    entity S4HCProjectsProjectProfileCode as projection on RemoteS4HCProjectProjectProfileCode.ProjectProfileCode {
        key ProjectProfileCode as ProjectProfileCode,
        ProjectProfileCodeText as ProjectProfileCodeText    
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
