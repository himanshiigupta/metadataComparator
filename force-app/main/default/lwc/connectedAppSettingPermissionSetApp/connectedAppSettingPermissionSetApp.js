import { LightningElement, api } from 'lwc';
import fetchconnectedAppSettings from '@salesforce/apex/permissionCompareHandlerClass.fetchConnectedAppSettings';
import fetchAssignedConnectedAppsForUsers from '@salesforce/apex/permissionCompareHandlerClass.fetchAssignedConnectedAppsForUsers';
import fetchIntegratedConnectedAppSettings from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedConnectedAppSettings';
import fetchIntegratedConnectedAppsForUsers from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedConnectedAppsForUsers';

export default class ConnectedAppSettingPermissionSetApp extends LightningElement {
    @api showConnectedAppSettings = false;
    @api showConnectedAppSettingsForUsers = false;
    connectedAppSettings1;
    connectedAppSettings2;
    connectedAppSettingsUser1;
    connectedAppSettingsUser2;
    @api showConnectedAppCardsForUsers = false;
    isDifferentOrg = false;
    @api orgSelection;
    @api namedCredential;

    get nodata(){
        if((this.connectedAppSettings1 == undefined || this.connectedAppSettings1.length == 0)){
            return true;
        }
        else{
            return false;
        }
    }
    get nodata1(){
        if((this.connectedAppSettings2 == undefined || this.connectedAppSettings2.length == 0)){
            return true;
        }
        else{
            return false;
        }
    }

    get noDataUser(){
        if((this.connectedAppSettingsUser1 == undefined || this.connectedAppSettingsUser1.length == 0)){
            return true;
        }
        else{
            return false;
        }
    }
    get noDataUser1(){
        if((this.connectedAppSettingsUser2 == undefined || this.connectedAppSettingsUser2.length == 0)){
            return true;
        }
        else{
            return false;
        }
    }

    @api
    async handleConnectedAppSettings(psid, psSelection){
        if(psSelection == 'ps1'){
            fetchconnectedAppSettings({ psId:psid })
            .then(result => {
                this.connectedAppSettings1 = result;
                console.log('connectedAppSettings1 data ----> ', this.connectedAppSettings1);
            })
            .catch(error => {
                console.error('Error fetching Apex Class settings for ps1:', error);
            });
        }
        
        if(psSelection == 'ps2'){
            fetchconnectedAppSettings({ psId:psid })
            .then(result => {
                this.connectedAppSettings2 = result;
                console.log('connectedAppSettings2 data ----> ', this.connectedAppSettings2);
            })
            .catch(error => {
                console.error('Error fetching Apex Class settings for ps1:', error);
            });
        }
        if(this.showConnectedAppSettingsForUsers == true){
            this.showConnectedAppSettingsForUsers = false;
        }

        this.showConnectedAppSettings = true;

    };

    @api
    async handleConnectedAppSettingsForUsers(userName, userSelection){
        if(userSelection == 'user1'){
            fetchAssignedConnectedAppsForUsers({ username:userName })
            .then(result => {
                this.connectedAppSettingsUser1 = result;
                console.log('connectedAppSettingsUser1 data ----> ', this.connectedAppSettingsUser1);
            })
            .catch(error => {
                console.error('Error fetching Connected App settings for user1:', error);
            });
        }
        
        if(userSelection == 'user2'){
            fetchAssignedConnectedAppsForUsers({ username:userName })
            .then(result => {
                this.connectedAppSettingsUser2 = result;
                console.log('connectedAppSettingsUser2 data ----> ', this.connectedAppSettingsUser2);
            })
            .catch(error => {
                console.error('Error fetching Connected App settings for user2:', error);
            });
        }
        if(this.showConnectedAppSettings == true){
            this.showConnectedAppSettings = false;
        }

        this.showConnectedAppSettingsForUsers = true;

    }

    @api
    async handleIntegratedConnectedAppSettings(psid, psSelection){
        if(this.orgSelection == 'DifferentOrg' && psSelection == 'ps2'){
            this.isDifferentOrg = true;
            fetchIntegratedConnectedAppSettings({credName:this.namedCredential, psId:psid })
            .then(result => {
                this.connectedAppSettings2 = result;
            })
            .catch(error => {
                console.error('Error fetching Connnected App settings for integrated ps2:', error);
            });
        }
    }

    @api
    async handleIntegratedConnectedAppsForUsers(userName){
        this.isDifferentOrg = true;
        fetchIntegratedConnectedAppsForUsers({credName:this.namedCredential,username:userName})
        .then(result => {
            this.connectedAppSettingsUser2 = result;
            console.log('The assigned connected apps is : '+this.connectedAppSettingsUser2);
        })
        .catch(error => {
            console.error('Error fetching Connected App settings for integrated user2:', error);
        });
    }

    onSectionToggle(){
        if(this.showConnectedAppCardsForUsers == false){
            this.showConnectedAppCardsForUsers = true;
        }
        else if(this.showConnectedAppCardsForUsers == true){
            this.showConnectedAppCardsForUsers = false;
        }
    }
}