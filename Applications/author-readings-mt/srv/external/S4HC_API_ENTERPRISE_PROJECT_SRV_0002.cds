/* checksum : 2bc5b1f38dfa3f3be83850432cb2c3b2 */
@cds.external : true
@m.IsDefaultEntityContainer : 'true'
@sap.message.scope.supported : 'true'
@sap.supported.formats : 'atom json xlsx'
service S4HC_API_ENTERPRISE_PROJECT_SRV_0002 {};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.content.version : '2'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project Block Function'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjBlkFunc {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  key ProjectUUID : UUID not null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjTimeRecgIsBlkd : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjStaffExpensePostgIsBlkd : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjServicePostingIsBlkd : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjOtherExpensePostgIsBlkd : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjPurchasingIsBlkd : Boolean null;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '2'
@sap.deletable.path : 'Delete_mc'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project Element'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  key ProjectElementUUID : UUID not null;
  @sap.label : 'Dyn. Action Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ChangeEntProjElmntPosition_ac : Boolean null;
  @sap.label : 'Dyn. Action Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ChangeEntProjElmntProcgStatus_ac : Boolean null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ActualEndDate_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ActualStartDate_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ControllingArea_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  CostingSheet_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FactoryCalendar_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FunctionalArea_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FunctionalLocation_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Location_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  PlannedEndDate_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  PlannedStartDate_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Plant_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProfitCenter_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProjectElement_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProjectElementDescription_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ResponsibleCostCenter_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  TaxJurisdiction_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  WBSElementIsBillingElement_fc : Integer null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Delete_mc : Boolean null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.label : 'Dynamic CbA-Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  to_EntProjElmntBlkFunc_oc : Boolean null;
  @sap.label : 'Dynamic CbA-Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  to_SubProjElement_oc : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ProjectElement_fc'
  @sap.label : 'Number'
  @sap.quickinfo : 'Identification of Entities'
  ProjectElement : String(24) null;
  @sap.display.format : 'NonNegative'
  @sap.label : 'WBS Internal ID'
  @sap.quickinfo : 'WBS Element'
  WBSElementInternalID : String(8) null;
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.updatable : 'false'
  ProjectUUID : UUID null;
  @sap.field.control : 'ProjectElementDescription_fc'
  @sap.label : 'Name'
  @sap.quickinfo : 'Description'
  ProjectElementDescription : String(60) null;
  @sap.label : 'Parent GUID'
  @sap.quickinfo : 'Parent Entity Guid'
  ParentObjectUUID : UUID null;
  @sap.label : 'Sort Number'
  @sap.quickinfo : 'Sortnumber'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  ProjectElementOrdinalNumber : Integer null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Processing Status'
  @sap.quickinfo : 'Object Processing Status'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  ProcessingStatus : String(2) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Task Type'
  EntProjectElementType : String(15) null;
  @sap.display.format : 'Date'
  @sap.field.control : 'PlannedStartDate_fc'
  @sap.label : 'Latest Planned Start'
  PlannedStartDate : Date null;
  @sap.display.format : 'Date'
  @sap.field.control : 'PlannedEndDate_fc'
  @sap.label : 'Ltst Planned Finish'
  @sap.quickinfo : 'Latest Planned Finish'
  PlannedEndDate : Date null;
  @sap.display.format : 'Date'
  @sap.field.control : 'ActualStartDate_fc'
  @sap.label : 'Actual Start'
  ActualStartDate : Date null;
  @sap.display.format : 'Date'
  @sap.field.control : 'ActualEndDate_fc'
  @sap.label : 'Actual Finish'
  ActualEndDate : Date null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ResponsibleCostCenter_fc'
  @sap.label : 'Responsible CC'
  @sap.quickinfo : 'Responsible Cost Center'
  ResponsibleCostCenter : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Company code'
  @sap.quickinfo : 'Company code for WBS element'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  CompanyCode : String(4) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ProfitCenter_fc'
  @sap.label : 'Profit Center'
  ProfitCenter : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'FunctionalArea_fc'
  @sap.label : 'Functional Area'
  FunctionalArea : String(16) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ControllingArea_fc'
  @sap.label : 'Controlling area'
  @sap.quickinfo : 'Controlling area for WBS element'
  ControllingArea : String(4) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'Plant_fc'
  @sap.label : 'Plant'
  Plant : String(4) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'Location_fc'
  @sap.label : 'Location'
  Location : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'TaxJurisdiction_fc'
  @sap.label : 'Tax Jurisdiction'
  TaxJurisdiction : String(15) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'FunctionalLocation_fc'
  @sap.label : 'Functional Location'
  FunctionalLocation : String(40) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'FactoryCalendar_fc'
  @sap.label : 'Factory Calendar'
  @sap.quickinfo : 'Factory calendar key'
  FactoryCalendar : String(2) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'CostingSheet_fc'
  @sap.label : 'Costing Sheet'
  CostingSheet : String(6) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Investment Profile'
  @sap.quickinfo : 'Investment Measure Profile'
  InvestmentProfile : String(6) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Statistical'
  @sap.quickinfo : 'Statistical WBS element'
  WBSIsStatisticalWBSElement : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'CCtr posted actual'
  @sap.quickinfo : 'Cost center to which costs are actually posted'
  CostCenter : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'WBSElementIsBillingElement_fc'
  @sap.label : 'Billing Element'
  @sap.quickinfo : 'Indicator: Billing element'
  WBSElementIsBillingElement : Boolean null;
  @sap.label : 'Created By'
  @sap.quickinfo : 'Name of Person Who Created Object'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  CreatedByUser : String(12) null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Created On'
  @sap.quickinfo : 'Timestamp of Object Creation'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  CreationDateTime : DateTime null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Changed On'
  @sap.quickinfo : 'Timestamp of Last Object Change'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  LastChangeDateTime : DateTime null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Changed By'
  @sap.quickinfo : 'Name of Person Who Changed Object'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  LastChangedByUser : String(12) null;
  @cds.ambiguous : 'missing on condition?'
  to_EntProjectElementJVA : Composition of S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntProjectElementJVA on to_EntProjectElementJVA.ProjectElementUUID = ProjectElementUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EntProjectElmntPublicSector : Composition of S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntProjectElmntPublicSector on to_EntProjectElmntPublicSector.ProjectElementUUID = ProjectElementUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EntProjElmntBlkFunc : Composition of S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntProjElmntBlockFunc on to_EntProjElmntBlkFunc.ProjectElementUUID = ProjectElementUUID;
  @cds.ambiguous : 'missing on condition?'
  to_ParentProjElement : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement {  };
  @cds.ambiguous : 'missing on condition?'
  to_SubProjElement : Association to many S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement {  };
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
} actions {
  action ChangeEntProjElmntPosition(
    @sap.label : 'PrjElmnt GUID'
    ParentObjectUUID : UUID null,
    @sap.label : 'PrjElmnt GUID'
    LeftSiblingUUID : UUID null
  ) returns S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement null;
  action ChangeEntProjElmntProcgStatus(
    @sap.label : 'Proc. Status'
    ProcessingStatus : String(2) null
  ) returns S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.deletable : 'false'
@sap.content.version : '2'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project JVA'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectJVA {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  key ProjectUUID : UUID not null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Joint Venture'
  JointVenture : String(6) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Recovery Indicator'
  JointVentureCostRecoveryCode : String(2) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Equity type'
  JointVentureEquityType : String(3) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'JV Object Type'
  @sap.quickinfo : 'Joint Venture Object Type'
  JntVntrProjectType : String(4) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'JIB/JIBE Class'
  JntIntrstBillgClass : String(3) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'JIB/JIBE Subclass A'
  JntIntrstBillgSubClass : String(5) null;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
};

