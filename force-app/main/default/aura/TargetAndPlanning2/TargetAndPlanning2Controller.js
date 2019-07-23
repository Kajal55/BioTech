({
    doInit : function(component, event, helper) {
        var action = component.get("c.getTargetAmountByUserDivision");
        action.setParams({
            month: 'Feb',
            year: '2019'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retData = response.getReturnValue();
                //const aops = [];
                // console.log(  "In Trget&PlaningComp2-->C-->doInit_M--> retVal-->" + JSON.stringify(retData) );
                
                if (!$A.util.isEmpty(retData)) {
                    helper.createColumn(component,event,retData);
                    //component.set("v.target", retData);
                }
            }
        });
        
        $A.enqueueAction(action);  
        
    },
    rowSelectionHandler : function (component, event, helper) {
        /*var editedRecords =  component.find("salesDataTable").get("v.selectedRows");
        console.log("Selected Rec-->"+JSON.stringify(editedRecords));
        var totalRecordEdited = editedRecords.length;    
        console.log("Selected Rec length-->"+JSON.stringify(totalRecordEdited));*/
        
        var slrow2 = component.find("salesDataTable").getSelectedRows();
        console.log("New Select-->"+JSON.stringify(slrow2));
        
    },
    onSave : function (component, event, helper) {
        var selectedRowList = component.find("salesDataTable").getSelectedRows();
        console.log("ONSAVE-->DATA-->"+JSON.stringify(selectedRowList));
    },
})