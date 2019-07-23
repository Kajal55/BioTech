@isTest
public class ActivitiesListViewControllerTest {
    
    @TestSetup
    static void makeData(){
        Account acc=new Account(name='Account', 
                                Country_Key__c='IN', City__c='mumbai',City_postal_code__c='400001',Account_Locked__c=false,Status__c='Activated',GSTIN_No__c='GSTIN2343423456');
        insert acc;
        
        Lead lead1=new Lead(Lastname='Lead test', 
                            Status='New', Company='abcd');
        insert lead1;
        
        event obj = new event();
        obj.subject = 'test event';   
        obj.startDateTime = system.now();
        obj.endDateTime = System.now().addDays(1);
        obj.whatid  = acc.id;
        // obj.whoId=lead1.id;
        insert obj;
        
        event obj1 = new event();
        obj1.subject = 'test event';   
        obj1.startDateTime = system.now();
        obj1.endDateTime = System.now().addDays(1);
        // obj.whatid  = acc.id;
        obj1.whoId=lead1.id;
        insert obj1;
        
        Account_Team__c scc_team=new Account_Team__c(Account__c=acc.Id);
        insert scc_team;
        
    }
    public static testmethod void methodName(){
        List<Event> test_events= ActivitiesListViewController.getEvents();
        ActivitiesListViewController.updateEvents(test_events);
    }
}