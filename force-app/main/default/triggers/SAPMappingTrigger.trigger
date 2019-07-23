//********************
//Name: SAPMappingTrigger
//Purpose : Handles relationship between SAP Line items and Monthly AOP
//Version : 1.0
//********************/

trigger SAPMappingTrigger on SAP_Line_Item__c (before insert,after delete) 
{
    SAPLineHandler.MapSap(trigger.new);  
    if(Trigger.isDelete){
        SAPLineHandler.updateActualAmtOnAOP(trigger.old);      
    }
    
}