trigger OpportunityTrigger on Opportunity(after insert,after update, after delete, after undelete){

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OpportunityTriggerHandler.afterInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            OpportunityTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }else if(Trigger.isDelete){
            OpportunityTriggerHandler.afterDelete(Trigger.oldMap);
        }else if(Trigger.isUndelete){
            OpportunityTriggerHandler.afterUndelete(Trigger.new);
        }
    }
}