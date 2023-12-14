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
async function purchaseOrderDataRecord(authorReadingIdentifier, authorReadingTitle, authorReadingDate) {
    try{
   
        const purchaseOrderRecord = {
            "DocType": "Document_Items",
            "DocDate": "2023-12-01T00:00:00Z",
            "DocDueDate": "2023-12-6T00:00:00Z",
            "CardCode": "V10000",
            "DocumentLines": [
                    {
                        "LineNum": 0,
                        "ItemCode": "A00001",
                        "Quantity": 10,
                        "Price": 400
                                            }              
                            ]
            
        };
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
            const purchaseOrders = await b1PurchaseOrder.run( SELECT.from('AuthorReadingManager.B1PurchaseOrder').where({ purchaseOrderID: purchaseOrderIDs }) );

            // Convert in a map for easier lookup
            const purchaseOrderMap = {};
            for (const purchaseOrder of purchaseOrders) purchaseOrderMap[purchaseOrders.purchaseOrderID] = purchaseOrder;

            // Assemble result
            for (const authorReading of asArray(authorReadings)) {
                authorReading.toB1PurchaseOrder = purchaseOrderMap[authorReading.purchaseOrderID];
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
