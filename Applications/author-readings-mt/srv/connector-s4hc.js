"use strict";

// Include cds libraries and reuse files
const cds = require("@sap/cds");

// ----------------------------------------------------------------------------
// ByD specific reuse functions
// ----------------------------------------------------------------------------

// Delegate OData requests to remote S4HC project entities
async function delegateODataRequests(req,remoteService) {
    try{
        const s4hcProject = await cds.connect.to(remoteService);
        return s4hcProject.run(req.query);
    }catch (error) {
        console.log(error);
    }
}

// Return json-payload to create S4HC projects 
async function projectDataRecord(authorReadingIdentifier, authorReadingTitle, authorReadingDate) {
    try{
        // Set project ID with pattern PRA-{{author reading identifier}}
        var generatedID = "PRA-" + authorReadingIdentifier;
        var generatedPLANID = generatedID + "-PLAN";
        var generatedEXEID = generatedID + "-EXE";

        // Set project start date 30 days before author reading date
        var moment = require("moment");
        var generatedStartDate = moment(authorReadingDate).subtract(30, "days").toISOString().substr(0, 10) + "T00:00:00.0000000Z";
        var generatedEndDate   = moment(generatedStartDate).add(30, "days").toISOString().substr(0, 10) + "T00:00:00.0000000Z";
        var generatedTaskEndDate   = moment(generatedEndDate).add(30, "days").toISOString().substr(0, 10) + "T00:00:00.0000000Z";
        
        // Assemble project payload based the sample data provided by *SAP Business ByDesign Partner Demo Tenants* (reference systems)
        const projectRecord = {
            "Project": generatedID,
            "ProjectDescription": authorReadingTitle,
            "ProjectStartDate": generatedStartDate,
            "ProjectEndDate": generatedEndDate,
            "EntProjectIsConfidential": false,
            "ResponsibleCostCenter": "10101601",
            "ProfitCenter": "YB900",
            "ProjectProfileCode": "YP03",
            "ProjectCurrency": "EUR",
            "to_EntProjTeamMember": [
                {
                    "BusinessPartnerUUID": "fa163ef3-01de-1edc-a2e5-b4de0917af16",
                    "to_EntProjEntitlement": [
                        {
                            "ProjectRoleType": "YP_RL_0001"
                        }
                    ]
                },
                {
                    "BusinessPartnerUUID": "fa163ef3-01de-1edc-b1a9-e163ddc535b6",
                    "to_EntProjEntitlement": [
                        {
                            "ProjectRoleType": "YP_RL_0004"
                        }
                    ]
                }
            ],
            "to_EnterpriseProjectElement": [
                {
                    "ProjectElement": generatedPLANID,
                    "ProjectElementDescription": "Event planning and preparations",
                    "PlannedStartDate": generatedStartDate,
                    "PlannedEndDate": generatedEndDate
                },
                {
                    "ProjectElement": generatedEXEID,
                    "ProjectElementDescription": "Event administration and execution",
                    "PlannedStartDate": generatedEndDate,
                    "PlannedEndDate": generatedTaskEndDate
                }
            ]
        };
        
        return projectRecord;
    }catch (error) {
        console.log(error);
    }
}

// Expand author readings to remote projects
// OData parameter following the UI-request pattern: "/AuthorReadings(ID=79ceab87-300d-4b66-8cc3-f82c679b77a1,IsActiveEntity=true)?$select=toByDProject&$expand=toS4HCProject($select=ProcessingStatus,ProjectDescription,ProjectEndDate,ProjectProfileCode,ProjectStartDate,ProjectUUID,ResponsibleCostCenter)""
async function readProject(authorReadings) {
    try {     
        const s4hcProject = await cds.connect.to('S4HC_API_ENTERPRISE_PROJECT_SRV_0002');
        let isProjectIDs = false;
        
        const asArray = x => Array.isArray(x) ? x : [ x ];
        // Read Project ID's related to ByD
        let projectIDs = []; 
        for (const authorReading of asArray(authorReadings)) {
            //Check if the Project ID exist in the aurthor reading record AND backend ERP is S4HC => then project information is read from S4HC
            if(authorReading.projectSystem == "S4HC" && authorReading.projectID ){               
                projectIDs.push(authorReading.projectID);
                isProjectIDs = true;
            }
        }
        
        // Read the S4HC Projects data only if ProjectIDs is filled ( other wise with blank entries in projectIDs , the SELECT with fetch all projects from S4HC )
        if(isProjectIDs){
            // Request all associated projects        
            const projects = await s4hcProject.run( SELECT.from('AuthorReadingManager.S4HCProjects').where({ Project: projectIDs }) );

            // Convert in a map for easier lookup
            const projectsMap = {};
            for (const project of projects) projectsMap[project.Project] = project;
            // Add suppliers to result
            for (const authorReading of asArray(authorReadings)) {
                authorReading.toS4HCProject = projectsMap[authorReading.projectID];
            };
        }
        return authorReadings;    
    } catch (error) {
        // App reacts error tolerant in case of calling the remote service, mostly if the remote service is not available of if the destination is missing
        console.log("ACTION_READ_PROJECT_CONNECTION" + "; " + error);
    };
}

// Publish constants and functions
module.exports = {
    readProject,
    projectDataRecord,
    delegateODataRequests
  };