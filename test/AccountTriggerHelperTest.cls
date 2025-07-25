@isTest
public class AccountTriggerHelperTest{
    @isTest 
    static void testCreateContactOnAccountInsert(){
        //create a test account
        Account testAcc = new Account(Name='TestCrop');
        insert testAcc;

        //query related contact
        contact relatedCon = [
            SELECT Id, LastName, Email, AccountId FROM Contact WHERE AccountId =: testAcc.Id LIMIT 1
        ];

        System.assertEquals('TestCrop', relatedCon.LastName);
        System.assertEquals('info@testcrop.com', relatedCon.Email);
        System.assertequals(testAcc.Id, relatedCon.AccountId);
    }

    @isTest 
    static void testPopulateStatusOnAccountInsert(){

        //create a list of accounts
        List<Account> testAccList = new List<Account>();
        testAccList.add(new Account(Name='TestAcc1'));
        testAccList.add(new Account(Name= 'TestAcc2',Account_Status__c = 'Old'));

        insert testAccList;

        //query the updated accounts
        List<Account> insertedAcc = [
            SELECT Id, Name, Account_Status__c FROM Account WHERE Id =: testAccList[0].Id 
            OR Id =: testAccList[1].Id
        ];

        //Validate the status on the Accounts
        System.assertEquals('New', insertedAcc[0].Account_Status__c);
        System.assertEquals('Old', insertedAcc[1].Account_Status__c);
    }

    @isTest 
    static void testSyncAccountPhone(){
        //create a test account
        Account acc = new Account(Name='TestAcc',Phone = '1234567890');
        insert acc;

        //create a related contact
        Contact con = new Contact(LastName = 'TestCon', AccountId = acc.Id );
        insert con;

        //update the phone on the account
        acc.Phone = '9988998899';
        update acc;

        //fetch the updated related contacts
        List<Contact> relatedConList = [
            SELECT Id,AccountId, LastName, Account_Phone__c FROM Contact WHERE AccountId =: acc.Id LIMIT 2
        ];

        System.assertEquals('9988998899', relatedConList[0].Account_Phone__c);
        System.AssertEquals('9988998899', relatedConList[1].Account_Phone__c);

    }
}