({
    fetchBeatPlan : function(component, event, helper) {
        helper.fetchBeatHelper(component, event, helper);
    },
    handleClick : function (component, event, helper) {
        component.set("v.ShowMonthYear",false);
        //console.log(component.get("v.sDate"));
       /* var startDate;
        if(!$A.util.isUndefined(component.find("StartDateField").get("v.value"))){
        	 startDate = component.find("StartDateField").get("v.value");
        }
        else{
            startDate = null;
        }
        var endDate = component.find("EndDateField").get("v.value");
        console.log(startDate);
        console.log(endDate);*/

        if(!$A.util.isUndefined(component.find("EndDateField")) && !$A.util.isUndefined(component.find("StartDateField")) && !$A.util.isEmpty(component.find("StartDateField").get("v.value")) && !$A.util.isEmpty(component.find("EndDateField").get("v.value")) ){
            var startDate = component.find("StartDateField").get("v.value");
            var endDate = component.find("EndDateField").get("v.value");
            var startDate1 = new Date(startDate), 
            endDate1 = new Date(endDate),
            days = (endDate1-startDate1)/8.64e7;
            if(endDate1 > startDate1){
                if(days <= 40){
                    var montVar = component.get("v.monthVar");
                    console.log('montVar-=-=-'+montVar);//7
                    var yyrVar =  component.get("v.yrVar");//2019
                    console.log('yyrVar-=-=-'+yyrVar);
                    var regVar = component.get("v.RegionVar");
                    
                    	helper.fetchRecordAsPerYr(component, event, helper, montVar, yyrVar,regVar,startDate,endDate);
                    
                }
                else{
                    helper.showError(component, event, helper, 'Number of Days can not be greater than 40');
                } 
            }
            else{
                	helper.showError(component, event, helper, 'EndDate Should be greater than Start Date');
            }
        }
        else{
           		var montVar = component.get("v.monthVar");
                var yyrVar =  component.get("v.yrVar");
                var regVar = component.get("v.RegionVar");
                helper.fetchRecordAsPerYr(component, event, helper, montVar, yyrVar,regVar,null,null); 
        }
        
    	
    },
    myselectedmonth: function (component, event, helper) {
    	console.log(component.find("select1").get("v.value"));
    	var changeMonth = event.getSource().get("v.value");
        console.log('--'+typeof changeMonth );
    	component.set("v.monthVar",changeMonth);
    },
    myselectedYr: function (component, event, helper) {
    	console.log(component.find("select2").get("v.value"));
    	var changeYr = event.getSource().get("v.value");
    	component.set("v.yrVar",changeYr);
    },
    myselectedRegion: function (component, event, helper) {
    	console.log(component.find("select23").get("v.value"));
    	var changeRegion = event.getSource().get("v.value");
        component.set("v.RegionVar",changeRegion);
    },
     downloadCsv : function(component,event,helper){
        var csv = helper.convertArrayOfObjectsToCSV(component,component.get("v.test")); 
		if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click();
    },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    handleActiveMonth : function(component,event,helper){
        component.set("v.sDate", '');
        component.set("v.eDate", '');
    },
    handleActiveDate : function(component,event,helper){
        
        component.set("v.selectedValue2", '---NONE---');
        component.set("v.selectedValue1", '---NONE---');    }
})