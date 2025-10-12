/**
 * Test class for ContactTriggerHelper.
 * 
 * This class validates that the ContactTriggerHelper correctly updates
 * the `Total_Contacts__c` field on related Accounts whenever Contacts
 * are inserted, updated, deleted, or undeleted.
 * 
 * Test Scenarios Covered:
 * 1. Insert Account → Verify default related Contact count.
 * 2. Insert Contact → Verify Account contact count increases.
 * 3. Update Contact to another Account → Verify counts on both Accounts adjust correctly.
 * 4. Delete and Undelete Contact → Verify Account contact count decreases and restores.
 */
@isTest 
public class ContactTriggerHelperTest{

    /**
     * Tests that `Total_Contacts__c` is correctly maintained on Accounts
     * during Contact DML operations (insert, update, delete, undelete).
     *
     * Steps:
     * - Case 1: Insert a new Account and verify `Total_Contacts__c` = 1 
     *   (due to trigger logic creating a related Contact).
     * - Case 2: Insert a Contact related to the Account and verify count increments.
     * - Case 3: Create a second Account and move a Contact to it, 
     *   verifying both Account counts are updated.
     * - Case 4: Delete and then undelete a Contact, verifying counts decrease and restore.
     */
    @isTest 
    static void testContactCount(){
       
        // Case 1: Create a new Account and verify contact count
        Account testAcc1 = new Account(Name='TestAccount1');
        insert testAcc1;

        List<Account> insertedAcc1 = [
            SELECT Id, Name,Total_Active_Contacts__c, Total_Contacts__c 
            FROM Account 
            WHERE Id =: testAcc1.Id
        ]; 
        System.assertEquals(1, insertedAcc1[0].Total_Contacts__c, 
            'New Account should have Total_Contacts__c = 1');
        System.assertEquals(0, insertedAcc1[0].Total_Active_Contacts__c, 
            'New Account should have Total Active Contacts = 0');

        // Case 2: Insert a related Contact and verify contact count
        Contact testCon1 = new Contact(LastName='TestContact1', AccountId = testAcc1.Id,IsActive__c=true);
        insert testCon1;

        List<Account> insertedAccs = [
            SELECT Id, Name,Total_Active_Contacts__c, Total_Contacts__c 
            FROM Account 
            WHERE Id =: testAcc1.Id
        ];
        System.assertEquals(2, insertedAccs[0].Total_Contacts__c, 
            'Account should have Total_Contacts__c = 2 after inserting another Contact');
        System.assertEquals(1, insertedAccs[0].Total_Active_Contacts__c, 
            'Account should have Total Active Contacts = 1 after inserting another Contact');

        // Case 3: Insert another Account and reassign Contact to it
        Account testAcc2 = new Account(Name='TestAccount2');
        insert testAcc2;

        Contact conUpdate = new Contact(Id=testCon1.Id, AccountId=testAcc2.Id);
        update conUpdate;

        List<Account> updatedAccounts = [
            SELECT Id, Name, Total_Active_Contacts__c,Total_Contacts__c 
            FROM Account 
            WHERE Id IN :new List<Id>{testAcc1.Id, testAcc2.Id}
        ];

        Map<String,Account> accToContactCountMap = new Map<String,Account>();
        for(Account ac : updatedAccounts){
            accToContactCountMap.put(ac.Name, ac);
        }

        System.assertEquals(1, accToContactCountMap.get('TestAccount1').Total_Contacts__c,
            'Original Account should have count reduced to 1');
        System.assertEquals(2, accToContactCountMap.get('TestAccount2').Total_Contacts__c,
            'New Account should have count increased to 2');
         System.assertEquals(1, accToContactCountMap.get('TestAccount2').Total_Active_Contacts__c, 
            'Account should have Total Active Contacts = 1 after inserting another Contact');

        // Case 4: Delete and undelete the Contact
        List<Contact> consToDelete = [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE AccountId =: testAcc2.Id
        ];
        delete consToDelete;

        List<Account> insAccs = [
            SELECT Id, Name, Total_Contacts__c 
            FROM Account 
            WHERE Id =: testAcc2.Id
        ];
        System.assertEquals(0, insAccs[0].Total_Contacts__c, 
            'After delete, Account should have Total_Contacts__c = 0');

        // Undelete the Contact
        undelete consToDelete;

        List<Account> undeletedAccs = [
            SELECT Id, Name, Total_Contacts__c 
            FROM Account 
            WHERE Id =: testAcc2.Id
        ];
        System.assertEquals(2, undeletedAccs[0].Total_Contacts__c, 
            'After undelete, Account should have Total_Contacts__c = 2 again');
    }
}
