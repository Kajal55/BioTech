({
    doInit : function(component, event, helper) {
        component.set("v.firstLoad",true);
        var monMap = component.get("v.monthMap");
        var d = new Date();
        var currYear = d.getFullYear();
        var currMonth = monMap[d.getMonth()];
        component.set("v.showTab",currMonth); // default tab--> current month
        component.set("v.month",currMonth);
        component.set("v.year",currYear);
        
    },
    
     handleSwitchTabCompEvent : function(component, event, helper) {
        console.log('Comp Event Received in Parent!!');
        var tabId = event.getParam("tabId");
        console.log('Comp Event Received in Parent--> Tab VALUE-->'+tabId);
         if(tabId){
            // set the handler attributes based on event data
           component.set("v.showTab", tabId);
            // var numEventsHandled = parseInt(component.get("v.numEvents")) + 1;
          // component.set("v.numEvents", numEventsHandled);    
         }
         
         var refreshParentComp = event.getParam("refreshParent");
         console.log('Comp Event Received in Parent-->RefreshParent VALUE-->'+refreshParentComp);
         if(refreshParentComp){
         	$A.get('e.force:refreshView').fire();       
         }
		
    },
    
    handleShowTabChange : function(component,event) {
        console.log("In SalesPlanDom-->Parent--> handleChange Evt!!!");
        var selected = component.get("v.showTab");
        console.log("In SalesPlanDom-->Parent--> handleChange Evt-->TAbID-->"+selected);
        component.find("salesTab").set("v.selectedTabId", selected);
        console.log("In SalesPlanDom-->Parent--> handleChange Evt-->After Setting-->TabId-->"+component.find("salesTab").get("v.selectedTabId"));
        var refreshEvt = $A.get('e.force:refreshView');
        if(!$A.util.isEmpty(refreshEvt)){
            //console.log('PARENT REFRESHed !!');
        	//refreshEvt.fire();    
            //console.log('After PARENT REFRESHed !!');
        }else{
            console.log('CANNOT REFRESH PARENT!!');
        }
        
        
    },
    OnRefreshBtnClick : function(component,event) {
        console.log("In SalesPlanDom-->Parent--> In onRefreshButtonCLICK Evt!!!");
        $A.get('e.force:refreshView').fire();    
    },
})