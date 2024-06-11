import { LightningElement, api } from 'lwc';
import fetchVfPageSettings from '@salesforce/apex/permissionCompareHandlerClass.fetchVfPageAccess';
import fetchVfPageAccessForUsers from '@salesforce/apex/permissionCompareHandlerClass.fetchVfPageAccessForUsers';
import fetchIntegratedVfPageSettings from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedVfPageSettings';
import fetchIntegratedVfPageAccessForUsers from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedVfPageAccessForUsers';

export default class VfPageSettingsPermissionSetApp extends LightningElement {
    vfPages1;
    vfPages2;
    vfPagesForUser1;
    vfpagesForUser2;
    @api showVfPageAccess = false;
    @api showVfPageAccessForUsers = false;
    @api showVfPageCardsForUsers = false;
    isDifferentOrg = false;
    @api orgSelection;
    @api namedCredential;

    get noData(){

        if(this.vfPages1 == undefined || this.vfPages1.length == 0){
            return true;
        }
        else{
            return false;
        }
    }
    get nodata2(){

        if(this.vfPages2 == undefined || this.vfPages2.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    get nodataUser(){

        if(this.vfPagesForUser1 == undefined || this.vfPagesForUser1.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    get nodataUser2(){

        if(this.vfPagesForUser2 == undefined || this.vfPagesForUser2.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    
    @api
    async handleVfPageSettings(psid, psSelection){
        if(psSelection == 'ps1'){
            fetchVfPageSettings({ psId:psid })
            .then(result => {
                this.vfPages1 = result;
                console.log('vfPages1 data ----> ', this.vfPages1);
            })
            .catch(error => {
                console.error('Error fetching vfPage Settings for ps1:', error);
            });
        }
        
        if(this.orgSelection == 'OrgOnly' && psSelection == 'ps2'){
            fetchVfPageSettings({ psId:psid })
            .then(result => {
                this.vfPages2 = result;
                console.log('vfPages2 data ----> ', this.vfPages2);
            })
            .catch(error => {
                console.error('Error fetching vfPage Settings for ps2:', error);
            });
        }
        
        if(this.orgSelection == 'DifferentOrg' && psSelection == 'ps2'){
            fetchIntegratedVfPageSettings({credName:this.namedCredential, psId:psid })
            .then(result => {
                console.log('result--> '+result);
                this.vfPages2 = result;
            })
            .catch(error => {
                console.error('Error fetching Vf Page settings for integrated ps2:', error);
            });
        }
        if(this.showVfPageAccessForUsers == true){
            this.showVfPageAccessForUsers = false;
        }
        
        this.showVfPageAccess = true;
    };
    
    @api
    async handleVfPageSettingsForUsers(userName, userSelection){
        if(userSelection == 'user1'){
            fetchVfPageAccessForUsers({ username : userName })
            .then(result => {
                this.vfPagesForUser1 = result;
                console.log('vfPagesForUser1 data ----> ', this.vfPagesForUser1);
            })
            .catch(error => {
                console.error('Error fetching vfPage Settings for user1:', error);
            });
        }
        
        if(this.orgSelection == 'OrgOnly' && userSelection == 'user2'){
            fetchVfPageAccessForUsers({ username : userName })
            .then(result => {
                this.vfPagesForUser2 = result;
            })
            .catch(error => {
                console.error('Error fetching vfPage Settings for user2:', error);
            });
        }
        
        if(this.orgSelection == 'DifferentOrg' && userSelection == 'user2'){
            fetchIntegratedVfPageAccessForUsers({credName:this.namedCredential, username:userName })
            .then(result => {
                this.vfPagesForUser2 = result;
                console.log('vfPagesForUser2 data ----> ', this.vfPagesForUser2);
            })
            .catch(error => {
                console.error('Error fetching vfPage Settings for integrated user2:', error);
            });
        }
        if(this.showVfPageAccess == true){
            this.showVfPageAccess = false;
        }
        
        this.showVfPageAccessForUsers = true;
    }
    
    onSectionToggle(){
        if(this.showVfPageCardsForUsers == false){
            this.showVfPageCardsForUsers = true;
        }
        else if(this.showVfPageCardsForUsers == true){
            this.showVfPageCardsForUsers = false;
        }
    }
}