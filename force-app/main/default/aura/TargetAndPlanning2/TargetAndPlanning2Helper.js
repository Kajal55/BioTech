({
    createColumn : function(component,event,columnData) {
        var col = [];
        var accCol = {label: 'Account Names', fieldName: 'AccountName',type: 'text'};
        col.push(accCol);
        for( var i = 0; i < columnData.length; i++ ){
            var colObj = {label: columnData[i].Name, fieldName: 'Name',type: 'text',editable: 'true'};
            col.push(colObj);
            
        }
        
        component.set("v.columns",col);
        this.getMonthlyPlanAndAccount(component,event);
        
        /* myAssociativeArr.push({
                label: columnData[i].Product__r.Name,
                fieldName: 'Name',
                type: 'text'
            });
            */
    },
    
    getMonthlyPlanAndAccount :function(component,event) {
        var action2 = component.get("c.getAccounts");
        action2.setParams({
            month: 'Feb',
            year: '2019'
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //var retData = response.getReturnValue();
                //const aops = [];
                // console.log( "In Trget&PlaningComp2-->H-->getMonthlyPlanAndAccount_M--> ret Acc-->" +JSON.stringify(retData));
                
               // if (!$A.util.isEmpty(retData)) {
                    var rows = response.getReturnValue();
                    for (var i = 0; i < rows.length; i++) {
                        var row = rows[i];
                        if (row.Account__c) row.AccountName = row.Account__r.Name;
                    }
                    component.set('v.data', rows);
               // }
            }
        });
        
        $A.enqueueAction(action2);
    }
})