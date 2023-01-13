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
// OData parameter following the UI-request pattern: "/AuthorReadings(ID=79ceab87-300d-4b66-8cc3-f82c679b77a1,IsActiveEntity=true)?$select=toByDProject&$expand=toByDProject($select=ID,costCenter,endDateTime,startDateTime,statusCodeText,typeCodeText)"
async function readProject(req, next) {
    try {     
        const bydProject = await cds.connect.to('byd_khproject');
        var expandIndex = -1;
        // Check the if the object exists before running the findIndex-function
        if(req){
            if(req.query){                
                if(req.query.SELECT){
                    if(req.query.SELECT.columns){
                        expandIndex = req.query.SELECT.columns.findIndex( ({ expand, ref }) => expand && ref[0] === "toByDProject" );
                    }
                }
            }
        }
        if (expandIndex < 0) return next();
        // Remove expand from query
        req.query.SELECT.columns.splice(expandIndex, 1);
        // Return projectID
        if (!req.query.SELECT.columns.find(
            column => column.ref.find((ref) => ref == "projectID"))
        ) req.query.SELECT.columns.push({ ref: ["projectID"] });

        const authorReadings = await next();
        const asArray = x => Array.isArray(x) ? x : [ x ];

        // Read Project ID's related to ByD
        let projectIDs = []; 
        for (const authorReading of asArray(authorReadings)) {
            //Check if the Project ID exist in the aurthor reading record AND backend ERP is ByD => then project information is read from ByD
            if(authorReading.projectSystem == "ByD" && authorReading.projectID ){               
                projectIDs.push(authorReading.projectID);
            }
        }
        
        // Read the ByD Projects data only if ProjectIDs is filled ( other wise with blank entries in projectIDs , the SELECT with fetch all projects from ByD )
        if(projectIDs.length > 0){
            // Request all associated projects        
            const projects = await bydProject.run( SELECT.from('AuthorReadingManager.ByDProjects').where({ projectID: projectIDs }) );

            // Convert in a map for easier lookup
            const projectsMap = {};
            for (const project of projects) projectsMap[project.projectID] = project;
            // Add suppliers to result
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