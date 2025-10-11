public class OpportunityTriggerHandler{
    public static void afterInsert(List<Opportunity> newOppList){
        OpportunityTriggerHelper.updateOpportunityFieldsOnAccount(newOppList, NULL);
    }

    public static void afterUpdate(List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap){
        OpportunityTriggerHelper.updateOpportunityFieldsOnAccount(newOppList, oldOppMap);
    }

    public static void afterDelete(Map<Id,Opportunity> oldOppMap){
        OpportunityTriggerHelper.updateOpportunityFieldsOnAccount(oldOppMap.values(),NULL);
    }

    public static void afterUndelete(List<Opportunity> newOppList){
        OpportunityTriggerHelper.updateOpportunityFieldsOnAccount(newOppList, NULL);
    }
}