"use strict";

// Include cds libraries and reuse files
const cds = require("@sap/cds");

// ----------------------------------------------------------------------------
// C4P specific reuse functions
// ----------------------------------------------------------------------------

// Delegate OData requests to remote C4P project entities
async function delegateODataRequests(req,remoteService) {
    try{
        const c4pProject = await cds.connect.to(remoteService);
        return c4pProject.run(req.query);
    }catch (error) {
        console.log(error);
    }
}

// Return json-payload to create C4P projects 
async function projectDataRecord(authorReadingIdentifier, authorReadingTitle, authorReadingDate) {
    try{
        // Set project ID with pattern PS-{{author reading identifier}}
        var generatedID = "PS-" + authorReadingIdentifier;

        // Set project start date 30 days before author reading date
        var moment = require("moment");
        var generatedStartDate = moment(authorReadingDate).subtract(30, "days").toISOString().substring(0, 10);
        var generatedEndDate   = moment(generatedStartDate).add(30, "days").toISOString().substring(0, 10);
        
        // Assemble project payload
        const projectRecord = {
            "displayId": generatedID,
            "name": authorReadingTitle,
            "startDate": generatedStartDate,
            "endDate": generatedEndDate,
            "location": "Dietmar-Hopp-Allee 15a, 69190 Walldorf, Germany",
            "description": "This project is created by the partner reference application for author readings and poetry slams.",
        };
        return projectRecord;
    }catch (error) {
        console.log(error);
    }
}

// Expand author readings to remote projects
async function readProject(authorReadings) {
    try {     
        const c4pProject = await cds.connect.to('c4p_ProjectService');
        let isProjectIDs = false;
        const asArray = x => Array.isArray(x) ? x : [ x ];

        // Read Project ID's related to C4P
        let projectIDs = []; 
        for (const authorReading of asArray(authorReadings)) {
            // Check if the Project ID exists in the author reading record AND backend ERP is C4P => then read project information from C4P
            if(authorReading.projectSystem == "C4P" && authorReading.projectID ){               
                projectIDs.push(authorReading.projectID);
                isProjectIDs = true;
            }
        }
        
        // Read C4P projects data
        if(isProjectIDs){

            // Request all associated projects        
            const projects = await c4pProject.run( SELECT.from('AuthorReadingManager.C4PProject').where({ displayId: projectIDs }) );

            // Convert in a map for easier lookup
            const projectsMap = {};
            for (const project of projects) projectsMap[project.displayId] = project;

            // Assemble result
            for (const authorReading of asArray(authorReadings)) {
                authorReading.toC4PProject = projectsMap[authorReading.projectID];
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