import { LightningElement,api } from 'lwc';
import fetchSystemPermissionsForPermissionSet from '@salesforce/apex/permissionCompareHandlerClass.fetchSystemPermissionsForPermissionSet';
import fetchSystemPermissionsForusers from '@salesforce/apex/permissionCompareHandlerClass.fetchSystemPermissionsForusers';
import fetchIntegratedSystemPermissions from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedSystemPermissions';
import fetchIntegratedSystemPermissionsForUsers from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedSystemPermissionsForUsers';

const columns = [
    { label: 'SystemPermission', fieldName: 'SystemPermission', type: 'text', sortable: true },
    { label: 'enabled', fieldName:'Enabled', type: 'boolean', sortable: true}
]
export default class SystemPermissionPermissionSetApp extends LightningElement {
    @api systemPermission1;
    @api systemPermission2;
    @api systemPermissionForUser1;
    @api systemPermissionForUser2;
    @api showSystemPermissions=false;
    @api showSystemPermissionsforUsers=false;
    @api orgSelection;
    @api namedCredential;
   @api showSystemPermissionsCards=false;

   get isData(){
    if(this.systemPermissionForUser2 == undefined || this.systemPermissionForUser2.length == 0){
        return false;
    }
    else{
        return true;
    }
   }
   get isData2(){
    if(this.systemPermissionForUser1 == undefined || this.systemPermissionForUser1.length == 0){
        return false;
    }
    else{
        return true;
    }
   }

    @api
    async handleSystemPermissions(psid, psSelection){
        if(psSelection == 'ps1'){
            let objdata = [];
            fetchSystemPermissionsForPermissionSet({ psId:psid })
                .then(result => {
                    console.log(' result -> '+JSON.stringify(result));
                    
                    let test = Object.entries(result).map(([key,value]) => ({key, value})); 
                    
                    test.forEach(key => {
                        console.log('key.value:', key.value);
                        if(key.value == 'true'){
                            
                            objdata.push({'key' : key.key,'value' : key.value});
                        }
                        if(key.value == 'false'){
                            
                            objdata.push({'key' : key.key,'value' : null});
                        }
                    });
                    this.systemPermission1 = objdata;
                    console.log('system permissions result -> '+JSON.stringify(this.systemPermission1)); 
                })
                .catch(error => {
                    console.error('Error fetching system permissions Class settings for ps1:', error);
                });
        }

        if(this.orgSelection == 'OrgOnly' && psSelection == 'ps2'){
            let objdata = [];
            fetchSystemPermissionsForPermissionSet({ psId:psid })
                .then(result => {
                    
                    let test = Object.entries(result).map(([key,value]) => ({key, value})); 
                    console.log(' test -> '+JSON.stringify(test));
                    test.forEach(key => {
                        
                        if(key.value == 'true'){
                            
                            objdata.push({'key' : key.key,'value' : key.value});
                        }
                        if(key.value == 'false'){
                            
                            objdata.push({'key' : key.key,'value' : null});
                        }
                    });
                    this.systemPermission2 = objdata;
                    console.log('system permissions result -> '+JSON.stringify(this.systemPermission2));   
                })
                .catch(error => {
                    console.error('Error fetching system permissions Class settings for ps1:', error);
                });
        }
        
        if(this.orgSelection == 'DifferentOrg' && psSelection == 'ps2'){
            let objdata = [];
            fetchIntegratedSystemPermissions({credName:this.namedCredential, psId:psid })
                .then(result => {
                    //this.systemPermission2 = Object.entries(result).map(([key,value]) => ({key, value}));
                    let test = Object.entries(result).map(([key,value]) => ({key, value})); 
                    console.log(' test -> '+JSON.stringify(test));
                    test.forEach(key => {
                        
                        if(key.value == 'true'){
                            
                            objdata.push({'key' : key.key,'value' : key.value});
                        }
                        if(key.value == 'false'){
                            
                            objdata.push({'key' : key.key,'value' : null});
                        }
                    });
                    this.systemPermission2 = objdata;
                    console.log('Integrated system permissions this.systemPermission2-->'+ json.stringify(this.systemPermission2));
                })
                .catch(error => {
                    console.error('Error fetching system permissions for integrated ps1:', error);
                });
        }
        if(this.showSystemPermissionsforUsers == true){
            this.showSystemPermissionsforUsers = false;
        }
        this.showSystemPermissions=true;
    }

    @api
    async handleSystemPermissionsForUsers(userName, userSelection){
        if(userSelection == 'user1'){
            let objdata = [];
            fetchSystemPermissionsForusers({ username:userName })
                .then(result => {
                    
                    
                    let user = Object.entries(result).map(([key,value]) => ({key, value})); 
                    console.log(' user -> '+JSON.stringify(user));
                    user.forEach(key => {
                        
                        if(key.value == 'true'){
                            
                            objdata.push({'key' : key.key,'value' : key.value});
                        }
                        if(key.value == 'false'){
                            
                            objdata.push({'key' : key.key,'value' : null});
                        }
                    });
                    this.systemPermissionForUser1 = objdata;  
                    console.log('this.systemPermissionForUser1-->'+(this.systemPermissionForUser1));
                    
                })
                .catch(error => {
                    console.error('Error fetching system permissions Class settings for ps1:', error);
                });
        }
        if(this.orgSelection == 'OrgOnly' && userSelection == 'user2'){
            let objdata = [];
            fetchSystemPermissionsForusers({ username:userName })
                .then(result => {
                    
                    
                    let user = Object.entries(result).map(([key,value]) => ({key, value})); 
                    console.log(' user -> '+JSON.stringify(user));
                    user.forEach(key => {
                        
                        if(key.value == 'true'){
                            
                            objdata.push({'key' : key.key,'value' : key.value});
                        }
                        if(key.value == 'false'){
                            
                            objdata.push({'key' : key.key,'value' : null});
                        }
                    });
                    this.systemPermissionForUser2 = objdata;     
                    console.log(' this.systemPermissionForUser2-->'+ JSON.stringify(this.systemPermissionForUser2));
                })
                .catch(error => {
                    console.error('Error fetching system permissions Class settings for ps1:', error);
                });
        }
        
        if(this.orgSelection == 'DifferentOrg' && userSelection == 'user2'){
            let objdata = [];
            fetchIntegratedSystemPermissionsForUsers({credName:this.namedCredential, username:userName})
                .then(result => {
                    //this.systemPermissionForUser2 = Object.entries(result).map(([key,value]) => ({key, value}));
                    let user = Object.entries(result).map(([key,value]) => ({key, value})); 
                    console.log(' user -> '+JSON.stringify(user));
                    user.forEach(key => {
                        
                        if(key.value == 'true'){
                            
                            objdata.push({'key' : key.key,'value' : key.value});
                        }
                        if(key.value == 'false'){
                            
                            objdata.push({'key' : key.key,'value' : null});
                        }
                    });
                    this.systemPermissionForUser2 = objdata;
                    console.log('integrated this.systemPermissionForUser2-->'+ (this.systemPermissionForUser2)); 
                })
                .catch(error => {
                    console.error('Error fetching system permissions for integrated user2', error);
                });
        }
        if(this.showSystemPermissions == true){
            this.showSystemPermissions = false;
        }
        this.showSystemPermissionsforUsers=true;
    }

    onSectionToggle(){
        if(this.showSystemPermissionsCards==false){
            this.showSystemPermissionsCards=true;
        }
        else if(this.showSystemPermissionsCards==true){
            this.showSystemPermissionsCards=false;
        }
    }
    

}