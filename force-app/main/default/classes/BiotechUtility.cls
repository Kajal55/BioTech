public inherited sharing class BiotechUtility {
    
    private static Blob aesKey; // Used to Store Generated "AESKEY" in encryption and then the same will be used in Decrpytion.
    
    public static void getSobjectDetailFromId(Id recId){
        Sobject sobj = recId.getSobjectType().newSObject(recId);
        //System.debug('Sobject Details1-->'+sobj);
        //Database.DeleteResult deleteresult = Database.delete(sobj);
        //System.debug('DELETE Result-->'+deleteresult);
        
    	BiotechUtility bio = new BiotechUtility();
        Schema.SObjectType sobj2 = bio.getSobjectFromId(recId); //Displays Sobject Name
        //delete sobj2;
        System.debug('Sobject Details2-->'+sobj2);
    }
        
    private Schema.SObjectType getSobjectFromId (Id recordId){
            Schema.SObjectType sobjectType = recordId.getSObjectType();
            return sobjectType;
            //sobjectName = sobjectType.getDescribe().getName();       
    }
    public static list<SelectOption> getPicklistValues (String objApiName, String fieldName){
        List<SelectOption> options = new  List<SelectOption>();
        String[] types = new String[]{objApiName};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()){
                    options.add(new SelectOption(entry.getLabel(), entry.getValue()));
                }
            }
        }                                                        
        return options;
    }
    
    //This method returns "Email" address stored in CustomMetadataType-->"BranchLocationWiseEmail__mdt" by branch location(city)
    // Note: DeveloperName of CMDT and Picklist Val of Acc's "Branch__c" field needs to be same to get email address from CMDT.
    public static String getEmailByBranchLocation(String branchLocation){
        if(String.isNotBlank(branchLocation)){
            System.debug('ZZ In BiotechUtility Cls-->getEmailByBranchLocation_M-->branch Location -->'+branchLocation);
            List<BranchLocationWiseEmail__mdt> branchData =   [ SELECT Email__c 
                                                               FROM BranchLocationWiseEmail__mdt 
                                                               WHERE DeveloperName =: branchLocation 
                                                               LIMIT 1 
                                                              ];
            System.debug('ZZ In BiotechUtility Cls-->getEmailByBranchLocation_M-->fetched Branch CMDT VAl -->'+branchData);
            if(!branchData.isEmpty()){
                if(branchData[0].Email__c != '' && branchData[0].Email__c != null){
                    return branchData[0].Email__c;
                }else{
                    return null;
                }    
            }else{
                return null;
            } 
            
        }else{
            return null;
        }
    }
    
    
    //Not used instead new method for encryption/decryption is added in AccountTriggerHandler.cls 
    //And also below custom metadata is not used instead custom setting is used
    /*public static Blob encryptData(Blob data){
try{
EncryptionConfigData__mdt encDataConfig = [Select IV__c,Key__c,Algorithm_Name__c 
FROM EncryptionConfigData__mdt
WHERE DeveloperName = 'Encryp_Decryp_Data'
LIMIT 1
];
If(encDataConfig != null){
Blob ivValue = Blob.valueOf(encDataConfig.IV__c);
Blob keySize = Crypto.generateAesKey(Integer.valueOf(encDataConfig.Key__c));
aesKey = keySize;
System.debug('IV-->'+ivValue);
System.debug('Key-->'+Integer.valueOf(encDataConfig.Key__c));
System.debug('Blob Key-->'+keySize);
System.debug('Algo-->'+encDataConfig.Algorithm_Name__c);

//Blob dataToEncrypt = Blob.valueOf(data);
Blob encryptedData = Crypto.encrypt(encDataConfig.Algorithm_Name__c, keySize, ivValue, data);
Blob dData = Crypto.decrypt(encDataConfig.Algorithm_Name__c, keySize, ivValue, encryptedData);
System.debug('In EN_M-->DECRYPTED DATA-->'+dData.toString());
return encryptedData;
}

return null;       
}catch(Exception e){
System.debug('ZZ In BiotechUtility Cls-->encryptData_M-->Exception-->'+e.getMessage()+' at Line-->'+e.getLineNumber());
return null; 
}

}*/
    
    //Not used instead new method for encryption/decryption is added in AccountTriggerHandler.cls
    //And also below custom metadata is not used instead custom setting is used.
    /*public static String decryptData(Blob dataToDecrypt){
try{
EncryptionConfigData__mdt decConfigData = [Select IV__c,Key__c,Algorithm_Name__c 
FROM EncryptionConfigData__mdt
WHERE DeveloperName = 'Encryp_Decryp_Data'
LIMIT 1
];
If(decConfigData != null){
Blob decIvValue = Blob.valueOf(decConfigData.IV__c);
Blob decKeySize = Crypto.generateAesKey(Integer.valueOf(decConfigData.Key__c));
//System.debug('Dec IV-->'+decIvValue.toString());
//System.debug('Dec Key-->'+Integer.valueOf(decConfigData.Key__c));
//System.debug('Dec Blob Key-->'+decKeySize.toString());
//System.debug('Dec Data-->'+dataToDecrypt);
//System.debug('Dec Algo-->'+decConfigData.Algorithm_Name__c);

//paasing The Unique generated "aeskey" in encryption Method for decryption
Blob decryptedData = Crypto.decrypt(decConfigData.Algorithm_Name__c, decKeySize, decIvValue, dataToDecrypt);
System.debug('Decrytpdata-->'+decryptedData.toString());
return decryptedData.toString();
}

return null;       
}catch(Exception ex){
System.debug('STACK TRACE-->'+ex.getStackTraceString()); 
System.debug('ZZ In BiotechUtility Cls-->decryptData_M-->Exception-->'+ex.getMessage()+' at Line-->'+ex.getLineNumber());
return null; 
}

}*/
    
    /*
@Description: This method will give upto three level of Approvers(Managers) for a User.
*/
    
    public static List<Id> getApprovers(String accOwnerId){
        List<Id> approverIds = new List<Id>();
        try{
            List<User> accOwner = [SELECT Id,Name,User_Type__c,UserRole.Name,ProfileId,Profile.Name,ManagerId,Manager.Name,Manager.UserRole.Name,Manager.Profile.Name,Manager.ManagerId,Manager.Manager.Name,Manager.Manager.UserRole.Name,Manager.Manager.ManagerId,Manager.Manager.Manager.Name,Manager.Manager.Manager.UserRole.Name
                                   FROM USER
                                   WHERE Id =: accOwnerId
                                  ];
            System.debug('ZZZ In BiotechUtility.cls-->getApprover_M-->Owner Details-->'+accOwner[0].Name+'owner userrole-->'+accOwner[0].UserRole.Name);
            System.debug('ZZZ In BiotechUtility.cls-->getApprover_M-->Owner Managers UsrRole-->'+accOwner[0].Manager.UserRole.Name);
            System.debug('ZZZ In BiotechUtility.cls-->getApprover_M-->Owner User Type-->'+accOwner[0].User_Type__c);
            if(accOwner[0].User_Type__c == Constants.USER_USERTYPE_DOMESTIC && accOwner[0].Manager == null){
                approverIds.add(BiotechUtility.getDomesticAdminUserId()[0].Id); //Adding DomAdmin as first Approver.
                return approverIds;
            }else if(accOwner[0].User_Type__c == Constants.USER_USERTYPE_TURKEY && accOwner[0].Manager == null){
                approverIds.add(BiotechUtility.getTurkeyAdminUserId()[0].Id); // Setting 1st Approver as Admin_Turkey user
                return approverIds;
            }else if(accOwner[0].User_Type__c == Constants.USER_USERTYPE_INTERNATIONAL && accOwner[0].Manager == null){
                approverIds.add(BiotechUtility.getIntAdminUserId()[0].Id); // Setting 1st Approver as Admin_Int user 
                return approverIds;
            }else{
                
                if (accOwner[0].User_Type__c == Constants.USER_USERTYPE_DOMESTIC){
                    
                    String ownersManagerRole = accOwner[0].Manager.UserRole.Name;
                    if(ownersManagerRole.containsIgnoreCase('DM')){
                        System.debug('ZZZ In BiotechUtility.cls-->getApprover_M-->Inside If-->When DM!!!');
                        List<User> usersDM = [Select Id,Name,UserRole.Name,ProfileId,Profile.Name,ManagerId,Manager.Name,Manager.Profile.Name,Manager.ManagerId,Manager.Manager.Name,Manager.Manager.UserRole.Name,Manager.Manager.ManagerId,Manager.Manager.Manager.Name,Manager.Manager.Manager.UserRole.Name
                                              FROM User
                                              WHERE Id=: accOwner[0].ManagerId                    
                                             ];
                        
                        //System.debug('ZZZ In BiotechUtility.cls-->getApprover_M-->userWithDM-->'+usersDM);
                        if(!usersDM.isEmpty()){
                            approverIds.add(usersDM[0].Manager.Id);  // Setting Approver 1 (DM's Manager--> RSM)
                            approverIds.add(usersDM[0].Manager.Manager.Id);  // Setting Approver 2 (RSM's Manager--> ZSM)
                            approverIds.add(usersDM[0].Manager.Manager.Manager.Id);  // Setting Approver 3 (will be RH)
                        }
                        
                        return approverIds;   
                    }else{
                        System.debug('ZZZ In BiotechUtility.cls-->getApprover_M-->Inside If-->When No DM!!!');
                        approverIds.add(accOwner[0].Manager.Id);  // Setting Approver 1 (will be RSM)
                        approverIds.add(accOwner[0].Manager.Manager.Id);  // Setting Approver 2 (will be ZSM)
                        approverIds.add(accOwner[0].Manager.Manager.Manager.Id);  // Setting Approver 3 (will be RH)
                        
                        return approverIds;
                    }
                    
                }else if (accOwner[0].User_Type__c == Constants.USER_USERTYPE_TURKEY){
                    approverIds.add(accOwner[0].ManagerId); // Setting Approver1 Immediate Manager Of Acc Owner 
                    approverIds.add(BiotechUtility.getTurkeyAdminUserId()[0].Id); // Setting Approver2 as Admin_Turkey user
                    System.debug('ZZ In BiotechUtility Cls-->getApprovers_M-->When Turkey UserRoles -->ret userIds-->'+approverIds);
                    
                    return approverIds; 
                }else if (accOwner[0].User_Type__c == Constants.USER_USERTYPE_INTERNATIONAL){
                    approverIds.add(accOwner[0].ManagerId); // Setting Approver1 Immediate Manager Of Acc Owner (Which will be RBM_OP in this case)
                    approverIds.add(BiotechUtility.getIntAdminUserId()[0].Id); // Setting Approver2 as Admin_Int user
                    System.debug('ZZ In BiotechUtility Cls-->getApprovers_M-->When SS_RBM-->ret userIds-->'+approverIds);
                    
                    return approverIds;
                }else{
                    // No Usertype on user
                    System.debug('ZZZ In BiotechUtility.cls-->getApprover_M-->Inside ELSE-->No UserType!! !!!');
                    
                    
                    approverIds.add(accOwner[0].Manager.Id); 
                    approverIds.add(accOwner[0].Manager.Manager.Id); 
                    approverIds.add(accOwner[0].Manager.Manager.Manager.Id); 
                    
                    return approverIds;
                }
                
            }
        }catch (Exception excp){
            System.debug('ZZ In BiotechUtility Cls-->getApprovers_M-->Exception-->'+excp.getMessage()+' at Line-->'+excp.getLineNumber());
            return null;
        }
        
    }
    
    /*public static List<User> getIntSalesHeadId(){
List<User> users = new List<User>();
List<User> salesHeadUser = [Select Id,Name,UserRole.Name,ProfileId,Profile.Name,ManagerId,Manager.Name,Manager.Profile.Name,Manager.ManagerId
FROM User
Where UserRole.Name = 'SH/CH'
Limit 1
];
if(test.isrunningtest())
salesHeadUser = [Select Id,Name,UserRole.Name,ProfileId,Profile.Name FROM User
Limit 1];


if(!salesHeadUser.isEmpty()){
users.add(salesHeadUser[0]);
return users;
}else{
return null;
}



}*/
    public static List<User> getDomesticAdminUserId(){
        List<User> users = new List<User>();
        List<User> adminUser =     [Select Id,Name
                                    FROM User
                                    Where UserRole.DeveloperName =: Constants.ACCOUNT_DOM_ADMINROLENAME
                                    Limit 1
                                   ];
        
        if(!adminUser.isEmpty()){
            users.add(adminUser[0]);
            return users;
        }else{
            return null;
        }
        
    }
    public static List<User> getIntAdminUserId(){
        List<User> users = new List<User>();
        List<User> adminUser =     [Select Id,Name
                                    FROM User
                                    Where UserRole.DeveloperName =: Constants.ACCOUNT_INT_ADMINROLENAME
                                    Limit 1
                                   ];
        
        if(!adminUser.isEmpty()){
            users.add(adminUser[0]);
            return users;
        }else{
            return null;
        }
        
    }
    
    public static List<User> getTurkeyAdminUserId(){
        List<User> users = new List<User>();
        List<User> adminUser =     [Select Id,Name
                                    FROM User
                                    Where UserRole.DeveloperName =: Constants.ACCOUNT_TURKEY_ADMINROLENAME
                                    Limit 1
                                   ];
        
        if(!adminUser.isEmpty()){
            users.add(adminUser[0]);
            return users;
        }else{
            return null;
        }
        
    }
}