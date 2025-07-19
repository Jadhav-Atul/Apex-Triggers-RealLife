public class AccountTriggerHelper{

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
}