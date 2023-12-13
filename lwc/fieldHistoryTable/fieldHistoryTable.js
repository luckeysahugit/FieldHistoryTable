import { LightningElement, api  } from 'lwc';
import getFieldDetails from '@salesforce/apex/FieldHistoryController.getFieldDetails';
import fetchHistoryRecord from '@salesforce/apex/FieldHistoryController.fetchHistoryRecord';

export default class FieldHistoryTable extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api cmpHeading = 'Field History Details';
    @api cardIcon = 'custom:custom88';
    @api columnNames;
    @api showLatest = false;
    @api showTime = false;
    @api showUser = false;

    isLoaded = false;
    isRowAvailable = false;
    historyList;
    selectedField = '';
    fieldOptions =[];

    connectedCallback(){
        this.doInit();
    }

    doInit(){
        getFieldDetails({objName : this.objectApiName,fieldLst : this.columnNames}).then(response =>{
            response.forEach(element => {
                var opt = {
                    label: element.labelStr,
                    value: element.valueStr
                }
                this.fieldOptions.push(opt);
            });
        this.isLoaded = true;
        }).catch(error =>{
            console.log('Error on getFieldDetails: '+JSON.stringify(error));
        });
    }

    handleFieldChange(event){
        this.selectedField = event.target.value;

        fetchHistoryRecord({objectName : this.objectApiName,fieldName : this.selectedField, parentId : this.recordId, onlyLatest : this.showLatest}).then(response =>{
            this.historyList = response;
            if(this.historyList.length > 0){
                this.isRowAvailable = true;
            }else{
                this.isRowAvailable = false;
            }
            
        }).catch(error =>{
            console.log('Error on fetchHistoryRecord: '+JSON.stringify(error));
        });
    }
   
}
