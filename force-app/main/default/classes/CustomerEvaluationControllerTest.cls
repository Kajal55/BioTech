@isTest
public class CustomerEvaluationControllerTest {
 public static Account acc;
         @TestSetup
    static void makeData(){
        
        
        
    }
    
    
     static testmethod void test() { 
           Profile p = [SELECT Id FROM Profile WHERE Name='International Sales'];

           //UserRole r =[SELECT Id,name FROM UserRole WHERE Name='SS_NSM'];
         
          User u1 = new User(Alias = 'newU', Email='newuser123@testorg.com',
                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                      LocaleSidKey='en_US', ProfileId = p.Id,
                      TimeZoneSidKey='America/Los_Angeles', UserName='newuser123@testorg123.com');
         insert u1;
         System.runAs(u1){
          acc =new Account(name='Account', 
                Country_Key__c='IN', City__c='mumbai',City_postal_code__c='400001',Account_Locked__c=true,Status__c='Activated');
                   
        insert acc;
         }
        
        Customer_Evaluation__c cust_eval=new Customer_Evaluation__c(Account__c=acc.Id);
        insert cust_eval;
         
         System.debug('ACC ID::::'+String.valueOf(acc.id));
          System.debug('USER ID name::::'+u1.UserRole.Name);
         String acc_id=String.valueOf(acc.id);
       // Integer acc_id= Integer.valueOf(acc.id);
         CustomerEvaluationController.getLastCE(String.valueOf(acc.id));
         
         //String cust_eval_json='[{"Account__c":"0010l00000amSiMAAU"}]';
         String str = JSON.serialize(cust_eval);
         CustomerEvaluationController.saveCustEvaluation(str);
         
         
     }
     
    // This method should not be in this class. This is creating unnecessary dependency with BiotechUtility class.
     static testmethod void test1() { 
       
         string before = 'Testing base 64 encode';            
         Blob beforeblob = Blob.valueOf(before);
         
         
     }
    
}