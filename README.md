# SObjectMapper
Map two Salesforce SObjects together.

Mappings can be created automatically by dynamically iterating over fields or by defining manual mappings in custom metadata records.

This is designed so that you can create mappings between objects and keep them up to date without modifying and redeploying code.

Code coverage is 100%.

<a href="https://githubsfdeploy.herokuapp.com?owner=jtowers&repo=SObjectMapper">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## Usage

### Getting started

Start by using the deploy button above to deploy the main class, test class, and custom metadata to your instance.

After that you can construct a mapper by passing in the source object, target object, a list of fields to exclude from the mapping and a boolean indicating whether the mapping should be automatiac or not.

Call doMap() to perform the mapping and get the objects back as a result.

```Apex
Custom_Object_1__c obj1 = new Custom_Object_1__c;
Custom_Object_2__c obj2 = new Custom_Object_2__c;

Set<String> exceptions = new Set<String>{'Custom_Field__c'}

ObjectMapper mapper = new ObjectMapper(obj1, obj2, exceptions, true);

mapper.doMap();

```

The above code will automatically run through each field in Custom_Object_1__c and map it to the corresponding field in Custom_Object_2__c.

Automatic mapping requires that the mapped field names are exactly the same on both objects. Fields that exist on one object but not the other are ignored. Fields that aren't writeable (e.g., create dates) are also ignored.

Manual mappings can specify fields between objects that don't have an API name that matches exactly. This is best for use with existing objects/fields that cannot be changed to accommodate automatic mapping.

### Manual Mappings

Create manual mappings by adding a record to the Object_Mapper_Field__mdt custom metadata. This should be simple to do with the new Custom Metadata editor released in Winter '16.

Each field that you wish to map manually needs to have a new metadata record that tells the mapper which field on the source object is mapped to which field on the target object.

Required fields are:

- Source_Object__c: This is the source object that you are mapping from.
- Target_Object__c: This is the target object that you are mapping to.
- Source_Field_API_Name__c: This is the API name on the source object that you wish to copy
- Target_Field_API_Name__c: This is the APi name on the target up that you wish to populate

Manual mappings are perfored in exactly the same way as automatic mappings - only you pass false as the last argument in the constructor.


```Apex
Custom_Object_1__c obj1 = new Custom_Object_1__c;
Custom_Object_2__c obj2 = new Custom_Object_2__c;

Set<String> exceptions = new Set<String>{'Custom_Field__c'}

ObjectMapper mapper = new ObjectMapper(obj1, obj2, exceptions, false);

mapper.doMap();

```

This instructs the mapper to look for custom metadata where the source object is Custom_Object_1__c and the target object is Custom_Object_2__c;
