/*
 * Class Name - FieldHistoryController
 * Description - Controller class for FieldHistoryTable lwc component
 * Created By - Luckey Sahu
 * Version 1 - Dec, 2023
 * */
public with sharing class FieldHistoryController {

    /*
    * Method Name - fetchHistoryRecord
    * Description - Method to fetch the records based on the selected object,field and parent record key
    * */
    @AuraEnabled
    public static List<HistoryWrapper> fetchHistoryRecord(String objectName,String fieldName,String parentId,Boolean onlyLatest) {
        List<HistoryWrapper> historyList = new List<HistoryWrapper>();
        String historyObjName = '';
        String queryField = '';
        String limitStr = '';
        if(objectName.contains('__c')){
            historyObjName = objectName.replace('__c','__History');
            queryField = 'ParentId';
        }else{
            historyObjName = objectName+'History';
            queryField = objectName+'Id';
        }
        
        if(onlyLatest == true){
            limitStr = 'LIMIT 1';
        }

        String queryString = 'SELECT Id,Field, NewValue, OldValue,CreatedDate,CreatedById,'+queryField+
            ' FROM '+historyObjName+' WHERE Field = :fieldName AND '+queryField+
            ' =:parentId Order By CreatedDate DESC '+limitStr;
        List<sObject> sobjList = Database.query(queryString);
		System.debug('##sobjList##'+sobjList);

        Set<String> userIDs = new Set<String>();
        for(sObject obj : sobjList){
            userIDs.add(String.valueof(obj.get('CreatedById')));
        }
        
        Map<ID, User> userMap = new Map<ID, User>([SELECT Id, Name FROM User WHERE Id IN :userIDs]);
		System.debug('##userMap##'+userMap);
        
        for(sObject obj : sobjList){
            HistoryWrapper hw = new HistoryWrapper();
            hw.fieldName = String.valueof(obj.get('Field'));
            hw.currentVal = String.valueof(obj.get('NewValue'));
            hw.oldVal = String.valueof(obj.get('OldValue'));
            hw.changedDate = Datetime.valueof(obj.get('CreatedDate')).format('MM/dd/YYYY hh:mm a');
            hw.changedBy = userMap.get(String.valueof(obj.get('CreatedById'))).Name;
            historyList.add(hw);
        }
		
        System.debug('##historyList##'+historyList);
        return historyList;
    }
    
    /*
    * Method Name - getFieldDetails
    * Description - Method to fetch the field label and creating option to show over LWC
    * */
    @AuraEnabled
    public static List<OptionWrapper> getFieldDetails(String objName,String fieldLst){
        
        List<OptionWrapper> optWrapList = new List<OptionWrapper>();
        if(objName != '' && fieldLst != ''){
            List<String> fieldList = fieldLst.contains(',') ? fieldLst.split(',') : new List<String>{fieldLst};
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(objName);
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
            for(String fieldName : fieldList){
                Schema.SObjectField field = MapofField.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe();
                OptionWrapper opt = new OptionWrapper();
                    opt.labelStr = F.getLabel();
                    opt.valueStr = F.getName();
                optWrapList.add(opt);
        	}
        }
        System.debug('##optWrapList##'+optWrapList);
        return optWrapList;
    }
    
     /*
    * Wrapper Class Name - OptionWrapper class 
    * Description - OptionWrapper class to return label vs api name for field options
    * */
    public class OptionWrapper{
         @AuraEnabled
        public String labelStr {get;set;}
         @AuraEnabled
        public String valueStr {get;set;}
    }

     /*
    * Wrapper Class Name - HistoryWrapper class 
    * Description - HistoryWrapper class to return list of history reocod of seleted field.
    * */
    public class HistoryWrapper{
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public String currentVal {get;set;}
        @AuraEnabled
        public String oldVal {get;set;}
        @AuraEnabled
        public String changedBy {get;set;}
        @AuraEnabled
        public String changedDate {get;set;}
    }
}
