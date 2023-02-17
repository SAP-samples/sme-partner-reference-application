"use strict";

// Include SAP Cloud SDK reuse functions
const { getDestination, retrieveJwt } = require("@sap-cloud-sdk/connectivity");

// ----------------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------------

const color = {
  grey: 0, 
  red: 1,
  yellow: 2,
  green: 3
};

const authorReadingStatusCode = {
  inPreparation: 0,
  published: 1,
  booked: 2,
  completed: 3, // not used
  blocked: 4,
  cancelled: 5 // not used
};

const participantStatusCode = {
  inProcess: 1,
  confirmed: 2,
  cancelled: 3
};

// ----------------------------------------------------------------------------
// Reuse functions
// ----------------------------------------------------------------------------

// Reuse function to check the formating of an e-mail address
function validateEmail(email) {
  const regexEmail = /^\w+([\\.-]?\w+)*@\w+([\\.-]?\w+)*(\.\w{2,3})+$/;
  if (email.match(regexEmail)) {
    return true;
  } else {
    return false;
  }
}

// Reuse function to check the formating of an phone number
function validatePhone(phone) {
  const regexPhone = /^\+(?:[0-9] ?){6,14}[0-9]$/;
  if (phone.match(regexPhone)) {
    return true;
  } else {
    return false;
  }
}

// Emit event message to event mesh
async function emitAuthorReadingEvent(req, id, eventMeshTopic) {

  // Return updated reading event data
  const authorReadings = await SELECT.from("sap.samples.authorreadings.AuthorReadings").where({ ID: id });
  const authorReading = authorReadings[0];
  
  try {
    const msg = await cds.connect.to("outbound_messaging");
    await msg.emit( eventMeshTopic, { authorReading, tenant:req.user.tenant } );
    console.log( "====== Inside reuse function to emit Author Reading event messages ======" );
    console.log( `Event message emitted for topic ${eventMeshTopic} and author reading ${authorReading.identifier} and Tenant ID:${req.user.tenant} ` );

    req.info(200, 'EMIT_MESSAGE_SUCCESS', [authorReading.identifier, eventMeshTopic]);

    const text = `Event notification for topic ${eventMeshTopic} emitted successully.`;
    let eventMessages;
    if (authorReading.eventMeshMessage) {
        eventMessages = authorReading.eventMeshMessage + "\n" + text;
    } else {
        eventMessages = text;
    };
    console.log( "Event message log: ", eventMessages);

    let authorReadingUpdate = await UPDATE("sap.samples.authorreadings.AuthorReadings")
      .set({ eventMeshMessage: eventMessages })
      .where({ ID: id });
    if (authorReadingUpdate) { console.log( "Event message log update successfull") }
  } catch (error) {
    req.error(error);
  }
}

// Reuse function to get the ERP URL
async function getDestinationURL(req, destinationName) {
    let destinationURL;
    try {
        // Read the destination details using the SAP Cloud SDK reusable getDestination function:
        // The JWT-token contains the subaccount information, such that the function works for single tenant as well as for multi-tenant apps:
        // - Single tenant: Get destination from the subaccount that hosts the app.
        // - Multi tenant: Get destination from subscriber subaccount.
        const destination = await getDestination({ destinationName: destinationName, jwt: retrieveJwt(req) });
        
        if(destination){
          console.log("Get ERP destination URL: " + destination.url);        
          destinationURL = destination.url;
        }
        else{
            // No destination found
            console.log("Get ERP destination URL: " + destinationName + " not found");  
        }
    } catch (error) {
        // App reacts error tolerant if the destination cannot be retrieved
        console.log("GET_DESTINATION" + "; " + error);
    }
    return destinationURL;    
}

// Reuse function to check if BTP destination exists  
async function checkDestination(req, destinationName) {
  try {
      // Check if the destination exist using the SAP Cloud SDK reusable getDestination function:
      // The JWT-token contains the subaccount information, such that the function works for single tenant as well as for multi-tenant apps:
      // - Single tenant: Get destination from the subaccount that hosts the app.
      // - Multi tenant: Get destination from subscriber subaccount.
      const destination = await getDestination({ destinationName: destinationName, jwt: retrieveJwt(req) });
      
      if(destination){
        console.log("Check ERP destination: " + destinationName + " found"); 
        return true;
      }
      else{
        console.log("Check ERP destination: " + destinationName + " not found"); 
        return false;           
      }      
  } catch (error) {
      // App reacts error tolerant if the destination is missing
      console.log("CHECK_DESTINATION" + "; " + error);
  }  
}

// Reuse function to get the ERP Name
async function getDestinationDescription(req, destinationName) {
  let destinationDescription;
  try {
      // Read the destination details using the SAP Cloud SDK reusable getDestinationDescription function:
      // The JWT-token contains the subaccount information, such that the function works for single tenant as well as for multi-tenant apps:
      // - Single tenant: Get destination from the subaccount that hosts the app.
      // - Multi tenant: Get destination from subscriber subaccount.
      const destination = await getDestination({ destinationName: destinationName, jwt: retrieveJwt(req) });
      if(destination){
        for(var originalProperty in destination.originalProperties){         
          if (originalProperty == "Description"){
            destinationDescription = destination.originalProperties[originalProperty];
            break;  
          }
        }            
      }     
  } catch (error) {
      // App reacts error tolerant if the destination is missing
      console.log("GET_DESTINATION_DESCRIPTION" + "; " + error);
  }
  return destinationDescription;    
}


// Publish constants and functions
module.exports = {
  color,
  authorReadingStatusCode,
  participantStatusCode,
  validateEmail,
  validatePhone,
  emitAuthorReadingEvent,
  getDestinationURL,
  checkDestination,
  getDestinationDescription
};
