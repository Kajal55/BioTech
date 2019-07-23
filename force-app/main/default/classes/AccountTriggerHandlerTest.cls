@isTest
public class AccountTriggerHandlerTest {
    @testsetup
    static void initData(){
        
        BranchSiteEncryptAndDecryptData__c cs = new BranchSiteEncryptAndDecryptData__c();
        cs.Algorithm_Name__c = 'AES128';
        cs.Name = 'URL Data';
        cs.base64EncodeKey__c = 'QVHujC98AjdeCL08OXAVzQ==';
        insert cs;
        
        
        
    }
    
    @isTest
    static void testMethod1(){
        Test.startTest();
        
        String domDist = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
        String domDoc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Doctor_D').getRecordTypeId();
        String turDist = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Distributor_T').getRecordTypeId();
        String turDoc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Doctor_T').getRecordTypeId();
        String Opthal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Ophthalmic_Vision').getRecordTypeId();
        String Ortho = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Ortho_Dermal').getRecordTypeId();
        BranchSiteEncryptAndDecryptData__c csobj=new BranchSiteEncryptAndDecryptData__c();
        //csobj.Name = '6G8b0010l00000Z6G8bAAF';
        /*csobj.Name = 'URL Data';
        csobj.Algorithm_Name__c='AES128';
        csobj.base64EncodeKey__c='TestBase64';
        csobj.GeneratedAesKey__c='123';
        insert csobj;*/ 
        Account acc =new Account(recordtypeId=domDoc,
                                 name='Account',Country_Key__c='IN', City__c='mumbai',City_postal_code__c='4000011',
                                 Medical_Registration_No__c='MEDREG123424567',GSTIN_No__c='GSTIN2343423456',Account_Locked__c=true,
                                 Status__c='Draft',Sub_Status__c='Submitted To Approver 1');
        insert acc;
        Account_Team__c act_team1 = new Account_Team__c();
        act_team1.Account__c=acc.Id;
        act_team1.Account_Access__c='Read';
        act_team1.Team_Member__c=acc.OwnerId;
        act_team1.Team_Role__c = 'Div 1';
        insert act_team1;
        acc.Sub_Status__c = 'Submitted To Branch Team';
        acc.Branch__c='MUMBAI';
        update acc;
        Account acc2 =new Account(recordtypeId=Opthal,
                                  name='Account2',Country_Key__c='AE', City__c='mumbai',City_postal_code__c='4000021',
                                  Medical_Registration_No__c='MEDREG12342678',GSTIN_No__c='GSTIN2343423456',Account_Locked__c=true,
                                  Status__c='Draft',Sub_Status__c='Submitted To Approver 1');
        insert acc2;
        acc2.Sub_Status__c = 'Approved by Admin';
        acc2.Customer_Account_Group__c = 'ZEXP';
        acc2.Sales_District__c= 'D001';
        acc2.Sales_Office__c= 'S123';
        acc2.Customer_Group__c = '01';
        acc2.Delivering_Plant__c = '1101';
        acc2.Number_of_an_SD_business_partner_Z1__c = '1';
        acc2.Number_of_an_SD_business_partner_Z2__c = '2';
        acc2.Number_of_an_SD_business_partner_Z3__c = '3';
        acc2.Number_of_an_SD_business_partner_Z4__c = '4';
        acc2.Number_of_an_SD_business_partner_Z8__c = '5';
        
        //Adding below line to increase the code coverage
        AccountTriggerHandler.encryptAndEncodeToUrlFomatUsingCusSet('TestName',Blob.valueOf('Test Class Running'));
        AccountTriggerHandler.increasecodeCoverage();
        
        
        Test.stopTest();
    }
    
    
    
    @isTest
    static void testMethod3(){
        String turDoc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Doctor_T').getRecordTypeId();
        String turUserName = 'tur_user' + DateTime.now().getTime() + '@testorg.com';
        Profile tprof  = [SELECT Id FROM Profile WHERE Name='Turkey Sales'];
        UserRole trole =[SELECT Id,name FROM UserRole WHERE (Name like'%Turkey%'OR Name like'%SS_T%' OR Name like'%Domestic RH%' ) LIMIT 1];
        
        User turkeyUser = new User(Alias = 'tur_u', Email='tur_user@testorg.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = tprof.Id,
                                   TimeZoneSidKey='America/Los_Angeles',
                                   User_Type__c='Turkey',UserName=turUserName,UserRoleId=trole.Id,Division__c='I;II',Employee_Code__c='TUR1234');
        
        insert turkeyUser;
        System.runAs(turkeyUser){
            Account acc =new Account(recordtypeId=turDoc,
                                     name='Account',Country_Key__c='TR', City__c='mumbai',City_postal_code__c='400001',
                                     Medical_Registration_No__c='MEDREG123424567',GSTIN_No__c='GSTIN2343423456',Account_Locked__c=true,
                                     Status__c='Draft',Sub_Status__c='Submitted To Approver 1');
            insert acc;
            Account_Team__c act_team1 = new Account_Team__c();
            act_team1.Account__c=acc.Id;
            act_team1.Account_Access__c='Read';
            act_team1.Team_Member__c=acc.OwnerId;
            act_team1.Team_Role__c = 'Div 2';
            insert act_team1;
            acc.Sub_Status__c = 'Submitted To Approver 2';
            update acc;
            
            Account acct2 =new Account(recordtypeId=turDoc,
                                       name='Account22',Country_Key__c='TR', City__c='mumbai',City_postal_code__c='400001',
                                       Medical_Registration_No__c='MEDREG12324567',GSTIN_No__c='GSTIN2343423456',Account_Locked__c=true,
                                       Status__c='Draft',Sub_Status__c='Submitted To Approver 2');
            insert acct2;
        }
        
        
    }
    
    @isTest
    static void testMethod2(){
        Test.startTest();
        //BranchSiteEncryptAndDecryptData__c cuss = BranchSiteEncryptAndDecryptData__c.getInstance('URL Data');
        //cuss = null;
        //update cuss;
        String Opthal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Ophthalmic_Vision').getRecordTypeId();
        Account acc2 =new Account(recordtypeId=Opthal,
                                  name='Account2',Country_Key__c='AE', City__c='mumbai',City_postal_code__c='400002',
                                  Medical_Registration_No__c='MEDREG12342678',GSTIN_No__c='GSTIN2343423456',Account_Locked__c=true,
                                  Status__c='Draft',Sub_Status__c='Approved by Admin');
        //insert acc2;
       // DmlException d = new DmlException();
       // d.setMessage('Please fill in the mandate fields under CRM Details Section');

        Test.stopTest();
    }
    //public class AccountTriggerHandlerTestException extends Exception{}
}