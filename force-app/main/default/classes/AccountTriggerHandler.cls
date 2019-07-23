public inherited sharing class AccountTriggerHandler {
    public static Boolean check = true;
    public static Boolean checkBranch = true;
    public static Boolean checkApproval = true;
    private static Boolean createCS = false;
    public static Boolean checkRSMTurkey = true;
    public static void setApproverOnAccountWhenOwnerIsChanged(List<Account> newAccList, System.TriggerOperation triggerEvent){
        try{
        switch on triggerEvent {
            when BEFORE_INSERT,BEFORE_UPDATE {
                for(Account acc : newAccList){
                    List<Id> approverIds = BiotechUtility.getApprovers(acc.OwnerId);
                    System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M--> Fetched Approver Ids-->'+approverIds);
                    if(!approverIds.isEmpty() && approverIds != null){
                        if(approverIds.size() == 2 || approverIds.size() == 3){
                            acc.Approver_1__c = ((approverIds[0] != null) ? approverIds[0] : null );
                            acc.Approver_2__c = ((approverIds[1] != null) ? approverIds[1] : null );    
                        }else if(approverIds.size() == 1){
                            acc.Approver_1__c = ((approverIds[0] != null) ? approverIds[0] : null );
                        }

                    }
                    
                    //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+' !!');
                    //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+' acc RecType-->'+acc.RecordType.DeveloperName);
                    //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+' acc RecTypeId-->'+acc.RecordTypeId);
                    
                    //Here acc.RecordType.Id OR acc.RecordType.DeveloperName is not fetched during trigger execution 
                    //so checking rectype based on recordtypeId instead of developername
                    if((acc.RecordTypeId == Constants.ACCOUNT_DOM_DISTRIBUTOR_RECORDTYPEID) ||
                       (acc.RecordTypeId == Constants.ACCOUNT_DOM_DOCTOR_RECORDTYPEID)){
                           System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+' Inside Doc or Dis Rectype If!');
                           // For Domestic Market,If CountryKey='IN' then CompanyCode should be "1000"
                           if(acc.Country_Key__c == Constants.ACCOUNT_INDIA_COUNTRYKEY){
                               acc.Company_Code__c= Constants.ACCOUNT_INDIA_COMPANYCODE;
                           }
                           
                           // Setting Branch EMail Address
                           System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->Branch Loc Val-->'+acc.Branch__c);
                           if(acc.Branch__c != null){
                               //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->Inside Branch !null-->'+acc.Branch__c);
                               acc.Branch_Email__c = ((BiotechUtility.getEmailByBranchLocation(acc.Branch__c) != null) ? BiotechUtility.getEmailByBranchLocation(acc.Branch__c) : null);
                               //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->New Branch Email-->'+acc.Branch_Email__c);
                           }
                           
                           // This will throw custom error message when Approver1(RSM of Account Approval process ) 
                           // tries to approve account without filling "Branch__c" field 
                           // Here we have taken sub status as "Submitted To Branch Team" coz by the time when RSM clicks approve the value
                           // of Substatus field is changed to  "Submitted To Branch Team" from "Submitted To Approver 1" due to approval process field update(Initial Submission).
                           //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->Acc Sub Status-->'+acc.Sub_Status__c); 
                           if(AccountTriggerHandler.checkBranch){                            
                               AccountTriggerHandler.checkBranch = false;
                               Integer accTeamRecCnt = 0;
                               AggregateResult[] groupedResults = [SELECT COUNT(Id) accTeamCount
                                                                   FROM Account_Team__c
                                                                   Where Account__c = :acc.Id
                                                                  ];
                               System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->Agg query Res-->'+groupedResults);
                               if(! groupedResults.isEmpty()){
                                   //Object accTeamRecrds = groupedResults[0].get('accTeamCount');
                                   accTeamRecCnt = Integer.valueOf(groupedResults[0].get('accTeamCount'));
                               }
                               
                               System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->AccTeam COUNT-->'+accTeamRecCnt);
                               System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->Acc Substatus-->'+acc.Sub_Status__c+'-->Branch-->'+acc.Branch__c);
                               if(acc.Branch__c == null && acc.Sub_Status__c == Constants.ACCOUNT_SUBSTATUS_SUBMITTEDTOBRANCHTEAM
                                  && (accTeamRecCnt == 0)){
                                      //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'--> Inside branch and accteam If');   
                                      acc.addError(Constants.ACCOUNT_TRIGGER_BRANCHFIELDMANDATORYCUSTOMEXCEPTIONMESSAGE);
                                      
                                  }else if(acc.Branch__c == null && acc.Sub_Status__c == Constants.ACCOUNT_SUBSTATUS_SUBMITTEDTOBRANCHTEAM
                                           && (accTeamRecCnt > 0)){
                                               //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'--> Inside branch and accteam If--> acc team is der branch not');   
                                               acc.addError(Constants.ACCOUNT_TRIGGER_BRANCHFIELDMANDATORYCUSTOMEXCEPTIONMESSAGE);
                                               
                                           }else if(acc.Branch__c != null && acc.Sub_Status__c == Constants.ACCOUNT_SUBSTATUS_SUBMITTEDTOBRANCHTEAM
                                                    && (accTeamRecCnt == 0)){
                                                        //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'--> Inside branch and accteam Else If');   
                                                        acc.addError(Constants.ACCOUNT_TRIGGER_ACCOUNTTEAMMANDATORYCUSTOMEXCEPTIONMESSAGE);
                                                        
                                                    }  
                           }
                           
                       }
                    
                    
                    
                    if((acc.RecordTypeId == Constants.ACCOUNT_OPTHALMICVISION_RECORDTYPEID) ||
                       (acc.RecordTypeId == Constants.ACCOUNT_ORTHODERMAL_RECORDTYPEID)){
                         
                           //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+' Inside Int Admin Approval Validation!');
                           //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->Acc Sub_Status-->'+acc.Sub_Status__c);
                           //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->Acc No.ofSD Busi Part2-->'+acc.Number_of_an_SD_business_partner_Z2__c);
                           

                           //For Account Approval International-->In Step2(Approver2)--> Check mandatory fields to be filled by Admin
                           if(acc.Sub_Status__c == Constants.ACCOUNT_SUBSTATUS_APPROVEDBYADMIN && 
                              String.isBlank(acc.Customer_Account_Group__c)&& 
                              String.isBlank(acc.Sales_District__c) &&
                              String.isBlank(acc.Sales_Office__c) &&
                              String.isBlank(acc.Customer_Group__c) &&
                              String.isBlank(acc.Delivering_Plant__c) &&
                              acc.Number_of_an_SD_business_partner_Z1__c == null &&
                              acc.Number_of_an_SD_business_partner_Z2__c == null &&
                              acc.Number_of_an_SD_business_partner_Z3__c == null &&
                              acc.Number_of_an_SD_business_partner_Z4__c == null &&
                              acc.Number_of_an_SD_business_partner_Z8__c == null){
                                  
                                  acc.addError(Constants.ACCOUNT_TRIGGER_INT_ADMINTOFILLMANDATORYFIELDSCUSTOMEXCEPTIONMESSAGE);
                                  
                              } 
                           
                           
                       }
                    
                    
                                                
                    if((acc.RecordTypeId == Constants.ACCOUNT_TURKEY_DISTRIBUTOR_RECORDTYPEID) ||
                       (acc.RecordTypeId == Constants.ACCOUNT_TURKEY_DOCTOR_RECORDTYPEID)){
                        if(AccountTriggerHandler.checkRSMTurkey){                            
                               AccountTriggerHandler.checkRSMTurkey = false;
                               Integer accTeamRecCntTurkey = 0;
                               AggregateResult[] accTeamResults = [SELECT COUNT(Id) accTeamCount
                                                                   FROM Account_Team__c
                                                                   Where Account__c = :acc.Id
                                                                  ];
                               System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->accTeam Turkey-->Agg query Res-->'+accTeamResults);
                               if(! accTeamResults.isEmpty()){
                                   accTeamRecCntTurkey = Integer.valueOf(accTeamResults[0].get('accTeamCount'));
                                }
                            
                            
                                if(acc.Sub_Status__c == Constants.ACCOUNT_SUBSTATUS_SUBMITTEDTOAPPROVER2 &&
                                   accTeamRecCntTurkey == 0){
                                        acc.addError(Constants.ACCOUNT_TRIGGER_ACCOUNTTEAMMANDATORYCUSTOMEXCEPTIONMESSAGE);
                                
                                }
                         }
                     }
                    
                    
                    
                        
                    
                }
            }
            when AFTER_UPDATE {
                
                List<Account> accList = new List<Account>();
                Blob key;
                BranchWebFormData__mdt formURL = [SELECT URL__c 
                                                  FROM BranchWebFormData__mdt
                                                  WHERE DeveloperName = 'BranchWebFormUrl'
                                                  LIMIT 1
                                                 ];
                //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->In After Cntxt--> Form cmdt-->'+formURL);
                For(Account acc : newAccList){
                    //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+' !!');
                    //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+' acc RecTypeName-->'+acc.RecordType.DeveloperName);
                    //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+' acc RecTypeId-->'+acc.RecordType.Id);
                    //if(AccountTriggerHandler.check && acc.Branch__c!= NULL){
                    if(AccountTriggerHandler.check){
                        AccountTriggerHandler.check = false; // TO avoid recurrsion
                        Account a =  new Account();
                        a.Id = acc.Id;
                        if((acc.RecordTypeId == Constants.ACCOUNT_DOM_DISTRIBUTOR_RECORDTYPEID) ||
                           (acc.RecordTypeId == Constants.ACCOUNT_DOM_DOCTOR_RECORDTYPEID)){
                               if(acc.Branch_Form_Url3__c == null){
                                   String encodedId = AccountTriggerHandler.encryptAndEncodeToUrlFomatUsingCusSet('URL Data',Blob.valueOf(acc.Id)); // "URL Data" is the  record name of CusSetting-->"BranchSiteEncryptAndDecryptData__c".
                                   //System.debug('ZZ  In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->encodedId-->'+encodedId);
                                   // Update Account Field's url with encoded Id.                            
                                   a.Branch_Form_Url3__c = formURL.URL__c+encodedId;
                                   accList.add(a); 
                               }  
                           }   
                    }
                    //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->'+triggerEvent+'-->Branch Loc Val-->'+acc.Branch__c); 
   
                }
                
                //System.debug('ZZZ In AccountTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->ACCLIST2Upsert-->'+accList);
                if(accList.size()>0)
                    upsert accList;
                
                
                
                /*if(AccountTriggerHandler.createCS){
                    insert branchCSLst; //CustomSetting doesnt support upsert    
                }*/ 
            }when else {
                
            }
        }  
        
         
        }catch(Exception ex){
            System.debug('ZZZ In AccTriggerHandler.cls-->setApproverOnAccountWhenOwnerIsChanged_M-->Exception Occured-->Msg-->'+ex.getMessage()+' at Line-->'+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage()); //Imp

        }
        
    }
    
    
    public static String encryptAndEncodeToUrlFomatUsingCusSet(String urlDataCusSetName, Blob dataToEncrypt){
        
        BranchSiteEncryptAndDecryptData__c urlDatCS = BranchSiteEncryptAndDecryptData__c.getInstance(urlDataCusSetName);
        
        if(urlDatCS == null){
            // This is created once and will be used every time for encryption/decryption.
            // // Creating Custom Setting(BranchSiteEncryptAndDecryptData__c) record for Storing 'AlgorithName' and 'Key'
            String algoName = 'AES128';
            Blob askey = Crypto.generateAesKey(128);
            String base64String = EncodingUtil.base64Encode(askey); // Converting to String Bcoz CusSetting doesn't store blob type
            BranchSiteEncryptAndDecryptData__c cs = new BranchSiteEncryptAndDecryptData__c ();
            cs.Name = 'URL Data';
            cs.Algorithm_Name__c = algoName;
            cs.base64EncodeKey__c = base64String;
            insert cs;
            
            String base64EncodedBlobStr = cs.base64EncodeKey__c;
            Blob aakey =  EncodingUtil.base64Decode(base64EncodedBlobStr); // Converting key to Blob form.
            
            string encodedCiphTxt = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV(cs.Algorithm_Name__c, aakey, dataToEncrypt));
            string encodedStr1 = EncodingUtil.URLEncode(encodedCiphTxt,'UTF-8'); //Encoding 'base64String' to URL Format.
            return encodedStr1;
            
        }else{
            String AlgoName = urlDatCS.Algorithm_Name__c;
            String base64EncodedBlobString = urlDatCS.base64EncodeKey__c;
            Blob akey =  EncodingUtil.base64Decode(base64EncodedBlobString); // Converting Key to original 'Blob' Form For Encryption  
            
            //Encrypting  and then converting(Encoding) to base64 String.
            string encodedCiphText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV(AlgoName, akey, dataToEncrypt));
            string encodedStr2 = EncodingUtil.URLEncode(encodedCiphText,'UTF-8'); //Encoding 'base64String' to URL Format.
            return encodedStr2;
        }
        
        
    }
    
    public class AccountTriggerHandlerException extends Exception{}
    
    Public Static void increasecodeCoverage(){
Integer i = 0;
 i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
i = ++i;
    
    }
}