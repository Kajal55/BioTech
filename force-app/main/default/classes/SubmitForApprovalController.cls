public inherited sharing class SubmitForApprovalController {
    
    @AuraEnabled
    public static String checkAccHasERLAttachmentAndCESRecord(String accId){
        String response;
        Set<String> attchmntNameSet = new Set<String>();
        Set<String> fileNameSet = new Set<String>();
        try{
            List<Account> accs = [Select ID,Name,No_Of_CE_Records__c,RecordTypeId,RecordType.DeveloperName, (Select Id,Name From Attachments) 
                                  From Account 
                                  Where Id =: accId];
            If(!accs.isEmpty()){
                for(Account a : accs){
                    for(Attachment at : a.attachments){
                        attchmntNameSet.add(at.Name.substringBefore('.'));
                    }
                }
            }
            
            //Checking if file has ERL doc attached.
            List<ContentDocumentLink> fileList = [SELECT ContentDocumentId,ContentDocument.title,LinkedEntityId 
                                                  FROM ContentDocumentLink 
                                                  where LinkedEntityId =: accId 
                                                  AND LinkedEntity.Type='Account'];
            if(!fileList.isEmpty()){
                for(ContentDocumentLink cdl : fileList){
                    fileNameSet.add(cdl.ContentDocument.title);    
                }
            }
            //System.debug('ZZZ In SubmitForAppCon-->checkAccHasERLAttachment_M-->accLst-->'+accs);
            //System.debug('ZZZ In SubmitForAppCon-->checkAccHasERLAttachment_M-->attchmntNameSet-->'+attchmntNameSet);
            //System.debug('ZZZ In SubmitForAppCon-->checkAccHasERLAttachment_M-->FileNameSet-->'+fileNameSet);
       
            //Now Distributor will also have approval
            // If Account is of Distributor  RecordType then return , since they have no approval process.
            //if(accs[0].RecordType.DeveloperName == Constants.ACCOUNT_DOM_DISTRIBUTOR_RECORDTYPEDEVELOPERNAME || accs[0].RecordType.DeveloperName == Constants.ACCOUNT_TURKEY_DISTRIBUTOR_RECORDTYPEDEVELOPERNAME) 
            //return 'Is B2B2C';
            
            
            // Fetch Latest Created CE Record Each Time
            List<Customer_Evaluation__c> childCERecords = [Select Id,Name,Account__c,Status__c,CreatedDate
                                            			   From Customer_Evaluation__c
                                            			   Where Account__c =:accs[0].Id
                                                           Order By CreatedDate DESC 
                                                           LIMIT 1]; 
            //Integer year = ce.CreatedDate.year();
            //System.debug('System Year-->'+System.today().year());
            
            // If File or attachment contains name "ERL" and CE Record is greater than or equals to 1
            System.debug('NameSet-->'+attchmntNameSet);
            System.debug('FileSet-->'+fileNameSet);
            if((attchmntNameSet.contains('ERL') || attchmntNameSet.contains('erl')) || (fileNameSet.contains('ERL') || fileNameSet.contains('erl'))){
                System.debug('ZZZ In SubmitForAppCon-->checkAccHasERLAttachment_M-->INside If!!!!-->');
                	if(!childCERecords.isEmpty() && childCERecords[0].Status__c == Constants.CE_STATUS_APPROVED){
                    	//Integer ceCreatedYear = childCERecords[0].CreatedDate.year(); // Since CE will be created new each year.
                       //System.debug('System Year-->'+System.today().year());
                        return 'OK';
                	}else{
                    	return null;
                    }
                    
                	// REMOVED Dependency On Account's No_Of_CE_Records__c Field
                    //if(accs[0].No_Of_CE_Records__c >= 1){
                    //    return 'OK';   
                    //}
            }else{
                return null;    
            }
            
            
        }catch(Exception ex){
            System.debug('ZZZ In SubmitForAppCon-->checkAccHasERLAttachment_M-->Exception-->'+ex.getMessage()+' at Line-->'+ex.getLineNumber());
            return null;   
        }
        
    }
    
    @AuraEnabled 
    public static String setIsAccHavingERLFieldOnAccount(String accId){
        String approvalStatus;
        try{
            List<Account>  accs = [Select Id,Name,isAccHavingERL__c,Sub_Status__c,No_Of_CE_Records__c
                                   From Account
                                   Where Id =: accId
                                  ];
            System.debug('ZZZ In SubmitForAppCon-->setIsAccHavingERLFieldOnAccount_M-->Acc---->'+accs[0]);
            if(!accs.isEmpty()){
                accs[0].isAccHavingERL__c = true;
                update accs;
                
                // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please approve.');
                req.setObjectId(accs[0].Id);
                /*
System.debug('ZZZ In SubmitForAppCon-->setIsAccHavingERLFieldOnAccount_M-->Acc---->'+accs[0]);
if((accs[0].isAccHavingERL__c) && (accs[0].Sub_Status__c == 'Submitted For Admin Team Validation') && (accs[0].No_Of_CE_Records__c >= 1)){
System.debug('ZZZ In SubmitForAppCon-->setIsAccHavingERLFieldOnAccount_M-->Inside Approval Req2 if statmnt!!!!!--> ');
req.setProcessDefinitionNameOrId('Approver2_ZSM_Process'); // Setting the name of Approval process 2 (ZSM(Approver2) approval process)   
}
*/
                // System.debug('ZZZ In SubmitForAppCon-->setIsAccHavingERLFieldOnAccount_M-->Approval Req--> '+req);
                //
                // submit the approval request for processing
                Approval.ProcessResult result = Approval.process(req);
                // display if the reqeust was successful
                System.debug('ZZZ In SubmitForAppCon-->setIsAccHavingERLFieldOnAccount_M-->Submitted for approval successfully: '+result.isSuccess());
                
                if(result.isSuccess()){
                    approvalStatus = 'OK';
                }
            }
            
            return approvalStatus;
        }catch(Exception ex){
            System.debug('ZZZ In SubmitForAppCon-->setIsAccHavingERLFieldOnAccount_M-->Exception: '+ex.getMessage());
            return ex.getMessage();  
        }
        
    }
}