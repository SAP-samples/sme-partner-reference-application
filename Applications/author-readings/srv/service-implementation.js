"strict";

// Include cds libraries and reuse files
const cds = require("@sap/cds");
const reuse = require("./reuse");

module.exports = cds.service.impl(async (srv) => {

// ----------------------------------------------------------------------------
// Implementation of entity events (entity AuthorReadings)

// Initialize some values
srv.before("CREATE", "AuthorReadings", async (req) => {
    try {
    req.data.statusCode_code = reuse.authorReadingStatusCode.inPreparation;
    req.data.availableFreeSlots = req.data.maxParticipantsNumber;
    } catch (error) {
        req.error(error);
    }
});

// Set the event status to booked based on confirmed slots
srv.after("UPDATE", "AuthorReadings", async (req) => {
    try {
        var authorReadings;
        const id = req.ID;
        if (id) {
            authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ ID: id }); 
        }
        // Get the count of confirmed participants
        let confirmedParticipantsCount = 0;
        let participantIDs = [];
        if (req.participants && req.participants.length > 0) {
            req.participants.forEach((participant) => {
                participantIDs.push(participant.ID);
            });
            const participants = await SELECT.from("sap.samples.authorreadings.Participants").where("ID in", participantIDs);
            participants.forEach((participant) => {
                if (participant.statusCode_code === reuse.participantStatusCode.confirmed) {
                    confirmedParticipantsCount = confirmedParticipantsCount + 1;
                }
            });
        }
        // Set the status of reading event to booked, if there are no free slots
        if (authorReadings[0].availableFreeSlots != undefined) {
            if ( authorReadings[0].availableFreeSlots <= 0 ) {
                if (confirmedParticipantsCount === authorReadings[0].maxParticipantsNumber) {
                    await UPDATE("sap.samples.authorreadings.AuthorReadings")
                    .set({ statusCode_code: reuse.authorReadingStatusCode.booked })
                    .where({ ID: id });
                }
            }
            // Check if the availabe slots is less than maximum and status was booked, then change the status to published
            if ( confirmedParticipantsCount < authorReadings[0].maxParticipantsNumber && authorReadings[0].statusCode_code === reuse.authorReadingStatusCode.booked ) {
                await UPDATE("sap.samples.authorreadings.AuthorReadings")
                .set({ statusCode_code: reuse.authorReadingStatusCode.published })
                .where({ ID: id });
            }
        }
        // If max number of participants being updated is more than confirmed participants, then allow update of free slots
        if (authorReadings[0].maxParticipantsNumber >= confirmedParticipantsCount) {
            let availableFreeSlots = authorReadings[0].maxParticipantsNumber - confirmedParticipantsCount;
            await UPDATE("sap.samples.authorreadings.AuthorReadings")
            .set({ availableFreeSlots: availableFreeSlots })
            .where({ ID: id });
        }
        if ( authorReadings[0].maxParticipantsNumber > confirmedParticipantsCount && authorReadings[0].statusCode_code === reuse.authorReadingStatusCode.booked ) {
            let availableFreeSlots = authorReadings[0].maxParticipantsNumber - confirmedParticipantsCount;
            await UPDATE("sap.samples.authorreadings.AuthorReadings")
            .set({ availableFreeSlots: availableFreeSlots, statusCode_code: reuse.authorReadingStatusCode.published })
            .where({ ID: id });
        }
    } catch (error) {
        req.error(error);
    }
});

// Place holder for delete event implementation
srv.on("DELETE", "AuthorReadings", async (req, next) => {
    // nothing done here
});

// Apply a colour code based on the author reading status
srv.after("READ", "AuthorReadings", (each) => {
    if(each.statusCode) {
        switch (each.statusCode.code) {
            case reuse.authorReadingStatusCode.inPreparation:
                each.statusCriticality = reuse.color.yellow; // New author readings are yellow
                break;
            case reuse.authorReadingStatusCode.published:
                each.statusCriticality = reuse.color.green; // Published author readings are Green
                break;
            case reuse.authorReadingStatusCode.booked:
                each.statusCriticality = reuse.color.yellow; // Booked author readings are yellow
                break;
            case reuse.authorReadingStatusCode.blocked:
                each.statusCriticality = reuse.color.red; // Blocked author readings are red
                break;
            default:
        }
    }
    if (each.projectID) {
        each.createProjectEnabled = false;
    } else {
        each.createProjectEnabled = true;
    }
});

