public class AccountProcessHandlerQueueable implements Queueable {
    List<Monthly_Product_Plan__c> mppToUpdate = new List<Monthly_Product_Plan__c>();
    public AccountProcessHandlerQueueable(List<Monthly_Product_Plan__c> mppsToUpdate){
      this.mppToUpdate = mppsToUpdate;  
    }
    public void execute(QueueableContext context) {
        System.debug('ZZZ In AccountProcessHandlerQueueable.cls-->execute_M-->MPP2UPDATE LST SIZE-->'+mppToUpdate.size());
        if(!mppToUpdate.isEmpty()){
        	update mppToUpdate;        
        }
		
    }
}