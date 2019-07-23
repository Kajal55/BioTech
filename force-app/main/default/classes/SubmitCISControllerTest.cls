@isTest
public class SubmitCISControllerTest {
    // public static Account acc;
    //public static CIS_Header__c cis_head;
    @TestSetup
    static void makeData(){
        
    }
    
    static testmethod void test() {   
        
        Account acc =new Account(name='Account',  Country_Key__c='IN', City__c='mumbai',City_postal_code__c='400001',Account_Locked__c=false,Status__c='Activated');
        acc.Medical_Registration_No__c = '123456789';
        acc.GSTIN_No__c='GSTIN2343423456';
        insert acc;
        
        Customer_Evaluation__c cust_eval=new Customer_Evaluation__c(Account__c=acc.Id,Year__c='2019',Status__c='Approved');
        insert cust_eval;
        
        CIS_Header__c cis_head=new CIS_Header__c(Account__c=acc.Id,Year__c='2019',Month__c='Apr');
        insert cis_head;
        
        SubmitCISController.getBudgetOptions(String.valueOf(acc.Id),String.valueOf(cis_head.Id));
        
        
        
        
        List<CIS_Line__c> cis_line=new List<CIS_Line__c>();
        cis_line.add(new CIS_Line__c(CIS_Header__c=cis_head.Id,Company__c='Biotech'));
        insert cis_line;
        CIS_Line__c cis_line1=cis_line.get(0);
        SubmitCISController.CISLineItem cs_line_item=new SubmitCISController.CISLineItem(cis_line1,true);
        
        SubmitCISController.CISWrapper wrapper=new SubmitCISController.CISWrapper('1000',cis_line,true);
        
        List<SubmitCISController.CISWrapper> wrapper_list=new List<SubmitCISController.CISWrapper>();
        wrapper_list.add(wrapper);
        //JSON.serialize(cis_head);
        SubmitCISController.saveCISRecord(JSON.serialize(wrapper_list),String.valueOf(acc.Id),'',String.valueOf(cis_head.Id));
        SubmitCISController.approveCISRecord(String.valueOf(cis_head.Id),'test status','test comment');
        
        
        delete cis_head;
        //  SubmitCISController.getBudgetOptions(String.valueOf(acc.Id),null);
    }
    static testmethod void test1() {   
        Account acc =new Account(name='Account',  Country_Key__c='IN', City__c='mumbai',City_postal_code__c='400001',Account_Locked__c=false,Status__c='Activated');
        acc.Medical_Registration_No__c = '123456789';
        acc.GSTIN_No__c='GSTIN2343423456';
        insert acc;
        CIS_Header__c cis_head=new CIS_Header__c(Account__c=acc.Id,Year__c='2019',Month__c='Apr');
        insert cis_head;
        SubmitCISController.getBudgetOptions(String.valueOf(acc.Id),null);
    }
    static testmethod void test2() {   
        Account acc =new Account(name='Account',  Country_Key__c='IN', City__c='mumbai',City_postal_code__c='400001',Account_Locked__c=false,Status__c='Activated');
        acc.Medical_Registration_No__c = '123456789';
        acc.GSTIN_No__c='GSTIN2343423456';
        insert acc;
        // CIS_Header__c cis_head=new CIS_Header__c(Account__c=acc.Id,Year__c='2019',Month__c='Apr');
        //insert cis_head;
        SubmitCISController.getBudgetOptions(String.valueOf(acc.Id),null);
    }
}