// Entity action "block": Set the status of author reading to blocked
srv.on("block", async (req) => {
    try {
        const id = req.params.pop().ID;
        const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ ID: id });
        const authorReading = authorReadings[0];

        // Update blocking status of the reading event
        const updateStatus = await UPDATE("sap.samples.authorreadings.AuthorReadings")
            .set({ statusCode_code: reuse.authorReadingStatusCode.blocked })
            .where({ ID: id });
        
        // handle update result
        if (updateStatus === 1) { // success
            req.info(200, 'ACTION_BLOCK_SUCCESS', [authorReading.identifier]);
            // emit event message to event mesh
            await reuse.emitAuthorReadingEvent(req, id, "AuthorReadingBlocked");
        } else { // no success
            // error message: could not be blocked
            req.error(400, 'ACTION_BLOCK_NOT_POSSIBLE', [authorReading.identifier]);
        }
        return authorReading;
    } catch (error) {
        req.error(error);
    }    
});

// Entity action "publish": Set the status of author reading to published
srv.on("publish", async (req) => {
    try {
        const id = req.params.pop().ID;
        const authorReadings = await SELECT.from("AuthorReadings").where({ ID: id });
        const authorReading = authorReadings[0];

        // Allow action for active entity instances only (draft events cannot be published)
    
        // Update publishing status of the author reading
        let updateStatus = await UPDATE("sap.samples.authorreadings.AuthorReadings")
            .set({ statusCode_code: reuse.authorReadingStatusCode.published })
            .where({ ID: id });
    
        // handle update result
        if (updateStatus === 1) { // success
            req.info(200, 'ACTION_PUBLISH_SUCCESS', [authorReading.identifier]);
            // emit event message to event mesh
            await reuse.emitAuthorReadingEvent(req, id, "AuthorReadingPublished");
        } else { // no success
            // error message: could not be blocked
            req.error(400, 'ACTION_PUBLISH_NOT_POSSIBLE', [authorReading.identifier]);
        }
        return authorReading;
    } catch (error) {
        req.error(error);
    }
});

// ----------------------------------------------------------------------------
// Implementation of entity events (entity Participants)

// Validate participant input data (reject create in case of failed data validation)
srv.before("CREATE", "Participants", async (req) => {
    try {
        // Check e-mail address
        if (req.data.email !== "undefined" && req.data.email ) {
            if (reuse.validateEmail(req.data.email) === false) {
                // invalid email
                req.reject(400, 'INVALID_EMAIL', [req.data.email]);
            }
        }
        // Check phone number
        if ( req.data.mobileNumber !== "undefined" && req.data.mobileNumber ) {
            if (!reuse.validatePhone(req.data.mobileNumber)) {
                // invalid phone number
                req.reject(400, 'INVALID_MOBILE_NUMBER', [req.data.mobileNumber]);
            }
        }

        // Check author reading status
        const authorReadingID = req.data.parent_ID;
        const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings")
            .where({ ID: authorReadingID });
        if (authorReadings.length === 0) { // authorReadingID not found
            req.error(400, 'PARTICIPANT_AUTHOR_UNKNOWN');
        }
        if (authorReadings[0].statusCode_code === reuse.authorReadingStatusCode.booked) {
            req.error(400, 'PARTICIPANT_FULLY_BOOKED');
        }
        if (authorReadings[0].statusCode_code === reuse.authorReadingStatusCode.blocked) {
            req.error(400, "PARTICIPANT_AUTHOR_READING_BLOCKED");
        }
        if (authorReadings[0].statusCode_code === reuse.authorReadingStatusCode.inPreparation) {
            req.error(400, "PARTICIPANT_AUTHOR_READING_NOT_RELEASED");
        }
    } catch (error) {
        req.error(error);
    }
});

// Update participant: Auto confirm participation and update freeslots and author reading status
srv.after("CREATE", "Participants", async (req) => {
    try {
        const authorReadingID = req.parent_ID;
        const participantID = req.ID;
        const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ ID: authorReadingID });
        await UPDATE("sap.samples.authorreadings.Participants")
            .set({ statusCode_code: reuse.participantStatusCode.confirmed })
            .where({ ID: participantID });      
        const availableFreeSlots = authorReadings[0].availableFreeSlots - 1;
        await UPDATE("sap.samples.authorreadings.AuthorReadings")
            .set({
                availableFreeSlots: availableFreeSlots,
                statusCode_code: availableFreeSlots === 0 ? reuse.authorReadingStatusCode.booked : authorReadings[0].statusCode_code
            })
            .where({ ID: authorReadingID });
    } catch (error) {
        req.error(error);
    }
});

