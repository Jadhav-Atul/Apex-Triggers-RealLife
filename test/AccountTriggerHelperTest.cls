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
}