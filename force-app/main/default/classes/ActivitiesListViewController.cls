public class ActivitiesListViewController {
    
    @AuraEnabled
    public static List<Event> getEvents(){
        return [Select Id,Subject,Beat_plan__c,Status__c,StartDateTime,EndDateTime,Event_Locked__c,What.Name,WhoId,Owner.Name 
                From Event 
                Where Status__c =: Constants.EVENT_STATUS_SENTFORAPPROVAL 
                ];
        
         
    }
    @AuraEnabled
    public static void getBeatPlan(list<string> eventId){
        system.debug(eventId);
        set<id> beatplanId  = new set<id>();
        for(event ev : [Select Id,Subject,Beat_plan__c,Status__c,StartDateTime,EndDateTime,Event_Locked__c,What.Name,WhoId,Owner.Name From Event Where Id IN: eventId]){
            system.debug('ev.id==>'+ev.id);
            system.debug('ev.Status__c==>'+ev.Status__c);
            if(ev.Beat_plan__c != null){       
                beatplanId.add(ev.Beat_plan__c);
                system.debug('beatplanId==>'+beatplanId);
            }
        }
        
        list<Beat_plan__c> beatPlanToBeupdated = new list<Beat_plan__c>();
        map<id,list<string>> mapOfBeatIdVsListOfEvent = new map<id,list<string>>();
        for(event eve : [Select Id,Subject,Beat_plan__c,Status__c,StartDateTime,EndDateTime,Event_Locked__c,What.Name,WhoId,Owner.Name 
                        From Event 
                        Where Beat_plan__c IN: beatplanId AND Status__c = 'Approved'
                        ]){                            
                            system.debug('eve.id==>'+eve.Id);
                            system.debug('eve.Beat_plan__c==>'+eve.Beat_plan__c);
                            if(mapOfBeatIdVsListOfEvent.containsKey(eve.Beat_plan__c)){ 
                                list<string> eveSub = mapOfBeatIdVsListOfEvent.get(eve.Beat_plan__c);
                                mapOfBeatIdVsListOfEvent.put(eve.Beat_plan__c,eveSub);
                                system.debug('mapOfBeatIdVsListOfEvent==>'+mapOfBeatIdVsListOfEvent);
                            }
                            else{
                                if(eve.Beat_plan__c !=null){
                                    list<string> eveSub = new list<string>();
                                    eveSub.add(eve.Subject);
                                    mapOfBeatIdVsListOfEvent.put(eve.Beat_plan__c,eveSub);  
                                    system.debug('mapOfBeatIdVsListOfEvent1==>'+mapOfBeatIdVsListOfEvent);
                                }
                                
                            }
                            
            
        }
        
        
        for(Event newlyApprovedevents : [Select Id,Subject,Beat_plan__c,Status__c,StartDateTime,EndDateTime,Event_Locked__c,What.Name,WhoId,Owner.Name From Event Where Id IN: eventId AND Beat_plan__c != null]){
            
            if(newlyApprovedevents.Subject != null && newlyApprovedevents.Beat_plan__c != null){
                system.debug('you ar here!!!');
                if(newlyApprovedevents.Subject == 'Leave' &&  mapOfBeatIdVsListOfEvent.get(newlyApprovedevents.Beat_plan__c).contains('Leave')){
                    Beat_plan__c bb = new Beat_plan__c();
                    bb.id = newlyApprovedevents.Beat_plan__c;
                    bb.Event_Type__c = 'L';
                    system.debug('bb.Event_Type__c1==>'+bb.Event_Type__c);
                    beatPlanToBeupdated.add(bb);
                }       
                else if(newlyApprovedevents.Subject == 'Leave' &&  !mapOfBeatIdVsListOfEvent.get(newlyApprovedevents.Beat_plan__c).contains('Leave')){
                    Beat_plan__c bb = new Beat_plan__c();
                    bb.id = newlyApprovedevents.Beat_plan__c;
                    bb.Event_Type__c = 'Half day';
                    system.debug('bb.Event_Type__c2==>'+bb.Event_Type__c);
                    beatPlanToBeupdated.add(bb);
                } 
                
                else if(newlyApprovedevents.Subject != 'Leave' &&  mapOfBeatIdVsListOfEvent.get(newlyApprovedevents.Beat_plan__c).contains('Leave')){
                    Beat_plan__c bb = new Beat_plan__c();
                    bb.id = newlyApprovedevents.Beat_plan__c;
                    bb.Event_Type__c = 'Half day';
                    system.debug('bb.Event_Type__c2.2==>'+bb.Event_Type__c);
                    beatPlanToBeupdated.add(bb);
                } 
                else if( newlyApprovedevents.Subject != 'Leave' &&  mapOfBeatIdVsListOfEvent.get(newlyApprovedevents.Beat_plan__c).contains('Leave') == false){
                    Beat_plan__c bb = new Beat_plan__c();
                    bb.id = newlyApprovedevents.Beat_plan__c;
                    bb.Event_Type__c = 'P';
                    system.debug('bb.Event_Type__c3==>'+bb.Event_Type__c);
                    beatPlanToBeupdated.add(bb);
                }
                else{
                    
                    if(newlyApprovedevents.Subject == 'Holiday'){
                        Beat_plan__c bb = new Beat_plan__c();
                        bb.id = newlyApprovedevents.Beat_plan__c;
                        bb.Event_Type__c = 'PH';
                        system.debug('bb.Event_Type__c6==>'+bb.Event_Type__c);
                        beatPlanToBeupdated.add(bb);
                        
                    }
                    
                    
                }
            }
        }
        system.debug('beatPlanToBeupdated==='+beatPlanToBeupdated);
        update beatPlanToBeupdated;
        
    }
    
    
    @AuraEnabled
    public static boolean updateEvents(List<Event> editedAccountList)
     
    {            
        //System.debug('Evts Recvd-->'+editedAccountList);
        try{
            update editedAccountList;
            return true;
            //list<event> evlist = new list<event>();
            
            
        } catch(Exception e){
            System.debug('IN ActivitiesLstVwCon.cls-->Exception-->'+e.getMessage()+' at Line-->'+e.getLineNumber());
            return false;
        }
        
        
    }
    
}