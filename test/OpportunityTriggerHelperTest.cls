/**
 * @description
 * Test class for verifying the functionality of **OpportunityTrigger** 
 * and its underlying handler/helper logic.
 * 
 * This class tests the Account roll-up fields (Highest Opportunity Amount 
 * and Last Opportunity Close Date) that are automatically updated whenever 
 * Opportunities are **inserted**, **updated**, **deleted**, or **undeleted**.
 * 
 * @testClass
 * This test class ensures that:
 *   1. Account fields are updated correctly after Opportunity insert.
 *   2. Account fields recalculate correctly after Opportunity update or reassignment.
 *   3. Account fields reset and restore correctly on delete and undelete events.
 * 
 * @see OpportunityTrigger
 * @see OpportunityTriggerHandler
 * @see OpportunityTriggerHelper
 */
@isTest
public class OpportunityTriggerHelperTest {

    /**
     * @description
     * Test case: After inserting multiple Opportunities related to the same Account,
     * verify that the Account roll-up fields (Highest_Opportunity_Amount__c and 
     * Last_Opportunity_Close_Date__c) are updated correctly.
     * 
     * @expected
     * Account.Highest_Opportunity_Amount__c = Highest amount among related Opportunities  
     * Account.Last_Opportunity_Close_Date__c = Most recent close date among related Opportunities
     */
    @isTest
    static void testInsertOpportunityUpdatesAccountRollup() {
        // Create parent Account
        Account a1 = new Account(Name = 'A1');
        insert a1;

        // Create related Opportunities
        Opportunity o1 = new Opportunity(
            Name = 'O1', 
            AccountId = a1.Id, 
            StageName = 'Prospecting', 
            CloseDate = Date.today().addDays(30), 
            Amount = 1000
        );
        Opportunity o2 = new Opportunity(
            Name = 'O2', 
            AccountId = a1.Id, 
            StageName = 'Closed Won', 
            CloseDate = Date.today().addDays(-2), 
            Amount = 2000
        );

        // Insert Opportunities and trigger rollup logic
        Test.startTest();
        insert new List<Opportunity>{ o1, o2 };
        Test.stopTest();
        
        // Validate updated rollup fields on Account
        a1 = [SELECT Highest_Opportunity_Amount__c, Last_Opportunity_Close_Date__c 
              FROM Account WHERE Id = :a1.Id];
        System.assertEquals(2000, a1.Highest_Opportunity_Amount__c, 
            'Highest amount should match the highest Opportunity amount.');
        System.assertEquals(Date.today().addDays(-2), a1.Last_Opportunity_Close_Date__c, 
            'Last close date should match the most recent Opportunity close date.');
    }

    /**
     * @description
     * Test case: Verify that Account rollup values are recalculated correctly 
     * when Opportunity Amount or Account association changes.
     * 
     * @expected
     * 1. Updating Opportunity.Amount should update the Account’s highest amount.  
     * 2. Reassigning Opportunity to another Account should recalculate both Accounts correctly.
     */
    @isTest
    static void testUpdateOpportunityUpdatesAccountRollup() {
        // Setup two Accounts
        Account a1 = new Account(Name = 'A1');
        Account a2 = new Account(Name = 'A2');
        insert new List<Account>{ a1, a2 };

        // Create Opportunity under first Account
        Opportunity o = new Opportunity(
            Name = 'O1',
            AccountId = a1.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 1000
        );
        insert o;

        // Update Opportunity amount and validate recalculation
        o.Amount = 1500;
        Test.startTest();
        update o;
        Test.stopTest();

        // Validate updated rollup for Account A1
        a1 = [SELECT Highest_Opportunity_Amount__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(1500, a1.Highest_Opportunity_Amount__c, 
            'Account A1 rollup should reflect updated Opportunity amount.');

        // Move Opportunity from A1 to A2
        o.AccountId = a2.Id;
        update o;

        // Validate recalculated values for both Accounts
        a1 = [SELECT Highest_Opportunity_Amount__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(0, a1.Highest_Opportunity_Amount__c, 
            'Account A1 should reset rollup after Opportunity reassignment.');

        a2 = [SELECT Highest_Opportunity_Amount__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(1500, a2.Highest_Opportunity_Amount__c, 
            'Account A2 should now reflect the reassigned Opportunity’s amount.');
    }

    /**
     * @description
     * Test case: Verify that Account roll-up fields are updated correctly 
     * when Opportunities are deleted and undeleted.
     * 
     * @expected
     * - After delete: Account roll-up fields should reset to zero/null.
     * - After undelete: Account roll-up fields should restore previous values.
     */
    @isTest
    static void testDeleteUndeleteOpportunityUpdatesAccountRollUp() {
        // Create parent Account
        Account a1 = new Account(Name = 'A1');
        insert a1;

        // Create and insert Opportunity
        Opportunity o = new Opportunity(
            Name = 'O1',
            AccountId = a1.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 5000
        );
        insert o;

        // Validate roll-up after insert
        a1 = [SELECT Highest_Opportunity_Amount__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(5000, a1.Highest_Opportunity_Amount__c, 
            'Rollup should reflect inserted Opportunity amount.');

        // Delete Opportunity and validate roll-up reset
        Test.startTest();
        delete o;
        Test.stopTest();

        a1 = [SELECT Highest_Opportunity_Amount__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(0, a1.Highest_Opportunity_Amount__c, 
            'Rollup should reset after Opportunity deletion.');

        // Undelete Opportunity and validate restoration
        undelete o;

        a1 = [SELECT Highest_Opportunity_Amount__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(5000, a1.Highest_Opportunity_Amount__c, 
            'Rollup should restore after Opportunity undelete.');
    }
}
