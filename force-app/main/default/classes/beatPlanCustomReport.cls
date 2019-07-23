public class beatPlanCustomReport {
    @AuraEnabled
    public set<date> beatdateList{get;set;}
    @AuraEnabled
    public map<string, string> numMonthList{get;set;}
    @AuraEnabled
    public List<String> getEntity{get;set;}
    @AuraEnabled
    public map<string, string> yrList{get;set;}
    @AuraEnabled
    public map<string,string> numRegionList{get;set;}
    @AuraEnabled
    public map<string , map<date,string>> mapOfMap{get;set;}
    @AuraEnabled
    public string attachmentId{get;set;}
    @AuraEnabled
    public map<string , map<date,string>> mapOfMapNew{get;set;}
    @AuraEnabled
    public set<date> beatdateListNew{get;set;}
    @AuraEnabled
    public string currentMonth{get;set;}
    @AuraEnabled
    public string currentYear{get;set;}
    
    @AuraEnabled
    public static  beatPlanCustomReport getfetchBeatPlan() {
        map<string , map<date,string>> mapdateVsUserEvents = new  map<string , map<date,string>>();
        Attachment attachObj = [SELECT Id, Name FROM Attachment where name = 'biotech_logo-1.png' limit 1];
        string attchId = attachObj.id;
        beatPlanCustomReport beatplanObj = new beatPlanCustomReport();                
        Integer monthSelection = Date.Today().Month(); //month > declared here so it can be overwritten in afuture enhancement
        Integer yearSelection = Date.Today().Year(); //year > declared here so it can be overwritten in afuture enhancement
        List<Date> returnList = new List<Date>(); //return list of Dates
        Integer daysInMonth = Date.daysInMonth(yearSelection, monthSelection ); //number of days in month
        
        
        map<Date,string> mapVsEventCommon = new map<Date, string>();
         map<Date,string> mapVsEventCommon1 = new map<Date, string>();
        set<date> setOfDays = new set<date>();
        for (Integer day = 1; day <= daysInMonth; day++) { //for first to last day in month
            setOfDays.add(Date.newInstance(yearSelection, monthSelection, day));
            mapVsEventCommon.put(Date.newInstance(yearSelection, monthSelection, day) , 'A');
            mapVsEventCommon1.put(Date.newInstance(yearSelection, monthSelection, day) , 'A');
        }
        
        map<string, string> monListOfString = getNumMonth();
        map<string, string> listOfYr = getNumYr();
        map<string, string> listOfregion = getNumOfRegion();
        
        /*//Qyery  beatPlan*/
                 
        List<Beat_Plan__c> beatList = [SELECT Id, End_Time__c, Event_Type__c, 
                                       Beat_Date__c, BeatYr__c, BeatMonth__c,BUI__c, Assigned_To__c,owner.name 
                                       from Beat_Plan__c 
                                       where Beat_Date__c = THIS_MONTH and Event_Type__c != null]; 
        
        for(Beat_Plan__c btObj : beatList){
            map<date,string> newTempMap = new map<date,string>();
            if(mapdateVsUserEvents.containskey(btObj.Owner.name)){
               newTempMap = mapdateVsUserEvents.get(btObj.Owner.name);
                newTempMap.put(btObj.Beat_Date__c,btObj.Event_Type__c);
                mapdateVsUserEvents.put(btObj.Owner.name , newTempMap);
            }
            else{
                newTempMap = mapVsEventCommon.clone();
                if(newTempMap != null && newTempMap.containskey(btObj.Beat_Date__c)){
                	newTempMap.put(btObj.Beat_Date__c,btObj.Event_Type__c);
            	} 
            }
            
            mapdateVsUserEvents.put(btObj.Owner.name,newTempMap);
        }
        
        for(user usrObj : [select id, name, User_Type__c from user where User_Type__c = 'Domestic' and IsActive = true ]){
            if(!mapdateVsUserEvents.containskey(usrObj.name)){
                mapdateVsUserEvents.put(usrObj.name,mapVsEventCommon1);
            }
            
        }
        system.debug(string.valueOf(yearSelection));
        beatplanObj.currentMonth = monListOfString.get(string.valueOf(monthSelection + 1));
        beatplanObj.currentyear = string.valueOf(yearSelection);
        beatplanObj.mapOfMap = mapdateVsUserEvents;
        beatplanObj.beatdateList = setOfDays;
        beatplanObj.numMonthList = monListOfString;
        beatplanObj.yrList = listOfYr;
        beatplanObj.numRegionList = listOfregion;
        beatplanObj.attachmentId = attchId;
        return beatplanObj; 
    }
    @AuraEnabled
    public static beatPlanCustomReport getSearchedBeatPlan( string selectedYr, string selectedMonths, string selectedreg, date startDate, date endDate){   
        
        Integer numberDaysDue = 0;
        integer selectedMon = 0;
        string yearSelected = '';
        if(startDate != null && endDate != null){
        	 numberDaysDue = startDate.daysBetween(endDate) + 1;
             selectedMon = startDate.month();
			 yearSelected = string.valueOf(startDate.year());
        }
        
        else if(selectedMonths != null && selectedMonths != '1'){
            selectedMon = integer.valueOf(selectedMonths) - 1;
        }
        else{ 
            selectedMon = Date.Today().Month();
        }
        
        if(selectedYr != null && selectedYr != '1' && yearSelected == ''){
            yearSelected = string.valueOf(selectedYr);
        }
        else{
             yearSelected = string.valueOf(Date.Today().Year());
        }
        string selectedMonth = string.valueOf(selectedMon);
        String qString = '';
        string qUserString = ''; 
        if(yearSelected != null  && selectedMon == null ){
            qString ='SELECT Id, End_Time__c, Event_Type__c, Beat_Date__c, BeatYr__c, BeatMonth__c,BUI__c, Assigned_To__c,owner.name from Beat_Plan__c where Event_Type__c != null AND BeatYr__c = \'' + yearSelected + '\''; 
        }
        else if(yearSelected == null && selectedMon != null  ){
            qString ='SELECT Id, End_Time__c, Event_Type__c, Beat_Date__c, BeatYr__c, BeatMonth__c,BUI__c, Assigned_To__c,owner.name from Beat_Plan__c where Event_Type__c != null AND BeatMonth__c = \'' + selectedMon + '\'';
        }
        else if(yearSelected != null  && selectedMon != null  ){
            qString ='SELECT Id, End_Time__c, Event_Type__c, Beat_Date__c, BeatYr__c, BeatMonth__c,BUI__c, Assigned_To__c,owner.name from Beat_Plan__c where Event_Type__c != null AND BeatMonth__c = \'' + selectedMon + '\' and BeatYr__c = \'' + yearSelected + '\'';
        }
        else{
            qString ='SELECT Id, End_Time__c, Event_Type__c, Beat_Date__c, BeatYr__c, BeatMonth__c,BUI__c, Assigned_To__c,owner.name from Beat_Plan__c where Event_Type__c != null';
        }
        system.debug(qString);
        List<Beat_Plan__c> beatList = database.query(qString);
        system.debug(yearSelected);
        system.debug(selectedMon);
        //system.debug(beatList);
        system.debug(beatList);
        map<string , map<date,string>> mapdateVsUserEvents = new  map<string , map<date,string>>();
        beatPlanCustomReport beatplanObj = new beatPlanCustomReport();                
        Integer monthSelection = integer.valueOf(selectedMon); //month > declared here so it can be overwritten in afuture enhancement
        Integer yearSelection = integer.valueOf(yearSelected); //year > declared here so it can be overwritten in afuture enhancement
        List<Date> returnList = new List<Date>(); //return list of Dates
        Integer daysInMonth = Date.daysInMonth(yearSelection, monthSelection ); //number of days in month
        
        
        map<Date,string> mapVsEventCommon = new map<Date, string>();
        map<Date,string> mapVsEventCommon1 = new map<Date, string>();
        set<date> setOfDays = new set<date>();
        if(numberDaysDue == 0){
            for (Integer day = 1; day <= daysInMonth; day++) { //for first to last day in month
                 setOfDays.add(Date.newInstance(yearSelection, monthSelection, day));
                 mapVsEventCommon.put(Date.newInstance(yearSelection, monthSelection, day) , 'A');
                 mapVsEventCommon1.put(Date.newInstance(yearSelection, monthSelection, day) , 'A');
            }
        }
        else{
            
            for (Integer day = 1; day <= numberDaysDue; day++) { //for first to last day in month
                 setOfDays.add(Date.newInstance(yearSelection, monthSelection, day));
                 mapVsEventCommon.put(Date.newInstance(yearSelection, monthSelection, day) , 'A');
                 mapVsEventCommon1.put(Date.newInstance(yearSelection, monthSelection, day) , 'A');
            }
        }
        
        if(selectedreg != null && selectedreg != '1'){
            qUserString ='select id, name, User_Type__c from user where User_Type__c = \'' + selectedreg + '\' and IsActive = true';
        }
        else{
            string regionStr = 'Domestic';
            qUserString ='select id, name, User_Type__c from user where User_Type__c = \'' + regionStr + '\' and IsActive = true';
        }
        List<user> userList = new list<user>();
        set<string> userSet = new set<string>();
        userList = database.query(qUserString);
            for(user usrObj : userList){
                userSet.add(usrObj.name);
        	}
                
        /*//Qyery  beatPlan*/
        system.debug(beatList);
        system.debug(userSet);
        for(Beat_Plan__c btObj : beatList){
            map<date,string> newTempMap = new map<date,string>();
            if(mapdateVsUserEvents.containskey(btObj.Owner.name) && userSet.contains(btObj.Owner.name)){
               newTempMap = mapdateVsUserEvents.get(btObj.Owner.name);
                system.debug(btObj.Event_Type__c);
                if(btObj.Event_Type__c != null){
                    system.debug('i am in');
                    system.debug(btObj.Event_Type__c);
                	newTempMap.put(btObj.Beat_Date__c,btObj.Event_Type__c);
                }
                system.debug(newTempMap);
                mapdateVsUserEvents.put(btObj.Owner.name , newTempMap);
            }
            else{
                    newTempMap = mapVsEventCommon.clone();
                
                    if(newTempMap != null && newTempMap.containskey(btObj.Beat_Date__c)  && !string.isBlank(newTempMap.get(btObj.Beat_Date__c)) && newTempMap.get(btObj.Beat_Date__c) != null){
                    	newTempMap.put(btObj.Beat_Date__c,btObj.Event_Type__c);
            		} 
                if(userSet.contains(btObj.Owner.name)){
                	mapdateVsUserEvents.put(btObj.Owner.name , newTempMap);
                }
            }
            //system.debug(newTempMap);
            if(userSet.contains(btObj.Owner.name)){
            	mapdateVsUserEvents.put(btObj.Owner.name,newTempMap);
            }
          	
        }
        
        for(user usrObj : userList){
            if(!mapdateVsUserEvents.containskey(usrObj.name)){
                mapdateVsUserEvents.put(usrObj.name,mapVsEventCommon1);
            }
            
               // userSet.add(usrObj.name);
        }
        beatplanObj.mapOfMapNew = mapdateVsUserEvents;
        beatplanObj.beatdateListNew = setOfDays;
        
        
        return beatplanObj; 
    }
    
    @AuraEnabled 
    public static user fetchUser(){
       User u = [select id,Name, User_Type__c from User where id =: userInfo.getUserId()];
        return u;
    }
    
    public static Map<string, string> getNumMonth(){
        Map<string, string> monthList = new Map<string, string>();
        monthList.put('1','---NONE---');
        monthList.put('2','Jan');
        monthList.put('3','Feb');
        monthList.put('4','Mar');
        monthList.put('5','Apr');
        monthList.put('6','May');
        monthList.put('7','Jun');
        monthList.put('8','Jul');
        monthList.put('9','Aug');
        monthList.put('10','Sep');
        monthList.put('11','Oct');
        monthList.put('12','Nov');
        monthList.put('13','Dec');
        
        return monthList;
    }
    public static Map<string, string> getNumYr(){
        Map<string, string> yrMap = new Map<string, string>();
        yrMap.put('1','---NONE---');
        yrMap.put('2019','2019');
        yrMap.put('2020','2020');
        yrMap.put('2021','2021');
        yrMap.put('2022','2022');
        yrMap.put('2023','2023');
        
        
        return yrMap;
    }
    public static map<string,string> getNumOfRegion(){
        Map<string, string> regionMap = new Map<string, string>();
        regionMap.put('1','---NONE---');
        regionMap.put('Domestic','Domestic');
        regionMap.put('International','International');
        regionMap.put('Turkey','Turkey');
        
        return regionMap;
    }
   
 }