@cds.external : true
@cds.persistence.skip : true
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.content.version : '2'
@sap.label : 'Project Role'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectRole {
  @sap.label : 'Role'
  @sap.quickinfo : 'Role GUID'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  key ProjectRoleUUID : UUID not null;
  @sap.label : 'Project'
  @sap.quickinfo : 'Project GUID'
  @sap.updatable : 'false'
  ProjectUUID : UUID null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Role Type'
  ProjectRoleType : String(15) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Role Category'
  ProjectRoleCategory : String(3) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Role Name'
  ProjectRoleName : String(40) null;
  @sap.label : 'Created By'
  @sap.quickinfo : 'Name of Person Who Created Object'
  CreatedByUser : String(12) null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Created On'
  @sap.quickinfo : 'Timestamp of Object Creation'
  CreationDateTime : DateTime null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Changed By'
  @sap.quickinfo : 'Name of Person Who Changed Object'
  LastChangedByUser : String(12) null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Changed On'
  @sap.quickinfo : 'Timestamp of Last Object Change'
  LastChangeDateTime : DateTime null;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
};

@cds.external : true
@cds.persistence.skip : true
@sap.updatable : 'false'
@sap.deletable : 'false'
@sap.content.version : '2'
@sap.label : 'Project Team Member'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectTeamMember {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  key TeamMemberUUID : UUID not null;
  @sap.label : 'Dynamic CbA-Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  to_EntProjEntitlement_oc : Boolean null;
  @sap.label : 'BP GUID'
  @sap.quickinfo : 'Business Partner GUID'
  BusinessPartnerUUID : UUID null;
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.updatable : 'false'
  ProjectUUID : UUID null;
  @sap.label : 'Created By'
  @sap.quickinfo : 'Name of Person Who Created Object'
  CreatedByUser : String(12) null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Created On'
  @sap.quickinfo : 'Timestamp of Object Creation'
  CreationDateTime : DateTime null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Changed By'
  @sap.quickinfo : 'Name of Person Who Changed Object'
  LastChangedByUser : String(12) null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Changed On'
  @sap.quickinfo : 'Timestamp of Last Object Change'
  LastChangeDateTime : DateTime null;
  @cds.ambiguous : 'missing on condition?'
  to_EntProjEntitlement : Composition of many S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntTeamMemberEntitlement on to_EntProjEntitlement.TeamMemberUUID = TeamMemberUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '2'
@sap.deletable.path : 'Delete_mc'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  key ProjectUUID : UUID not null;
  @sap.label : 'Dyn. Action Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ChangeEntProjProcgStatus_ac : Boolean null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ActualEndDate_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ActualStartDate_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  AvailabilityControlIsActive_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  AvailabilityControlProfile_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ControllingArea_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  EnterpriseProjectType_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  EntProjIsMultiSlsOrdItmsEnbld_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FunctionalArea_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FunctionalLocation_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  InvestmentProfile_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  IsBillingRelevant_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Location_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Plant_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  PriorityCode_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProfitCenter_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Project_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProjectCurrency_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProjectDescription_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProjectEndDate_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProjectProfileCode_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ProjectStartDate_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  ResponsibleCostCenter_fc : Integer null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Delete_mc : Boolean null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.label : 'Dynamic CbA-Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  to_EnterpriseProjectElement_oc : Boolean null;
  @sap.label : 'Dynamic CbA-Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  to_EntProjBlkFunc_oc : Boolean null;
  @sap.label : 'Dynamic CbA-Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  to_EntProjRole_oc : Boolean null;
  @sap.label : 'Dynamic CbA-Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  to_EntProjTeamMember_oc : Boolean null;
  @sap.display.format : 'NonNegative'
  @sap.label : 'Project def.'
  @sap.quickinfo : 'Project (internal)'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  ProjectInternalID : String(8) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'Project_fc'
  @sap.text : 'ProjectDescription'
  @sap.label : 'Number'
  @sap.quickinfo : 'Identification of Entities'
  Project : String(24) null;
  @sap.field.control : 'ProjectDescription_fc'
  @sap.label : 'Name'
  @sap.quickinfo : 'Description'
  ProjectDescription : String(60) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'EnterpriseProjectType_fc'
  @sap.label : 'Project Type'
  EnterpriseProjectType : String(2) null;
  @sap.display.format : 'NonNegative'
  @sap.field.control : 'PriorityCode_fc'
  @sap.label : 'Priority'
  PriorityCode : String(3) null;
  @sap.display.format : 'Date'
  @sap.field.control : 'ProjectStartDate_fc'
  @sap.label : 'Latest Planned Start'
  ProjectStartDate : Date null;
  @sap.display.format : 'Date'
  @sap.field.control : 'ProjectEndDate_fc'
  @sap.label : 'Ltst Planned Finish'
  @sap.quickinfo : 'Latest Planned Finish'
  ProjectEndDate : Date null;
  @sap.display.format : 'Date'
  @sap.field.control : 'ActualStartDate_fc'
  @sap.label : 'Actual Start'
  ActualStartDate : Date null;
  @sap.display.format : 'Date'
  @sap.field.control : 'ActualEndDate_fc'
  @sap.label : 'Actual Finish'
  ActualEndDate : Date null;
  @sap.label : 'BP GUID'
  @sap.quickinfo : 'Business Partner GUID'
  CustomerUUID : UUID null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Service Organization'
  EnterpriseProjectServiceOrg : String(5) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Confidential'
  @sap.quickinfo : 'Enterprise Project Is Confidential'
  EntProjectIsConfidential : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Restrict Unstaffed'
  @sap.quickinfo : 'Restrict Unstaffed Posting'
  RestrictedTimePosting : String(1) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Processing Status'
  @sap.quickinfo : 'Object Processing Status'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  ProcessingStatus : String(2) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ResponsibleCostCenter_fc'
  @sap.label : 'Responsible CC'
  @sap.quickinfo : 'Responsible Cost Center'
  ResponsibleCostCenter : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ProfitCenter_fc'
  @sap.label : 'Profit Center'
  ProfitCenter : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ProjectProfileCode_fc'
  @sap.label : 'Project Profile'
  ProjectProfileCode : String(7) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'FunctionalArea_fc'
  @sap.label : 'Functional Area'
  FunctionalArea : String(16) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Company code'
  @sap.quickinfo : 'Company code for the project'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  CompanyCode : String(4) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ControllingArea_fc'
  @sap.label : 'Controlling area'
  @sap.quickinfo : 'Controlling area for the project'
  ControllingArea : String(4) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'Plant_fc'
  @sap.label : 'Plant'
  Plant : String(4) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'Location_fc'
  @sap.label : 'Location'
  Location : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Tax Jurisdiction'
  TaxJurisdiction : String(15) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'ProjectCurrency_fc'
  @sap.label : 'Custom Project Curr'
  @sap.quickinfo : 'Custom Project Currency'
  @sap.semantics : 'currency-code'
  ProjectCurrency : String(5) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'AvailabilityControlProfile_fc'
  @sap.label : 'Availy Ctrl Prfl'
  @sap.quickinfo : 'Budget Availability Control: Profile'
  AvailabilityControlProfile : String(6) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'AvailabilityControlIsActive_fc'
  @sap.label : 'AVC is active'
  @sap.quickinfo : 'Availability control indicator(AVC)'
  AvailabilityControlIsActive : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'FunctionalLocation_fc'
  @sap.label : 'Functional Location'
  FunctionalLocation : String(40) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'IsBillingRelevant_fc'
  @sap.label : 'Billing Element'
  @sap.quickinfo : 'Indicator: Billing element'
  IsBillingRelevant : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'InvestmentProfile_fc'
  @sap.label : 'Investment Profile'
  @sap.quickinfo : 'Investment Measure Profile'
  InvestmentProfile : String(6) null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Changed On'
  @sap.quickinfo : 'Timestamp of Last Object Change'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  LastChangeDateTime : DateTime null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Changed on'
  @sap.quickinfo : 'Timestamp on which project data was changed last'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  ProjectLastChangedDateTime : DateTime null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Changed By'
  @sap.quickinfo : 'Name of Person Who Changed Object'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  LastChangedByUser : String(12) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'EntProjIsMultiSlsOrdItmsEnbld_fc'
  @sap.label : 'Project Assigned'
  @sap.quickinfo : 'Enterprise Project Assigned to Multiple SO Items'
  EntProjIsMultiSlsOrdItmsEnbld : Boolean null;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProjectElement : Composition of many S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement on to_EnterpriseProjectElement.ProjectUUID = ProjectUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProjectJVA : Composition of S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectJVA on to_EnterpriseProjectJVA.ProjectUUID = ProjectUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EntProjBlkFunc : Composition of S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjBlkFunc on to_EntProjBlkFunc.ProjectUUID = ProjectUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EntProjectPublicSector : Composition of S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntProjectPublicSector on to_EntProjectPublicSector.ProjectUUID = ProjectUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EntProjRole : Composition of many S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectRole on to_EntProjRole.ProjectUUID = ProjectUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EntProjTeamMember : Composition of many S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectTeamMember on to_EntProjTeamMember.ProjectUUID = ProjectUUID;
} actions {
  action ChangeEntProjProcgStatus(
    @sap.label : 'Proc. Status'
    ProcessingStatus : String(2) null
  ) returns S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject null;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.deletable : 'false'
@sap.content.version : '2'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project Element JVA'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntProjectElementJVA {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.updatable : 'false'
  key ProjectElementUUID : UUID not null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  JntIntrstBillgClass_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  JntIntrstBillgSubClass_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  JntVntrProjectType_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  JointVenture_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  JointVentureCostRecoveryCode_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  JointVentureEquityType_fc : Integer null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.updatable : 'false'
  ProjectUUID : UUID null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'JointVenture_fc'
  @sap.label : 'Joint Venture'
  JointVenture : String(6) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'JointVentureCostRecoveryCode_fc'
  @sap.label : 'Recovery Indicator'
  JointVentureCostRecoveryCode : String(2) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'JointVentureEquityType_fc'
  @sap.label : 'Equity type'
  JointVentureEquityType : String(3) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'JntVntrProjectType_fc'
  @sap.label : 'JV Object Type'
  @sap.quickinfo : 'Joint Venture Object Type'
  JntVntrProjectType : String(4) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'JntIntrstBillgClass_fc'
  @sap.label : 'JIB/JIBE Class'
  JntIntrstBillgClass : String(3) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'JntIntrstBillgSubClass_fc'
  @sap.label : 'JIB/JIBE Subclass A'
  JntIntrstBillgSubClass : String(5) null;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProjectElement : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement on to_EnterpriseProjectElement.ProjectElementUUID = ProjectElementUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.deletable : 'false'
@sap.content.version : '2'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project Public Sector'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntProjectPublicSector {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  key ProjectUUID : UUID not null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Fund'
  Fund : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Fund Fixed Assignment'
  @sap.quickinfo : 'Indicator for Fund with Fixed Assignment'
  FundIsFixAssigned : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Functional Area Fixed Assignment'
  @sap.quickinfo : 'Indicator for Functional Area with Fixed Assignment'
  FunctionalAreaIsFixAssigned : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Grant'
  GrantID : String(20) null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Grant Fixed Assignment'
  @sap.quickinfo : 'Indicator for Grant with Fixed Assignment'
  GrantIsFixAssigned : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Sponsored Program'
  SponsoredProgram : String(20) null;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
};

