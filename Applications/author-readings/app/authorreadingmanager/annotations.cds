using AuthorReadingManager as service from '../../srv/service-models';

// ----------------------------------------------------------------------------
// Author readings floorplan

annotate service.AuthorReadings with @(UI : {

    SelectionFields : [
        identifier,
        date,
        maxParticipantsNumber,
        availableFreeSlots,
        statusCode_code,
        participantsFeeAmount,
        projectID,
        projectSystem,        
        projectSystemName        
    ],
   
    // Table columns
    LineItem : [
        {
            $Type  : 'UI.DataFieldForAction',
            Label  :  '{i18n>publish}',
            Action : 'AuthorReadingManager.publish'
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>block}',
            Action : 'AuthorReadingManager.block'
        },
        {
            $Type : 'UI.DataField',
            Value : identifier
        },
        {
            $Type : 'UI.DataField',
            Value : title
        },
        {
            $Type : 'UI.DataField',
            Value : description,
            @UI.Hidden : true
        },
        {
            $Type       : 'UI.DataField',
            Value       : statusCode.descr,
            Criticality : statusCriticality,
            Label       : '{i18n>statusCriticality}'
        },        
        {
            $Type : 'UI.DataFieldWithUrl',
            Value : projectID,
            Url   : projectURL
        },
        {
            $Type : 'UI.DataField',
            Value : projectSystemName
        },
        {
            $Type : 'UI.DataField',
            Value : projectSystem
        },
        {
            $Type : 'UI.DataField',
            Value : date
        },
/*        
        {
            Value      : statusCode.code,
            @UI.Hidden : true
        },
*/        
        {
            $Type : 'UI.DataField',
            Value : participantsFeeAmount
        },
        {
            $Type : 'UI.DataField',
            Value : availableFreeSlots
        },
        {
            $Type : 'UI.DataField',
            Value : createdBy
        }
    ],

    Identification : [
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>publish}',
            Action : 'AuthorReadingManager.publish'
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>block}',
            Action : 'AuthorReadingManager.block'
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>createByDProject}',
            Action : 'AuthorReadingManager.createByDProject',            
            @UI.Hidden : { $edmJson : 
                { $If : 
                    [
                        { $Eq : [ {$Path : 'createByDProjectEnabled'}, false ] },
                        true,
                        false
                    ]
                }   
            }
        }
    ],
    
    HeaderInfo : {
        $Type          : 'UI.HeaderInfoType',
        TypeName       : '{i18n>authorreading}',
        TypeNamePlural : '{i18n>authorreading-plural}',
        Title          : {
            $Type : 'UI.DataField',
            Value : identifier
        },
        Description    : {
            $Type : 'UI.DataField',
            Value : description
        }
    },
      
    HeaderFacets : [
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#Date'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#AvailableFreeSlots'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#ParticipantsFeeAmount'
        },                
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#Status' 
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.FieldGroup#Created'
        }
    ],
    DataPoint #Date : {
        Title : '{i18n>date}',        
        Value : date,
        ![@UI.Emphasized],
    },
    DataPoint #AvailableFreeSlots : {
        Title : '{i18n>availableFreeSlots}',        
        Value : availableFreeSlots,
        ![@UI.Emphasized],
    },
    DataPoint #ParticipantsFeeAmount : {
        Title : '{i18n>participantsFeeAmount}',        
        Value : participantsFeeAmount,
        ![@UI.Emphasized],
    },
    DataPoint #Status : {
        Title : '{i18n>statusCriticality}',        
        Value       : statusCode.descr,
        Criticality : statusCriticality,
        ![@UI.Emphasized],
    },
    Facets                           : [
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>generalData}',
            ID     : 'GeneralData',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#Values],
                ID     : 'GeneralData'
            }],
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>participantData}',
            ID     : 'Participants',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : 'participants/@UI.LineItem',
                ID     : 'Participants'
            }],
        },        
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>projectData}',
            ID     : 'ProjectData',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#ProjectData],
                ID     : 'ProjectData'
            }],
        },        
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>administativeData}',
            ID     : 'AdministrativeData',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#AdminData],
                ID     : 'AdministrativeData'
            }],
        }        
    ],    
    FieldGroup #Values : {Data : [
        {
            $Type : 'UI.DataField',
            Value : identifier,
        },
        {
            $Type : 'UI.DataField',
            Value : statusCode.descr,
        },
        {
            $Type : 'UI.DataField',
            Value : title,
        },
        {
            $Type : 'UI.DataField',
            Value : description,
        },
        {
            $Type : 'UI.DataField',
            Value : date,
        },
        {
            $Type : 'UI.DataField',
            Value : maxParticipantsNumber,
        },
        {
            $Type : 'UI.DataField',
            Value : availableFreeSlots,
        },
        {
            $Type : 'UI.DataField',
            Value : participantsFeeAmount,
        },
        {
            $Type : 'UI.DataFieldWithUrl',
            Value : projectID,
            Url   : projectURL
        },
        {
            $Type : 'UI.DataField',
            Value : projectSystemName
        } ,
        {
            $Type : 'UI.DataField',
            Value : projectSystem
        }
    ]},    
    FieldGroup #ProjectData : {Data : [
        // Project system independend fields:
        {
            $Type : 'UI.DataFieldWithUrl',
            Value : projectID,
            Url   : projectURL,
            @UI.Hidden : false
        },
                {
            $Type : 'UI.DataField',
            Value : projectSystemName,
            @UI.Hidden : false
        },
        {
            $Type : 'UI.DataField',
            Value : projectSystem,
            @UI.Hidden : false
        },

        // SAP Business ByDesign specific fields
        {
            $Type : 'UI.DataField',
            Value : toByDProject.projectID,
            @UI.Hidden : true 
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectTypeCodeText}',
            Value : toByDProject.typeCodeText,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectStatusCodeText}',
            Value : toByDProject.statusCodeText,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectCostCenter}',
            Value : toByDProject.costCenter,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectStartDateTime}',
            Value : toByDProject.startDateTime,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectEndDateTime}',
            Value : toByDProject.endDateTime,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'projectSystem'}, 'ByD' ] }, false, true ] } }
        }
    ]},
    FieldGroup #AdminData : {Data : [
        {
            $Type : 'UI.DataField',
            Value : createdBy,
        },
        {
            $Type : 'UI.DataField',
            Value : createdAt,
        },
        {
            $Type : 'UI.DataField',
            Value : modifiedBy,
        },
        {
            $Type : 'UI.DataField',
            Value : modifiedAt,
        },
        {
            $Type : 'UI.DataField',
            Value : eventMeshMessage,
        }
    ]},
    FieldGroup #Created : {Data : [
        {
            $Type : 'UI.DataField',
            Value : createdBy,
        },
        {
            $Type : 'UI.DataField',
            Value : createdAt,
        },
    ]}
});

