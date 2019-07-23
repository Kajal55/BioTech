({
	onApprove : function(component, event, helper){
	   //Get the event using registerEvent name. 
        var cmpEvent = component.getEvent("deleteLineItemConfirmEvt"); 
        //Set event attribute value
        cmpEvent.setParams({"deleteThisLineItem" : "Yes"}); 
        cmpEvent.fire();
        component.destroy();
        //var closeModalOrPopUp = $A.get("e.force:closeQuickAction");
        //closeModalOrPopUp.fire();
	},
    onReject : function(component, event, helper){
		//Get the event using registerEvent name. 
        var cmpEvent = component.getEvent("deleteLineItemConfirmEvt"); 
        //Set event attribute value
        cmpEvent.setParams({"deleteThisLineItem" : "No"}); 
        cmpEvent.fire();
        component.destroy();
        //var closeModalOrPopUp = $A.get("e.force:closeQuickAction");
       // closeModalOrPopUp.fire();
	}
})