import { LightningElement,api } from 'lwc';
import fetchAssignedConnectedAppsForUsers from '@salesforce/apex/permissionCompareHandlerClass.fetchAssignedConnectedAppsForUsers';

export default class ChildFetchConnectedAppForUsersPermissionSetApp extends LightningElement {
    @api hasChildFetchConnectedAppForUsersPermissionSetApp=false;
    @api ChildFetchConnectedAppForUsers1;
    @api ChildFetchConnectedAppForUsers2;

    @api
    async handleFetchConnectedAppForUsers(userName, UserSelection){
        if(UserSelection == 'user1'){
            await fetchAssignedConnectedAppsForUsers({ username:userName })
            .then(result => {
                this.ChildFetchConnectedAppForUsers1 = result;
            })
            .catch(error => {
                console.error('Error fetching Connected App settings for ps1:', error);
            });
        }
        
        if(UserSelection == 'user2'){
            await fetchAssignedConnectedAppsForUsers({ username:userName })
            .then(result => {
                this.apexClassSettingforUser2 = result;
            })
            .catch(error => {
                console.error('Error fetching Connected App settings for ps1:', error);
            });
            
        }
        this.hasChildFetchConnectedAppForUsersPermissionSetApp=true;

    }
}