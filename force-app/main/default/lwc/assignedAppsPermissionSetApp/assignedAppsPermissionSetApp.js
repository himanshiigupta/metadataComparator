import { LightningElement, api } from 'lwc';
import fetchAssignedApps from '@salesforce/apex/permissionCompareHandlerClass.fetchAssignedApps';
import fetchAssignedAppsForUsers from '@salesforce/apex/permissionCompareHandlerClass.fetchAssignedAppsForUsers';
import fetchIntegratedAssignedAppSettings from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedAssignedAppsSettings';
import fetchIntegratedAssignedAppsForUsers from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedAssignedAppsForUsers';

export default class AssignedAppsPermissionSetApp extends LightningElement {
    assignedApps1;
    assignedApps2;
    assignedAppsUser1;
    assignedAppsUser2;
    isDifferentOrg=false;
    @api showAssignedApps = false;
    @api showAssignedAppsForUser=false;
    @api orgSelection;
    @api namedCredential;
    @api showAssignedAppsCardsForUsers = false;

    get noData(){

        if(this.assignedApps1 == undefined || this.assignedApps1.length == 0){
            return true;
        }
        else{
            return false;
        }
    }
    get noData2(){

        if(this.assignedApps2 == undefined || this.assignedApps2.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    get noDataUser(){

        if(this.assignedAppsUser1 == undefined || this.assignedAppsUser1.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    get noDataUser2(){

        if(this.assignedAppsUser2 == undefined || this.assignedAppsUser2.length == 0){
            return true;
        }
        else{
            return false;
        }
    }

    
    @api
    async handleAssignedAppsSettings(psid, psSelection){
        if(psSelection == 'ps1'){
            fetchAssignedApps({ psId:psid })
            .then(result => {
                this.assignedApps1 = result;
            })
            .catch(error => {
                console.error('Error fetching assginedApps Settings for ps1:', error);
            });
        }
        
        if(psSelection == 'ps2'){
            fetchAssignedApps({ psId:psid })
            .then(result => {
                this.assignedApps2 = result;
            })
            .catch(error => {
                console.error('Error fetching assignedApps Settings for ps2:', error);
            });
        }
        if(this.showAssignedAppsForUser == true){
            this.showAssignedAppsForUser = false;
        }
        
        this.showAssignedApps = true;
    }
    @api
    async handleAssignedAppsSettingsforUsers(userName, userSelection){
        if(userSelection == 'user1'){
            fetchAssignedAppsForUsers({ username:userName })
            .then(result => {
                this.assignedAppsUser1 = result;
            })
            .catch(error => {
                console.error('Error fetching assginedApps Settings for user1:', error);
            });
        }
        
        if(this.orgSelection='OrgOnly' && userSelection == 'user2'){
            fetchAssignedAppsForUsers({ username:userName })
            .then(result => {
                this.assignedAppsUser2 = result;
            })
            .catch(error => {
                console.error('Error fetching assginedApps Settings for user2:', error);
            });
        }
        if(this.showAssignedApps == true){
            this.showAssignedApps = false;
        }
        this.showAssignedAppsForUser = true;
    }
    
    @api
    async handleIntegratedAssignedAppSettings(psid, psSelection){
        if(this.orgSelection == 'DifferentOrg' && psSelection == 'ps2'){
            this.isDifferentOrg = true;
            fetchIntegratedAssignedAppSettings({credName:this.namedCredential, psId:psid })
            .then(result => {
                console.log('result--> '+result);
                this.assignedApps2 = result;
            })
            .catch(error => {
                console.error('Error fetching Assigned App settings for integrated ps2:', error);
            });
        }
    }
    
    @api
    async handleIntegratedAssignedAppsForUsers(userName){
        this.isDifferentOrg = true;
        fetchIntegratedAssignedAppsForUsers({credName:this.namedCredential,username:userName})
        .then(result => {
            this.assignedAppsUser2 = result;
            console.log('The assigned apps is : '+this.assignedAppsUser2);
        })
        .catch(error => {
            console.error('Error fetching Assigned App settings for integrated user2:', error);
        });
    }
    
    onSectionToggle(){
        if(this.showAssignedAppsCardsForUsers == false){
            this.showAssignedAppsCardsForUsers = true;
        }
        else if(this.showAssignedAppsCardsForUsers == true){
            this.showAssignedAppsCardsForUsers = false;
        }
    }
}