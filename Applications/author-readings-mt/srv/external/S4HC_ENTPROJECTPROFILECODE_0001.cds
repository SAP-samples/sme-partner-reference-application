/* checksum : 13e587f74abded43d3b4b29d2579f7fc */
@cds.external : true
@cds.persistence.skip : true
@Capabilities.SearchRestrictions : {
  Searchable: true,
  UnsupportedExpressions: #phrase
}
@Capabilities.InsertRestrictions : { Insertable: false }
@Capabilities.DeleteRestrictions : { Deletable: false }
@Capabilities.UpdateRestrictions : {
  Updatable: false,
  QueryOptions: { SelectSupported: true }
}
@Core.OptimisticConcurrency : [  ]
@Capabilities.FilterRestrictions : { FilterExpressionRestrictions: [ {
  Property: ProjectProfileCode,
  AllowedExpressions: 'MultiValue'
} ] }
entity S4HC_ENTPROJECTPROFILECODE_0001.ProjectProfileCode {
  @Common.SAPObjectNodeTypeReference : 'ProjectProfileCode'
  @Common.Text : { $Path: 'ProjectProfileCode' }
  @Common.IsUpperCase : true
  @Common.Label : 'Project Profile'
  @Common.Heading : 'Prj.Prf'
  key ProjectProfileCode : String(7) not null;
  @Common.Label : 'Description'
  @Common.QuickInfo : 'Text for Profile'
  ProjectProfileCodeText : String(40) not null;
  @cds.ambiguous : 'missing on condition?'
  @Common.Composition : null
  _ProjectProfileCodeText : Composition of many S4HC_ENTPROJECTPROFILECODE_0001.ProjectProfileCodeText;
};

@cds.external : true
@cds.persistence.skip : true
@Capabilities.SearchRestrictions : {
  Searchable: true,
  UnsupportedExpressions: #phrase
}
@Capabilities.InsertRestrictions : { Insertable: false }
@Capabilities.DeleteRestrictions : { Deletable: false }
@Capabilities.UpdateRestrictions : {
  Updatable: false,
  QueryOptions: { SelectSupported: true }
}
@Core.OptimisticConcurrency : [  ]
@Capabilities.FilterRestrictions : { FilterExpressionRestrictions: [ {
  Property: ProjectProfileCode,
  AllowedExpressions: 'MultiValue'
} ] }
entity S4HC_ENTPROJECTPROFILECODE_0001.ProjectProfileCodeText {
  @Common.Label : 'Language Key'
  @Common.Heading : 'Language'
  key Language : String(2) not null;
  @Common.Text : { $Path: 'ProjectProfileCode' }
  @Common.IsUpperCase : true
  @Common.Label : 'Project Profile'
  @Common.Heading : 'Prj.Prf'
  key ProjectProfileCode : String(7) not null;
  @Common.Label : 'Description'
  @Common.QuickInfo : 'Text for Profile'
  ProjectProfileCodeText : String(40) not null;
  @cds.ambiguous : 'missing on condition?'
  _ProjectProfileCode : Association to one S4HC_ENTPROJECTPROFILECODE_0001.ProjectProfileCode on _ProjectProfileCode.ProjectProfileCode = ProjectProfileCode;
};

@cds.external : true
@Aggregation.ApplySupported : {
  Transformations: [ 'aggregate', 'groupby', 'filter' ],
  Rollup: #None
}
@Common.ApplyMultiUnitBehaviorForSortingAndFiltering : true
@Capabilities.FilterFunctions : [ 'eq', 'ne', 'gt', 'ge', 'lt', 'le', 'and', 'or', 'contains', 'startswith', 'endswith', 'any', 'all' ]
@Capabilities.SupportedFormats : [ 'application/json', 'application/pdf' ]
service S4HC_ENTPROJECTPROFILECODE_0001 {};

