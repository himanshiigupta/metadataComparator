//Component - 05/02/2024
import { LightningElement,api } from 'lwc';
import fetchApexClassForUsers from '@salesforce/apex/permissionCompareHandlerClass.fetchApexClassForUsers';
export default class ChildFetchApexClassForUsersPermissionSetApp extends LightningElement {
    @api ShowApexClassForUser=false;
    @api apexClassSettingforUser1;
    @api apexClassSettingforUser2;

    @api
    async handleApexClassSettings(userName, UserSelection){
        if(UserSelection == 'user1'){
            await fetchApexClassForUsers({ username:userName })
            .then(result => {
                this.apexClassSettingforUser1 = result;
                console.log('apexClassSettingforUser1 data ----> ', this.apexClassSettingforUser1);
            })
            .catch(error => {
                console.error('Error fetching Apex Class settings for ps1:', error);
            });
        }
        
        if(UserSelection == 'user2'){
            await fetchApexClassForUsers({ username:userName })
            .then(result => {
                this.apexClassSettingforUser2 = result;
                console.log('apexClassSettingforUser2 data ----> ', this.apexClassSettingforUser2);
            })
            .catch(error => {
                console.error('Error fetching Apex Class settings for ps1:', error);
            });
        }

        this.ShowApexClassForUser=true;

    }

}