// ----------------------------------------------------------------------------
// Participants floorplan

annotate service.Participants with @(UI : {

    SelectionFields : [
        identifier,
        email,
        mobileNumber,
        statusCode_code
    ],

    LineItem : [
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>confirmParticipation}',
            Action : 'AuthorReadingManager.confirmParticipation'
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>cancelParticipation}',
            Action : 'AuthorReadingManager.cancelParticipation'
        },
        {
            $Type             : 'UI.DataField',
            Value             : identifier,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : name,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : email,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : mobileNumber,
            ![@UI.Importance] : #High,
        },
        {
            Value      : statusCode_code,
            @UI.Hidden : true
        },
        {
            $Type             : 'UI.DataField',
            Label             : '{i18n>statusCriticality}',
            Value             : statusCode.descr,
            Criticality       : statusCriticality
        }
    ],

    // Participant details
    HeaderInfo : {
        $Type          : 'UI.HeaderInfoType',
        TypeName       : '{i18n>participant}',
        TypeNamePlural : '{i18n>participant-plural}',
        Title          : {
            $Type : 'UI.DataField',
            Value : identifier,
        },
        Description    : {
            $Type : 'UI.DataField',
            Value : name,
        }

    },
    HeaderFacets : [
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#ParticipantStatus'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.FieldGroup#Created'
        }
    ],
    DataPoint #ParticipantStatus : {
        Title       : '{i18n>codeListStatusText}',        
        Value       : statusCode.descr,
        Criticality : statusCriticality,
        ![@UI.Emphasized],
    },
    Facets : [
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>generalData}',
            ID     : 'GeneralData',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#ParticipantDetails],
                ID     : 'GeneralData'
            }],
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>administativeData}',
            ID     : 'AdministrativeData',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#AdminData],
                ID     : 'AdministrativeData'
            }],
        }
    ],
    FieldGroup #ParticipantDetails : {Data : [
        {
            $Type : 'UI.DataField',
            Value : identifier,
        },
        {
            $Type : 'UI.DataField',
            Value : name,
        },
        {
            $Type : 'UI.DataField',
            Value : email,
        },
        {
            $Type : 'UI.DataField',
            Value : mobileNumber,
        }
    ]},
    FieldGroup #AdminData : {Data : [
        {
            $Type : 'UI.DataField',
            Value : createdBy,
        },
        {
            $Type : 'UI.DataField',
            Value : createdAt,
        },
        {
            $Type : 'UI.DataField',
            Value : modifiedBy,
        },
        {
            $Type : 'UI.DataField',
            Value : modifiedAt,
        }
    ]},
    FieldGroup #Created : {Data : [
        {
            $Type : 'UI.DataField',
            Value : createdAt,
        },
        {
            $Type : 'UI.DataField',
            Value : modifiedAt,
        }
    ]}
});