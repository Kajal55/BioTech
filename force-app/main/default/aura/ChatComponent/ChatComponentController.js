({
    /* Calling server side controller to get the current logged in User details */
    doInit :  function(component, event, helper){
        //console.log('Initializing');
        var action=component.get("c.getCurrentUser");
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){ 
                component.set("v.currentUser",response.getReturnValue());
            }
            else
                console.log(response.getState()); 
        });
        $A.enqueueAction(action);
    },
    
    /* Subscribing/Unsubscribing to the channel depending upon subscription state */
    handleSubscription  : function(component, event, helper) {
        //console.log('handleSubscription Called'); 
        
        //If subscribed, call unsubscribe helper method, else call subscribe helper method
       /* if(component.get("v.isSubscribed"))
            helper.unsubscribe(component, event, helper);
        else{
            helper.subscribe(component, event, helper);
            console.log('response::::1111');
            // Calling helper method to get the users subscribed to that channel
            window.setTimeout(
                $A.getCallback(function() {
                    helper.getOnlineUsers(component, event)
                }), 1000
            ); 
        }*/
        
          $A.createComponent(
            "c:ChatPopup",
            {
               
              
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    console.log('target comp:::::'+targetCmp);
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
    },
    
    /* Calling helper method to get the users subscribed to that channel */
    refreshUserlist : function(component, event, helper) {
        helper.getOnlineUsers(component, event);
    },
    
    /* Open the chat window, upon user selection */
    selectChatUser : function(component, event, helper){
        //console.log('selectChatUser called');
        component.set("v.selectedUserId",event.currentTarget.dataset.id);
        component.set("v.selectedUserName",event.currentTarget.dataset.name);
        // component.set("v.showChatBox",true);
        // component.set("v.isChatActive",true);
        console.log('selectedUserId::::'+event.currentTarget.dataset.id);
        console.log('selectedUserName::::'+event.currentTarget.dataset.name);
        $A.createComponent(
            "c:ChatWindow",
            {
                "selectedUserId": event.currentTarget.dataset.id.toString(50),
                "selectedUserName": event.currentTarget.dataset.name.toString(50),
                "message":""
              
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    console.log('target comp:::::'+targetCmp);
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
        
    },
    
    /* Calling server side controller to push the generic event with user message
     * and helper method to push the user message on Chat window
     */
    sendMessage :  function(component, event, helper) {
        //console.log('Sending Message');
        var message=component.find("inputMessage").get("v.value");
        
        //calling server side controller to push the generic event with user message
        var action=component.get("c.publishStreamingEvent");
        action.setParams({
            "message" : message,
            "userID"  : component.get("v.selectedUserId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue()===200)
                    component.find("inputMessage").set("v.value",'');
                helper.handleOutboundMessage(component, event, message); //Calling helper to push message on chat window
            }
            else
                console.log(response.getState()); 
        });
        $A.enqueueAction(action);
    },
    
    /* Closing chat window */
    removeComponent:function(cmp,event){
        console.log('inside remove controller::::');
        //get the parameter you defined in the event, and destroy the component
        var comp = event.getParam("comp");		
        comp.destroy();
    },
    createComp:function(cmp,event){
        var params = event.getParam('arguments');
                console.log('param1::'+params.param1+'param2:::'+params.param2+'::param3::'+params.param3);

        if (params) {
            var userid = params.param1;
            var username = params.param2;
            var message = params.param3;
            // add your code here
        }
        $A.createComponent(
            "c:ChatWindow",
            {
                "selectedUserId": userid,
                "selectedUserName": username,
                "message": message
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
         
    },
    setUtilityIcon : function(component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.openUtility("utilitybar_window")
    }, 
   
})