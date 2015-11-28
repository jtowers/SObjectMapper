@isTest
private class ObjectMapperTests {

    /**
     * Test automapping between two objects.
     * Using the same object so we can verify that fields are transferred.
     * Test uses Contact->Contact but can map any object to any other
     */
    @isTest static void test_constructor_auto() {
        Contact testcontact1 = new Contact(FirstName = 'Test', LastName = 'Contact1');
        Contact testcontact2 = new Contact(FirstName = 'Test', LastName = 'Contact2');
        Set<String> includeLabels = new Set<String>();
        includeLabels.add('ObjectMapper_Test_Include');
        Test.startTest();

        ObjectMapper mapper = new ObjectMapper(testcontact1, testcontact2, null, true, null, includeLabels);
        mapper.doMap();

        Test.stopTest();

        System.assertEquals(mapper.sourceObject.get('LastName'), mapper.targetObject.get('LastName'));
    }

    /**
     * Test automapping with exceptions.
     * Should copy every field that maps over except the exception
     */
    @isTest static void test_constructor_auto_with_exceptions() {
        Contact testcontact1 = new Contact(FirstName = 'Test1', LastName = 'Contact1');
        Contact testcontact2 = new Contact(FirstName = 'Test2', LastName = 'Contact2');
        Set<String> exceptions = new Set<String> {'FirstName'};
        Set<String> includeLabels = new Set<String>();
        includeLabels.add('ObjectMapper_Test_Include');
        Test.startTest();

        ObjectMapper mapper = new ObjectMapper(testcontact1, testcontact2, exceptions, true, null, includeLabels);
        Map<String, SObject> results = mapper.doMap();

        Test.stopTest();

        Contact resultContact1 = (Contact)results.get('source');
        Contact resultContact2 = (Contact)results.get('target');
        System.assertEquals(resultContact1.LastName, resultContact2.LastName);
        System.assertNotEquals(resultContact1.FirstName, resultContact2.LastName);
    }

    /**
     * Test with objects that have little/no fields in common.
     * Should result in no errors because we catch errors resulting from mismatched fields
     */
    @isTest static void test_constructor_auto_missing_fields() {

        Account testAccount = new Account(Name = 'Test Account');
        Contact testcontact = new Contact(FirstName = 'Test', LastName = 'Contact2');
        Set<String> includeLabels = new Set<String>();
        includeLabels.add('ObjectMapper_Test_Include');
        Test.startTest();

        ObjectMapper mapper = new ObjectMapper(testAccount, testcontact, null, true, null, includeLabels);
        mapper.doMap();

        Test.stopTest();

    }

    /**
     * Test with a manual map
     * Map metadata is already set up because you can't dynamically create custom metadata with Apex
     */
    @isTest static void test_manual_map() {
        Account testAccount = new Account(Name = 'Test Account');
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        Set<String> includeLabels = new Set<String>();
        includeLabels.add('ObjectMapper_Test_Include');

        ObjectMapper mapper = new ObjectMapper(testAccount, testContact, null, false, null, includeLabels);
        Test.startTest();
        Map<String, SObject> results = mapper.doMap();
        Test.stopTest();

        Account resultAccount = (Account)results.get('source');
        Contact resultContact = (Contact)results.get('target');

        System.assertEquals(resultAccount.Name, resultContact.LastName);
    }

    /**
     * Test exceptions to make sure that you can exclue certain mappings
     */
    @isTest static void test_exclude_mappings(){
        Account testAccount = new Account(Name = 'Test Account');
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        Set<String> excludeLabels = new Set<String>();
        excludeLabels.add('ObjectMapper_Test_Exclude');
        ObjectMapper mapper = new ObjectMapper(testAccount, testContact, null, false, excludeLabels, null);
        Test.startTest();
        System.debug('doing exclude tests');
        Map<String, SObject> results = mapper.doMap();
        Test.stopTest();

        Account resultAccount = (Account)results.get('source');
        Contact resultContact = (Contact)results.get('target');

        System.assertNotEquals(resultAccount.Name, resultContact.LastName);

    }

        /**
     * Test exceptions to make sure that you can include certain mappings
     */
    @isTest static void test_include_mappings(){
        Account testAccount = new Account(Name = 'Test Account');
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        Set<String> includeLabels = new Set<String>();
        includeLabels.add('ObjectMapper_Test_Include');
        ObjectMapper mapper = new ObjectMapper(testAccount, testContact, null, false,null,includeLabels);
        Test.startTest();
        System.debug('doing include tests');
        Map<String, SObject> results = mapper.doMap();
        Test.stopTest();

        Account resultAccount = (Account)results.get('source');
        Contact resultContact = (Contact)results.get('target');

        System.assertEquals(resultAccount.Name, resultContact.LastName);

    }



}