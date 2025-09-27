/**
 * ContactTriggerHandler class
 * 
 * This class serves as the trigger handler for Contact object events.
 * It delegates logic to the ContactTriggerHelper class to maintain 
 * the `Total_Contacts__c` field on related Accounts whenever Contact 
 * records are inserted, updated, deleted, or undeleted.
 * 
 * Responsibilities:
 * - Handle Contact trigger events (`after insert`, `after update`, 
 *   `after delete`, `after undelete`).
 * - Pass the appropriate `new` and `old` values to the helper class.
 */
public class ContactTriggerHandler{

    /**
     * Handles the `after insert` trigger event for Contacts.
     * Delegates to ContactTriggerHelper to update Account contact counts.
     *
     * @param newConList  List of newly inserted Contact records (Trigger.new).
     */
    public static void afterInsert(List<Contact> newConList){
        ContactTriggerHelper.updateContactCountOnAccount(newConList, NULL);
    }

    /**
     * Handles the `after update` trigger event for Contacts.
     * Delegates to ContactTriggerHelper to update Account contact counts 
     * when Contact-Account relationships may have changed.
     *
     * @param newConList  List of updated Contact records (Trigger.new).
     * @param oldConMap   Map of old Contact records with Id as key (Trigger.oldMap).
     */
    public static void afterUpdate(List<Contact> newConList, Map<Id,Contact> oldConMap){
        ContactTriggerHelper.updateContactCountOnAccount(newConList, oldConMap);
    }

    /**
     * Handles the `after delete` trigger event for Contacts.
     * Delegates to ContactTriggerHelper to update Account contact counts 
     * after related Contacts are removed.
     *
     * @param oldConMap   Map of deleted Contact records with Id as key (Trigger.oldMap).
     */
    public static void afterDelete(Map<Id,Contact> oldConMap){
        ContactTriggerHelper.updateContactCountOnAccount(oldConMap.values(), NULL);
    }

    /**
     * Handles the `after undelete` trigger event for Contacts.
     * Delegates to ContactTriggerHelper to update Account contact counts 
     * when Contacts are restored from the Recycle Bin.
     *
     * @param newConList  List of undeleted Contact records (Trigger.new).
     */
    public static void afterUndelete(List<Contact> newConList){
        ContactTriggerHelper.updateContactCountOnAccount(newConList, NULL);
    }
}
