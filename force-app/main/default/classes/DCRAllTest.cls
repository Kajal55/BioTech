/********************************************************************************
Author : Prashant Rana
Description : This is the test class for DCR and Mobile App
Date : 01-01-2019
********************************************************************************/
@isTest
public class DCRAllTest {
    
    @TestSetup
    static void makeData(){

       beat_Plan__c beatobj = new beat_Plan__c();
       beatobj.beat_date__c = date.today();
       insert beatobj;
       
       CIty__c robj = new CIty__c();
       robj.country_key__c = 'IN';
       robj.Name = 'Maharashtra';
       robj.Region_Code__c = '24';
       insert robj;

       Account accObj = new Account();
       accObj.Name = 'Test';
       accObj.AccountNumber = '12345678';
       accObj.Region__c = robj.Id;
       accObj.Street_2__c = 'street2';
       accObj.Street_3__c = 'street3';
       accObj.Street_4__c = 'street4';
       accObj.Street_5__c = 'street5';
       accObj.Country_Key__c='IN';
       accObj.City__c='Mumbai';
       accObj.City_postal_code__c='400001';
       accObj.Medical_Registration_No__c = '123';
       accObj.GSTIN_No__c = 'AF122345678912F';
       insert accObj;


       event obj = new event();
       obj.subject = 'test';
       obj.startDateTime = system.now();
       obj.endDateTime = System.now().addDays(1);
       obj.Beat_Plan__c = beatobj.id;
       obj.Checkout__Latitude__s = 77.0000;
       obj.Checkout__Longitude__s = 24.0000;
       obj.whatId = accObj.id;
       insert obj;

        Product__c pobj = new Product__c();
        pobj.Dummy_Product_Code__c = '123';
        insert pobj;

    }
    /*
    Class to Cover : DailyCallRecordController
    Coverage : 90%
    */
    public static testmethod void dailyCallrecord(){
      
      test.startTest();
      Account accObj = [select id , name, ownerId from Account];
      Event obj = [select id from event];
       DailyCallRecordController.getUserData(accObj.OwnerId);
       DailyCallRecordController.returnHomePage();
       DailyCallRecordController DCRobj = new DailyCallRecordController();
       DCRobj.accountData = JSON.serialize(accObj);
       DCRobj.eventData = JSOn.serialize(obj);
      
      
      string request = '[{"subject":"subject","date":"2019-10-10","startTime":"10:00","endTime":"11:00","ownerId":"","callType":"OT","relatedTo":"'+accObj.Id+'","isJoint":false,"remarkDoctor":"","marketInfo":"","remarkTender":"","surgery":"","pmsCollected":"","contact":"","doctorVisit":"","address":"", "name":"","nextVisitPlanning":"","employeeName":"test data","toPlace":"test data","fromPlace":"test data","month":"9","week":"6","dayTravel":"89", "ToDate":"2019-01-02","country":"india","FromDate":"2019-02-01","description":"test","product":"600"}]';
      map<string,object> r1 = new map<string,object>();
        r1.put('eventId',obj.Id);
        r1.put('date','2019-10-10');
        r1.put('startTime','11:00');
        r1.put('endTime','11:05');
        r1.put('status', 'submitAndSave');
        r1.put('product', '600');
        r1.put('folloUpDate', '');
        r1.put('description', '');
        DailyCallRecordController.createNewEvents(request);
        DailyCallRecordController.updateEvent(r1);
        DailyCallRecordController.deleteEvent(obj.Id);
      test.stopTest();
      
    }

    /*********************************************************************************
    Class to Cover : BeatPlanMapPageController
    Coverage : 85%
    *********************************************************************************/
    @IsTest
    static void BeatPlanMapPageController(){
        
        Test.startTest();
        Event obj = [select id from Event];
        BeatPlanMapPageController beatPlanObj = new BeatPlanMapPageController();
        Map<String,Object> startDayMap = new Map<String,Object>{
            'UserLatitude' => 77.288,
            'UserLongitude'=> 24.000
        };
        Map<String,Object> mapData = new Map<String,Object>{
            'CheckInLat'=>77.23546,
            'CheckInLong'=>77.8768,
            'eventId'=>obj.id
        };
        Map<String,Object> updateMap = new Map<String,Object>{
            'startTime'=>'11:20',
            'endTime'=>'11:32',
            'reason'=>'testreason',
            'date'=>'2019-02-02',
            'eventId'=>obj.Id
        };
        BeatPlanMapPageController.startMyDay(startDayMap);
        BeatPlanMapPageController.endMyDay(startDayMap); 
        BeatPlanMapPageController.checkInMethod(mapData);
        BeatPlanMapPageController.checkOutMethod(mapData);
        BeatPlanMapPageController.updateCancelEvent('cancel', updateMap);
        Test.stopTest();
        
    }

    /******************************************************************************************
    Class to Cover : BeatPlanSecondAppPageController
    Coverage : 90%
    *******************************************************************************************/

    @IsTest
    static void BeatPlanSecondAppPageController(){
        
        Test.startTest();
        event obj = [select id from Event];
        test.setCurrentPage( new Pagereference('BeatPlanSecondAppPage'));
        System.currentPageReference().getParameters().put('id', obj.Id);
        BeatPlanSecondAppPageController beatSecond = new BeatPlanSecondAppPageController();
        Map<String,Object> dataMap = new Map<String,Object>{
            'remark'=>'test',
            'followUpDate'=>'2019-02-02',
            'eventId'=>obj.id,
            'product'=>'600'
        };
        Map<String,Object> mapData = new Map<String,Object>{
            'CheckInLat'=>77.23546,
            'CheckInLong'=>77.8768,
            'eventId'=>obj.id
        };
        BeatPlanSecondAppPageController.checkOutMethod(mapData);
        BeatPlanSecondAppPageController.saveDCR(dataMap);
        BeatPlanSecondAppPageController.submitDCR(dataMap);
        Test.stopTest();
        
    }
}