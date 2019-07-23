({
    init: function (cmp, event, helper) {
        var action = cmp.get('c.getEvent');
        console.log('In method');
        action.setCallback(this,function(response){
            console.log('response : ',response);
			console.log('Respose from class : ',response.getReturnValue());
            cmp.set('v.list',response.getReturnValue());
        });
        $A.enqueueAction(action);

    }
})