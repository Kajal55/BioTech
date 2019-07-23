({
	/* Subscribing to the channel */
    subscribe : function(component, event, helper) {
        
        var empApi = component.find("empApi");
        var channel = component.get("v.channelName");
        var replayId = -1;
		var callback = function (message) {
            /*
            console.log("Received [" + message.channel +
                        " : " + message.data.event.replayId + "] payload=" +
                        JSON.stringify(message.data.payload)
                       );
            */
            
        /* Extracting payload, userId and username from the message
         * and setting the attributes accordingly
         */    
            
            console.log("Subscribe function called");
            var payload=JSON.stringify(message.data.payload);
            var s=payload.substring(1);
			s=s.substring(0,s.length-1);
			var i=s.indexOf('`');
			var message=s.substring(0,i);
            var FromUserid=s.substring(i+1,i+19);
            var FromUserName=s.substring(i+19);
            
             if(FromUserid!=component.get("v.selectedUserId") ){
                 if(component.get("v.selectedUserId")!=null ){
                 console.log("inside if Subscribe11"+component.get("v.selectedUserName")); 
                 var targetCmp = component.find('ModalDialogPlaceholder');
                  
               // this.handleInboundMessage(component, event, message,FromUserid,FromUserName);

            //	var objCompB = component.find("compB");
                     
              //        objCompB.sampleMethod(FromUserid, FromUserName,message);
                     
       			
                //   component.set("v.selectedUserId",FromUserid);
                
                     return;
               
                 }
            }else{
             // this.handleInboundMessage(component, event, message,FromUserid,FromUserName);       
            }
         
            //Calling helper method to push the message to the chat window

 		console.log("inside if Subscribe3311");                
        }.bind(this);
        
		var errorHandler = function (message) {
                    console.log("Received error ", JSON.stringify(message) );
                }.bind(this);
		empApi.onError(errorHandler);
        
		var sub;
      	empApi.subscribe(channel, replayId, callback).then(function(value) {
          	console.log("Subscribed to channel " + channel);
          	sub = value;
          	component.set("v.sub", sub);
          	component.set("v.isSubscribed",true);
            
        });
    },
    
    /* Unsubscribing to the channel */
    unsubscribe : function(component, event, helper) {
        //console.log("Unsubscribe function called");
        
        var empApi = component.find("empApi");
        var channel = component.get("v.channelName");
        var callback = function (message) {
            console.log("Unsubscribed from channel " + channel);
        }.bind(this);

        var errorHandler = function (message) {
            console.log("Received error ", message);
        }.bind(this);

        var sub = {"id": component.get("v.sub")["id"],
                    "channel": component.get("v.sub")["channel"]};

        empApi.onError(errorHandler);
		empApi.unsubscribe(sub, callback);
        component.set("v.isSubscribed",false);
        component.set("v.showChatBox",false);
    },
    
    /* Calling server side controller to get the list of users subscribed to the streaming channel */
   
    
    /* Pushing the received message to chat window */
    handleInboundMessage : function(component, event, message,userid,username){
        console.log("Incoming message1111"+component.get("v.selectedUserId")+'::incoming userid:::'+userid+'::message'+message);
        component.set("v.showChatBox",true);
        
         /* if(userid!=component.get("v.selectedUserId") ){
           
            	component.set("v.isChatActive",true);
                component.set("v.selectedUserId",userid);
        		component.set("v.selectedUserName",username);
              component.set("v.message",message);
          }*/
            
         if(userid==component.get("v.selectedUserId")){
        var ul = document.getElementById("ChatList");
    	var li = document.createElement("li");
    	li.setAttribute("class","slds-chat-listitem slds-chat-listitem_inbound");
    	li.innerHTML ='<div class="slds-chat-message">'+
                           '<div class="slds-chat-message__body">'+
                                     '<div class="slds-chat-message__text slds-chat-message__text_inbound">'+
                                         '<span>'+message+'</span>'+
                                     '</div>'+
                           '</div>'+
                        '</div>';
        ul.appendChild(li);
         
        }
        
         if(userid!=component.get("v.selectedUserId") ){
           if(!component.get("v.isChatActive")){
            	component.set("v.isChatActive",true);
                component.set("v.selectedUserId",userid);
        		component.set("v.selectedUserName",username);
            }
             var comp=component;
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
                   //component.sampleMethod1();
                   comp.destroy();
                }
            }
         );
             
         }else{
             console.log('selectedUserId111::::') ;
             
         }
        
        
       
        /*else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef  : "c:ChatWindowHelper" ,
                componentAttribute : {
                    selectedUserId : userid,
                    selectedUserName : username
            }
        });    
        evt.fire();
     
        }*/
    },
    
    /* Pushing the sent message to chat window */
    handleOutboundMessage : function(component, event, message){
        console.log('Outbound message:::'+message);
        var ul = document.getElementById("ChatList");
    	var li = document.createElement("li");
    	li.setAttribute("class","slds-chat-listitem slds-chat-listitem_outbound");
    	li.innerHTML ='<div class="slds-chat-message">'+
                           '<div class="slds-chat-message__body">'+
                                     '<div class="slds-chat-message__text slds-chat-message__text_outbound">'+
                                         '<span>'+message+'</span>'+
                                     '</div>'+
                           '</div>'+
                        '</div>';
        ul.appendChild(li);
    },
    closeMe : function(comp, event, helper)  { 
        comp.destroy();
	},
     getOnlineUsers :  function(component, event){
        //console.log('getOnlineUsers  called');
        var action=component.get("c.getOnlineUsers");
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){ 
                //console.log(response.getReturnValue());
                console.log('response::::'+response.getReturnValue());
                component.set("v.UserList",response.getReturnValue());
            }
            else
               console.log(response.getState()); 
        });
        $A.enqueueAction(action);
    },
    
})