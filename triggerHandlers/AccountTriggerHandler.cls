public class AccountTriggerHandler{
    public static void afterInsert(List<Account> newAccList){
       AccountTriggerHelper.createContacts(newAccList);
    }
}