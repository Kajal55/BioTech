global with sharing class AccountProcessHandler {
    
    @InvocableMethod(label='Create Monthly Plan Records' description='When Account gets activated, this method will create 12 MonthlyPlan records for each account')
    global static void createMonthlyPlanRecords(List<MonthlyPlanCreationRequest> mpcrRequests) {
        For(MonthlyPlanCreationRequest mpcr : mpcrRequests ){
            if(mpcr.isFromBatch){
                createMonthlyPlanRecord(mpcr,true,mpcr.accountStatus);
            }else{
                createMonthlyPlanRecord(mpcr,false,mpcr.accountStatus); 
            }
        }    
    }
    
    public static void createMonthlyPlanRecord(MonthlyPlanCreationRequest mpcrRequest,Boolean fromBatch,String accountStatus){
        System.debug('In ZZZ AccountProcessHandler.cls-->createMonthlyPlanRecord_M--> Entered!!!!');
        //String fiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        
        Period currPeriod = [SELECT FiscalYearSettings.Name,FiscalYearSettings.EndDate,FiscalYearSettings.StartDate FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY LIMIT 1];
        String  fiscalYear            = currPeriod.FiscalYearSettings.Name; //Fiscal Year End
        String  prevFiscalYear        = String.valueOf(Integer.valueOf(fiscalYear) - 1);
        Integer fiscalStartMonthValue = currPeriod.FiscalYearSettings.StartDate.month();
        Integer fiscalEndMonthValue   = currPeriod.FiscalYearSettings.EndDate.month();
        Integer fiscalStartYearValue  = currPeriod.FiscalYearSettings.StartDate.year();
        Integer fiscalEndYearValue    = currPeriod.FiscalYearSettings.EndDate.year();
        Integer currentMonthValue = System.today().month();
        Integer currentYearValue  = System.today().year();
        
        List<Monthly_Plan__c> monthlyPlansList =  new List<Monthly_Plan__c>();
        List<Monthly_Plan__c> monthlyPlansListTur =  new List<Monthly_Plan__c>();
        
        if(!fromBatch && String.isNotBlank(accountStatus) && accountStatus == Constants.ACCOUNT_STATUS_DRAFT){ 
            System.debug('ZZZ In AccountProcessHandler.cls-->Inside Draft Status!');
            //Now this is used for draft account condition in process builder.(As per 23042019 suggested modifications)
            List<Account> accWithExistingMP = [ Select Id,SAP_Code__c,Temprary_Id__c,recordtypeid,(Select Id from Monthly_Plans__r)
                                               FROM Account
                                               Where Id = :mpcrRequest.accountId
                                               AND SAP_Code__c = NULL   //Added on 24042019
                                               LIMIT 1
                                              ];
            
            String recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(accWithExistingMP[0].recordtypeid).getDeveloperName();
            String recordname=(( recordtypename=='Distributor' || recordtypename=='Doctor_D' || recordtypename=='Ophthalmic_Vision' || recordtypename=='Ortho_Dermal') ? 'Dom/Int' : (( recordtypename=='Distributor_T' || recordtypename=='Doctor_T')  ? 'Turkey' : 'NA'));
            if(!accWithExistingMP.isEmpty()){ 
                Set<Monthly_Plan__c> existingMP = new Set<Monthly_Plan__c>(accWithExistingMP[0].Monthly_Plans__r);
                if(!(existingMP.size() > 0)){ 
                    Integer index=0;
                    for(Integer i=0; i < mpcrRequest.numberOfMonthlyPlanRecords; i++ ){
                        Monthly_Plan__c mp = new Monthly_Plan__c();
                        mp.Account__c = mpcrRequest.accountId;
                        mp.Stage__c   = 'Open';
                        mp.Financial_Year__c = String.valueOf(recordname=='Turkey'? String.valueOf(System.today().year()) : (recordname=='Dom/Int' ? fiscalYear : 'NA')); 
                        
                        if(i==9 || i==10 || i==11)
                            mp.Year__c= String.valueOf(recordname=='Turkey'?String.valueOf(System.today().year()) : (recordname=='Dom/Int' ? String.valueOf(fiscalEndYearValue) : 'NA')); 
                        else
                            mp.Year__c= String.valueOf(System.today().year());                                       
                        
                        
                        Switch on i{
                            when 9 {
                                mp.Name = 'JAN-'+mp.Year__c +'-'+accWithExistingMP [0].Temprary_Id__c+'-Monthly Plan';                                                  
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Jan'  +mp.Year__c ;
                                mp.Month__c   = 'Jan';
                                monthlyPlansList.add(mp);
                            }
                            when 10 {
                                mp.Name = 'FEB-'+ mp.Year__c +'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Feb' +mp.Year__c ;
                                mp.Month__c   = 'Feb';                            
                                monthlyPlansList.add(mp);
                            }
                            when 11 {
                                mp.Name = 'MAR-'+mp.Year__c +'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Mar'  +mp.Year__c ;
                                mp.Month__c   = 'Mar'; 
                                monthlyPlansList.add(mp);
                            }
                            when 0 {
                                mp.Name = 'APR-'+ mp.Year__c+'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Apr'+String.valueOf(System.today().year());
                                mp.Month__c   = 'Apr'; 
                                monthlyPlansList.add(mp);
                            }
                            when 1 {
                                mp.Name = 'MAY-'+ mp.Year__c+'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'May'+String.valueOf(System.today().year());
                                mp.Month__c   = 'May'; 
                                monthlyPlansList.add(mp);
                            }
                            when 2 {
                                mp.Name = 'JUN-'+ mp.Year__c+'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Jun'+String.valueOf(System.today().year());
                                mp.Month__c   = 'Jun';
                                monthlyPlansList.add(mp);
                            }
                            when 3 {
                                mp.Name = 'JUL-'+ mp.Year__c+'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Jul'+String.valueOf(System.today().year());
                                mp.Month__c   = 'Jul'; 
                                monthlyPlansList.add(mp);
                            }
                            when 4 {
                                mp.Name = 'AUG-'+ mp.Year__c +'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Aug'+String.valueOf(System.today().year());
                                mp.Month__c   = 'Aug'; 
                                monthlyPlansList.add(mp);
                            }
                            when 5 {
                                mp.Name = 'SEP-'+ mp.Year__c +'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Sep'+String.valueOf(System.today().year());
                                mp.Month__c   = 'Sep';
                                monthlyPlansList.add(mp);
                            }
                            when 6 {
                                mp.Name = 'OCT-'+ mp.Year__c +'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Oct'+String.valueOf(System.today().year());
                                mp.Month__c   = 'Oct'; 
                                monthlyPlansList.add(mp);
                            }
                            when 7 {
                                mp.Name = 'NOV-'+  mp.Year__c +'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Nov'+String.valueOf(System.today().year());
                                mp.Month__c   = 'Nov';
                                monthlyPlansList.add(mp); 
                            }
                            when 8 {
                                mp.Name = 'DEC-'+ mp.Year__c +'-'+accWithExistingMP[0].Temprary_Id__c+'-Monthly Plan';
                                mp.MPUID__c   = accWithExistingMP[0].Temprary_Id__c+'Dec'+String.valueOf(System.today().year());
                                mp.Month__c   = 'Dec';   
                                monthlyPlansList.add(mp);
                            } 
                            when else{
                                
                            }
                        }
                        
                    }
                    System.debug('ZZZ In AccountProcessHandler.cls-->Draft Status-->MP List Size to CREATE-->'+monthlyPlansList.size());
                    if(monthlyPlansList.size()>0)  
                        Database.SaveResult[] srList = Database.insert(monthlyPlansList,false);                  
                    
                    //System.debug('ZZZ In AccountProcessHandler.cls-->createMonthlyPlanRecord_M-->DML Result-->'+srList);
                    
                }  // If ends.......
            }
        }
        if(!fromBatch && String.isNotBlank(accountStatus) && accountStatus == Constants.ACCOUNT_STATUS_ACTIVATED){
            System.debug('ZZZ In AccountProcessHandler.cls-->Inside Activated Status!');
            //Now onwards(as of 23042019 modification) account will always have monthly plan, and now for activated accounts(which will have SAPCode)
            //we have to update monthly plan's Name and MPUID field with SAPcode.
            //***** Note: This code will run every time when Account Status is Activated and Sapcode is not null.
            //*** NEED TO AVOID UNNECESSARY RUN*********//
            List<Account> activatedAccWithExistingMP = [Select Id,SAP_Code__c,
                                                        (Select Id,Name,Month__c,Year__c,Financial_Year__c,MPUID__c,Account__c,Account__r.SAP_Code__c
                                                         from Monthly_Plans__r)
                                                        FROM Account
                                                        Where Id = :mpcrRequest.accountId
                                                        AND SAP_Code__c != NULL   //Added on 24042019
                                                        LIMIT 1
                                                       ];
            if(!activatedAccWithExistingMP.isEmpty()){
                List<Monthly_Plan__c> mpListToUpdate = new List<Monthly_Plan__c>();
                Set<Id> mpIdSet = new Set<Id>();
                Set<Monthly_Plan__c> existingMPs = new Set<Monthly_Plan__c>(activatedAccWithExistingMP[0].Monthly_Plans__r);
                if((existingMPs.size() > 0)){
                    for(Monthly_Plan__c mp : existingMPs){
                        mp.Name  = mp.Month__c+'-'+mp.Year__c +'-'+activatedAccWithExistingMP[0].SAP_Code__c+'-Monthly Plan';
                        mp.MPUID__c = activatedAccWithExistingMP[0].SAP_Code__c+mp.Month__c+mp.Year__c;
                        mpListToUpdate.add(mp);
                        mpIdSet.add(mp.Id);
                    }
                    
                    System.debug('ZZZ In AccountProcessHandler.cls-->Activated Status-->MP List Size to update-->'+mpListToUpdate.size());
                    update mpListToUpdate;
                    updateMppsByMPId(mpIdSet); //Now Updating Related Mpp's
                }
            }
            
        }else{
            
            if(mpcrRequest.isFromBatch){
                //Now this is used for draft account condition in process builder.(As per 23042019 suggested modifications)
                List<Account> accWithExistingMP = [ Select Id,SAP_Code__c,Temprary_Id__c,recordtypeid,(Select Id from Monthly_Plans__r)
                                                   FROM Account
                                                   Where Id = :mpcrRequest.accountId
                                                   LIMIT 1
                                                  ];
                
                String recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(accWithExistingMP[0].recordtypeid).getDeveloperName();
                String recordname=(( recordtypename=='Distributor' || recordtypename=='Doctor_D' || recordtypename=='Ophthalmic_Vision' || recordtypename=='Ortho_Dermal') ? 'Dom/Int' : (( recordtypename=='Distributor_T' || recordtypename=='Doctor_T')  ? 'Turkey' : 'NA'));
                // System.debug('ZZZ In AccountProcessHandler.cls-->createMonthlyPlanRecord_M-->Inside Batch !!!!!!!!!!!!');
                //System.debug('ZZZ In AccountProcessHandler.cls-->createMonthlyPlanRecord_M-->Batch-->CURR_FISCALSTARTYEAR-->'+fiscalStartYearValue);
                //System.debug('ZZZ In AccountProcessHandler.cls-->createMonthlyPlanRecord_M-->Batch-->CURR_FISCALENDYEAR-->'+fiscalEndYearValue);
                
                for(Integer j = 0; j < mpcrRequest.mPlanList.size(); j++ ){
                    // System.debug('Constants.MONTH_VALUE_MAP.get'+j+'  VAL-->'+Constants.MONTH_VALUE_MAP.get(j));
                    // System.debug('mpcrRequest.mPlanList['+j+'].Month__c VAL-->'+mpcrRequest.mPlanList[j].Month__c);
                    // System.debug('mpcrRequest.mPlanList['+j+'].Financial_Year__c VAL-->'+mpcrRequest.mPlanList[j].Financial_Year__c);
                    // System.debug('mpcrRequest.previousFiscalYear VAL-->'+mpcrRequest.previousFiscalYear);
                    
                    if((Constants.MONTH_VALUE_MAP.get(j) == mpcrRequest.mPlanList[j].Month__c) && (mpcrRequest.mPlanList[j].Financial_Year__c == mpcrRequest.previousFiscalYear) ){
                        //  system.debug('INSIDE IF!!!!!!!!!!!!!!!!');
                        Monthly_Plan__c mp = new Monthly_Plan__c();
                        mp.Last_Year_Monthly_Plan__c = mpcrRequest.mPlanList[j].Id;
                        mp.Account__c = mpcrRequest.accountId;
                        mp.Stage__c   = 'Open';
                        mp.Month__c   = Constants.MONTH_VALUE_MAP.get(j);
                        mp.Financial_Year__c = String.valueOf(recordname=='Turkey'? String.valueOf(System.today().year()) : (recordname=='Dom/Int' ? fiscalYear : 'NA')); 
                        
                        if(j == 9 || j == 10 || j == 11){
                            mp.Year__c    = String.valueOf(recordname=='Turkey'?String.valueOf(System.today().year()) : (recordname=='Dom/Int' ? String.valueOf(fiscalEndYearValue) : 'NA'));                         
                            mp.Name = Constants.MONTH_VALUE_MAP.get(j).toUpperCase()+'-'+ mp.Year__c +'-'+ mpcrRequest.mPlanList[j].Account__r.SAP_Code__c +'-Monthly Plan';
                            mp.MPUID__c   = mpcrRequest.mPlanList[j].Account__r.SAP_Code__c+Constants.MONTH_VALUE_MAP.get(j)+mp.Year__c;
                        }else{
                            mp.Year__c= String.valueOf(System.today().year());
                            mp.Name = Constants.MONTH_VALUE_MAP.get(j).toUpperCase()+'-'+ mp.Year__c +'-'+ mpcrRequest.mPlanList[j].Account__r.SAP_Code__c +'-Monthly Plan';
                            mp.MPUID__c   = mpcrRequest.mPlanList[j].Account__r.SAP_Code__c+(j+1)+Constants.MONTH_VALUE_MAP.get(j)+mp.Year__c;    
                        }
                        monthlyPlansList.add(mp);
                    }
                    
                    
                }
                //System.debug('ZZZ In AccountProcessHandler.cls-->createMonthlyPlanRecord_M-->BATCH-->LIST2INSERT-->'+monthlyPlansList);
                //System.debug('ZZZ In AccountProcessHandler.cls-->createMonthlyPlanRecord_M-->BATCH-->LIST2INSERT SIZE-->'+monthlyPlansList.size());
                Database.SaveResult[] srList = Database.insert(monthlyPlansList);
                // System.debug('ZZZ In AccountProcessHandler.cls-->createMonthlyPlanRecord_M-->BATCH-->DML Result-->'+srList);
                
            }
        }
        
    }
    global class MonthlyPlanCreationRequest {
        
        @InvocableVariable(required=true)
        global ID accountId;
        
        @InvocableVariable(required=true)
        global Integer numberOfMonthlyPlanRecords;
        
        @InvocableVariable
        global String accountStatus;
        
        global Boolean isFromBatch = false;
        
        global Monthly_Plan__c mPlan = new Monthly_Plan__c();
        
        global List<Monthly_Plan__c> mPlanList = new List<Monthly_Plan__c>();
        
        global String previousFiscalYear = '';
        
        global String SAPCode ='';
        
        // global Map<Id,List<Monthly_Plan__c>> accAndAllItsMP = new Map<Id,List<Monthly_Plan__c>>();
    }
    
    @future   
    private static void updateMppsByMPId(Set<Id> mpIds){
        for(Id mpId : mpIds){
            updateMPPsMappingCode(mpId);
        }
    }

    private static void updateMPPsMappingCode(Id mpId)  {
        System.debug('ZZZ In AccountProcessHandler.cls-->In updateMPPsMappingCode_M Future Method!');
        List<Monthly_Product_Plan__c> mppToUpdate = new List<Monthly_Product_Plan__c>();
        List<Monthly_Product_Plan__c> mppList = [SELECT Id,Monthly_Plan__c,MPP_Mapping__c,Account_Sap_code__c,Monthly_Plan__r.Month__c,Monthly_Plan__r.Year__c,Product__r.Dummy_Product_Code__c
                                                 FROM Monthly_Product_Plan__c
                                                 WHERE Monthly_Plan__c =:mpId
                                                ];
        if(!mppList.isEmpty()){
            For(Monthly_Product_Plan__c mpp : mppList){
                //Updating MPP Mapping Code with SAP Code (earlier it had account's temp id).
                mpp.MPP_Mapping__c = mpp.Monthly_Plan__r.Month__c+mpp.Monthly_Plan__r.Year__c+mpp.Product__r.Dummy_Product_Code__c+mpp.Account_Sap_code__c;
                mppToUpdate.add(mpp);
            }
            System.debug('ZZZ In AccountProcessHandler.cls-->updateMPPsMappingCode_M-->Future_M-->MPP2UPDATE LST SIZE-->'+mppToUpdate.size());
            // Below will not work because it calls another future method(process builder(mpp)-->rollupaop method of trgtandplningCont class) from this future method which is not allowed.
            //update mppToUpdate; 
            
            //Now calling Queueable from future method
            ID jobID = System.enqueueJob(new AccountProcessHandlerQueueable(mppToUpdate));
        }
        
    }  
    
    
    class AccountProcessHandlerException extends Exception{}
}