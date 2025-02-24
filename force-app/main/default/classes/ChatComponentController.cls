public class ChatComponentController {
    
    //WrapperClass to handle the GET callout response 
    public class ChannelResponse{
        public string ChannelName;
        public string[] OnlineUserIds;
    }
    
    //To get the details of current logged in User
    @AuraEnabled
    public static user getCurrentUser(){
       return [select id,firstname,lastName from user where id=:userinfo.getUserId()];
    }
    
    //Callout to the API to push the generic event on the channel 
    @AuraEnabled
    public static integer publishStreamingEvent(string message,string userID){
        
        //Calling helper function to make the API callout
        httpresponse response=makeCallout('POST', message, userID);
        return response.getStatusCode();
    }
    
    //Callout to get the list of users subscribed on to the channel
    @AuraEnabled
    public static user[] getOnlineUsers(){
        set<id> UserIds=new set<id>();
        httpResponse response=makeCallout('GET', NULL, NULL);
        ChannelResponse ResponseObject=new ChannelResponse();
        ResponseObject=(ChannelResponse)JSON.deserialize(response.getBody(), ChannelResponse.class);
        
        for(string UserId: ResponseObject.OnlineUserIds ){
            UserIds.add(UserId);
        }
        
        return [select id,name,firstname,lastName from user where id in :UserIds];        
    }
    
    //Helper function to making the callouts
    private static httpresponse makeCallout(string method, string message, string userId){
        
        string BaseUrl=system.Url.getOrgDomainUrl().toExternalForm();
        http http = new http();
        httprequest request= new httprequest();
        request.setMethod(method);
        request.setEndpoint(BaseUrl+'/services/data/v44.0/sobjects/StreamingChannel/0M60l00000000FL/push');
        request.setHeader('Authorization', 'Bearer ' + getSessionIdFromVfPage());
        request.setHeader('Content-Type','application/json; charset=UTF-8');
	request.setHeader('Accept','application/json');
        if(method=='POST')
	    request.setBody('{"pushEvents": [{"payload": "'+message+'`'+userinfo.getUserId()+userinfo.getName()+'","userIds": ["'+userId+'"]}]}');
        
        httpresponse response=http.send(request);
        return response;
    }
    
    //Extracting session ID from VF page content
    private static string getSessionIdFromVfPage(){
        PageReference visualforcePage = Page.SessionIdPage;
        String content;
        try{
            content = visualforcePage.getContent().toString();
        }
        catch(VisualforceException e){
            content='ID'+userinfo.getSessionId()+'END';
		}
        Integer s = content.indexOf('ID') + 'ID'.length();
        Integer e = content.indexOf('END');
        return content.substring(s, e);
    }
    
  /*  @AuraEnabled
    public static PageReference getRedirect(String userid,String username,String msg){
        //String userId = UserInfo.getUserId();
        PageReference pageRef = new PageReference('/apex/vfchatPopup');
        pageRef.getParameters().put('UserId',userId);
        pageRef.getParameters().put('username',username);
        pageRef.getParameters().put('message',msg);
        pageRef.setRedirect(true);
        return pageRef;
    }*/

}