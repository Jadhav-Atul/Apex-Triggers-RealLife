/**
 * Helper class for Contact Trigger.
 * 
 * This class is responsible for maintaining the `Total_Contacts__c` field 
 * on the Account object whenever Contacts are inserted, updated, deleted, or undeleted.
 * 
 * Key responsibilities:
 * - Identifies related Account Ids when Contact records are modified.
 * - Aggregates the count of active Contacts per Account.
 * - Updates the Account's `Total_Contacts__c` field accordingly.
 */
public class ContactTriggerHelper{

    /**
     * Updates the `Total_Contacts__c` field on related Accounts 
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
            SELECT AccountId, Count(Id) contactCount 
            FROM Contact 
            WHERE AccountId IN :accIdSet 
            GROUP BY AccountId
        ];

        // Create a Map to store AccountId → Account
        Map<Id,Account> accIdToAccMap = new Map<Id,Account>();

        for(AggregateResult agg : aggResult){
            Account a = new Account(
                Id = (Id)agg.get('AccountId'),
                Total_Contacts__c = (Integer)agg.get('contactCount')
            );
            accIdToAccMap.put(a.Id,a);
        }

        // If an Account has no child contacts, set Total Contacts = 0
        for(Id i : accIdSet){
            if(!accIdToAccMap.keySet().contains(i)){
                Account ac = new Account(Id=i, Total_Contacts__c=0);
                accIdToAccMap.put(i,ac);           
            }
        }

        // Update the Accounts
        if(!accIdToAccMap.values().isEmpty()){
            update accIdToAccMap.values();
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
            if(oldContact!=NULL && oldContact.AccountId!= newContact.AccountId){
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
