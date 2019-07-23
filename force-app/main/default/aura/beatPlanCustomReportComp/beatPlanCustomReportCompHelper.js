({
    
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var data = [];
        var headerArray = [];
        var csvContentArray = [];
        var fileName = "BeatPlan"
        var fielExtension = ".csv";  

        headerArray.push('User');
        headerArray.push(component.get("v.dateInMonth"));
        data.push(headerArray);
        
        for(var i=0; i<objectRecords.length; i++)
        {
            var tempArray = [];
            tempArray.push(objectRecords[i].Id);
            for(var k=0; k<objectRecords[i].Value.length; k++){                
                tempArray.push(objectRecords[i].Value[k].Value);
            }
            
            data.push(tempArray);
        }
            
        for(var j=0; j<data.length; j++)
        {
            var dataString = data[j].join(",");
            csvContentArray.push(dataString);
        }        
        
        var csvContent = csvContentArray.join("\n");        
        return csvContent;        
    },
    fetchBeatHelper: function(component) {   
        
        var action = component.get("c.getfetchBeatPlan");  
        
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if (state === "SUCCESS")
                               {
                                   var map1 = response.getReturnValue();
                                   console.log(map1);
                                   component.set("v.currentmonth",map1.currentMonth);
                                   component.set("v.currentyear",map1.currentYear);
                                   component.set("v.ShowMonthYear",true);
                                   component.set("v.attchid",map1.attachmentId);
                                   var dateList = [];
                                   var i = 1;
                                   for (var key in map1.beatdateList) {
                                       dateList.push(i++);
                                   }
                                   component.set("v.dateInMonth",dateList);
                                   var optionsList = [];
                                   for (var key in map1.numMonthList) {
                                       if (map1.numMonthList.hasOwnProperty(key)) {
                                           optionsList.push({value: key, label: map1.numMonthList[key]});
                                       }  
                                   } 
                                   
                                   //component.set("v.wrapList",beatObjAllValues.warpObj);
                                   //console.log(component.get("v.wrapList"));
                                   component.set("v.monthNameList",optionsList);
                                   var yrList = [];
                                   for (var key in map1.yrList) {
                                       if (map1.yrList.hasOwnProperty(key)) {
                                           yrList.push({value: key, label: map1.yrList[key]});
                                       }
                                   }
                                   component.set("v.yrNameList",yrList);
                                   var regionList = [];
                                   for (var key in map1.numRegionList) {
                                       if (map1.numRegionList.hasOwnProperty(key)) {
                                           regionList.push({value: key, label: map1.numRegionList[key]});
                                       }
                                   }
                                   component.set("v.regionNameList",regionList);
                                   
                                   var map = map1.mapOfMap;
                                   console.log('map');
                                   console.log(map);
                                   var parsingWarpper=[];
                                   
                                   //Iterate over the key for Outer Map
                                   Object.keys(map).forEach(function(key) {
                                       
                                       var individualElement = {};
                                       individualElement.Id = key;
                                       individualElement.Value =[];
                                       var innerMapObject =map[key];
                                       
                                       //Iterate over the key for Inner  Map
                                       Object.keys(innerMapObject).forEach(function(key2) {
                                           console.log(key2);
                                           var innerIndivididualElement ={};
                                           innerIndivididualElement.Key = key2;
                                           innerIndivididualElement.Value = innerMapObject[key2];
                                           
                                           individualElement.Value.push(innerIndivididualElement);
                                       });  
                                       parsingWarpper.push(individualElement);
                                       
                                       
                                   });
                                   console.log('parsingWarpper');
                                   console.log(parsingWarpper);
                                   component.set("v.test",parsingWarpper);
                                   
                               }else
                               {
                                   console.debug(response.error[0].message);
                               }
                           });
        $A.enqueueAction(action);
    },
    fetchRecordAsPerYr : function(component, event, helper, montVar, yyrVar,regVar,startDate,endDate) {   
        console.log('month---'+montVar);
        var action = component.get("c.getSearchedBeatPlan");  
        action.setParams({ selectedYr : yyrVar,
                          selectedMonths : montVar,
                          selectedreg : regVar,
                          startDate : startDate,
                          endDate : endDate
                         });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if (state === "SUCCESS")
                               {	
                                   component.set("v.dateInMonth",'');
                                   component.set("v.test",'');
                                   var map1 = response.getReturnValue();   
                                   //component.set("v.dateInMonth",map1.beatdateListNew);
                                   var dateList = [];
                                   var i = 1;
                                   for (var key in map1.beatdateListNew) {
                                       dateList.push(i++);
                                   }
                                   component.set("v.dateInMonth",dateList);
                                   var map = map1.mapOfMapNew;                                   
                                   var parsingWarpper=[];
                                   
                                   //Iterate over the key for Outer Map
                                   Object.keys(map).forEach(function(key) {
                                       
                                       var individualElement = {};
                                       individualElement.Id = key;
                                       individualElement.Value =[];
                                       var innerMapObject =map[key];
                                       console.log('innerMapObject');
                                       console.log(innerMapObject);
                                       //Iterate over the key for Inner  Map
                                       Object.keys(innerMapObject).forEach(function(key2) {
                                           console.log(key2);
                                           var innerIndivididualElement ={};
                                           innerIndivididualElement.Key = key2;
                                           innerIndivididualElement.Value = innerMapObject[key2];
                                           
                                           individualElement.Value.push(innerIndivididualElement);
                                       });  
                                       parsingWarpper.push(individualElement);
                                       
                                       
                                   });
                                   console.log('parsingWarpper');
                                   console.log(parsingWarpper);
                                   
                                   component.set("v.test",parsingWarpper);
                                   
                               }else
                               {
                                   console.debug(response.error[0].message);
                               }
                           });
        $A.enqueueAction(action);
    },
    showError : function(component, event, helper, displayError){
    	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                title : 'Error Message',
                message: displayError,
                messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
    }
})