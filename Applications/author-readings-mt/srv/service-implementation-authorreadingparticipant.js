"strict";

// Include cds libraries and reuse files
const cds = require("@sap/cds");
const reuse = require("./reuse");

module.exports = cds.service.impl(async (srv) => {

// ----------------------------------------------------------------------------
// Implementation of entity events (entity AuthorReadings)

// Apply a colour code based on the author reading status
srv.after("READ", "AuthorReadings", (req) => {
    const asArray = x => Array.isArray(x) ? x : [ x ];
    for (const authorReading of asArray(req)) {    

        // Set status colour code
        if(authorReading.statusCode) {
            switch (authorReading.statusCode.code) {
                case reuse.authorReadingStatusCode.inPreparation:
                    authorReading.statusCriticality = reuse.color.yellow; // New author readings are yellow
                    break;
                case reuse.authorReadingStatusCode.published:
                    authorReading.statusCriticality = reuse.color.green; // Published author readings are Green
                    break;
                case reuse.authorReadingStatusCode.booked:
                    authorReading.statusCriticality = reuse.color.yellow; // Booked author readings are yellow
                    break;
                case reuse.authorReadingStatusCode.blocked:
                    authorReading.statusCriticality = reuse.color.red; // Blocked author readings are red
                    break;
                default:
            }
        }        
    };
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
        if (req.data && req.data.parent_ID) {
            const authorReadingID = req.data.parent_ID;
            if(authorReadingID){
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
            }
        }
    } catch (error) {
        req.error(error);
    }
});

// Update participant: Auto confirm participation and update freeslots and author reading status
srv.after("CREATE", "Participants", async (req) => {
    try {
        
        const participantID = req.ID;
        if(participantID){
            const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ ID: authorReadingID });
            await UPDATE("sap.samples.authorreadings.Participants")
                .set({ statusCode_code: reuse.participantStatusCode.confirmed })
                .where({ ID: participantID }); 
        }
        
        if(req.parent_ID){
            const authorReadingID = req.parent_ID;
            const availableFreeSlots = authorReadings[0].availableFreeSlots - 1;
            await UPDATE("sap.samples.authorreadings.AuthorReadings")
                .set({
                    availableFreeSlots: availableFreeSlots,
                    statusCode_code: availableFreeSlots === 0 ? reuse.authorReadingStatusCode.booked : authorReadings[0].statusCode_code
                })
                .where({ ID: authorReadingID });
            }
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

        if(participantID){
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
        if(participantID){
            let participants = await SELECT.from("sap.samples.authorreadings.Participants").where({ ID: participantID });
            //const authorReadingID = participants.parent_ID;

            let updateStatus;
            // Allow action for active entity instances only (draft participants cannot be cancelled)
            if (participants.length === 1) {
                if (participants[0].statusCode_code !== reuse.participantStatusCode.cancelled) {
                    
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
        }
    } catch (error) {
        req.error(error);
    }
});

// Entity action "confirmParticipation": Set the status of the participant and adopt the number of free slots
srv.on("confirmParticipation", async (req) => {
    try {
        const participantID = req.params.pop().ID;
        if(participantID){
            let participants = await SELECT.from("sap.samples.authorreadings.Participants").where({ ID: participantID });

            let updateStatus;
            // Allow action for active entity instances only (draft participants cannot be confirmed)
            if (participants.length === 1) {
                
                // Confirm participation if not already confirmed
                if (participants[0].statusCode_code !== reuse.participantStatusCode.confirmed) {
                    
                                
                                // Update cancellation status of participant
                                updateStatus = await UPDATE("sap.samples.authorreadings.Participants")
                                .set({ statusCode_code: reuse.participantStatusCode.confirmed })
                                .where({ ID: participantID });
                                
                                participants = await SELECT.from("sap.samples.authorreadings.Participants").where({ ID: participantID });
                               
                   
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
        }
    } catch (error) {
        req.error(error);
    }
});


// Expand author readings to remote projects
srv.on("READ", "AuthorReadings", async (req, next) => {

    // Read the AuthorReading instances
    let authorReadings = await next();

    // Return remote project data
    return authorReadings;
});


  
})