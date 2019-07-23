public class SubmitCISController {
    public  static Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'May',
        6 => 'Jun',
        7 => 'Jul',
        8 => 'Aug',
        9 => 'Sep',
        10 => 'Oct',
        11 => 'Nov',
        12 => 'Dec'
        };
    @AuraEnabled
    public static MainWrapper getBudgetOptions(String recordId,String headerId){
        CIS_Setting__c setting = CIS_Setting__c.getInstance();
        MainWrapper wrapper = new MainWrapper();
        wrapper.readOnly = false;
        wrapper.error = '';
        List<CIS_Header__c> headerList;
        boolean preserveId = true;
        if(headerId != null && headerId.trim() !=''){ //Approval Mode
            headerList = [SELECT Id,Status__c FROM CIS_Header__c WHERE Id=:headerId];
            wrapper.readOnly = true;
            wrapper.headerId = headerId;
        }else if(recordId != null && recordId.trim() != ''){
            
            String year = ''+System.today().year();
            String month = monthMap.get(System.today().month());
            headerList = [SELECT Id,Status__c FROM CIS_Header__c WHERE Account__c=:recordId AND Month__c=:month AND Year__c=:year];
            if(headerList.size()>0){
                wrapper.headerId = headerList[0].Id;
                wrapper.readOnly = headerList[0].Status__c == 'Pending';
                if(wrapper.readOnly){
                    wrapper.error = 'CIS is locked because approval is pending.';
                }
            }else{
                List<Account> acc = [Select id,Account_Locked__c from Account where id=:recordId];
                if(acc.size() > 0 && acc[0].Account_Locked__c){
                    wrapper.readOnly = true;
                    wrapper.error = 'You can not submit CIS. Please contact your system admin.';
                }else{
                    //Check CE submitted for this year
                    String thisYear = ''+System.today().year();
                    List<Customer_Evaluation__c> CEList = [SELECT Id FROM Customer_Evaluation__c WHERE Account__c=:recordId AND Year__c=:thisYear AND Status__c='Approved'];
                    if(CEList.size() > 0){
                        //Get Last month CIS
                        Date lastMonth = System.today().addMonths(-1);
                        year = ''+lastMonth.year();
                        month = monthMap.get(lastMonth.month());
                        headerList = [SELECT Id,Status__c FROM CIS_Header__c WHERE Account__c=:recordId AND Month__c=:month AND Year__c=:year];
                        preserveId = false;
                        if(headerList.size()>0){
                            wrapper.headerId = headerList[0].Id;
                            wrapper.lastHeaderId = headerList[0].Id;
                        }
                    }else{
                        wrapper.readOnly = true;
                        wrapper.error = 'Customer Evaluation is not submitted for this year.';
                    }
                }
            }
        }
        
        wrapper.CISList = getCISRecordList(wrapper.headerId,preserveId);
        if(preserveId ==false){
            wrapper.headerId = '';
        } 
        wrapper.grandTotal = 0;
        for(CISWrapper cw : wrapper.CISList){
            if(cw.totalValue != null){
                wrapper.grandTotal += cw.totalValue;
            }
        }
        wrapper.companyPicklistValues = new List<OptionModel>();
        wrapper.productPicklistValues = new List<OptionModel>();
        
        wrapper.companyPicklistValues.add(new OptionModel('--- None ---','',null));
        wrapper.productPicklistValues.add(new OptionModel('--- None ---','',null));
        
        for(Schema.PicklistEntry a : CIS_Line__c.Company_Display__c.getDescribe().getPickListValues()){
            wrapper.companyPicklistValues.add(new OptionModel(a.getValue(),a.getValue(),null));
        }
        
        for(Schema.PicklistEntry a : CIS_Line__c.Product_Display__c.getDescribe().getPickListValues()){
            wrapper.productPicklistValues.add(new OptionModel(a.getValue(),a.getValue(),null));
        }
        
        //Get PickLIst values for controlling field
        /*
        List<String> parentValues = new List<String>();
        List<Integer> controllerIndexes = new List<Integer>();
        integer counter = 0;
        for(Schema.PicklistEntry a : CIS_Line__c.Company_Display__c.getDescribe().getPickListValues()){
            parentValues.add(a.getValue());
            controllerIndexes.add(counter++);
            wrapper.companyPicklistValues.add(new OptionModel(a.getValue(),a.getValue(),null));
        }
        
        //Get PickLIst values for dependent field  
        List<Schema.PicklistEntry> pick_list_values = CIS_Line__c.Product_Display__c.getDescribe().getPickListValues();
        List<OptionModel> entries = (List<OptionModel>)JSON.deserialize(JSON.serialize(pick_list_values), List<OptionModel>.class);
        for (OptionModel a : entries) { 
            String validForOptions = ';';
            if(a.validFor !=null){
                List<Integer> parentIndex = BitSet.testBits(a.validFor,controllerIndexes);
                if(parentIndex !=null){
                    for(Integer i: parentIndex){
                        validForOptions +=parentValues[i]+';';  
                    }
                }
            }
            wrapper.productPicklistValues.add(new OptionModel(a.value,a.label,validForOptions)); 
        }
        */
        return wrapper;
    }
    
    @AuraEnabled
    public static string saveCISRecord(String recordJSON,String recordId,String headerId,String lastHeaderId){
        try{
            System.debug(recordJSON);
            List<CISWrapper> CISList = (List<CISWrapper>) JSON.deserialize(recordJSON, List<CISWrapper>.class);
            if(headerId ==null || headerId.trim()==''){
                //Insert CIS header
                CIS_Header__c header = new CIS_Header__c();
                header.Month__c = monthMap.get(System.today().month());
                header.Year__c = ''+ System.today().year();
                header.Account__c = recordId;
                if(lastHeaderId !=null && lastHeaderId.trim() != ''){
                    header.Last_Month_CIS__c = lastHeaderId;
                }
                header.Status__c = 'Draft';
                insert header;
                headerId = header.Id;
                Account a = new Account();
                a.last_CIS_date__c = System.today();
                a.Id = header.Account__c;
                update a;
            }
            List<CIS_Line__c> cisLineList = new List<CIS_Line__c>();
            Set<String> lineItemToDelete = new Set<String>();
            for(CISWrapper CW : CISList){
                for(CISLineItem item : CW.CISItemList){
                    if(item.company != null && item.company.trim() !=''){
                        CIS_Line__c line = new CIS_Line__c();
                        line.id = item.id;
                        if(line.id ==null)
                            line.CIS_Header__c = headerId;
                        line.Company__c = item.company;
                        line.Product__c = item.product;
                        line.Avg_Purchase_Price__c = item.price;
                        line.No_of_Surguries__c = item.surguries;
                        line.Package_Range__c = CW.budget;
                        cisLineList.add(line);
                    }else if(item.id !=null && item.id.trim() !=''){
                        lineItemToDelete.add(item.id);
                    }
                }
            }
            if(cisLineList.size()>0){
                upsert cisLineList;
            }
            if(lineItemToDelete.size()>0){
                delete [select id from CIS_Line__c where id in:lineItemToDelete];
            }
            return headerId;
        }catch(DMLException e){
            return 'ERROR:'+e.getDMlMessage(0);
        }catch(Exception e){
            System.debug('ERROR:cis save record:::'+e.getMessage());
            return 'ERROR:'+e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string approveCISRecord(String headerId,String status,String comments){
        try{
            //Getting Work Item Id
            List<ProcessInstanceWorkitem> pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: headerId];
            if(pItem.size() > 0){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments(comments);
                req.setAction(status);
                
                
                req.setWorkitemId(pItem[0].Id);
                // Submit the request for approval
                Approval.ProcessResult result = Approval.process(req);
                return 'SUCCESS';
            }else{
                return 'Record already approved/rejected.';
            }
            
        }catch(exception e){
            return e.getMessage();
        }
    }
    
    private static List<CISWrapper> getCISRecordList(String headerId,Boolean preserveId ){
        List<CISWrapper> CISList = new List<CISWrapper>();
        MaP<String,List<CIS_Line__c>> lineMap = new MaP<String,List<CIS_Line__c>>();
        if(headerId !=null){
            List<CIS_Line__c> lineList = [SELECT Id,Company__c,Product__c,No_of_Surguries__c,Avg_Purchase_Price__c,Value__c,Package_Range__c
                                         FROM CIS_Line__c
                                         WHERE CIS_Header__c=:headerId
                                         ORDER BY CreatedDate ASC];
            for(CIS_Line__c cl : lineList){
                List<CIS_Line__c> existing = lineMap.get(cl.Package_Range__c);
                if(existing == null)
                    existing = new List<CIS_Line__c>();
                existing.add(cl);
                lineMap.put(cl.Package_Range__c,existing);
            }
        }
        for(Schema.PicklistEntry a : CIS_Line__c.Package_Range_Display__c.getDescribe().getPickListValues()){
            if(lineMap.containsKey(''+a.getValue())){
                CISList.add(new CISWrapper(a.getValue(),lineMap.get(''+a.getValue()),preserveId ));
            }else{
                CISList.add(new CISWrapper(a.getValue()));
            } 
            
        } 
        return CISList;
    }
    
    
    public Class MainWrapper{
        @AuraEnabled
        public boolean readOnly;
        @AuraEnabled
        public String error;
        @AuraEnabled
        public String headerId;
        @AuraEnabled
        public String lastHeaderId;
        @AuraEnabled
        public Decimal grandTotal;
        @AuraEnabled
        public List<CISWrapper> CISList;
        @AuraEnabled
        public List<OptionModel> companyPicklistValues;
        @AuraEnabled
        public List<OptionModel> productPicklistValues; 
        
    }
    
    public Class CISWrapper{
        
        @AuraEnabled
        public string budget;
        @AuraEnabled
        public string indicator;
        @AuraEnabled
        public Decimal totalValue;
        @AuraEnabled
        public List<CISLineItem> CISItemList;
        
        public CISWrapper(String budget){
            this.budget = budget;
            CISItemList = new List<CISLineItem>();
            CISItemList.add(new CISLineItem());
            CISItemList.add(new CISLineItem());
            CISItemList.add(new CISLineItem());
        }
        
        public CISWrapper(String budget,List<CIS_Line__c> lineList,Boolean preserveId ){
            this.budget = budget;
            CISItemList = new List<CISLineItem>();
            totalValue = 0;
            indicator = '';
            for(CIS_Line__c cl : lineList){
                if(cl.Value__c !=null)
                    totalValue += cl.Value__c;
                
                CISItemList.add(new CISLineItem(cl,preserveId ));
            }
            while(CISItemList.size() < 3){
                CISItemList.add(new CISLineItem());
            }
            if(totalValue > 0){
                indicator = '*';
            }
        }
        
    }
    
    public class CISLineItem{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String company;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public Decimal surguries;
        @AuraEnabled
        public Decimal price;
        @AuraEnabled
        public Decimal value; 
        
        public CISLineItem(){
        }
        public CISLineItem(CIS_Line__c cl,Boolean preserveId ){
            this.company = cl.Company__c;
            this.product = cl.Product__c;
            this.surguries = cl.No_of_Surguries__c;
            this.price = cl.Avg_Purchase_Price__c;
            this.value = cl.Value__c;
            if(preserveId)
                this.id = cl.Id;
        }
    }
    
    public class OptionModel{
        
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
        
        @AuraEnabled
        public string validFor;
        @AuraEnabled
        public string validForOptions;
        
        public OptionModel(string label,string value,String validForOptions){
            this.label = label;
            this.value = value;
            
            this.validForOptions = validForOptions;
        }
    }
    
}