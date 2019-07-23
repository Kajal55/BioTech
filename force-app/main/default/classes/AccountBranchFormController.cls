public class AccountBranchFormController {
    public Account acc {get; set; }
    public String accntId {get; set; }
    
    public AccountBranchFormController(){
        String accId =  ApexPages.currentPage().getParameters().get('id'); // URL Encoded and Encrypted String
        System.debug('ZZZ In AccountBranchFormController.cls-->In Constructor-->Val of passes Acc Id-->'+accId);
        
        if(String.isNotBlank(accId)){
            // Using Custom Setting to get 'AlogrithName' and 'Key' For Decryption.
            BranchSiteEncryptAndDecryptData__c urlDataCs = BranchSiteEncryptAndDecryptData__c.getInstance('URL Data'); //This cus setting name is generated while encryption in AccountTriggerHandler.cls
            String AlgoName = urlDataCs.Algorithm_Name__c;
            String base64EncodedBlobString = urlDataCs.base64EncodeKey__c;
            Blob key =  EncodingUtil.base64Decode(base64EncodedBlobString); // Converting Key to original Blob Form For Decryption
            System.debug('ZZZ In AccountBranchFormController.cls-->In Constructor-->Val of CusSet-->'+urlDataCs);

            Blob blobData = EncodingUtil.base64Decode(accId); // you can also 'URLDecode' this accId before Converting.
            Blob decryptedBlob = Crypto.decryptWithManagedIV(AlgoName, key, blobData);      
            string decodedId = decryptedBlob.toString();
            System.debug('ZZZ In AccountBranchFormController.cls-->In Constructor-->DECRYPTED Acc Id-->'+decodedId);
            this.accntId = decodedId;
        }
        
    }
    
    //
    @AuraEnabled
    public Static List<Branch_Data__c> branch_details(String branchID){
        
   List<Branch_Data__c> BranchList=new List<Branch_Data__c>();
  
    
       BranchList=[select Sales_District__c,Region_Code__c,Plant__c
                   from Branch_Data__c 
                   where
                   Region_Code__c=:branchID];
        
        system.debug('stateList'+BranchList);
        
        if (BranchList.size() > 0)
        {
            BranchList.sort();
            
            for(Branch_Data__c branch : BranchList)
            {
                
              // StateCodeList.add( new SelectOption(branch.Sales_District__c) );
               // system.debug(statecodeList);
            }  
        }
        
        
        return BranchList;
    }
    
      @AuraEnabled
    public Static Account getAccount(String accId){
        return [Select Id,Name,Phone,BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry,Type,Company_Code__c,Customer_Account_Group__c, Customer_Group__c,Distributor_Channel__c,Industry_Key__c,Rating,Division__c,Status__c,Sub_Status__c,IsBranchedApproved__c,Account_Assignment_Group__c,Approver1_Profile_Name__c,Approver2_Profile_Name__c,City__c,
                Company_Name__c,Contact_Person__c,Country_Key__c,Delivery_Priority__c,E_Mail__c,First_mobile_telephone_no__c,First_Telephone_No__c,GSTIN_No__c,Medical_Registration_No__c,Reconciliation_Account_GL__c,Sales_Office__c,Street_2__c,Street_3__c,Street_4__c,Street_5__c,
                Terms_Of_Payment_Key__c,region__c,City_postal_code__c,Owner.name,Owner.Employee_Code__c,Owner.Profile.Name,Owner.UserRole.Name,SOP_B_Customer_Type__c,SOP_NB_Customer_Type__c,
                SOP_B_Total_Customer_Mapped__c,SOP_B_Account_Overdue__c,SOP_B_Percentage_Of_Overdue__c,SOP_B_Collection_List__c,SOP_B_Overdue_Account_List__c,SOP_B_Percentage_Of_List_Overdue__c,SOP_B_Gross_Sales__c,SOP_B_GRN_Value__c,SOP_B_Percentage_Max_Limit__c,SOP_NB_Total_Customer_Mapped__c,SOP_NB_Account_Overdue__c,SOP_NB_Percentage_Of_Overdue__c,SOP_NB_Collection_List__c,SOP_NB_Overdue_Account_List__c,SOP_NB_Percentage_Of_List_Overdue__c,SOP_NB_Gross_Sales__c,SOP_NB_GRN_Value__c,SOP_NB_Percentage_Max_Limit__c,
                Delivering_Plant__c,Pricing_Procedure_Assigned__c,Sales_District__c,Tax_Classification__c,Currency__c,Region_Code__c,No_Of_Customer_Mapped_SAP__c,No_Of_Account_Overdue__c,region__r.name
                
                From Account
                WHERE Id=: accId
                Limit 1];
    }
    
    @AuraEnabled
    public Static void saveAccount(Account acc){
        update acc;    
    }
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
 
    ////
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;
        
        return oAttachment.Id;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
    
    //Added for dependent picklist-- 28 May2019
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
}