public class AccountTriggerHandler{
    
    public static void beforeInsert(List<Account> newAccList){
        AccountTriggerHelper.populateStatus(newAccList);
    }

    public static void beforeUpdate(List<Account> newAccList, Map<Id,Account> oldAccMap){
        AccountTriggerHelper.syncAccountPhone(newAccList, oldAccMap);
    }

    public static void afterInsert(List<Account> newAccList){
       AccountTriggerHelper.createContacts(newAccList);
    }
}