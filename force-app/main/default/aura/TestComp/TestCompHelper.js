({
	helperMethod : function(component, event) {
	var action2 = component.get("c.getProductTest");
        action2.setParams({
            month: 'Apr',
            year:'2019'
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var retData = response.getReturnValue();
                component.set("v.product",retData);
                console.log("In TestCompHelper-->H-->onInit_M--> ret Acc Act?-->" +JSON.stringify(retData) );
                console.log("In TestCompHelper-->H-->onInit_M--> ret Acc Act?-->" +typeof retData );
                //console.log("In TestCompHelper-->H-->onInit_M--> ret Acc Act?-->" +typeof component.set("v.product") );
            }else{
               
				
                //component.set("v.initMessage","Please fill all the mandatory fields.");                
                console.log("In TestCompHelper-->H-->onInit_M-->From Apex-->Error in apex call......");
            }
        });
        $A.enqueueAction(action2);	
	}
})