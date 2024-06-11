import { LightningElement,api } from 'lwc';
import fetchAssignedAppsForUsers from '@salesforce/apex/permissionCompareHandlerClass.fetchAssignedAppsForUsers';
export default class ChildFetchAssignedAppsForUsersPermissionSetApp extends LightningElement {
    @api showFetchAssignedAppsForUsers=false;
    @api fetchAssignedAppsForUsers1;
    @api fetchAssignedAppsForUsers2;

    
    @api
    async handleAssignedAppsSettings(userName, UserSelection){
        if(UserSelection == 'user1'){
            await fetchAssignedAppsForUsers({ username:userName })
            .then(result => {
                this.fetchAssignedAppsForUsers1 = result;
                console.log('fetchAssignedAppsForUsers1 data ----> ', this.fetchAssignedAppsForUsers1);
            })
            .catch(error => {
                console.error('Error fetching Apex Class settings for ps1:', error);
            });
        }
        
        if(UserSelection == 'user2'){
            await fetchAssignedAppsForUsers({ username:userName })
            .then(result => {
                this.fetchAssignedAppsForUsers2 = result;
                console.log('fetchAssignedAppsForUsers2 data ----> ', this.fetchAssignedAppsForUsers2);
            })
            .catch(error => {
                console.error('Error fetching Apex Class settings for ps1:', error);
            });
        }

        this.showFetchAssignedAppsForUsers=true;

    }

}