// Validate participant input data (update)
srv.after("UPDATE", "Participants", async (req) => {
    try {
        // Check e-mail address
        if (req.data.email !== "undefined" && req.data.email ) {
            if (reuse.validateEmail(req.data.email) === false) {
                // invalid email
                req.reject(400, 'INVALID_EMAIL', [req.data.email]);
            }
        }
        // Check phone number
        if ( req.data.mobileNumber !== "undefined" && req.data.mobileNumber ) {
            if (!reuse.validatePhone(req.data.mobileNumber)) {
                // invalid phone number
                req.reject(400, 'INVALID_MOBILE_NUMBER', [req.data.mobileNumber]);
            }
        }
    } catch (error) {
        req.error(error);
    }
});

// Check participant data
srv.before("PATCH", "Participants", async (req) => {
    try {
        const participantID = req.data.ID;

        // Check e-mail
        if (req.data.email !== "undefined" && req.data.email ) {
            if (reuse.validateEmail(req.data.email) === false) {
                req.reject(400, 'INVALID_EMAIL', [req.data.email]);
            } else {
            await UPDATE("sap.samples.authorreadings.Participants")
                .set({ email: req.data.email })
                .where({ ID: participantID });
            }
        }
        // Check phone number
        if (req.data.mobileNumber !== "undefined" && req.data.mobileNumber ) {
            if (reuse.validatePhone(req.data.mobileNumber) === false) {
                req.reject(400, 'INVALID_MOBILE_NUMBER', [req.data.mobileNumber]);
            } else {
            await UPDATE("sap.samples.authorreadings.Participants")
                .set({ email: req.data.mobileNumber })
                .where({ ID: participantID });
            }
        }
    } catch (error) {
        req.error(error);
    }
});

// Apply a colour code based on the participant status
srv.after("READ", "Participants", (each) => {
    if(each.statusCode) {
        switch (each.statusCode.code) {
            case reuse.participantStatusCode.confirmed:
                each.statusCriticality = reuse.color.green; // Confirmed participants are green
                break;
            case reuse.participantStatusCode.inProcess:
                each.statusCriticality = reuse.color.yellow; // InProcess participants are yellow
                break;
            case reuse.participantStatusCode.cancelled:
                each.statusCriticality = reuse.color.red; // Cancelled participants are red
                break;
            default:
        }
    }
});

// Entity action "cancelParticipation": Set the status of the participant and adopt the number of free slots
srv.on("cancelParticipation", async (req) => {
    try {
        const participantID = req.params.pop().ID;
        const authorReadingID = req.params.pop().ID;
        let participants = await SELECT.from("sap.samples.authorreadings.Participants").where({ ID: participantID });
        //const authorReadingID = participants.parent_ID;

        let updateStatus;
        // Allow action for active entity instances only (draft participants cannot be cancelled)
        if (participants.length === 1) {
            if (participants[0].statusCode_code !== reuse.participantStatusCode.cancelled) {
                // Increase the free slots by 1
                const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ ID: authorReadingID });
                const availableFreeSlots = authorReadings[0].availableFreeSlots + 1;
                // Update the free slots and the status of the author reading
                if (authorReadings[0].statusCode_code === reuse.authorReadingStatusCode.booked) {
                    await UPDATE("sap.samples.authorreadings.AuthorReadings")
                    .set({
                        availableFreeSlots: availableFreeSlots,
                        statusCode_code: reuse.authorReadingStatusCode.published
                    })
                    .where({ ID: authorReadingID });
                } else {
                    await UPDATE("sap.samples.authorreadings.AuthorReadings")
                    .set({ availableFreeSlots: availableFreeSlots })
                    .where({ ID: authorReadingID });
                }
                // Update cancellation status of participant
                updateStatus = await UPDATE("sap.samples.authorreadings.Participants")
                    .set({ statusCode_code: reuse.participantStatusCode.cancelled })
                    .where({ ID: participantID });
                participants = await SELECT.from("sap.samples.authorreadings.Participants").where({ ID: participantID });
            } else {
                req.error(400, "PARTICIPANT_ALREADY_CANCELLED");
            }
            if (updateStatus !== 1) {
                req.error(400, "ACTION_CANCEL_PARTICIPATION_NOT_POSSIBLE",[participants[0].identifier]);
            } else {
                req.info(200, "ACTION_CANCEL_PARTICIPATION_SUCCESS", [participants[0].identifier]);
            }
            return participants;
        } else {
            req.error(400, "ACTION_CANCEL_PARTICIPATION_DRAFT");
        }
    } catch (error) {
        req.error(error);
    }
});

