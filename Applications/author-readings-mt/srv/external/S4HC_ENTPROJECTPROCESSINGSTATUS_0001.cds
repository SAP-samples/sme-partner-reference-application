/* checksum : b25f54b418484e6f0af7f21d099f55fb */
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
  Property: ProcessingStatus,
  AllowedExpressions: 'MultiValue'
}, {
  Property: ProcessingStatusText,
  AllowedExpressions: 'MultiValue'
} ] }
entity S4HC_ENTPROJECTPROCESSINGSTATUS_0001.ProcessingStatusText {
  @Common.Label : 'Language Key'
  @Common.Heading : 'Language'
  key Language : String(2) not null;
  @Common.Text : { $Path: 'ProcessingStatusText' }
  @Common.IsUpperCase : true
  @Common.Label : 'Processing Status'
  key ProcessingStatus : String(2) not null;
  @Common.IsUpperCase : true
  @Common.Label : 'Status'
  @Common.Heading : 'Processing Status Text'
  @Common.QuickInfo : 'Processing Status Text'
  ProcessingStatusText : String(60) not null;
  @cds.ambiguous : 'missing on condition?'
  _ProcessingStatus : Association to one S4HC_ENTPROJECTPROCESSINGSTATUS_0001.ProcessingStatus on _ProcessingStatus.ProcessingStatus = ProcessingStatus;
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
  Property: ProcessingStatus,
  AllowedExpressions: 'MultiValue'
}, {
  Property: ProcessingStatusText,
  AllowedExpressions: 'MultiValue'
} ] }
entity S4HC_ENTPROJECTPROCESSINGSTATUS_0001.ProcessingStatus {
  @Common.Text : { $Path: 'ProcessingStatusText' }
  @Common.IsUpperCase : true
  @Common.Label : 'Processing Status'
  key ProcessingStatus : String(2) not null;
  @Common.IsUpperCase : true
  @Common.Label : 'Status'
  @Common.Heading : 'Processing Status Text'
  @Common.QuickInfo : 'Processing Status Text'
  ProcessingStatusText : String(60) not null;
  @cds.ambiguous : 'missing on condition?'
  @Common.Composition : null
  _ProcessingStatusText : Composition of many S4HC_ENTPROJECTPROCESSINGSTATUS_0001.ProcessingStatusText;
};

@cds.external : true
@Aggregation.ApplySupported : {
  Transformations: [ 'aggregate', 'groupby', 'filter' ],
  Rollup: #None
}
@Common.ApplyMultiUnitBehaviorForSortingAndFiltering : true
@Capabilities.FilterFunctions : [ 'eq', 'ne', 'gt', 'ge', 'lt', 'le', 'and', 'or', 'contains', 'startswith', 'endswith', 'any', 'all' ]
@Capabilities.SupportedFormats : [ 'application/json', 'application/pdf' ]
service S4HC_ENTPROJECTPROCESSINGSTATUS_0001 {};

