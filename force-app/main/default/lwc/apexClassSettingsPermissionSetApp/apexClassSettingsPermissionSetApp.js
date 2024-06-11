import { LightningElement, api } from 'lwc';
import fetchApexClassSettings from '@salesforce/apex/permissionCompareHandlerClass.fetchApexClassPermissions';
import fetchApexClassForUsers from '@salesforce/apex/permissionCompareHandlerClass.fetchApexClassForUsers';
import fetchIntegratedApexClassSettings from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedApexClassAccess';
import fetchIntegratedApexClassForUsers from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedApexClassForUsers';

export default class ApexClassSettingsPermissionSetApp extends LightningElement {
    @api showApexClassSettings = false;
    @api orgSelection;
    @api namedCredential;
    apexClasses1;
    apexClasses2;
    @api showApexClassSettingsForUsers=false;
    apexClassesForUser1;
    apexClassesForUser2;

    @api showApexClassCardsForUsers=false;

    get nodata(){

        if(this.apexClasses1 == undefined || this.apexClasses1.length == 0){
            return true;
        }
        else{
            return false;
        }
    }
    get noData1(){

        if(this.apexClasses2 == undefined || this.apexClasses2.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    get noDataUser(){

        if(this.apexClassesForUser1 == undefined || this.apexClassesForUser1.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    get noDataUser1(){

        if(this.apexClassesForUser2 == undefined || this.apexClassesForUser2.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    @api
    async handleApexClassSettings(psid, psSelection){
        if(psSelection == 'ps1'){
            fetchApexClassSettings({ psId:psid })
                .then(result => {
                    this.apexClasses1 = result;
                })
                .catch(error => {
                    console.error('Error fetching Apex Class settings for ps1:', error);
                });
        }
        
        if(this.orgSelection == 'OrgOnly' && psSelection == 'ps2'){
            fetchApexClassSettings({ psId:psid })
                .then(result => {
                    this.apexClasses2 = result; 
                })
                .catch(error => {
                    console.error('Error fetching Apex Class settings for ps2:', error);
                });
        }

        if(this.orgSelection == 'DifferentOrg' && psSelection == 'ps2'){
            fetchIntegratedApexClassSettings({credName:this.namedCredential, psId:psid })
                .then(result => {
                    console.log('result--> '+result);
                    this.apexClasses2 = result;
                })
                .catch(error => {
                    console.error('Error fetching Apex Class settings for integrated ps2:', error);
                });
        }
        
    if(this.showApexClassSettingsForUsers == true){
        this.showApexClassSettingsForUsers = false;
    }
        this.showApexClassSettings = true;
    }

    @api
    async handleApexClassSettingsforUser(userName, userSelection){
        if(userSelection == 'user1'){
            fetchApexClassForUsers({ username:userName })
                .then(result => {
                    this.apexClassesForUser1 = result;
                })
                .catch(error => {
                    console.error('Error fetching Apex Class settings for ps1:', error);
                });
        }
        
        if(this.orgSelection == 'OrgOnly' && userSelection == 'user2'){
            fetchApexClassForUsers({ username:userName })
                .then(result => {
                    this.apexClassesForUser2 = result;
                })
                .catch(error => {
                    console.error('Error fetching Apex Class settings for ps2:', error);
                });
        }

        if(this.orgSelection == 'DifferentOrg' && userSelection == 'user2'){
            fetchIntegratedApexClassForUsers({credName:this.namedCredential, username:userName })
            .then(result => {
                this.apexClassesForUser2 = result;
                console.log('integrated user2 apex: '+this.apexClassesForUser2);
            })
            .catch(error => {
                console.error('Error fetching Apex Class settings for integrated user2:', error);
            });
        }
        if(this.showApexClassSettings == true){
            this.showApexClassSettings = false;
        }
        
        this.showApexClassSettingsForUsers = true;
    }

    onSectionToggle(){
        if(this.showApexClassCardsForUsers == false){
            this.showApexClassCardsForUsers = true;
        }
        else if(this.showApexClassCardsForUsers == true){
            this.showApexClassCardsForUsers = false;
        }
    }

}