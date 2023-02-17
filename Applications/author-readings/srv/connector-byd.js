"use strict";

// Include cds libraries and reuse files
const cds = require("@sap/cds");

// ----------------------------------------------------------------------------
// ByD specific reuse functions
// ----------------------------------------------------------------------------

// Delegate OData requests to remote ByD project entities
async function delegateODataRequests(req,remoteService) {
    try{
        const bydProject = await cds.connect.to(remoteService);
        return bydProject.run(req.query);
    }catch (error) {
        console.log(error);
    }
}

// Return json-payload to create ByD projects 
async function projectDataRecord(authorReadingIdentifier, authorReadingTitle, authorReadingDate) {
    try{
        // Set project ID with pattern AR-{{author reading identifier}}
        var generatedID = "AR-" + authorReadingIdentifier;
        // Set project start date 40 days before author reading date
        var moment = require("moment");
        var generatedStartDate = moment(authorReadingDate).subtract(40, "days").toISOString().substr(0, 10) + "T00:00:00.0000000Z";
        
        // Assemble project payload based the sample data provided by *SAP Business ByDesign Partner Demo Tenants* (reference systems)
        const projectRecord = {
            ProjectID: generatedID,
            EstimatedCompletionPercent: 10,
            ResponsibleCostCentreID: "S1111",
            ProjectTypeCode: "10",
            ProjectLanguageCode: "EN",
            PlannedStartDateTime: generatedStartDate,
            PlannedEndDateTime: authorReadingDate,
            ProjectSummaryTask: {
                ProjectName: authorReadingTitle,
                ResponsibleEmployeeID: "E0202",
            },
            Task: [
                {
                    TaskID: generatedID + "-PREP",
                    TaskName: "Event planning and preparations",
                    PlannedDuration: "P30D",
                    TaskRelationship: [
                        {
                            DependencyTypeCode: "2",
                            SuccessorTaskID: generatedID + "-EXE",
                            LagDuration: "P2D",
                        },
                    ],
                },
                {
                    TaskID: generatedID + "-EXE",
                    TaskName: "Event administration and execution",
                    PlannedDuration: "P5D",
                    ConstraintEndDateTime: authorReadingDate,
                    ScheduleActivityEndDateTimeConstraintTypeCode: "2",
                },
            ],
        };
        return projectRecord;
    }catch (error) {
        console.log(error);
    }
}

// Expand author readings to remote projects
async function readProject(authorReadings) {
    try {     
        const bydProject = await cds.connect.to('byd_khproject');  
        let isProjectIDs = false;
        const asArray = x => Array.isArray(x) ? x : [ x ];

        // Read Project ID's related to ByD
        let projectIDs = []; 
        for (const authorReading of asArray(authorReadings)) {
            // Check if the Project ID exists in the author reading record AND backend ERP is ByD => then read project information from ByD
            if(authorReading.projectSystem == "ByD" && authorReading.projectID ){               
                projectIDs.push(authorReading.projectID);
                isProjectIDs = true;
            }
        }
        
        // Read ByD projects data
        if(isProjectIDs){

            // Request all associated projects        
            const projects = await bydProject.run( SELECT.from('AuthorReadingManager.ByDProjects').where({ projectID: projectIDs }) );

            // Convert in a map for easier lookup
            const projectsMap = {};
            for (const project of projects) projectsMap[project.projectID] = project;

            // Assemble result
            for (const authorReading of asArray(authorReadings)) {
                authorReading.toByDProject = projectsMap[authorReading.projectID];
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