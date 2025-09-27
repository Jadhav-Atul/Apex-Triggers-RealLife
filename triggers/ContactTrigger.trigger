trigger ContactTrigger on Contact(after insert, after update, after delete, after undelete){

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContactTriggerHandler.afterInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            ContactTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }else if(Trigger.isDelete){
            ContactTriggerHandler.afterDelete(Trigger.oldMap);
        }else if(Trigger.isUndelete){
            ContactTriggerHandler.afterUndelete(Trigger.new);
        }
    }

}