// Entity action "confirmParticipation": Set the status of the participant and adopt the number of free slots
srv.on("confirmParticipation", async (req) => {
    try {
        const participantID = req.params.pop().ID;
        const authorReadingID = req.params.pop().ID;
        let participants = await SELECT.from("sap.samples.authorreadings.Participants").where({ ID: participantID });

        let updateStatus;
        // Allow action for active entity instances only (draft participants cannot be confirmed)
        if (participants.length === 1) {
            // Reduce the free slots by 1
            const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ ID: authorReadingID });

            // Confirm participation if not already confirmed
            if (participants[0].statusCode_code !== reuse.participantStatusCode.confirmed) {
                if (authorReadings[0].availableFreeSlots !== 0) {
                    switch (authorReadings[0].statusCode_code) {                
                        case reuse.authorReadingStatusCode.published:
                            const availableFreeSlots = authorReadings[0].availableFreeSlots - 1;
                            // Update the free slots and status of the author reading
                            await UPDATE("sap.samples.authorreadings.AuthorReadings")
                            .set({
                                availableFreeSlots: availableFreeSlots,
                                statusCode_code: availableFreeSlots === 0 ? reuse.authorReadingStatusCode.booked : authorReadings[0].statusCode_code,
                            })
                            .where({ ID: authorReadingID });
                            
                            // Update cancellation status of participant
                            updateStatus = await UPDATE("sap.samples.authorreadings.Participants")
                            .set({ statusCode_code: reuse.participantStatusCode.confirmed })
                            .where({ ID: participantID });
                            
                            participants = await SELECT.from("sap.samples.authorreadings.Participants").where({ ID: participantID });
                            break;                        
                        case reuse.authorReadingStatusCode.inPreparation:
                            req.error(400, "PARTICIPANT_AUTHOR_READING_IN_PREPARATION");
                            break;                    
                        case reuse.authorReadingStatusCode.booked:
                            req.error(400, "ACTION_CONFIRM_PARTICIPATION_FULLY_BOOKED");
                            break;                
                        case reuse.authorReadingStatusCode.blocked:
                            req.error(400, "ACTION_CONFIRM_PARTICIPATION_BLOCKED");
                            break;
                    }
                } else {
                    req.error(400, "ACTION_CONFIRM_PARTICIPATION_FULLY_BOOKED");
                }
            } else {
                req.error(400, "ACTION_CONFIRM_PARTICIPATION_ALREADY_DONE");
            }
            if (updateStatus !== 1) {
                req.error(400, "ACTION_CONFIRM_PARTICIPATION_NOT_POSSIBLE", [participants[0].identifier]);
            } else {
                req.info(200, "ACTION_CONFIRM_PARTICIPATION_SUCCESS", [participants[0].identifier]);
            }
            return participants;
        } else {
            req.error(400, "ACTION_CONFIRM_PARTICIPATION_DRAFT");
        }
    } catch (error) {
        req.error(error);
    }
});

// --------------------------------------------------------------------------------------
// Implementation of entity events (entity AuthorReadings) with impact on remote services

