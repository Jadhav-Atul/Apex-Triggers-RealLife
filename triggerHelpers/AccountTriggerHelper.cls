public class AccountTriggerHelper{

    //Create a related contact on Account Insert
    public static void createContacts(List<Account> newAccList){
        List<Contact> consToInsert = new List<Contact>();

        for(Account acc : newAccList){
            if(String.isNotBlank(acc.Name)){
                Contact con = new Contact(
                    LastName = acc.Name,
                    Email = 'info@'+acc.Name.replaceAll('\\s+', '').toLowerCase() +'.com' , 
                    AccountId = acc.Id,
                    Description = 'This contact is created by the trigger on Account Object'
                );
                consToInsert.add(con);
            }
        }

        if(!consToInsert.isEmpty()){
            insert consToInsert;
        }
    }

    //Update Account's custom field 'Account_Status__c' to 'New', if left blank while inserting Account
    public static void populateStatus(List<Account> newAccList){

        for(Account acc : newAccList){
            if(String.isBlank(acc.Account_Status__c)){
                acc.Account_Status__c = 'New';
            }
        }
    }

}