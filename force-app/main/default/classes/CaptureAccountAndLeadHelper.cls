/**************************************************************************************************************
Description : This helper class will tag the event to its suitable beat plan on every create or update event
Author : Prashant Rana
Date : 2019-04-20
**************************************************************************************************************/
public class CaptureAccountAndLeadHelper {

    public static void updatevent(list<event> evlist){
        try{
            System.debug('event list : '+evlist);
            map<String , beat_Plan__c> beatMap = new map<String,beat_Plan__c>();
            list<date> dateList = new list<date>();
            set<id> beatIdSet = new set<id>();
            //set<id> newbeatIdSet = new set<id>();
            map<id,string> beatAndNewEventsMap = new map<id,string>();
            map<id,list<string>> beatAndEventListsMap = new map<id,list<string>>();
            for(event obj : evlist){
                dateList.add(obj.StartDateTime.date());
                //beatAndNewEventsMap.put(obj.Beat_plan__c, obj.Subject);
                //beatIdSet.add(obj.Beat_Plan__c);
            }
            date dobj = date.today().addDays(-5);
            list<beat_Plan__c> beatList = [select beat_Date__c,Assigned_To__c,BUI__c, id from beat_Plan__c where Beat_Date__c in : dateList];
            System.debug('beat plan : '+beatList);
            for (beat_Plan__c bobj : beatList) {
                beatMap.put(bobj.BUI__c, bobj);
            }
            System.debug('beat map : '+beatMap);
            if(evlist !=null){
                for (event evObj : evlist) {
                    System.debug('account : '+evObj.WhatId);
                    System.debug('subject: '+evObj.subject);
                    if(evObj.WhatId != null && String.valueOf(evObj.whatId).startswith('001')){
                        evObj.Account__c = evObj.WhatId;
                    }
                    evObj.Visit_Date__c = evObj.StartDateTime.date();
                    if (evObj.Visit_Date__c <= date.today() && beatMap.containsKey(evObj.ownerId+'-'+evObj.Visit_Date__c.format())) {
                        evObj.Beat_Plan__c = beatMap.get(evObj.ownerId+'-'+evObj.Visit_Date__c.format()).Id;
                        //beatAndEventsMap.put(evObj.Beat_Plan__c,evObj);
                        beatAndNewEventsMap.put(evObj.Beat_plan__c, evObj.Subject);
                        beatIdSet.add(evObj.Beat_Plan__c);
                    }else if(evObj.Visit_Date__c > date.today()){
                        evObj.Beat_Plan__c = null;
                    }else if (evObj.Visit_Date__c <= date.today() && !beatMap.containsKey(evObj.ownerId+'-'+evObj.Visit_Date__c.format())) {
                        beat_Plan__c bobj = new beat_Plan__c();
                        bobj.Beat_Date__c = evObj.Visit_date__c;
                        bobj.BUI__c = evObj.OwnerId+'-'+evObj.visit_Date__c.format();
                        bobj.Assigned_To__c = evObj.OwnerId;
                        insert bobj;
                        evObj.Beat_Plan__c = bobj.id;
                        beatMap.put(bobj.BUI__c,bobj);
                    }   
                }
                            
            }               

        }

        catch(exception e){
            system.debug('error in capturing account and lead : '+e.getMessage());
        }
    }
}