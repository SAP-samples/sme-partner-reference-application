"use strict";

// Include cds libraries and reuse files
const cds = require("@sap/cds");

// ----------------------------------------------------------------------------
// B1 specific reuse functions
// ----------------------------------------------------------------------------

// Delegate OData requests to remote B1 purchase order entities
async function delegateODataRequests(req,remoteService) {
    try{
        const b1PurchaseOrder = await cds.connect.to(remoteService);
        return b1PurchaseOrder.run(req.query);
    }catch (error) {
        console.log(error);
    }
}

// Return json-payload to create B1 purchase order 
async function purchaseOrderDataRecord(authorReadingIdentifier, authorReadingTitle, authorReadingDescription, authorReadingDate,authorReadingMaxParticipantsNumber, authorReadingsParticipantFeeAmount) {
    try{

        var purchaseOrderDeliveryDate = authorReadingDate;
        console.log("b1-debug inside purchaseOrderDataRecord , DocDueDate:"+purchaseOrderDeliveryDate);
        var purchaseOrderRemarks = "Author Reading: "+authorReadingIdentifier +" - "+authorReadingTitle +"\n"+authorReadingDescription;
        console.log("b1-debug inside purchaseOrderDataRecord , Comments:"+purchaseOrderRemarks);
        var purchaseOrderItem1Amount = 0.0;
        var purchaseOrderItem2Amount = 0.0;
        var authorReadingEventValue = (authorReadingMaxParticipantsNumber * authorReadingsParticipantFeeAmount);
        var authorReadingEventExpense = ( authorReadingEventValue  * .50 ) ;

        purchaseOrderItem1Amount = ( authorReadingEventExpense * .33 )  ;
        purchaseOrderItem2Amount = ( authorReadingEventExpense * .66 )  ;
        console.log("b1-debug inside purchaseOrderDataRecord , purchaseOrderItem1Amount:"+purchaseOrderItem1Amount);
        console.log("b1-debug inside purchaseOrderDataRecord , purchaseOrderItem2Amount:"+purchaseOrderItem2Amount);

        const purchaseOrderRecord = {
            "DocType": "dDocument_Service",
            "DocDueDate": purchaseOrderDeliveryDate,
            "CardCode": "V10000",
            "Comments": purchaseOrderRemarks,
            "DocumentLines": [
                                {
                                    "LineNum": 0,
                                    "ItemDescription": "Event planning and preparations",
                                    "AccountCode": "_SYS00000000001",
                                    "LineTotal": purchaseOrderItem1Amount
                                },
                                {
                                    "LineNum": 1,
                                    "ItemDescription": "Event administration and execution",
                                    "AccountCode": "_SYS00000000001",
                                    "LineTotal": purchaseOrderItem2Amount
                                }               
                            ]
        };

        console.log("b1-debug inside purchaseOrderDataRecord , purchaseOrderRecord"+JSON.stringify(purchaseOrderRecord));
        return purchaseOrderRecord;
    }catch (error) {
        console.log(error);
    }
}

// Expand author readings to remote purchase order
async function readPurchaseOrder(authorReadings) {
    try {     
        const b1PurchaseOrder = await cds.connect.to('b1_sbs_v2');  
        let isPurchaseOrderIDs = false;
        const asArray = x => Array.isArray(x) ? x : [ x ];

        // Read PurchaseOrder ID's related to B1
        let purchaseOrderIDs = []; 
        for (const authorReading of asArray(authorReadings)) {
            // Check if the Purchase Order ID exists in the author reading record AND backend ERP is b1 => then read purchase order information from b1
            if(authorReading.purchaseOrderSystem == "B1" && authorReading.purchaseOrderID ){               
                purchaseOrderIDs.push(authorReading.purchaseOrderID);
                isPurchaseOrderIDs = true;
            }
        }
        
        // Read ByD purcha data
        if(isPurchaseOrderIDs){

            // Request all associated purchase orders        
            const purchaseOrders = await b1PurchaseOrder.run( SELECT.from('AuthorReadingManager.B1PurchaseOrder').where({ DocNum: purchaseOrderIDs }) );
            console.log("b1-debug inside if , purchase order string "+JSON.stringify(purchaseOrders));
            // Convert in a map for easier lookup
            const purchaseOrderMap = {};
            for (const purchaseOrder of purchaseOrders) { purchaseOrderMap[purchaseOrder.DocNum] = purchaseOrder; console.log("b1-debug inside for , purchaseOrder.DocNum "+purchaseOrder.DocNum); }

            // Assemble result
            for (const authorReading of asArray(authorReadings)) {
                authorReading.toB1PurchaseOrder = purchaseOrderMap[authorReading.purchaseOrderID];
                console.log("b1-debug inside assemple result authorReading.toB1PurchaseOrder"+authorReading.toB1PurchaseOrder);
                console.log("b1-debug inside assemple result authorReading.purchaseOrderID"+authorReading.purchaseOrderID);
            };
        }
        return authorReadings;    
    } catch (error) {
        // App reacts error tolerant in case of calling the remote service, mostly if the remote service is not available of if the destination is missing
        console.log("ACTION_READ_PURCHASE_ORDER_CONNECTION" + "; " + error);
    };
}

// Publish constants and functions
module.exports = {
    readPurchaseOrder,
    purchaseOrderDataRecord,
    delegateODataRequests
  };
