trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    AccountTriggerHandler.setApproverOnAccountWhenOwnerIsChanged(Trigger.new, Trigger.operationType);
}