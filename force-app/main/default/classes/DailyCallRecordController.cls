/*******************************************************************************
Description : This controller will take care of calendar events
Date : 01-01-2019
Created By : Prashant Rana 
********************************************************************************/
global with sharing class DailyCallRecordController {
    public string eventData{get;set;}
    public string accountData{get;set;}
    public string allUser{get;set;}
    public List<String> pickListValuesList{get;set;}
    public user userObj{get;set;}
    public string userObject{get;set;}
    public string managerList{get;set;}
    public string productList{get;set;}
    public DCR_Planning_Translation_Turkey__c translationObject{get;set;}
   
   //Constructor
    global DailyCallRecordController(){
        try{
            userObj = [select id, name, profileId,User_Type__c from user where id =: userInfo.getUserId() limit 1];
            userObject = JSON.serialize(userObj);
            System.debug('user object : '+userObject);
            string curentLang = userinfo.getLanguage();
            translationObject = DCR_Planning_Translation_Turkey__c.getValues(curentLang);
            list<user> mngList = [select id, name from user where managerId = : userinfo.getUserId()];
            if(!mngList.isempty()){
                String ues = JSON.serialize(mngList);
                managerList = ues.escapeUnicode().remove('\'');
                System.debug('manager List : '+managerList);
            }
            system.debug('Manager list : '+managerList);
            list<event> evObj =[select id,follow_Up_Date__c,ActivityDate,startdateTime,DCR_Description__c,endDateTime,subject,Product__c,Account__r.Name,Account__r.RecordType.DeveloperName,Event_Locked__c,
                                CE_Rating__c,CIS_Rating__C, Status__c,Other_Type__c,Account__c,WhoId from event where ownerId =:UserInfo.getUserId()];
            if(!evObj.isEmpty()){
                String res = JSON.serialize(evObj);
                eventData = res.escapeUnicode().remove('\'');
                System.debug('event data : '+eventData);
            }
            system.debug('Data of event : '+evObj);
            list<account> accObj = [select id,(select contact.Name, contact.Department, contact.Id from contacts), name,recordType.DeveloperName,phone,Status__c,Account_Locked__c,Account_Locked_Reason__c,
                                    CE_Rating__c,CIS_Rating__C from account order by Name];
            if(!accObj.isEmpty()){
                String aces = JSON.serialize(accObj);
                accountData = aces.escapeUnicode().remove('\'');
                System.debug('account data : '+accountData);
            }
            list<product__c> prodList = [select name from Product__c where region__c =: userObj.user_Type__c AND MSP__c !=null AND MSP__c != 0 Order BY Name ASC];
            if(!prodList.isEmpty()){
                String pes = JSON.serialize(prodList);
                productList = pes.escapeUnicode().remove('\'');
                System.debug('product list : '+productList);
            }
            Map<Id,Profile> profileIds = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile where UserLicenseId  in (SELECT Id FROM UserLicense where name ='Salesforce Platform')]);
            list<user> userList = [select id, name, profileId from user where IsActive = true AND ProfileId in : profileIds.KeySet() AND User_type__c =: userObj.User_Type__c];
            if(!userList.isEmpty()){
                String aues = JSON.serialize(userList);
                allUser = aues.escapeUnicode().remove('\'');
                System.debug('All user : '+allUser);
            }
            pickListValuesList= new List<String>();
            map<string , CallTypeRemoval__c> removalCallTypeMap = CallTypeRemoval__c.getAll();
            Schema.DescribeFieldResult fieldResult = event.Call_Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                if(!removalCallTypeMap.containsKey(pickListVal.getLabel()))
                    pickListValuesList.add(pickListVal.getLabel());
            }   
            System.debug(pickListValuesList.size());
            System.debug('picklislt values after removal : '+pickListValuesList);
        }catch(exception e){
            system.debug('Error in constructor : '+e.getMessage()+',At line no : '+e.getLineNumber());
        }
    }
    
    //This method will receive list of events and will save all events in DB
    @RemoteAction
    public static void createNewEvents(string data){
        system.debug('Data : '+data);
        list<event> eventList = new list<event>();
        try{
            list<object> dataList = (list<object>)JSON.deserializeUntyped(data);
            system.debug('Data List : '+dataList);
            for(object o : dataList){
                map<string, object> dataMap =  (map<string, object>)o;
                event eventObj = new event();
                eventObj.Subject = string.valueOf(dataMap.get('subject'));
                string [] dateArr = string.valueOf(dataMap.get('date')).split('-');
                string [] startTimeArr = string.valueOf(dataMap.get('startTime')).split(':');
                string [] endTimeArr = string.valueOf(dataMap.get('endTime')).split(':');
                date evdate = date.newInstance(integer.valueOf(dateArr[0]), integer.valueOf(dateArr[1]), integer.valueOf(dateArr[2]));
                time startTime = time.newInstance(integer.valueOf(startTimeArr[0]), integer.valueOf(startTimeArr[1]), 0, 0);
                time endtime = time.newInstance(integer.valueOf(endTimeArr[0]), integer.valueOf(endTimeArr[1]), 0, 0);
                eventObj.StartDateTime = datetime.newInstance(evdate, startTime).addMinutes(0);
                eventObj.EndDateTime = datetime.newInstance(evdate, endTime).addMinutes(0);
                eventObj.visit_Date__c = eventObj.startDateTime.date();
                eventObj.Joint_Call__c = boolean.valueOf(dataMap.get('isJoint'));
                if(dataMap.get('outOfOffice') !=null){
                    eventObj.Out_Of_Office__c = Boolean.valueOf(dataMap.get('outOfOffice'));
                }
                if(string.valueOf(dataMap.get('relatedTo')).startsWith('001') && !string.valueOf(dataMap.get('relatedTo')).contains('001Leave')){
                    eventObj.WhatId = string.valueOf(dataMap.get('relatedTo'));
                    eventObj.status__c = 'Planned';
                }else if(string.valueOf(dataMap.get('relatedTo')).contains('001Leave')){
                    string temp = string.valueOf(dataMap.get('relatedTo'));
                    System.debug('temp var : '+temp);
                    if(temp == '001Leave'){
                        eventObj.Call_Type__c = 'Leave';
                    }else if (temp == '001LeaveHoli') {
                        eventObj.Call_Type__c = 'Holiday';
                    }
                    eventObj.status__c = 'Draft';
                    eventObj.Other_Type__c = true;
                }
                if(string.isNotBlank(string.valueOf(dataMap.get('ownerId')))){
                    eventObj.OwnerId = string.valueOf(dataMap.get('ownerId'));
                }
                eventObj.Address__c = dataMap.get('address') !=null ? dataMap.get('address').tostring() : '';
                eventObj.Contact__c = dataMap.get('contact') !=null ? dataMap.get('contact').tostring() : '';
                eventObj.Country__c = dataMap.get('country') !=null ? dataMap.get('country').toString() : '';
                eventObj.DCR_Description__c = dataMap.get('description') !=null ? dataMap.get('description').toString() : '';
                if(dataMap.get('FromDate') !=''){
                    String[] fromDateArr = dataMap.get('FromDate').toString().split('-');
                    eventObj.From_Date__c = date.newInstance(Integer.valueOf(fromDateArr[0]),Integer.valueOf(fromDateArr[1]),Integer.valueOf(fromDateArr[2]));
                }
                eventObj.From_place__c = dataMap.get('FromPlace') !=null ? dataMap.get('fromPlace').tostring() : '';
                eventObj.Name__c = dataMap.get('name') !=null ? dataMap.get('name').toString() : '';
                eventObj.Next_Visit_Planning_Remarks__c = dataMap.get('nextVisitPlanning') !=null ? dataMap.get('nextVisitPlanning').toString() : '';
                eventObj.No_of_days_travelled__c = dataMap.get('dayTravel') !='' ? integer.valueOf(dataMap.get('dayTravel')) : null;
                eventObj.No_of_doctors_visited__c = dataMap.get('doctorVisit') !='' ? integer.valueOf(dataMap.get('doctorVisit')) : null;
                eventObj.No_of_PMS_Collected__c = dataMap.get('pmsCollected') !='' ? integer.valueOf(dataMap.get('pmsCollected')) : null;
                eventObj.No_of_Surgeries_Attended__c = dataMap.get('surgery') !='' ? integer.valueOf(dataMap.get('surgery')) : null;
                eventObj.Remark_for_doctors__c = dataMap.get('remarkDoctor') !=null ? dataMap.get('remarkDoctor').toString() : '';
                eventObj.Remark_for_market_information__c = dataMap.get('marketInfo') !=null ? dataMap.get('marketInfo').toString() : '';
                eventObj.Remark_for_Tenders__c = dataMap.get('remarkTender') !=null ? dataMap.get('remarkTender').toString() : '';
                if(dataMap.get('ToDate') !=''){
                    string[] toDateArr = dataMap.get('ToDate').toString().split('-');
                    eventObj.To_Date__c = date.newInstance(Integer.valueOf(toDateArr[0]),Integer.valueOf(toDateArr[1]),Integer.valueOf(toDateArr[2]));
                }
                if(dataMap.get('contactId') !=''){
                    eventObj.whoId = dataMap.get('contactId').toString();
                    System.debug('Contact Id : '+eventObj.whoId);
                }
                eventObj.To_place__c = dataMap.get('toPlace') !='' ? dataMap.get('toPlace').tostring() : '';
                eventObj.Week_no__c = dataMap.get('week') !='' ? integer.valueof(dataMap.get('week')) : null;
                
                eventObj.Employee__c = dataMap.get('employeeName') !='' ? dataMap.get('employeeName').tostring() : '';
                if(dataMap.get('product') !=''){
                    eventObj.product__c = dataMap.get('product').toString();
                    system.debug(eventObj.product__c);
                }
                if(dataMap.get('callType') !=''){
                    eventObj.Call_Type__c = dataMap.get('callType').toString();
                } 
                eventList.add(eventObj);
            }
            system.debug('Event List to be inserted : '+eventList);
            insert eventList;
        }catch(exception e){
            system.debug('error in Creating visits : '+e.getMessage()+', at line no : '+e.getLineNumber());
        }
    }
    
    @RemoteAction
    public static void deleteEvent(string eventId){
        system.debug('Event id in param : '+eventId);
        try{
            event evObj = new event(id=eventId);
            delete evObj;
        }catch(exception e){
            system.debug('error in delete of event method : '+e.getLineNumber()+', at line no : '+e.getLineNumber());
        }
    }
    
    @RemoteAction
    public static void updateEvent(map<string, object> data){
        system.debug('prameter : '+data);
        try{
            event evObj = new event();
            evObj.id = data.get('eventId').toString();
            string[] eTimeArr = String.valueOf(data.get('endTime')).split(':');
            string[] STimeArr = String.valueOf(data.get('startTime')).split(':');
            string[] dateArr = string.valueOf(data.get('date')).split('-');
            date dt = date.newInstance(Integer.valueOf(dateArr[0]),Integer.valueOf(dateArr[1]),Integer.valueOf(dateArr[2]));
            time endTime = time.newInstance(Integer.valueOf(eTimeArr[0]), Integer.valueOf(eTimeArr[1]), 0, 0);
            time startTime = time.newInstance(Integer.valueOf(STimeArr[0]), Integer.valueOf(STimeArr[1]), 0, 0);
            evObj.StartDateTime = Datetime.newInstance(dt, startTime).addMinutes(0);
            evObj.EndDateTime = Datetime.newInstance(dt, endTime).addMinutes(0);
            evObj.visit_date__c = evObj.startDateTime.date();
            if(data.get('status') == 'submitAndSave'){
                evObj.Status__c = 'Sent for Approval ';
                evObj.Event_Locked__c = true;
            }
            if(data.get('product') !=''){
                evObj.product__c = data.get('product').toString();
                system.debug(evObj.product__c);
            }
            if(data.get('folloUpDate') !=''){
                string[] fromDateArr = String.valueOf(data.get('folloUpDate')).split('-');
                evObj.follow_Up_Date__c = date.newInstance(integer.valueOf(fromDateArr[0]),integer.valueOf(fromDateArr[1]),integer.valueOf(fromDateArr[2]));
            }
            if(data.get('contactId') !=''){
                evObj.whoId = data.get('contactId').toString();
                System.debug('Contact Id : '+evObj.whoId);
            }
            evObj.DCR_Description__c = data.get('description').tostring() !='' ? data.get('description').tostring() :'';
            System.debug('event before update : '+evObj);
            update evObj;
           
        }catch(Exception e){
            system.debug('error in updating event : '+e.getMessage()+',at line no. '+e.getLineNumber());
        }
    }
    
    @RemoteAction
    public static list<event> getUserData(string data){
        system.debug('parameter in user method : '+data);
       list<event> eventList = new list<event>();
        try{
             eventList = [select id,ActivityDate,startdateTime,endDateTime,subject,Account__r.Name,Event_Locked__c, Status__c from event where OwnerId =:data];
        }catch(exception e){
            system.debug('error in getting user details : '+e.getMessage()+',at line no '+e.getLineNumber());
        }
        return eventList;
    }

    @RemoteAction
    public static string returnHomePage(){
        return URL.getSalesforceBaseUrl().toExternalForm();
    }

    public string getAllFields(String objectAPIName){
        String allFeilds = '';
        Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(objectAPIName);           
        Map<String,Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();
        for(string apiName : fieldsMap.keySet()){
            if(String.isBlank(allFeilds)){
                allFeilds = apiName;
            }else {
                allFeilds = allFeilds+','+apiName;
            }
        }
        System.debug(allFeilds);
        return allFeilds;
    }

}