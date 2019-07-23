/***********************************************************************************************************************
Author : Prashant Rana
Description : This controller will take care of all the functionality behid mobile app (DCR Details)
Date : 01-01-2019 
************************************************************************************************************************/
global with sharing class BeatPlanMapPageController {
    global string eventList{get;set;}
    global beat_Plan__c beatObj{get;set;}
    global string checkinMapping{get;set;}
    global DCR_Detail1_Translation__c translationObject{get;set;}

    //Constructor
    global BeatPlanMapPageController(){
        try{
            translationObject= DCR_Detail1_Translation__c.getValues(UserInfo.getLanguage()); 
            if(translationObject== null){
                translationObject= DCR_Detail1_Translation__c.getValues('en_US');
            }
            list<Check_In_Setting__c> checkinList = Check_In_Setting__c.getAll().values();
            if(!checkinList.isEmpty()){
                checkinMapping = JSON.serialize(checkinList);
            }
            system.debug(UserInfo.getUserId());
            beatObj = [select name, Started__c,ended__c,id from beat_Plan__c where beat_Date__c =: date.today() AND Assigned_To__c = :UserInfo.getUserId()];
            system.debug('beat Object : '+beatObj);
            if(beatObj !=null){
                string beatId = beatObj.id;
                system.debug('Beat Id : '+beatId);
                list<event> eventData = [select id, subject,Cheked_In__c, StartDateTime,Check_Out__c, EndDateTime, Event_Latitude__c, Event_Longitude__c, Account__r.RecordType.DeveloperName,
                                            Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity,Beat_Plan__c,Out_Of_Office__c from event where Beat_Plan__c = :beatId AND
                                             Check_Out__c != true AND Account__c !=null AND Status__c !='Cancelled' order by StartDateTime  ASC];
                System.debug('event list : '+eventData.size());
                if(!eventData.isempty()){
                    string eventString = json.serialize(eventData);
                    eventList = eventString.escapeUnicode().remove('\'');
                }
            }
            system.debug('event list as string : '+eventList);
                        
        }catch(exception e){
            system.debug('error in beat plan constructor : '+e.getMessage()+', at line no : '+e.getLineNumber());
        }
    }
    //Start my day method
    @remoteAction
    global static String startMyDay(map<string,Object> mapData){
        try{
            System.debug('Data from request in start my day : '+mapData);
            beat_Plan__c beatObj = [select name,Started__c, Start_Time__c,Start_LatLang__Latitude__s,Start_LatLang__Longitude__s, End_Time__c from beat_Plan__c where beat_Date__c =: date.today() AND Assigned_To__c =:UserInfo.getUserId() limit 1];
            beatObj.Start_LatLang__Latitude__s = (Decimal)mapData.get('UserLatitude');
            beatObj.Start_Time__c = system.now().time();
            beatObj.Started__c = true;
            beatObj.Start_LatLang__Longitude__s = (Decimal)mapData.get('UserLongitude');
            System.debug('beat object : '+beatObj);
            update beatObj;
        }catch(Exception e){
            System.debug('error in start my day : '+e.getMessage()+', at line no : '+e.getLineNumber());
            return e.getMessage();
        }
        return 'SUCCESS';
    }

    //CheckIn Function
    @RemoteAction
    global static list<String> checkInMethod(map<string,Object> mapData){
        try{
            system.debug('request in checkin method : '+mapData);
            Event evObj = new event();
            evObj.Id = mapData.get('eventId').toString();
            evObj.check_In_Time__c = System.now().time();
            evObj.Stage__c = 'Checked‐In';
            evObj.Cheked_In__c = true;
            if(mapData.get('CheckInLat') !='' && mapData.get('CheckInLong') !=''){
                evObj.Checkin_Latlang__Latitude__s = (Decimal)mapData.get('CheckInLat');
                evObj.Checkin_Latlang__Longitude__s = (Decimal)mapData.get('CheckInLong');
            }
            System.debug('update in checkin : '+evObj);
            update evObj;
        }catch(Exception e){
            system.debug('error in checkin method : '+e.getMessage()+', at line no : '+e.getLineNumber());
            return new list<String>{'FAILED',e.getMessage()};
        }
        return new List<String>{'SUCCESS',URL.getSalesforceBaseUrl().toExternalForm()};
    }

    //Checkout Method
    @remoteAction
    global static void checkOutMethod(Map<String,Object> mapData){
        try {
           System.debug('request in checkout method : '+mapData);
           string Id = string.valueOf(mapData.get('eventId'));
           event evObj = [select subject ,Event_Latitude__c,Event_Longitude__c,Checkout_Distance__c,Checkout__Latitude__s,
                                         Checkout__Longitude__s ,check_Out_Time__c,check_Out__c,Stage__c from event where id =:Id ];
           Location loc1 = Location.newInstance(evObj.Event_Latitude__c,evObj.Event_Longitude__c);
           Location loc2 = Location.newInstance((decimal)mapData.get('CheckOutLat'),(Decimal)mapData.get('CheckOutLong'));
           System.debug('locations : '+loc1+', location 2 : '+loc2);
           Double dist = Location.getDistance(loc1, loc2, 'km');
           system.debug('distance : '+dist);
           evObj.Checkout_Distance__c = dist;
           evObj.Checkout__Latitude__s = (decimal)mapData.get('CheckOutLat');
           evObj.Checkout__Longitude__s = (decimal)mapData.get('CheckOutLong');
           evObj.check_Out_Time__c = System.now().time();
           evObj.check_Out__c = true;
           evObj.Stage__c = 'Checked-Out';
           System.debug('Event for update : '+evObj);
           update evObj;
        } catch (Exception e) {
           system.debug('error in checout method : '+e.getMessage()+', at line no : '+e.getLineNumber());
        }
    }

    //end my day method
    @remoteAction
    global static String endMyDay(map<string, Object> mapData){
        try {
            System.debug('request from page : '+mapData);
            beat_Plan__c beatObj = [select name,Started__c, Start_Time__c,End_LatLang__Latitude__s,End_Time__c,End_LatLang__Longitude__s,Start_LatLang__Latitude__s,Start_LatLang__Longitude__s,total_Distance__c from beat_Plan__c where beat_Date__c =: date.today() AND Assigned_To__c = : UserInfo.getUserId() limit 1];
            list<event> eventList = [select checkout__Latitude__s,Checkout__Longitude__s from event where Beat_Plan__c =: beatObj.Id order by startDateTime ASC];
            beatObj.End_LatLang__Latitude__s = (decimal)mapData.get('UserLatitude');
            beatObj.End_LatLang__Longitude__s = (Decimal)mapData.get('UserLongitude');
            integer count = 0;
            Double distance = 0;
            if(!eventList.isEmpty() && eventList[0].Checkout__Latitude__s !=null){
                Integer lastIndex = eventList.size() -1;
                Location loc1 = Location.newInstance(beatObj.Start_Latlang__latitude__s,beatObj.Start_Latlang__Longitude__s);
                Location loc2 = Location.newInstance(eventList[0].Checkout__Latitude__s,eventList[0].Checkout__Longitude__s);
                System.debug('location1 : '+loc1+', Locations 2 : '+loc2);
                distance += Location.getDistance(loc1,loc2,'KM');
                System.debug('distance after first checkout : '+distance);
                System.debug('event list size : '+eventList.Size());
                for(integer i=0; i+1 <eventList.size();i++){
                    distance += Location.getDistance(Location.newInstance(eventList[i].Checkout__Latitude__s,eventList[i].Checkout__Longitude__s),
                                                         Location.newInstance(eventList[i+1].Checkout__Latitude__s,eventList[i+1].Checkout__Longitude__s),'KM');
                }
                distance += Location.getDistance(Location.newInstance(eventList[lastIndex].Checkout__Latitude__s,eventList[lastIndex].Checkout__Longitude__s),
                                                            Location.newInstance(beatObj.End_Latlang__latitude__s,beatObj.End_Latlang__Longitude__s),'KM');
                beatObj.Total_Distance__c = distance ;
            }
            System.debug('distance : '+distance);
            beatObj.End_Time__c = system.now().time();
            beatObj.Ended__c = true;
            System.debug('beat object : '+beatObj);
            update beatObj;
        } catch (Exception e) {
          System.debug('error in end my day method : '+e.getMessage()+', at line no : '+e.getLineNumber()); 
          return 'FAILED';
        } 
        return 'SUCCESS';
    }

    //This method will update or cancel the event
    @RemoteAction
    global static string updateCancelEvent(string info,map<string,Object> mapData){
        System.debug('request : '+mapData+', with info : '+info);
        try {
            event eventObj = new event();
            eventObj.Id = String.valueOf(mapData.get('eventId'));
            string [] dateArr = string.valueOf(mapData.get('date')).split('-');
            string [] startTimeArr = string.valueOf(mapData.get('startTime')).split(':');
            string [] endTimeArr = string.valueOf(mapData.get('endTime')).split(':');
            date evdate = date.newInstance(integer.valueOf(dateArr[0]), integer.valueOf(dateArr[1]), integer.valueOf(dateArr[2]));
            time startTime = time.newInstance(integer.valueOf(startTimeArr[0]), integer.valueOf(startTimeArr[1]), 0, 0);
            time endtime = time.newInstance(integer.valueOf(endTimeArr[0]), integer.valueOf(endTimeArr[1]), 0, 0);
            eventObj.StartDateTime = datetime.newInstance(evdate, startTime).addMinutes(330);
            eventObj.Update_Reason__c = String.valueOf(mapData.get('reason'));
            eventObj.Visit_date__c = evdate;
            if(info == 'cancel'){
                eventObj.Status__c = 'Cancelled';
            }
            System.debug('event updated : '+eventObj);
            update eventObj;
        } catch (Exception e) {
            System.debug('error in updating event : '+e.getMessage()+', At line no : '+e.getLineNumber());
            return e.getMessage();
        }
        return 'SUCCESS';
    }
    
    @RemoteAction
    global static string GetBasicUrl(){
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
}