// Entity action "createProject"
srv.on("createProject", async (req) => {
    try {
        const authorReadingID = (req.params.pop()).ID;
        const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ ID: authorReadingID });
        // Allow action for active entity instances only
        if (authorReadings.length === 1) {
            let authorReadingIdentifier, authorReadingDescription, authorReadingTitle, authorReadingDate;
            authorReadings.forEach((authorReading) => {
                authorReadingIdentifier = authorReading.identifier;
                authorReadingDescription = authorReading.description;
                authorReadingTitle = authorReading.title;
                authorReadingDate = authorReading.date;
            });
            // Get the entity service (entity "Projects")
            const { Projects } = srv.entities;
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

            // Check and create the project instance
            // If the project already exist, then read and update the local project elements in entity AuthorReadings
            var remoteProjectID, remoteProjectObjectID;
            // GET service call on remote project entity
            const existingProject = await srv.run( SELECT.from(Projects).where({ ProjectID: generatedID }) );
            if (existingProject.length === 1) {
                remoteProjectID = existingProject[0].projectID;
                remoteProjectObjectID = existingProject[0].ID;
            } else {
                // POST request to create the project via remote service
                const remoteCreatedProject = await srv.run( INSERT.into(Projects).entries(projectRecord) );
                if (remoteCreatedProject) {
                    remoteProjectID = remoteCreatedProject.projectID;
                    remoteProjectObjectID = remoteCreatedProject.ID;
                }
            }
            if (remoteProjectID) {
                
                // Read the ByD system URL dynamically from BTP destination "byd-url"
                var bydRemoteSystem = await reuse.getDestinationURL(req , 'byd-url'); 

                // Set the URL of ByD project overview screen for UI navigation
                var bydRemoteProjectExternalURL =
                    "/sap/ap/ui/runtime?bo_ns=http://sap.com/xi/AP/ProjectManagement/Global&bo=Project&node=Root&operation=OpenByProjectID&object_key=" +
                    generatedID +
                    "&key_type=APC_S_PROJECT_ID";
                var bydRemoteProjectExternalCompleteURL = bydRemoteSystem.concat( bydRemoteProjectExternalURL );
                
                // Update project elements in entity AuthorReadings
                await UPDATE("sap.samples.authorreadings.AuthorReadings")
                    .set({
                        ProjectID: remoteProjectID,
                        projectObjectID: remoteProjectObjectID,
                        projectURL: bydRemoteProjectExternalCompleteURL,
                    })
                    .where({ ID: authorReadingID });
            }                   
        } else {
            req.error(400, "ACTION_CREATE_PROJECT_DRAFT");
        }
    } catch (error) {
        // App reacts error tolerant in case of calling the remote service, mostly if the remote service is not available of if the destination is missing
        console.log("ACTION_CREATE_PROJECT_CONNECTION" + "; " + error);
    }
});

