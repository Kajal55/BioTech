({
	searchHelper : function(component, event, getInputKeyWord) {
	    var action = component.get("c.fetchBillingAccount");
	    // alert("search help[r "+getInputKeyWord);
	    //console.log('@@ component.get("v.nameField") == ' + component.get("v.nameField"));
        // console.log('@@ component.get("v.recId") == ' + component.get("v.recId"));
        // console.log('@@ component.get("v.customCondition") == ' + component.get("v.customCondition"));
        component.set("v.Message", '');
        action.setParams({
	       'ObjectName': component.get("v.objectAPIName"), 
           'nameField': component.get("v.nameField"), 
           'searchKeyWord': getInputKeyWord,
	       'recordId': component.get("v.recId"),
           'customCondition': component.get("v.customCondition")
		});
    
	    action.setCallback(this, function(response) {
	      	$A.util.removeClass(component.find("mySpinner"), "slds-show");
	        
            var state = response.getState();
	        if (state === "SUCCESS") {
	            
                var storeResponse = response.getReturnValue();
	            //console.log('@@storeResponse');
                //console.log(storeResponse);
                if (storeResponse.length == 0) {
	                component.set("v.Message", 'No record found!');
	            } else if(storeResponse.length == 1 && !$A.util.isEmpty(component.get("v.recId"))) {
	            	//console.log('@@yes');
                    storeResponse.forEach( item=> {
	            		component.set("v.selectedRecord", item);
	            		//below script is used to handle lookup position
	            		var forclose = component.find("lookup-pill");
    					$A.util.removeClass(forclose, 'slds-hide');

					    var forclose = component.find("searchRes");
					    $A.util.addClass(forclose, 'slds-is-close');
						$A.util.removeClass(forclose, 'slds-is-open');

					    var lookUpTarget = component.find("lookupField");
					    $A.util.addClass(lookUpTarget, 'slds-hide');
					});
	            }
	            // set searchResult list with return value from server.
	            console.log("Store Response "+ JSON.stringify(storeResponse));
	            component.set("v.listOfSearchRecords", storeResponse);
                //console.log('## component.set("v.listOfSearchRecords", storeResponse) == ' + component.get("v.listOfSearchRecords"));
	        	$A.util.addClass(component.find("mySpinner"), "slds-hide");
            } else {
                $A.util.addClass(component.find("mySpinner"), "slds-hide");
	        	alert('Error');
	        }
		});

	    $A.enqueueAction(action);
	},
})