@cds.external : true
@cds.persistence.skip : true
@sap.deletable : 'false'
@sap.content.version : '2'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project Element Block Function'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntProjElmntBlockFunc {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.updatable : 'false'
  key ProjectElementUUID : UUID not null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  EntProjOtherExpensePostgIsBlkd_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  EntProjPurchasingIsBlkd_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  EntProjServicePostingIsBlkd_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  EntProjStaffExpensePostgIsBlkd_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  EntProjTimeRecgIsBlkd_fc : Integer null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.updatable : 'false'
  ProjectUUID : UUID null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'EntProjTimeRecgIsBlkd_fc'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjTimeRecgIsBlkd : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'EntProjStaffExpensePostgIsBlkd_fc'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjStaffExpensePostgIsBlkd : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'EntProjServicePostingIsBlkd_fc'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjServicePostingIsBlkd : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'EntProjOtherExpensePostgIsBlkd_fc'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjOtherExpensePostgIsBlkd : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'EntProjPurchasingIsBlkd_fc'
  @sap.label : 'Boolean Variable (X = True, - = False, Space = Unknown)'
  @sap.heading : ''
  EntProjPurchasingIsBlkd : Boolean null;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProjectElement : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement on to_EnterpriseProjectElement.ProjectElementUUID = ProjectElementUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
};

