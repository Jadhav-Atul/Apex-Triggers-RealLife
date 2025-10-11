/**
 * @description
 * Helper class for Opportunity trigger operations.
 * 
 * This class contains reusable methods to update related Account fields
 * whenever Opportunity records are inserted, updated, deleted, or undeleted.
 * 
 * Specifically, it:
 *  - Calculates the highest Opportunity Amount for each related Account.
 *  - Identifies the latest Opportunity Close Date among 'Closed Won' opportunities.
 *  - Updates Account fields:
 *        - Highest_Opportunity_Amount__c
 *        - Last_Opportunity_Close_Date__c
 * 
 * The helper ensures bulk-safe operations and can be reused across trigger contexts.
 */
public class OpportunityTriggerHelper {

    /**
     * @description
     * Updates Account fields based on related Opportunity changes.
     * 
     * This method identifies Accounts affected by insert, update, delete, or undelete
     * events on Opportunity records and updates two custom fields on Account:
     * 
     *  - Highest_Opportunity_Amount__c: Stores the maximum Opportunity Amount.
     *  - Last_Opportunity_Close_Date__c: Stores the most recent 'Closed Won' Close Date.
     * 
     * @param newOppList   List of new Opportunity records (Trigger.new).
     * @param oldOppMap    Map of old Opportunity records (Trigger.oldMap).
     * 
     * @example
     * OpportunityTriggerHelper.updateOpportunityFieldsOnAccount(Trigger.new, Trigger.oldMap);
     */
    public static void updateOpportunityFieldsOnAccount(List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap) {

        // Identify all Accounts impacted by Opportunity changes
        Set<Id> affectedAccIds = getAffectedAccIds(newOppList, oldOppMap);

        // Query: Get maximum Opportunity Amount per Account
        List<AggregateResult> aggResult = [
            SELECT AccountId, MAX(Amount) maxAmount
            FROM Opportunity
            WHERE AccountId IN :affectedAccIds
            GROUP BY AccountId
        ];

        // Query: Get latest CloseDate of 'Closed Won' Opportunities per Account
        List<AggregateResult> agResult = [
            SELECT AccountId, MAX(CloseDate) latestCloseDate
            FROM Opportunity
            WHERE AccountId IN :affectedAccIds AND StageName = 'Closed Won'
            GROUP BY AccountId
        ];

        // Map of AccountId → Max Opportunity Amount
        Map<Id, Decimal> accIdToAmountMap = new Map<Id, Decimal>();
        for (AggregateResult agg : aggResult) {
            accIdToAmountMap.put((Id)agg.get('AccountId'), (Decimal)agg.get('maxAmount'));
        }

        // Map of AccountId → Latest Closed Won CloseDate
        Map<Id, Date> accIdToCloseDateMap = new Map<Id, Date>();
        for (AggregateResult agg : agResult) {
            accIdToCloseDateMap.put((Id)agg.get('AccountId'), (Date)agg.get('latestCloseDate'));
        }

        // Prepare Accounts to update
        List<Account> accListToUpdate = new List<Account>();
        for (Id accId : affectedAccIds) {
            Decimal maxAmt = accIdToAmountMap.containsKey(accId) ? accIdToAmountMap.get(accId) : 0;
            Date latestClosedDate = accIdToCloseDateMap.containsKey(accId) ? accIdToCloseDateMap.get(accId) : null;

            Account accToUpdate = new Account(
                Id = accId,
                Highest_Opportunity_Amount__c = maxAmt,
                Last_Opportunity_Close_Date__c = latestClosedDate
            );

            accListToUpdate.add(accToUpdate);
        }

        // Perform DML update safely
        if (!accListToUpdate.isEmpty()) {
            try {
                update accListToUpdate;
            } catch (Exception e) {
                System.debug('Exception while updating Account records: ' + e.getMessage());
            }
        }
    }

    /**
     * @description
     * Determines which Account records are impacted based on changes to Opportunities.
     * 
     * This method handles all trigger contexts:
     *  - Insert: New Opportunity linked to an Account.
     *  - Update: Opportunity moved from one Account to another or updated within the same Account.
     *  - Delete / Undelete: Re-linking or unlinking from Accounts.
     * 
     * @param newOppList   List of new Opportunity records (Trigger.new).
     * @param oldOppMap    Map of old Opportunity records (Trigger.oldMap).
     * 
     * @return Set<Id>     A set of Account IDs that are impacted by Opportunity changes.
     */
    public static Set<Id> getAffectedAccIds(List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap) {
        Set<Id> affectedAccIdSet = new Set<Id>();

        for (Opportunity newOpp : newOppList) {
            Opportunity oldOpp = (oldOppMap != null) ? oldOppMap.get(newOpp.Id) : null;

            // Case 1: Insert, Delete, or Undelete
            if (oldOpp == null && newOpp.AccountId != null) {
                affectedAccIdSet.add(newOpp.AccountId);
            }

            // Case 2: Opportunity moved from one Account to another
            if (oldOpp != null && oldOpp.AccountId != newOpp.AccountId) {
                if (newOpp.AccountId != null) affectedAccIdSet.add(newOpp.AccountId);
                if (oldOpp.AccountId != null) affectedAccIdSet.add(oldOpp.AccountId);
            }

            // Case 3: Update within the same Account
            if (oldOpp != null && oldOpp.AccountId == newOpp.AccountId) {
                affectedAccIdSet.add(newOpp.AccountId);
            }
        }

        return affectedAccIdSet;
    }
}
