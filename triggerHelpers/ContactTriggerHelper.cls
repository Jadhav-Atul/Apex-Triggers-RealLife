/**
 * Helper class for Contact Trigger.
 * 
 * This class is responsible for maintaining the `Total_Contacts__c` and `Total_Active_Contacts__c` field 
 * on the Account object whenever Contacts are inserted, updated, deleted, or undeleted.
 * 
 * Key responsibilities:
 * - Identifies related Account Ids when Contact records are modified.
 * - Updates the Account's `Total_Contacts__c` and `Total_Active_Contacts__c` fields accordingly.
 */
public class ContactTriggerHelper{

    /**
     * Updates the `Total_Contacts__c`and `Total_Active_Contacts__c` fields on related Accounts 
     * whenever Contact records are inserted, updated, deleted, or undeleted.
     *
     * @param newConList   List of new Contact records (from Trigger.new or Trigger.newMap.values()).
     * @param oldConMap    Map of old Contact records with Id as key (from Trigger.oldMap).
     */
    public static void updateContactCountOnAccount(List<Contact> newConList, Map<Id,Contact> oldConMap){
        // Create a set to store the Account Ids
        Set<Id> accIdSet = getAccountIds(newConList, oldConMap);

        // Fetch the Aggregate result (count of Contacts per Account)
        List<AggregateResult> aggResult = [
            SELECT AccountId,IsActive__c, Count(Id) contactCount 
            FROM Contact 
            WHERE AccountId IN :accIdSet 
            GROUP BY AccountId,IsActive__c
        ];

        //Map to store AccountId and Total Active Contacts
        Map<Id,Integer> accIdToTotalActiveContactCountMap = new Map<Id,Integer>();
        //Map to store AccountId and Total Contacts
        Map<Id,Integer> accIdToTotalContactCountMap = new Map<Id,Integer>();
        for(AggregateResult ag : aggResult){
            Id accId = (Id)ag.get('AccountId');
            Boolean isActive = (Boolean)ag.get('IsActive__c');
            Integer totalCount = (Integer)ag.get('contactCount');

            //Add total contact count map
            accIdToTotalContactCountMap.put(accId, accIdToTotalContactCountMap.containsKey(accId)?accIdToTotalContactCountMap.get(accId)+totalCount : totalCount);

            //Add total active acount count
            if(isActive==true){
                accIdToTotalActiveContactCountMap.put(accId, accIdToTotalActiveContactCountMap.containsKey(accId)?accIdToTotalActiveContactCountMap.get(accId)+totalCount : totalCount);
            }
        }
        
        //List to store accounts to be updated
        List<Account> accountsToUpdate = new List<Account>();
        for(Id i : accIdSet){
            Integer totalActiveContacts = (accIdToTotalActiveContactCountMap.containsKey(i)) ? accIdToTotalActiveContactCountMap.get(i) : 0;
            Integer totalContactCount = (accIdToTotalContactCountMap.containsKey(i)) ? accIdToTotalContactCountMap.get(i) : 0;
            Account a = new Account(Id=i);
            a.Total_Active_Contacts__c = totalActiveContacts;
            a.Total_Contacts__c = totalContactCount;
            accountsToUpdate.add(a);
        }

        // Update the Accounts
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }

    /**
     * Extracts the Account Ids that are affected by Contact DML operations.
     * 
     * This method checks both old and new values of Contact records to determine:
     * - Inserted or undeleted Contacts with AccountId.
     * - Deleted Contacts (using old AccountId).
     * - Updated Contacts where AccountId was changed.
     *
     * @param newConList   List of new Contact records (from Trigger.new or Trigger.newMap.values()).
     * @param oldConMap    Map of old Contact records with Id as key (from Trigger.oldMap).
     * @return             Set of Account Ids that need to be recalculated.
     */
    private static Set<Id> getAccountIds(List<Contact> newConList, Map<Id,Contact> oldConMap){
        // Set to store the Account Ids
        Set<Id> accIds = new Set<Id>();

        for(Contact newContact : newConList){
            Contact oldContact = (oldConMap!=NULL)? oldConMap.get(newContact.Id) : NULL;

            // Insert or Undelete
            if(oldConMap==NULL && newContact.AccountId!=NULL){
                accIds.add(newContact.AccountId);
            }

            // Update (AccountId changed)
            if(oldContact!=NULL && ((oldContact.AccountId!= newContact.AccountId) || (oldContact.IsActive__c!= newContact.IsActive__c))){       //This line is changed during Trigger 6:-> '|| (oldContact.IsActive__c!= newContact.IsActive__c)'
                if(newContact.AccountId!=NULL){
                    accIds.add(newContact.AccountId);
                }
                if(oldContact.AccountId!=NULL){
                    accIds.add(oldContact.AccountId);
                }
            }
        }
        return accIds;
    }
}