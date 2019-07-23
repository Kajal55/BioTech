({
	 AddNewRow : function(component, event, helper){
       // fire the AddNewRowEvt Lightning Event 
        component.getEvent("AddNewRowCompEvt").fire();     
    },
    
    removeRow : function(component, event, helper){
     // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
       component.getEvent("DeleteRowCompEvt").setParams({"rowNumber" : component.get("v.rowIndex") }).fire();
    }, 
    onLookupValueChange : function (component, event, helper) {
        console.log("DynamicOppProdItemComp-->C-->old value: " + event.getParam("oldValue"));
        console.log("DynamicOppProdItemComp-->C-->current value: " + event.getParam("value"));
        //Setting Only The Id
        component.set("v.oppProdItem.Product__c",event.getParam("value").Id);
    }
})
       alert("old value: " + event.getParam("oldValue"));
        alert("current value: " + event.getParam("value"));