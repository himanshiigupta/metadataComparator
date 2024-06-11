import { LightningElement,api } from 'lwc';
import fetchObjectSetting from '@salesforce/apex/permissionCompareHandlerClass.fetchObjectSetting';
import fetchObjectPermissionsForUsers from '@salesforce/apex/permissionCompareHandlerClass.fetchObjectPermissionsForUsers';
import fetchIntegratedObjectSettings from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedObjectSetting';
import fetchIntegratedObjectSettingsForUsers from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedObjectSettingsForUsers';

const columns = [
    { label: 'Object', fieldName: 'sObjectType', type: 'text', sortable: true },
    { label: 'Read', fieldName: 'permissionsRead', type: 'boolean', sortable: true },
    { label: 'Create', fieldName: 'permissionsCreate', type: 'boolean', sortable: true },
    { label: 'Edit', fieldName: 'permissionsEdit', type: 'boolean', sortable: true },
    { label: 'Delete', fieldName: 'permissionsDelete', type: 'boolean', sortable: true },
    { label: 'Modify All', fieldName: 'permissionsModifyAllRecords', type: 'boolean', sortable: true },
    { label: 'View All', fieldName: 'permissionsViewAllRecords', type: 'boolean', sortable: true },
];

export default class ObjectSettingPermissionSetApp extends LightningElement {
    objectSetting1;
    objectSetting2;
    objectSettingForUser1;
    objectSettingForUser2;
    @api orgSelection;
    @api namedCredential;

    columns = columns;
    @api showObjectSettings = false;
    @api showObjectSettingForUsers=false;
    @api showObjectSettingCardsForUsers = false;

    @api
    async handleObjectSettings(psid, psSelection){
        if(psSelection == 'ps1'){
            fetchObjectSetting({ psId:psid })
                .then(result => {
                    this.objectSetting1 = result;
                    console.log('objectSetting1 is '+JSON.stringify(this.objectSetting1));
                })
                .catch(error => {
                    console.error('Error fetching object settings for ps1:', error);
                });
        }
        
        if(this.orgSelection == 'OrgOnly' && psSelection == 'ps2'){
            fetchObjectSetting({ psId:psid })
                .then(result => {
                    this.objectSetting2 = result;
                    console.log('objectSetting2 is '+this.objectSetting2);
                     })
                .catch(error => {
                    console.error('Error fetching object settings for ps2:', error);
                });
        }

        if(this.orgSelection == 'DifferentOrg' && psSelection == 'ps2'){
            fetchIntegratedObjectSettings({credName:this.namedCredential, psId:psid })
                .then(result => {
                    console.log('integrated object settings ---> '+result);
                    this.objectSetting2 = result;
                })
                .catch(error => {
                    console.error('Error fetching object settings for integrated ps2:', error);
                });
        }
        if(this.showObjectSettingForUsers == true){
            this.showObjectSettingForUsers = false;
        }
        this.showObjectSettings = true;
        
    }


    @api
    async handleObjectSettingsForUsers(userName, userSelection){
        if(userSelection == 'user1'){
            fetchObjectPermissionsForUsers({ username:userName })
                .then(result => {
                    this.objectSettingForUser1 = result;
                    console.log('objectSettingForUser1 for users '+JSON.stringify(this.objectSettingForUser1));
                })
                .catch(error => {
                    console.error('Error fetching Apex Class settings for user 1:', error);
                });
        }
        
        if(this.orgSelection == 'OrgOnly' && userSelection == 'user2'){
            fetchObjectPermissionsForUsers({  username:userName })
                .then(result => {
                    this.objectSettingForUser2 = result;
                    console.log('objectSettingForUser1 is '+this.objectSettingForUser2);
                    })
                .catch(error => {
                    console.error('Error fetching object settings for user 2:', error);
                });
        }

        if(this.orgSelection == 'DifferentOrg' && userSelection == 'user2'){
            fetchIntegratedObjectSettingsForUsers({credName:this.namedCredential, username:userName})
                .then(result => {
                    this.objectSettingForUser2 = result;
                    console.log('integrated obj settings ---> '+this.objectSettingForUser2);
                })
                .catch(error => {
                    console.error('Error fetching object settings for integrated user 2:', error);
                });
        }
        if(this.showObjectSettings == true){
            this.showObjectSettings = false;
        }
        this.showObjectSettingForUsers=true;
      
        
    }

    onSectionToggle(){
        if(this.showObjectSettingCardsForUsers == false){
            this.showObjectSettingCardsForUsers = true;
        }
        else if(this.showObjectSettingCardsForUsers == true){
            this.showObjectSettingCardsForUsers = false;
        }
    }
}