// Expand author readings to remote projects
// OData parameter following the UI-request pattern: "/AuthorReadings(ID=79ceab87-300d-4b66-8cc3-f82c679b77a1,IsActiveEntity=true)?$select=toProject&$expand=toProject($select=ID,costCenter,endDateTime,startDateTime,statusCodeText,typeCodeText)"
srv.on("READ", "AuthorReadings", async (req, next) => {     
    try {   
        const bydProject = await cds.connect.to('byd_khproject');
        var expandIndex = -1;
        // Check the if the object exists before running the findIndex-function
        if(req){
            if(req.query){                
                if(req.query.SELECT){
                    if(req.query.SELECT.columns){
                        expandIndex = req.query.SELECT.columns.findIndex( ({ expand, ref }) => expand && ref[0] === "toProject" );
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
        // Request all associated projects
        const projectIDs = asArray(authorReadings).map(authorReading => authorReading.projectID);     
        const projects = await bydProject.run( SELECT.from('AuthorReadingManager.Projects').where({ projectID: projectIDs }) );

        // Convert in a map for easier lookup
        const projectsMap = {};
        for (const project of projects) projectsMap[project.projectID] = project;
        // Add suppliers to result
        for (const authorReading of asArray(authorReadings)) {
            authorReading.toProject = projectsMap[authorReading.projectID];
        }
        return authorReadings;
    } catch (error) {
        // App reacts error tolerant in case of calling the remote service, mostly if the remote service is not available of if the destination is missing
        console.log("ACTION_READ_PROJECT_CONNECTION" + "; " + error);
    };          
})

// ----------------------------------------------------------------------------
// Implementation of service functions
  
// Function "userInfo": Return logged-in user
srv.on("userInfo", async (req) => {
    let results = {};
    results.user = req.user.id;
    // if(req.user.hasOwnProperty('locale')){
    //     results.locale = req.user.locale;
    // }
    results.roles = {};
    results.roles.identified = req.user.is("identified-user");
    results.roles.authenticated = req.user.is("authenticated-user");
    return results;
});

// ----------------------------------------------------------------------------
// Implementation of remote OData services (back-channel integration with ByD)

// Delegate OData requests to remote project entities
srv.on("READ", "Projects", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("READ", "ProjectSummaryTasks", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("READ", "ProjectTasks", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("CREATE", "Projects", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("CREATE", "ProjectSummaryTasks", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("CREATE", "ProjectTasks", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("UPDATE", "Projects", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("UPDATE", "ProjectSummaryTasks", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("UPDATE", "ProjectTasks", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("DELETE", "Projects", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("DELETE", "ProjectSummaryTasks", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("DELETE", "ProjectTasks", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject");
    return bydProject.run(req.query);
});
srv.on("READ", "ProjectsTechUser", async (req) => {
    const bydProject = await cds.connect.to("byd_khproject_tech_user");
    return bydProject.run(req.query);
});


// ----------------------------------------------------------------------------
// Event-based integration with ByD

const bydmessage = await cds.connect.to("byd_messaging");  
    
bydmessage.on("sap/byd/project/ProjectUpdated", async msg => {
    try{
        console.log("BYD-EVENT: Received event notification from ByD on topic sap/byd/project/ProjectUpdated via message queue ", msg);
        
        // Check if the message is for project root changes => "type": "sap.byd.Project.Root.Updated.v1"  
        let messageType = msg.headers.type;
        let messageTypePattern = /sap.byd.Project.Root/g;
        if( messageTypePattern.test(messageType) ){
            // Read the project key provided by the event data payload in element 'root-entity-id'
            let rootEntityID = Object.keys(msg.data)[0];
            let rootEntityIDPattern = /root-entity-id/g;
            if ( rootEntityIDPattern.test(rootEntityID)){
                const projectKey =  Object.values(msg.data)[0];                    
                const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ projectObjectID: projectKey });
                let eventMeshMessages, authorReadingID, authorReadingIdentifier;
                let remoteProjectID, remoteProjectObjectID, remoteProjectBlockingStatus;
                if (authorReadings.length === 1) {
                    authorReadings.forEach( authorReading => {
                        eventMeshMessages = authorReading.eventMeshMessage;
                        authorReadingID = authorReading.ID;
                        authorReadingIdentifier = authorReading.identifier;
                        remoteProjectID = authorReading.projectID;
                    });   
                    let authorReadingUpdateResp;
                    // Trigger remote service call to get the ByD project using a technical user                        
                    const bydProject = await cds.connect.to('byd_khproject_tech_user');                                               
                    const existingProject = await bydProject.run(SELECT.from('AuthorReadingManager.ProjectsTechUser').where({ projectID: remoteProjectID }));
                    
                    // Reuse ByD project if already existing                        
                    if (existingProject.length === 1){
                        remoteProjectID = existingProject[0].projectID;
                        remoteProjectObjectID = existingProject[0].ID;
                        remoteProjectBlockingStatus = existingProject[0].blockingStatusCode;                            
                        console.log("ByD project ID: " + remoteProjectID + ", project blocking status: " + remoteProjectBlockingStatus);
                    }
                    
                    // Check the remote project status:
                    // If 'on-hold'-checkbox is set, then block the author reading, else publish the author reading 
                    if (remoteProjectBlockingStatus === "1" ){     
                        if (eventMeshMessages){ 
                            eventMeshMessages = eventMeshMessages + "\n" +"Author reading published by ByD event notification.";
                        }else{
                            eventMeshMessages = "Author reading published by ByD event notification.";
                        };
                        authorReadingUpdateResp = await UPDATE("sap.samples.authorreadings.AuthorReadings").set({eventMeshMessage : eventMeshMessages , statusCode_code : reuse.authorReadingStatusCode.published }).where({ ID: authorReadingID });
                        console.log("Author reading " + authorReadingIdentifier +" is published via event message");
                    }else if(remoteProjectBlockingStatus === "2" || remoteProjectBlockingStatus === "3" ){
                        if (eventMeshMessages){ 
                            eventMeshMessages = eventMeshMessages + "\n" +"Author reading blocked by ByD event notification.";
                        }else{
                            eventMeshMessages = "Author reading blocked by ByD event notification.";
                        };
                        authorReadingUpdateResp = await UPDATE("sap.samples.authorreadings.AuthorReadings").set({eventMeshMessage : eventMeshMessages , statusCode_code : reuse.authorReadingStatusCode.blocked }).where({ ID: authorReadingID });
                        console.log("Author reading " + authorReadingIdentifier +" is blocked via event message");
                    }else{
                        console.log("BYD-EVENT: ByD blocking status else");                    
                        if (eventMeshMessages){ 
                            eventMeshMessages = eventMeshMessages + "\n" +"ByD event notification received; no action required.";
                        }else{
                            eventMeshMessages = "ByD event notification received; no action required.";
                        };
                        authorReadingUpdateResp = await UPDATE("sap.samples.authorreadings.AuthorReadings").set({eventMeshMessage : eventMeshMessages }).where({ ID: authorReadingID });
                        console.log("Author reading " + authorReadingIdentifier + ": Event message received from ByD and no action required");
                    };
                    if (authorReadingUpdateResp === 1){
                        console.log("Event message log updated");
                    }                    
                }
            }
        }     
    }catch (error){
        console.log("Internal error on processing ByD event notifications: " + error);
    }
})    

    
})