@cds.external : true
@cds.persistence.skip : true
@sap.creatable : 'false'
@sap.deletable : 'false'
@sap.content.version : '2'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project Element Public Sector'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntProjectElmntPublicSector {
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.updatable : 'false'
  key ProjectElementUUID : UUID not null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FunctionalAreaIsFixAssigned_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Fund_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  FundIsFixAssigned_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  GrantID_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  GrantIsFixAssigned_fc : Integer null;
  @odata.Type : 'Edm.Byte'
  @sap.label : 'Dyn. Field Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  SponsoredProgram_fc : Integer null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.label : 'Entity GUID'
  @sap.quickinfo : 'Entity Guid'
  @sap.updatable : 'false'
  ProjectUUID : UUID null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'Fund_fc'
  @sap.label : 'Fund'
  Fund : String(10) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'FundIsFixAssigned_fc'
  @sap.label : 'Fund Fixed Assignment'
  @sap.quickinfo : 'Indicator for Fund with Fixed Assignment'
  FundIsFixAssigned : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'FunctionalAreaIsFixAssigned_fc'
  @sap.label : 'Functional Area Fixed Assignment'
  @sap.quickinfo : 'Indicator for Functional Area with Fixed Assignment'
  FunctionalAreaIsFixAssigned : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'GrantID_fc'
  @sap.label : 'Grant'
  GrantID : String(20) null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'GrantIsFixAssigned_fc'
  @sap.label : 'Grant Fixed Assignment'
  @sap.quickinfo : 'Indicator for Grant with Fixed Assignment'
  GrantIsFixAssigned : Boolean null;
  @sap.display.format : 'UpperCase'
  @sap.field.control : 'SponsoredProgram_fc'
  @sap.label : 'Sponsored Program'
  SponsoredProgram : String(20) null;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProjectElement : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectElement on to_EnterpriseProjectElement.ProjectElementUUID = ProjectElementUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
};

