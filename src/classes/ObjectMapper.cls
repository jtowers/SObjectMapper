public class ObjectMapper {
    public SObject sourceObject;
    public SObject targetObject;

    @testVisible private List<Object_Mapper_Field__mdt> fieldMappings;
    private Set<String> exceptions = new Set<String>();
    private Set<String> includeLabels = new Set<String>();
    private Set<String> excludeLabels = new Set<String>();
    private Boolean autoMap;

    public ObjectMapper(SObject sourceObject, SObject targetObject, Set<String> exceptions, Boolean automap, Set<String> zexludeLabels, Set<String> zincludeLabels) {
        this.sourceObject = sourceObject;
        this.targetObject = targetObject;
        
        if(exceptions != null){
          this.exceptions = exceptions;
        }
        
        this.autoMap = automap;

        if(zincludeLabels != null){
          this.includeLabels = zincludeLabels;
        }

        if(zexludeLabels != null){
          this.excludeLabels = zexludeLabels;
        }


        // exclude Test mappings when tests aren't running
        if(Test.isRunningTest() == false){
          this.excludeLabels.add('ObjectMapper_Test');
        }

    }


    public Map<String, SObject> doMap(){
        if(this.autoMap == true){
            doAutoMapping();
        } else{
            doManualMapping();
        }

        Map<String, SObject> results = new Map<String, SObject>();

        results.put('source', this.sourceObject);
        results.put('target', this.targetObject);

        return results;
    }

    /**
     * Get the list of field mappings from the custom metadata settings
     */
    private void getFieldMappings() {
        String sourceAPIName = String.valueOf(this.sourceObject.getSObjectType());
        String targetAPIName = String.valueof(this.targetObject.getSObjectType());
        fieldMappings = [SELECT Source_Field_API_Name__c, Target_Field_API_Name__c, Labels__c FROM Object_Mapper_Field__mdt WHERE Source_Object__c = :sourceAPIName AND Target_Object__c= :targetAPIName AND Mapping_Enabled__c = true];
    }

    /**
     * Kick off the manual mapping process.
     * Used when manual mapping definitions are defined between source and target objects.
     */
    private void doManualMapping() {

        this.getFieldMappings();

        for (Object_Mapper_Field__mdt fieldMapping : fieldMappings) {

            String sourceField = fieldMapping.Source_Field_API_Name__c;
            String targetField = fieldMapping.Target_Field_API_Name__c;

            if (sourceField != '' && targetField != '' && exceptions.contains(sourceField) == false && includeFieldMapping(fieldMapping) == true) {
                targetObject.put(targetField, sourceObject.get(sourceField));
            }

        }
    }

    /**
     * Determine whether or not the field mapping should be included in the list
     * @param  Object_Mapper_Field__mdt fieldMapping
     * @return Boolean  returns true if it should be included, false if not
     */
    private Boolean includeFieldMapping(Object_Mapper_Field__mdt fieldMapping){
      Boolean hasIncludedLabel = true;
      Boolean hasExcludedLabel = false;

      if(includeLabels != null){
        if(includeLabels.size() > 0){
          hasIncludedLabel = fieldMappingHasIncludedLabel(fieldMapping);
        }
      }
System.debug('exclude labels size: ' + excludeLabels.size());
      if(excludeLabels != null){
        if(excludeLabels.size() > 0){
          hasExcludedLabel = fieldMappingHasExcludedLabel(fieldMapping);
        }
      }
      System.debug('has included labels: ' + hasincludedLabel);
      System.debug('has excluded labels:' + hasExcludedLabel);
      if(hasIncludedLabel == true && hasExcludedLabel == false){
        return true;
      } else {
        return false;
      }

    }

    /**
     * Determine if fieldMapping includes required labels
     * @param  Object_Mapper_Field__mdt fieldMapping  Field mapping to check
     * @return Boolean  true if has lable, false if not
     */
    private Boolean fieldMappingHasIncludedLabel(Object_Mapper_Field__mdt fieldMapping){
      Boolean include = false;
      if(fieldMapping.Labels__c != null){
        List<String> labels = fieldMapping.Labels__c.split(';');
        for(String label : labels){
          if(includeLabels.contains(label)){
            return true;
          }
        }
      } else {
        return true;
      }
      return include;

    }

    /**
     * Checks to see if a field mapping has an excluded label
     * @param  Object_Mapper_Field__mdt fieldMapping
     * @return Boolean  true if field mapping has an excluded label, false if not
     */
    private Boolean fieldMappingHasExcludedLabel(Object_Mapper_Field__mdt fieldMapping){
      Boolean exclude = false;
      if(fieldMapping.Labels__c != null){
        List<String> labels = fieldMapping.Labels__c.split(';');
        system.debug(labels);
          for(String label : labels){
            system.debug(label);
          if(excludeLabels.contains(label)){
            return true;
          }
        }
      }
      return exclude;
    }


    /**
     * Kick off the automapping process.
     * Gets a list of updateable fields from the source object and tries to set the corresponding value on the target object.
     */
    private void doAutoMapping() {
        Map<String, Schema.SObjectField> updateableFields = getUpdateableFields();

        for (String field : updateableFields.keySet()) {
            try {

                if(exceptions.contains(field) == false){
                    targetObject.put(field, sourceObject.get(field));
                }

            } catch (Exception ex) {
                // something went wrong. nothing else to do here.
            }
        }
    }

    /**
     * Gets a list of updateable fields for the source object
     * @return Returns a map of fields
     */
    private Map<String, Schema.SObjectField> getUpdateableFields() {
        Map<String, Schema.SObjectField> theFields = sourceObject.getSObjectType().getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> updateableFields = new Map<String, Schema.SobjectField>();

        for (String field : theFields.keySet()) {
            if (theFields.get(field).getDescribe().isUpdateable() || theFields.get(field).getDescribe().isCreateable()) {
                updateableFields.put(field, theFields.get(field));
            }
        }

        return updateableFields;
    }

}