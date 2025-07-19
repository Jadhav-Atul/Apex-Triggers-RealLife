trigger AccountTrigger on Account (before insert, after insert){
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccountTriggerHandler.beforeInsert(Trigger.new);
        }
    }
    
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AccountTriggerHandler.afterInsert(Trigger.new);
        }
    }
}