/***********************************************************************************************************
Author : Prashant Rana
Description : This class will take care for after checkin part from mobile app
Date : 01-01-2019
************************************************************************************************************/
global with sharing class BeatPlanSecondAppPageController {
    public String eventData{get;set;}
    public string lastFiveInvoicesList{get;set;}
    public string productList{get;set;}
    public user userObj{get;set;}
    public DCR_Detail2_Translation__c translationObject{get;set;}

    //Constructor
    global BeatPlanSecondAppPageController() {
        try {
            translationObject= DCR_Detail2_Translation__c.getValues(UserInfo.getLanguage()); 
            if(translationObject== null){
                translationObject= DCR_Detail2_Translation__c.getValues('en_US');
            }
            id eventId = apexpages.currentpage().getparameters().get('id');
            System.debug('event id on page : '+eventId);
            event eventObj = [select subject,product__c,DCR_Description__c, Call_Type__c,CE_Rating__c,CIS_Rating__c, Account__r.Name,Who.Name from event where Id=:eventId limit 1];
            System.debug('event record : '+eventObj);
            String ev = JSON.serialize(eventObj);
            eventData = ev.escapeUnicode().remove('\'');
            List<SAP_Line_Item__c> SAPList = [select Dummy_Product_Code__c, Product__r.Name,Amount__c,Quantity__c from SAP_Line_Item__c where Monthly_Product_Plan__r.Monthly_Plan__r.Account__c =:eventObj.Account__c ORDER By CreatedDate DESC limit 5];
            if(!SAPList.isEmpty()){
                String sap = JSON.serialize(SAPList);
                lastFiveInvoicesList = sap.escapeUnicode().remove('\'');
            }
            userObj = [select id, name, profileId,User_Type__c from user where id =: userInfo.getUserId() limit 1];
            list<product__c> prodList = [select name from Product__c where region__c =: userObj.user_Type__c AND MSP__c !=null AND MSP__c != 0 order by Name ASC];
            if(!prodList.isEmpty()){
                String pes = JSON.serialize(prodList);
                productList = pes.escapeUnicode().remove('\'');
            }
            system.debug('Orders ANd invoices : '+lastFiveInvoicesList);
        } catch (Exception  e) {
           System.debug('error in constructor : '+e.getMessage()+' At line no : '+e.getLineNumber());
        } 
    }

    // This method for save the DCR
    @RemoteAction
    global static string saveDCR(map<string, Object> dataMap){
        try {
           System.debug('Request in save dcr : '+dataMap);
           event eventObj = new Event();
               eventObj.Id = dataMap.get('eventId').toString();
               if(dataMap.get('followUpDate') !=''){
                   string[] dateArr = dataMap.get('followUpDate').toString().split('-');
                   eventObj.Follow_Up_Date__c = Date.newInstance(Integer.valueOf(dateArr[0]),Integer.valueOf(dateArr[1]),Integer.valueOf(dateArr[2]));
               }
               if(dataMap.get('product') !=''){
                    eventObj.product__c = dataMap.get('product').toString();
                    system.debug(eventObj.product__c);
                }
               eventObj.Status__c = 'Draft';
               eventObj.DCR_Description__c = dataMap.get('remark').toString();
               eventObj.Stage__c = 'Checked‐In';
           
           update eventObj;
           if(dataMap.get('remark') !=''){
               event ev = [select id, account__c from event where Id = :eventObj.id limit 1];
                Note noteObj = new Note();
                noteObj.parentId = ev.Account__c;
                noteObj.title = 'DCR SAVED =>'+date.today();
                noteObj.body = dataMap.get('remark').toString();
                insert noteObj;
           }
        } catch (Exception e) {
           system.debug('error in saving the DCR : '+e.getMessage()+', At line no : '+e.getLineNumber());
           return e.getMessage();
        }
        return 'SUCCESS';
    }

    //This method will submit the DCR for approval
    @remoteAction
    global static string submitDCR(Map<String,Object> dataMap){
        try{
            system.debug('Request in submit dcr : '+dataMap);
            event eventObj = new Event();
               eventObj.Id = dataMap.get('eventId').toString();
               if(dataMap.get('followUpDate') !=''){
                  string[] dateArr = dataMap.get('followUpDate').toString().split('-');
                  eventObj.Follow_Up_Date__c = Date.newInstance(Integer.valueOf(dateArr[0]),Integer.valueOf(dateArr[1]),Integer.valueOf(dateArr[2]));
               }
               eventObj.DCR_Description__c = dataMap.get('remark').toString();
               eventObj.Status__c = 'Sent for Approval';
               eventObj.event_Locked__c = true;
               if(dataMap.get('product') !=''){
                    eventObj.product__c = dataMap.get('product').toString();
                }
               eventObj.Stage__c = 'Checked‐In';
           update eventObj;
           if(dataMap.get('remark') !=''){
               event ev = [select id, account__c from event where Id = :eventObj.id limit 1];
                Note noteObj = new Note();
                noteObj.parentId = ev.Account__c;
                noteObj.title = 'DCR Submitted =>'+date.today();
                noteObj.body = dataMap.get('remark').toString();
                insert noteObj;
           }
        }catch(Exception e){
            system.debug('error in submitting the dcr : '+e.getMessage()+', at line no : '+e.getLineNumber());
            return e.getMessage();
        }
        return 'SUCCESS';
    } 
    //Checkout Method
    @remoteAction
    global static void checkOutMethod(Map<String,Object> mapData){
        try {
           System.debug('request in checkout method : '+mapData);
           string Id = string.valueOf(mapData.get('eventId'));
           event evObj = [select subject ,Event_Latitude__c,Event_Longitude__c,Checkout_Distance__c,Checkout__Latitude__s,
                                         Checkout__Longitude__s ,check_Out_Time__c,check_Out__c,Stage__c from event where id =:Id ];
            System.debug('event in checkout : '+evObj);
           Location loc1 = Location.newInstance(evObj.Event_Latitude__c,evObj.Event_Longitude__c);
           Location loc2 = Location.newInstance((decimal)mapData.get('CheckOutLat'),(Decimal)mapData.get('CheckOutLong'));
           Double dist = Location.getDistance(loc1, loc2, 'km');
           System.debug('locations : '+loc1+','+loc2);
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
    @RemoteAction
    global static string returnHomePage(){
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
}