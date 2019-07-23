({
	/* Calling server side controller to get the current logged in User details */
    doInit :  function(component, event, helper){
        var bool=false;
        console.log('Initializing');
        var action=component.get("c.getCurrentUser");
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                console.log('Initializing message:::'+component.get("v.message"));

                 var message=component.get("v.message");
                
                var ul = document.getElementById("ChatList");
    	var li = document.createElement("li");
                console.log('Ul list::::'+ul);
    	li.setAttribute("class","slds-chat-listitem slds-chat-listitem_inbound");
    	li.innerHTML ='<div class="slds-chat-message">'+
                           '<div class="slds-chat-message__body">'+
                                     '<div class="slds-chat-message__text slds-chat-message__text_inbound">'+
                                         '<span>'+message+'</span>'+
                                     '</div>'+
                           '</div>'+
                        '</div>';
        ul.appendChild(li);
                 console.log('Initializing success');
                
                component.set("v.currentUser",response.getReturnValue());
                 var a = component.get('c.handleSubscription');
       			 $A.enqueueAction(a);
                return;
            }
            else
               console.log(response.getState()); 
        });
        $A.enqueueAction(action);
       
    },
    
    /* Subscribing/Unsubscribing to the channel depending upon subscription state */
    handleSubscription  : function(component, event, helper) {
        console.log('handleSubscription Called'); 
        
        //If subscribed, call unsubscribe helper method, else call subscribe helper method
        if(component.get("v.isSubscribed"))
            helper.unsubscribe(component, event, helper);
        else{
            helper.subscribe(component, event, helper);
            console.log('response::::1111');
            //Calling helper method to get the users subscribed to that channel
           /*window.setTimeout(
    $A.getCallback(function() {
       helper.getOnlineUsers(component, event)
    }), 1000
); */
        }
    },
    
    /* Calling helper method to get the users subscribed to that channel */
    refreshUserlist : function(component, event, helper) {
        helper.getOnlineUsers(component, event);
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
     applycss:function(cmp,event){
	//initialize        
        var cmpTarget = cmp.find('Modalbox');
       	var cmpBack = cmp.find('MB-Back');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    removeComponent:function(component, event, helper){
        //get event and set the parameter of Aura:component type, as defined in the event above.
        
        console.log('inside remove comp::::');
        var compEvent = component.getEvent("RemoveComponent");
        compEvent.setParams({
        	"comp" : component
        });
	compEvent.fire();
    }
})