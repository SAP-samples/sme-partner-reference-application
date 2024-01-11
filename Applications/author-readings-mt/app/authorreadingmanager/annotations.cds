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
            Url   : projectURL,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, true, false ] } } //Display column in case of not B1 backend (back end could be ByD,S4HC,C4P)
        },
        {
            $Type : 'UI.DataField',
            Value : projectSystemName,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, true, false ] } } //Display column in case of not B1 backend (back end could be ByD,S4HC,C4P)
        },
        {
            $Type : 'UI.DataField',
            Value : projectSystem,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, true, false ] } } //Display column in case of not B1 backend (back end could be ByD,S4HC,C4P)
        },
        {
            $Type : 'UI.DataFieldWithUrl',
            Label : '{i18n>purchaseOrder}',
            Value : purchaseOrderID,
            Url   : purchaseOrderURL,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, false, true ] } } //Display column in case of B1 backend
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
            Label  : '{i18n>createProject}',
            Action : 'AuthorReadingManager.createByDProject',            
            @UI.Hidden : { $edmJson : 
                { $If : 
                    [
                        { $Eq : [ {$Path : 'createByDProjectEnabled'}, true ] },
                        false,
                        true
                    ]
                }   
            }
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>createProject}',
            Action : 'AuthorReadingManager.createS4HCProject',            
            @UI.Hidden : { $edmJson : 
                { $If : 
                    [
                        { $Eq : [ {$Path : 'createS4HCProjectEnabled'}, true ] },
                        false,
                        true
                    ]
                }   
            }
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>createProject}',
            Action : 'AuthorReadingManager.createC4PProject',            
            @UI.Hidden : { $edmJson : 
                { $If : 
                    [
                        { $Eq : [ {$Path : 'createC4PProjectEnabled'}, true ] },
                        false,
                        true
                    ]
                }   
            }
        }, 
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : '{i18n>createPurchaseOrder}',
            Action : 'AuthorReadingManager.createB1PurchaseOrder',            
            @UI.Hidden : { $edmJson : 
                { $If : 
                    [
                        { $Eq : [ {$Path : 'createB1PurchaseOrderEnabled'}, true ] },
                        false,
                        true
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
            ID     : 'ProjectDataByD',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#ProjectDataByD],
                ID     : 'ProjectDataByD'
            }],
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isByD'}, true ] }, false, true ] } }  //Display ProjectDataByD FieldGroup in case of ByD backend
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>projectData}',
            ID     : 'ProjectDataS4HC',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#ProjectDataS4HC],
                ID     : 'ProjectDataS4HC'
            }],
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isS4HC'}, true ] }, false, true ] } }  //Display ProjectDataS4HC FieldGroup in case of S4HC backend
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>projectData}',
            ID     : 'ProjectDataC4P',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#ProjectDataC4P],
                ID     : 'ProjectDataC4P'
            }],
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isC4P'}, true ] }, false, true ] } }  //Display ProjectDataC4P FieldGroup in case of C4P backend
        },  
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>purchaseOrderData}',
            ID     : 'PurchaseOrderDataB1',
            Facets : [{
                $Type  : 'UI.ReferenceFacet',
                Target : ![@UI.FieldGroup#PurchaseOrderDataB1],
                ID     : 'PurchaseOrderDataB1'
            }],
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, false, true ] } } //Display PurchaseOrderDataB1 FieldGroup in case of B1 backend
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
        // Display project related fields in case of backend systems ByD, S4HC, C4P (in case of B1 hide the project related fields)
        {
            $Type : 'UI.DataFieldWithUrl',
            Value : projectID,
            Url   : projectURL,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, true, false ] } } //Display field in case of not B1 backend (back end could be ByD,S4HC,C4P)
        },
        {
            $Type : 'UI.DataField',
            Value : projectSystemName,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, true, false ] } } //Display field in case of not B1 backend (back end could be ByD,S4HC,C4P)
        } ,
        {
            $Type : 'UI.DataField',
            Value : projectSystem,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, true, false ] } } //Display field in case of not B1 backend (back end could be ByD,S4HC,C4P)
        },
        // display B1 specific fields (hide the purchase order related fields incase of backend systems ByD, S4HC, C4P)
        {
            $Type : 'UI.DataFieldWithUrl',
            Label : '{i18n>purchaseOrder}',
            Value : purchaseOrderID,
            Url   : purchaseOrderURL,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, false, true ] } } //Display field in case of B1 backend (back end is not ByD,S4HC,C4P)
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>purchaseOrderSystemName}',
            Value : purchaseOrderSystem,
            @UI.Hidden : { $edmJson : { $If : [ { $Eq : [ {$Path : 'isB1'}, true ] }, false, true ] } } //Display field in case of  B1 backend (back end is not ByD,S4HC,C4P)
        },   
    ]},    
    FieldGroup #ProjectDataByD : {Data : [

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
            Value : toByDProject.typeCodeText
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectStatusCodeText}',
            Value : toByDProject.statusCodeText
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectCostCenter}',
            Value : toByDProject.costCenter
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectStartDateTime}',
            Value : toByDProject.startDateTime
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectEndDateTime}',
            Value : toByDProject.endDateTime
        },
    ]},
    FieldGroup #ProjectDataS4HC : {Data : [

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
       
        // S4HC specific fields
        {
            $Type : 'UI.DataField',
            Value : toS4HCProject.Project,
            @UI.Hidden : true 
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectDescription}',
            Value : toS4HCProject.ProjectDescription
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectProfile}',
            Value : projectProfileCodeText
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>responsibleCostCenter}',
            Value : toS4HCProject.ResponsibleCostCenter
        },
         {
            $Type : 'UI.DataField',
            Label : '{i18n>processingStatus}',
            Value : processingStatusText
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectStartDateTime}',
            Value : toS4HCProject.ProjectStartDate
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectEndDateTime}',
            Value : toS4HCProject.ProjectEndDate
        },
    ]},
    FieldGroup #ProjectDataC4P : {Data : [

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

        // C4P specific fields
        {
            $Type : 'UI.DataField',
            Value : toC4PProject.displayId,
            @UI.Hidden : true 
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectName}',
            Value : toC4PProject.projectName
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectStatus}',
            Value : toC4PProject.status
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectStartDateTime}',
            Value : toC4PProject.startDate
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>projectEndDateTime}',
            Value : toC4PProject.endDate
        },
        
        
    ]},
    FieldGroup #PurchaseOrderDataB1 : {Data : [

        // B1 specific fields
        {
            $Type : 'UI.DataFieldWithUrl',
            Label : '{i18n>purchaseOrder}',
            Value : purchaseOrderID,
            Url   : purchaseOrderURL
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>purchaseOrderSystemName}',
            Value : purchaseOrderSystem
        },       
        {
            $Type : 'UI.DataField',
            Label : '{i18n>deliveryDate}',
            Value : toB1PurchaseOrder.DocDueDate
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>creationDate}',
            Value : toB1PurchaseOrder.CreationDate
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>serviceProviderID}',
            Value : toB1PurchaseOrder.CardCode
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>serviceProviderName}',
            Value : toB1PurchaseOrder.CardName
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>purchaseOrderValue}',
            Value : toB1PurchaseOrder.DocTotal
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>purchaseOrderCurrency}',
            Value : toB1PurchaseOrder.DocCurrency
        },
        
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