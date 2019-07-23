public inherited sharing class AccountTeamHandler {
    public static void shareAccountWithAccTeam(List<Account_Team__c> newAccTeamList, List<Account_Team__c> oldAccTeamList,Map<Id,Account_Team__c> oldAccTeamMap, System.TriggerOperation triggerEvent){
        try{
            switch on triggerEvent {
                when BEFORE_UPDATE,AFTER_UPDATE {
                    //System.debug('In ZZZ BEF_UPD!!!!!');
                    List<AccountShare> accShareUpdLst = new List<AccountShare>();
                    List<AccountShare> accShareToDelete = new List<AccountShare>();
                    List<AccountShare> accShareToInsert = new List<AccountShare>();
                    for(Account_Team__c newAccTeam : newAccTeamList){
                        Account_Team__c oldAccTeam = oldAccTeamMap.get(newAccTeam.Id);
                        if((oldAccTeam.Team_Member__c == newAccTeam.Team_Member__c) && (oldAccTeam.Account__c == newAccTeam.Account__c)){
                            List<AccountShare>  atShareLst = [Select Id,AccountId,UserOrGroupId,AccountAccessLevel 
                                                              From AccountShare 
                                                              Where AccountId =: oldAccTeam.Account__c
                                                              AND UserOrGroupId =: oldAccTeam.Team_Member__c  
                                                             ];
                            for(AccountShare ast : atShareLst){
                                ast.AccountAccessLevel = ((newAccTeam.Account_Access__c == 'Read/Write') ? 'Edit' : 'Read'); //can't update "UserOrGroupId" , so we can change only the accountaccesslevel.
                                accShareUpdLst.add(ast);
                            }
                            
                            
                           System.debug('In ZZZAccTeamHandler.cls-->shareAccountWithAccTeam_M-->B4UPDATE-->IF--->2UPDATELST-->'+accShareUpdLst);
                            update accShareUpdLst;
                        }else if((oldAccTeam.Team_Member__c != newAccTeam.Team_Member__c) && (oldAccTeam.Account__c == newAccTeam.Account__c)){
                           // System.debug('In ZZZAccTeamHandler.cls-->shareAccountWithAccTeam_M-->IN B4UPDATE-->ELSE IF !!!!!');
                            //Deleting the old accountshare record because team member is changed
                            for(AccountShare oldAccShareObj : [Select Id,AccountId,UserOrGroupId,AccountAccessLevel 
                                                               From AccountShare 
                                                               Where (AccountId =: oldAccTeam.Account__c
                                                                      AND UserOrGroupId =: oldAccTeam.Team_Member__c)
                                                               AND RowCause = 'Manual'
                                                              ]){
                                                                  accShareToDelete.add(oldAccShareObj);
                                                              }
                            
                            
                            
                            //Creating New AccountShare Record
                            AccountShare newAccShare =  new AccountShare();
                            newAccShare.AccountAccessLevel = ((newAccTeam.Account_Access__c == 'Read/Write') ? 'Edit' : 'Read');
                            newAccShare.UserOrGroupId      = newAccTeam.Team_Member__c;
                            newAccShare.AccountId          = newAccTeam.Account__c;
                            newAccShare.OpportunityAccessLevel = 'Read';  // This is required field  
                            accShareToInsert.add(newAccShare);
                            
                            System.debug('In ZZZAccTeamHandler.cls-->shareAccountWithAccTeam_M-->IN B4UPDATE-->ELSE IF-->LST2DELETE-->'+accShareToDelete);
                            System.debug('In ZZZAccTeamHandler.cls-->shareAccountWithAccTeam_M-->IN B4UPDATE-->ELSE IF-->LST2INSERT-->'+accShareToInsert);
                            delete accShareToDelete;
                            insert accShareToInsert;
                        }
                    }
                    
                    
                }
                when AFTER_INSERT {
                    //System.debug('In ZZZ INA_UPD!!!!!');
                    List<AccountShare> accShareLst = new List<AccountShare>();
                    for(Account_Team__c accTeam : newAccTeamList){
                        if(accTeam.Member_Same_As_Account_Owner__c==false){
                            AccountShare acShare =  new AccountShare();
                            acShare.AccountAccessLevel = ((accTeam.Account_Access__c == 'Read/Write') ? 'Edit' : 'Read');
                            acShare.UserOrGroupId      = accTeam.Team_Member__c;
                            acShare.AccountId          = accTeam.Account__c;
                            acShare.OpportunityAccessLevel = 'Read';  // This is required field
                            //acShare.CaseAccessLevel        = 'Read';
                            //acShare.ContactAccessLevel     = 'Read';
                            accShareLst.add(acShare);
                        }
                    }
                    if(! accShareLst.isEmpty()){
                        insert accShareLst;
                    }
                    
                }
                when BEFORE_DELETE,AFTER_DELETE{
                    //System.debug('In ZZZ IN DELETE!!!!!');
                    List<AccountShare> accShareLstToDelete = new List<AccountShare>();
                    for(Account_Team__c oldAccTeam : oldAccTeamList){
                        for(AccountShare accShareO : [Select Id,AccountId,UserOrGroupId,AccountAccessLevel 
                                                      From AccountShare 
                                                      Where (AccountId =: oldAccTeam.Account__c
                                                             AND UserOrGroupId =: oldAccTeam.Team_Member__c)
                                                      AND RowCause = 'Manual'
                                                     ]){
                                                         accShareLstToDelete.add(accShareO);
                                                     }    
                        
                        
                    }
                    //System.debug('In ZZZAccTeamHandler.cls-->shareAccountWithAccTeam_M--> loop DELETE LST-->'+accShareLstToDelete);
                    if(! accShareLstToDelete.isEmpty()){
                        //System.debug('In ZZZAccTeamHandler.cls-->shareAccountWithAccTeam_M--> 2 DELETE LST-->'+accShareLstToDelete);
                        delete accShareLstToDelete;
                    }
                }
                when else{}
            }
        }catch(Exception ex){
            System.debug('In ZZZAccTeamHandler.cls-->shareAccountWithAccTeam_M-->Exception-->'+ex.getMessage()+' at Line-->'+ex.getLineNumber());
        }
        
    }
}