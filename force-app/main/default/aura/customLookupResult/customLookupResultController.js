({
   doInit: function(component, event, helper) {
        //alert("opportunityId "+opportunityId);
       var recId = component.get("v.recId");
       if(!$A.util.isEmpty(recId)){
           helper.searchHelper(component,event,'');
       }
   },
    
   selectRecord : function(component, event, helper){      
      var obj = component.get("v.listOfSearchRecords");
      component.set("v.selectedRecord",obj[parseInt(event.currentTarget.getAttribute("data-count"))]);
      var objectApiName = component.get("v.objectAPIName");
      
      var evt = $A.get("e.c:onSuccessEvent");
      if(objectApiName == 'Account'){
           evt.setParams({
               accountId : component.get("v.selectedRecord").Id
           });
      }else if(objectApiName == 'Billing_Account__c'){
           evt.setParams({
               billingAccId : component.get("v.selectedRecord").Id
           });
      }else if(objectApiName == 'Subscription_Plan__c'){
           evt.setParams({
               subscriptionPlanId : component.get("v.selectedRecord").Id
           });
      }else if(objectApiName == 'Price_Book_Custom__c'){
          console.log('## component.get("v.selectedRecord").Id ==' + component.get("v.selectedRecord").Id); 
          evt.setParams({
               priceBookId : component.get("v.selectedRecord").Id
           });
      }else if(objectApiName == 'Subscription_Term__c'){
          evt.setParams({
               subscriptionTermId : component.get("v.selectedRecord").Id
           });
      }else if(objectApiName == 'Billing_Schedule__c'){
          evt.setParams({
               billingScheduleId : component.get("v.selectedRecord").Id
           });
      }   

      evt.fire();
      
       //below to manage lookup UI	
      var pillTarget = component.find("lookup-pill");
      var lookUpTarget = component.find("lookupField"); 
        
      $A.util.removeClass(pillTarget, 'slds-hide');
      $A.util.addClass(lookUpTarget, 'slds-hide');
      component.set("v.listOfSearchRecords", null);
        
      var forclose = component.find("searchRes");
      $A.util.addClass(forclose, 'slds-is-close');
      $A.util.removeClass(forclose, 'slds-is-open');
     
    },

    onfocus: function(component, event, helper){
       $A.util.removeClass(component.find("mySpinner"), "slds-hide");
       var forOpen = component.find("searchRes");
       $A.util.addClass(forOpen, 'slds-is-open');
       $A.util.removeClass(forOpen, 'slds-is-close');
       helper.searchHelper(component,event, component.get("v.SearchKeyWord"));
       //component.find("inputEle").set("v.required", false); 
    },

    onblur: function(component, event, helper){       
        //component.set("v.listOfSearchRecords", null);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    // control the serach in lookup on keypress
    keyPressController: function(component, event, helper) {
	    // get the search Input keyword   
	    $A.util.removeClass(component.find("mySpinner"), "slds-hide");
        var getInputkeyWord = component.get("v.SearchKeyWord"); 
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        helper.searchHelper(component,event,getInputkeyWord);
	},
    
    // function for clear the Record Selection 
    clear :function(component, event , helper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        $A.util.addClass( pillTarget, 'slds-hide');
      
        component.set("v.SearchKeyWord", null);
        component.set("v.selectedRecord", null); 
        component.set("v.recId", ""); 
        
        var evt = $A.get("e.c:ClearEvent");
        evt.setParams({
            objectAPIName : component.get("v.objectAPIName")
        });
        evt.fire();
        
    },
    
})