@cds.external : true
@cds.persistence.skip : true
@sap.content.version : '2'
@sap.deletable.path : 'Delete_mc'
@sap.updatable.path : 'Update_mc'
@sap.label : 'Project Entitlement'
entity S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EntTeamMemberEntitlement {
  @sap.label : 'Entitlement'
  @sap.quickinfo : 'Entitlement Guid'
  @sap.updatable : 'false'
  key ProjectEntitlementUUID : UUID not null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Delete_mc : Boolean null;
  @sap.label : 'Dyn. Method Control'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  @sap.sortable : 'false'
  @sap.filterable : 'false'
  Update_mc : Boolean null;
  @sap.label : 'Project'
  @sap.quickinfo : 'Project GUID'
  @sap.creatable : 'false'
  @sap.updatable : 'false'
  ProjectUUID : UUID null;
  @sap.label : 'Role'
  @sap.quickinfo : 'Role GUID'
  @sap.updatable : 'false'
  ProjectRoleUUID : UUID null;
  @sap.label : 'Team Member'
  @sap.quickinfo : 'Team Member GUID'
  @sap.updatable : 'false'
  TeamMemberUUID : UUID null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Role Type'
  ProjectRoleType : String(15) null;
  @sap.label : 'Created By'
  @sap.quickinfo : 'Name of Person Who Created Object'
  CreatedByUser : String(12) null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Created On'
  @sap.quickinfo : 'Timestamp of Object Creation'
  CreationDateTime : DateTime null;
  @sap.display.format : 'UpperCase'
  @sap.label : 'Changed By'
  @sap.quickinfo : 'Name of Person Who Changed Object'
  LastChangedByUser : String(12) null;
  @odata.Type : 'Edm.DateTimeOffset'
  @sap.label : 'Changed On'
  @sap.quickinfo : 'Timestamp of Last Object Change'
  LastChangeDateTime : DateTime null;
  @cds.ambiguous : 'missing on condition?'
  to_TeamMember : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectTeamMember on to_TeamMember.TeamMemberUUID = TeamMemberUUID;
  @cds.ambiguous : 'missing on condition?'
  to_EnterpriseProject : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProject on to_EnterpriseProject.ProjectUUID = ProjectUUID;
  @cds.ambiguous : 'missing on condition?'
  to_Role : Association to S4HC_API_ENTERPRISE_PROJECT_SRV_0002.A_EnterpriseProjectRole {  };
};

