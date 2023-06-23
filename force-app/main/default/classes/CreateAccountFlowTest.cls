/**
 * @description       : Test class to test AccountInsertFLow and TaskCompleteFlow
 * @author            : Satyam Raj
 * @group             : KVP Business Solutions
 * @last modified on  : 06-23-2023
 * @last modified by  : satyam.r@kvpcorp.com
**/
@isTest
public class CreateAccountFlowTest {
    
    @isTest
    static void testFlows(){
     
        //creating user with access to close the task
      Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
	  User userWithAccess = new User();
      userWithAccess.Username = 'user456@kvpcorp.com';
      userWithAccess.FirstName = 'Access';
      userWithAccess.LastName = 'User';
      userWithAccess.Alias = 'au';
      userWithAccess.Email = 'satyam.r@kvpcorp.com';
      userWithAccess.TimeZoneSidKey = 'America/New_York';
      userWithAccess.LocaleSidKey = 'en_US';
      userWithAccess.EmailEncodingKey = 'ISO-8859-1';
      userWithAccess.ProfileId = systemAdminProfileId;
      userWithAccess.LanguageLocaleKey = 'en_US';
	  insert userWithAccess;
        
      //create user with no access to edit task
       Id standardUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Stand User Profile' LIMIT 1].Id;
	   User userWithoutAccess = new User();
       userWithoutAccess.Username = 'user45642@kvpcorp.com';
       userWithoutAccess.FirstName = 'Access';
       userWithoutAccess.LastName = 'User';
       userWithoutAccess.Alias = 'au';
       userWithoutAccess.Email = 'satyam.r@kvpcorp.com';
       userWithoutAccess.TimeZoneSidKey = 'America/New_York';
       userWithoutAccess.LocaleSidKey = 'en_US';
       userWithoutAccess.EmailEncodingKey = 'ISO-8859-1';
       userWithoutAccess.ProfileId = standardUserProfileId;
       userWithoutAccess.LanguageLocaleKey = 'en_US';
	   insert userWithoutAccess;
      //assigning permission set to user
      test.startTest();
        
        //Running the task closure code with user who have access
        System.runAs(userWithAccess){
            //creating account to trigger the flow and create task
            Account newAccount = new Account();
     	 	newAccount.name = 'Demo Account test';
     	 	newAccount.AccountNumber = '3400';
     	 	newAccount.Active__c = true;
     	 	insert newAccount;
            Id newAccountId = newAccount.Id;
            Account insertedAccount =[SELECT id,Active__c,Description FROM Account WHERE Id = :newAccountId];
            
            //getting task which is created using flow related to account
            Task createdTask = [SELECT id, whatId, description, status FROM Task WHERE whatId = :newAccountId];
            
            //editing task record
            if(Schema.sObjectType.Task.isUpdateable()){
          		createdTask.Status = 'Completed';
          		createdTask.Description = 'task details';
                update createdTask;
            }
           //assert check
          System.assertEquals('Completed',createdTask.Status, 'It should be completed');
        }
        
        //Running the task closure code with user who do not have access to edit task
        System.runAs(userWithoutAccess){
            //creating account to trigger the flow and create task
            Account newAccount = new Account();
     	 	newAccount.name = 'Demo Account test';
     	 	newAccount.AccountNumber = '3400';
     	 	newAccount.Active__c = true;
     	 	insert newAccount;
            Id newAccountId = newAccount.Id;
            Account insertedAccount =[SELECT id,Active__c,Description FROM Account WHERE Id = :newAccountId];
            //getting task which is created using flow related to account
            Task createdTask = [SELECT id, whatId, description, status FROM Task WHERE whatId = :newAccountId];
            if(Schema.sObjectType.Task.isUpdateable()){
          		createdTask.Status = 'Completed';
          		createdTask.Description = 'task details';
                update createdTask;
            }
            //assertions for testing
          System.assertEquals('Not Started',createdTask.Status, 'It should be not started');
        }  
               
      test.stopTest();
     
    }
    
    
    
}