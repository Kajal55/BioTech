trigger captureAccountAndLead on Event (before insert, before update) {
       list<event> eventList = new List<event>();
       for(event obj : trigger.new){
              if(trigger.isInsert || (trigger.isUpdate && obj.StartDateTime != trigger.oldMap.get(obj.id).StartDateTime)){
                     eventList.add(obj);
              }
       }
       if(!eventList.isEmpty()){
              CaptureAccountAndLeadHelper.updatevent(trigger.new);
       }
       
}