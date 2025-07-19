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

    //Sync Account Phone to Contact.Account_Phone__c on update
    public static void syncAccountPhone(List<Account> newAccList, Map<Id,Account> oldAccMap){
        //Fetch accounts with updated phones
        Map<Id,String> accIdToPhoneMap = new Map<Id,String>();

        for(Account acc : newAccList){
            Account oldAc = (oldAccMap!=NULL)? oldAccMap.get(acc.Id) : NULL;

            if(acc.Phone != oldAc.Phone){               //Updated phones on account
                accIdToPhoneMap.put(acc.Id, acc.Phone);
            }
        }

        if(accIdToPhoneMap.isEmpty()) return;

        //Fetch contacts for updated accounts
        List<Contact> consToUpdate = [
            SELECT Id, AccountId, Account_Phone__c
            FROM Contact
            WHERE AccountId IN : accIdToPhoneMap.keySet()
        ];

        //Update contact phones
        for(Contact con : consToUpdate){
            con.Account_Phone__c = accIdToPhoneMap.get(con.AccountId);
        }

        if(!consToUpdate.isEmpty()){
            update consToUpdate;
        }


    }

}