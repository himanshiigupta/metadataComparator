import { LightningElement } from 'lwc';
import logo from '@salesforce/resourceUrl/logo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UserNames from '@salesforce/apex/permissionCompareHandlerClass.fetchUsersNames'; 
import IntegratedUserNames from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedUserNames';
import IntegratedPermissionSetNames from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedPermissionSetNames';
import IntegratedPermissionSetGroupNames from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedPermissionSetGroupNames';
import PermissionSetNames from '@salesforce/apex/permissionCompareHandlerClass.fetchPermissionSetNames';
import PermissionSetGroupNames from '@salesforce/apex/permissionCompareHandlerClass.fetchPermissionSetGroupNames';
import NamedCredentialLabels from '@salesforce/apex/permissionCompareHandlerClass.fetchNamedCredentialLabels';
import UserDetails from '@salesforce/apex/permissionCompareHandlerClass.fetchUserDetails';
import USER_COMPARER from '@salesforce/label/c.User_Comparer';
import fetchPermissionSetGroupAndPermissionSet from '@salesforce/apex/permissionCompareHandlerClass.fetchPermissionSetGroupAndPermissionSet';
import fetchIntegratedPermissionSetGroupAndPermissionSet from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedPermissionSetGroupAndPermissionSet';
import LightningAlert from 'lightning/alert';
import resourceName from '@salesforce/resourceUrl/cssStyle';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';




export default class PermissionSetAppHeader extends LightningElement {
    label={
        USER_COMPARER
    }
    
    Logo = logo;
    var1;
    itemName;
    user1Name;
    user2Name;
    permissionSetName1;
    permissionSetName2;
    user1 = null;
    user2 = null;
    permissionSet1;
    permissionSet2;
    permissionSetGroup1;
    permissionSetGroup2;
    showNamesDropdown = false;
    showOptionDropdown = false;
    showNamedCredentialDropdown = false;
    showCloseButton = false;
    showUserDetails = false;
    NamesDropdown;
    NamesDropdown2;
    NamedCredentialDropdown;
    user1Details;
    user2Details;
    user1PermissionDetails;
    user2PermissionDetails;
    showUserPermissionSetDetails=false; 
    user1PermissionSetGroups;
    user1PermissionSetGroupsList = [];
    user2PermissionSetGroups;
    user1PermissionSetGroupMap;
    user2PermissionSetGroupMap;
    showUserPermissionSetGroups=false;
    user1PermissionSetsWithoutGroup = [];
    user2PermissionSetsWithoutGroup = [];
    showApexClassSettings=false; 
    showObjectSettings = false;
    dropdownLabel2= "Choose User 2";
    dropdownLabel1= "Choose User 1";
    showExpColAll=false;
    comboboxDisabled=false;
    userselectionDesable=true;
    disableUser1=true;
    disableUser2=true;
    compareButtonDisabled=true;
    disableCloseButton = true;
    //=================================== 
    credName;    
    showsecondclose = false;
    //=================================== 
    
    
    //With this flag we can hide and show the Modal in html file
    isOpen = false;
    
    showModal() {
        this.isOpen = true;
    }
    
    hideModal() {
        this.isOpen = false;
    }
    
    save() {
        this.isOpen = false;
    }
    //===================================
    
    connectedCallback(){
        loadStyle(this, resourceName);
        this.showNamedCredentialDropdown = false;
        this.showNamesDropdown = false;
        this.showOptionDropdown = false;
        

    }
    
    get options(){
        return [
            { label: 'Org Only', value :'OrgOnly'},
            { label : 'Different Org', value : 'DifferentOrg'}
        ]
    }
    
    get dropdownOptions(){
        return [
            {label : 'User', value:'user'},
            {label : 'Permission Set', value: 'permissionSet'}
            
        ]
    }
    handleRadioChange(event){
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = undefined;
        });
        this.userselectionDesable=true;
        this.disableUser1=true;
        this.disableUser2=true;
        this.compareButtonDisabled=true;
        this.comboboxDisabled=true;
        this.NamesDropdown = null;
        this.showExpColAll = false;
        //this.NamesDropdown2 = null;
        this.var1 = event.detail.value;
        this.disableCloseButton = true;
        console.log('this is true'+this.var1);
        if(this.var1=='OrgOnly')
            {
                this.userselectionDesable=false;
                console.log('this is true or false component');
            }
            else
            this.userselectionDesable=true;
            
        this.showUserDetails = false;
        this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassSettings = false;
        this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppSettings = false;
        this.template.querySelector('c-object-setting-permission-set-app').showObjectSettings = false;
        this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageAccess = false;
        this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedApps = false;
        this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageAccessForUsers = false;
        this.template.querySelector('c-object-setting-permission-set-app').showObjectSettingForUsers=false;
        this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassSettingsForUsers=false;
        this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedAppsForUser = false;
        this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppSettingsForUsers = false;
        this.template.querySelector('c-system-permission-permission-set-app').showSystemPermissions=false;
        this.template.querySelector('c-system-permission-permission-set-app').showSystemPermissionsforUsers=false;
        this.showUserPermissionSetGroups = false;
        this.showCloseButton = true;
        if(this.var1 == 'OrgOnly'){
            this.showOptionDropdown = true;
            this.showNamedCredentialDropdown = false;
            this.showNamesDropdown = false;
        }
        else if(this.var1 == 'DifferentOrg'){
            this.namedCredentialFunc();
            this.showNamedCredentialDropdown = true;
            this.showOptionDropdown = false;
            this.showNamesDropdown = false;
        }
    }
    
    handleDropdownChange(event){
        let combobox1 = this.template.querySelector("[data-id='listOfNames1']");
        combobox1.value = undefined;
        let combobox2 = this.template.querySelector("[data-id='listOfNames2']");
        combobox2.value = undefined;
        this.disableUser1=false;
        this.disableUser2=false;
        this.showNamesDropdown = true;
        this.showsecondclose = false;
        this.showOptionDropdown = true; // changed to true to still keep showing after selection
        //this.showCloseButton = false;
        this.itemName = event.detail.value;
        this.showExpColAll = false;
        this.showUserDetails = false;
        this.user1 = null;
        this.user2 = null;
        this.permissionSet1 = null;
        this.permissionSet2 = null;
        this.compareButtonDisabledMethod();
        this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassSettings = false;
        this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppSettings = false;
        this.template.querySelector('c-object-setting-permission-set-app').showObjectSettings = false;
        this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageAccess = false;
        this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedApps = false;
        this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageAccessForUsers = false;
        this.template.querySelector('c-object-setting-permission-set-app').showObjectSettingForUsers=false;
        this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassSettingsForUsers=false;
        this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedAppsForUser = false;
        this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppSettingsForUsers = false;
        this.template.querySelector('c-system-permission-permission-set-app').showSystemPermissions=false;
        this.template.querySelector('c-system-permission-permission-set-app').showSystemPermissionsforUsers=false;
        this.showUserPermissionSetGroups = false;
        //===================================
        if(this.var1 == 'DifferentOrg'){
            // this.showCloseButton = false;
            // this.showsecondclose = false;
            if(this.itemName == 'user'){
                console.log('item name in handledropdown  --> '+this.itemName);            
                this.userFunc();
                this.integratedUserFunc(this.credName);
                this.dropdownLabel1 = "Choose User 1";
                this.dropdownLabel2 = "Choose User 2";
            }
            else if(this.itemName == 'permissionSet'){
                this.permissionSetFunc();
                this.integratedPermissionSetFunc(this.credName);
                this.dropdownLabel1 = "Choose Permission Set 1";
                this.dropdownLabel2 = "Choose Permission Set 2";
            }
            else if(this.itemName == 'permissionSetGroup'){
                this.permissionSetGroupsFunc();
                this.integratedPermissionSetGroupFunc(this.credName);
                this.dropdownLabel1 = "Choose Permission Set Group 1";
                this.dropdownLabel2 = "Choose Permission Set Group 2";
            }
        }
        //===================================        
        else if(this.var1 == 'OrgOnly'){
            this.showsecondclose = true;
            this.disableCloseButton = false;
            if(this.itemName == 'user'){
                this.userFunc();
                this.dropdownLabel1 = "Choose User 1";
                this.dropdownLabel2 = "Choose User 2";
            }
            else if(this.itemName == 'permissionSet'){
                this.permissionSetFunc();
                this.dropdownLabel1 = "Choose Permission Set 1";
                this.dropdownLabel2 = "Choose Permission Set 2";
            }
            else if(this.itemName == 'permissionSetGroup'){
                this.permissionSetGroupsFunc();
                this.dropdownLabel1 = "Choose Permission Set Group 1";
                this.dropdownLabel2 = "Choose Permission Set Group 2";
            }
        }
    }
    
    userFunc(){
        UserNames()
        .then(result => {
            let arr = [];
            for(var i = 0; i < result.length; i++){
                arr.push({label : result[i].Name + ' - '+result[i].Username, value : result[i].Name});
            }
            this.NamesDropdown = arr;
            this.NamesDropdown2 = arr;
        })
    }
    
    //=========================================
    integratedUserFunc(crede){
        IntegratedUserNames({
            credName : crede
        }).then(result => {
            let arr = [];
            for(var i = 0; i < result.length; i++){
                const temp = result[i].split(' - ');
                arr.push({label : result[i], value : temp[0]});
            }
            console.log('arr-> '+JSON.stringify(arr));
            this.NamesDropdown2 = arr;
        })
    }    
    //=========================================
    
    permissionSetFunc(){
        PermissionSetNames()
        .then(result => {
            let arr = [];
            for(var i = 0; i < result.length; i++){
                arr.push({label : result[i].Label, value : result[i].Id});
            }
            this.NamesDropdown = arr;
            this.NamesDropdown2 = arr;
        })
    }
    
    integratedPermissionSetFunc(cred){
        IntegratedPermissionSetNames({
            credName : cred
        }).then(result => {
            let arr = [];
            for(var i = 0; i < result.length; i++){
                arr.push({label : result[i].Label, value : result[i].Id});
            }
            this.NamesDropdown2 = arr;
        })
    }
    
    permissionSetGroupsFunc(){
        PermissionSetGroupNames()
        .then(result => {
            let arr = [];
            for(var i = 0; i < result.length; i++){
                arr.push({label : result[i].MasterLabel, value : result[i].Id});
            }
            this.NamesDropdown = arr;
            this.NamesDropdown2 = arr;
        })
    }
    
    integratedPermissionSetGroupFunc(cred){
        IntegratedPermissionSetGroupNames({
            credName : cred
        }).then(result => {
            let arr = [];
            for(var i = 0; i < result.length; i++){
                arr.push({label : result[i], value : result[i]});
            }
            this.NamesDropdown2 = arr;
        })
    }
    
    namedCredentialFunc(){
        NamedCredentialLabels()
        .then(result => {
            let arr = [];
            for(let key in result){
                arr.push({label : key, value : result[key]});
            }
            console.log('org name and named credential--> '+arr);
            // for(var i = 0; i < result.length; i++){
            //     arr.push({label : result[i], value : result[i]});
            // }
            this.NamedCredentialDropdown = arr;
        })
    }
    
    handleCloseClick(event){
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = undefined;
        });
        this.showExpColAll = false;
        this.showNamesDropdown = false;
        this.showOptionDropdown = true;
        this.user1 = null;
        this.user2 = null;
        this.permissionSet1 = null;
        this.permissionSet2 = null;
        this.user1Name = null;
        this.user2Name = null;
        this.permissionSetName1 = null;
        this.permissionSetName2 = null;
        this.compareButtonDisabledMethod();
        this.disableCloseButton = true;
        this.disableUser1 = true;
        this.disableUser2 = true;
        
        // if(this.var1 == 'OrgOnly'){
        //     this.showCloseButton = false;
        // }
        if(this.var1 == 'DifferentOrg'){
            this.userselectionDesable = true;
        }
        this.showUserDetails = false;
        this.showUserPermissionSetDetails=false;
        this.showUserPermissionSetGroups=false;
        this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassSettings = false;
        this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppSettings = false;
        this.template.querySelector('c-object-setting-permission-set-app').showObjectSettings = false;
        this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageAccess = false;
        this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedApps = false;
        this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageAccessForUsers = false;
        this.template.querySelector('c-object-setting-permission-set-app').showObjectSettingForUsers=false;
        this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassSettingsForUsers=false;
        this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedAppsForUser = false;
        this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppSettingsForUsers = false;
        this.template.querySelector('c-system-permission-permission-set-app').showSystemPermissions=false;
        this.template.querySelector('c-system-permission-permission-set-app').showSystemPermissionsforUsers=false;
        
    }
    
    handleNamedCredentialChange(event){
        //==========================================
        this.userselectionDesable=false;
        this.disableCloseButton = false;
        this.credName = event.detail.value;
        console.log('cred name--> '+this.credName);
        this.ownOrgOrAnother = 'DifferentOrg';
        //==========================================        
        
        //this.showCloseButton = false;
        this.showNamedCredentialDropdown = true;// changed to true to still keep showing after selection
        this.showOptionDropdown = true;
    }
    
    handleCloseNamedCredential(){
        //this.showCloseButton = false;
        this.showNamedCredentialDropdown = true;
        this.showOptionDropdown = false;
    }
    
    handleUser1Change(event){
        
        if(this.itemName == 'user'){
            this.user1Name = event.detail.value;
            
        }
        else if(this.itemName == 'permissionSet'){
            this.permissionSetName1 = event.detail.value;
            
        }
        else if(this.itemName == 'permissionSetGroup'){
            this.permissionSetGroup1 = event.detail.value;
            
        }
        this.compareButtonDisabledMethod();
    }
    
    handleUser2Change(event){
        if(this.itemName == 'user'){
            this.user2Name = event.detail.value;
            console.log('user2-> '+this.user2Name);            
        }
        else if(this.itemName == 'permissionSet'){
            this.permissionSetName2 = event.detail.value;
        }
        else if(this.itemName == 'permissionSetGroup'){
            this.permissionSetGroup2 = event.detail.value;
        }
        this.compareButtonDisabledMethod();
    }
    
    handleCompare(){
        this.user1 = this.user1Name;
        this.user2 = this.user2Name;
        console.log('User 2 Name-->'+this.user2);
        this.permissionSet1 = this.permissionSetName1;
        this.permissionSet2 = this.permissionSetName2;
        console.log('itemName -> '+this.itemName+ ' user1-> '+this.user1+ ' user2-> '+this.user2);
        if(this.itemName == 'user' && (this.user1===this.user2)){
            LightningAlert.open({
                message: 'Please Select Two Different User',
                theme: 'error', 
                label: 'Error!',
            });
        }
        
        else if(this.itemName == 'permissionSet' && (this.permissionSet1===this.permissionSet2)){
            LightningAlert.open({
                message: 'Please Select Two Different Permission sets',
                theme: 'error', 
                label: 'Error!',
            });
        }

        else
        {
         if(this.user1 != null && this.user2 != null){
            if(this.var1 == 'OrgOnly'){
                this.showExpColAll=true;
                UserDetails({
                    userName: this.user1
                }).then(result =>{
                    this.user1Details = result;
                });
                
                UserDetails({
                    userName: this.user2
                }).then(result =>{
                    this.user2Details = result;
                });
                
                
                fetchPermissionSetGroupAndPermissionSet({
                    userName:this.user1   
                }).then(result =>{
                    
                    this.user1PermissionSetGroupMap=this.processPermissionSetGroupData(result, 'user1');
                    
                })
                fetchPermissionSetGroupAndPermissionSet({
                    userName:this.user2 
                }).then(result =>{
                    
                    this.user2PermissionSetGroupMap=this.processPermissionSetGroupData(result, 'user2');
                    
                })
                
                this.template.querySelector('c-vf-page-settings-permission-set-app').handleVfPageSettingsForUsers(this.user1,'user1');
                this.template.querySelector('c-vf-page-settings-permission-set-app').handleVfPageSettingsForUsers(this.user2,'user2');
                
                this.template.querySelector('c-object-setting-permission-set-app').handleObjectSettingsForUsers(this.user1,'user1');
                this.template.querySelector('c-object-setting-permission-set-app').handleObjectSettingsForUsers(this.user2,'user2');
                
                this.template.querySelector('c-apex-class-settings-permission-set-app').handleApexClassSettingsforUser(this.user1,'user1');
                this.template.querySelector('c-apex-class-settings-permission-set-app').handleApexClassSettingsforUser(this.user2,'user2');
                
                this.template.querySelector('c-assigned-apps-permission-set-app').handleAssignedAppsSettingsforUsers(this.user1,'user1');
                this.template.querySelector('c-assigned-apps-permission-set-app').handleAssignedAppsSettingsforUsers(this.user2,'user2');
                
                this.template.querySelector('c-connected-app-setting-permission-set-app').handleConnectedAppSettingsForUsers(this.user1,'user1');
                this.template.querySelector('c-connected-app-setting-permission-set-app').handleConnectedAppSettingsForUsers(this.user2,'user2');
                
                this.template.querySelector('c-system-permission-permission-set-app').handleSystemPermissionsForUsers(this.user1,'user1');
                this.template.querySelector('c-system-permission-permission-set-app').handleSystemPermissionsForUsers(this.user2,'user2');
                
                this.showUserDetails = true;
                this.showUserPermissionSetGroups=true;
                this.showApexClassSettings=false;
                
            }
            if(this.var1 == 'DifferentOrg'){
                this.showExpColAll=true;
                UserDetails({
                    userName: this.user1
                }).then(result =>{
                    this.user1Details = result;
                });
                this.template.querySelector('c-child-user-details-permission-set-app').handleIntegratedUserDetails(this.user2);
                
                fetchPermissionSetGroupAndPermissionSet({
                    userName:this.user1   
                }).then(result =>{
                    
                    this.user1PermissionSetGroupMap=this.processPermissionSetGroupData(result, 'user1');
                    
                })
                
                fetchIntegratedPermissionSetGroupAndPermissionSet({credName:this.credName, username:this.user2})
                .then(result => {
                    this.user2PermissionSetGroupMap = this.processPermissionSetGroupData(result, 'user2');;
                })
                
                this.template.querySelector('c-apex-class-settings-permission-set-app').handleApexClassSettingsforUser(this.user1,'user1');
                this.template.querySelector('c-apex-class-settings-permission-set-app').handleApexClassSettingsforUser(this.user2, 'user2');
                
                this.template.querySelector('c-assigned-apps-permission-set-app').handleAssignedAppsSettingsforUsers(this.user1,'user1');
                this.template.querySelector('c-assigned-apps-permission-set-app').handleIntegratedAssignedAppsForUsers(this.user2);
                
                this.template.querySelector('c-connected-app-setting-permission-set-app').handleConnectedAppSettingsForUsers(this.user1,'user1');
                this.template.querySelector('c-connected-app-setting-permission-set-app').handleIntegratedConnectedAppsForUsers(this.user2);
                
                this.template.querySelector('c-vf-page-settings-permission-set-app').handleVfPageSettingsForUsers(this.user1,'user1');
                this.template.querySelector('c-vf-page-settings-permission-set-app').handleVfPageSettingsForUsers(this.user2,'user2');
                
                this.template.querySelector('c-object-setting-permission-set-app').handleObjectSettingsForUsers(this.user1,'user1');
                this.template.querySelector('c-object-setting-permission-set-app').handleObjectSettingsForUsers(this.user2,'user2');
                
                this.template.querySelector('c-system-permission-permission-set-app').handleSystemPermissionsForUsers(this.user1,'user1');
                this.template.querySelector('c-system-permission-permission-set-app').handleSystemPermissionsForUsers(this.user2,'user2');
                
                this.showUserDetails = true;
                this.showUserPermissionSetGroups=true;
            }
        }
        
        if(this.permissionSet1 != null && this.permissionSet2 != null){
            if(this.itemName == 'permissionSet'){
                this.showExpColAll=false;
                this.template.querySelector('c-apex-class-settings-permission-set-app').handleApexClassSettings(this.permissionSet1, 'ps1');
                this.template.querySelector('c-apex-class-settings-permission-set-app').handleApexClassSettings(this.permissionSet2, 'ps2');                
                
                this.template.querySelector('c-object-setting-permission-set-app').handleObjectSettings(this.permissionSet1, 'ps1');
                this.template.querySelector('c-object-setting-permission-set-app').handleObjectSettings(this.permissionSet2, 'ps2');
                
                this.template.querySelector('c-connected-app-setting-permission-set-app').handleConnectedAppSettings(this.permissionSet1, 'ps1');
                this.template.querySelector('c-connected-app-setting-permission-set-app').handleConnectedAppSettings(this.permissionSet2, 'ps2');
                
                this.template.querySelector('c-vf-page-settings-permission-set-app').handleVfPageSettings(this.permissionSet1, 'ps1');
                this.template.querySelector('c-vf-page-settings-permission-set-app').handleVfPageSettings(this.permissionSet2, 'ps2');
                
                this.template.querySelector('c-assigned-apps-permission-set-app').handleAssignedAppsSettings(this.permissionSet1, 'ps1');
                this.template.querySelector('c-assigned-apps-permission-set-app').handleAssignedAppsSettings(this.permissionSet2, 'ps2');
                
                this.template.querySelector('c-system-permission-permission-set-app').handleSystemPermissions(this.permissionSet1,'ps1');
                this.template.querySelector('c-system-permission-permission-set-app').handleSystemPermissions(this.permissionSet2,'ps2');
                
                if(this.var1 == 'DifferentOrg'){
                    //this.template.querySelector('c-apex-class-settings-permission-set-app').handleIntegratedApexClassSettings(this.permissionSet2, 'ps2');
                    this.template.querySelector('c-assigned-apps-permission-set-app').handleIntegratedAssignedAppSettings(this.permissionSet2, 'ps2');
                    this.template.querySelector('c-connected-app-setting-permission-set-app').handleIntegratedConnectedAppSettings(this.permissionSet2, 'ps2');
                }
                
                this.showUserDetails = false;
                this.showUserPermissionSetGroups=false;
            }
        }
     }
    }
    
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    
    processPermissionSetGroupData(data, user) {
        let processedData = [];
        for (let groupName in data) {
            if(groupName == 'Without Group'){
                if(user == 'user1'){
                    this.user1PermissionSetsWithoutGroup = this.processData2(data[groupName]);
                }
                else{
                    this.user2PermissionSetsWithoutGroup = this.processData2(data[groupName]);
                }
            }
            else{
                
                processedData.push({
                    groupLabel: groupName,
                    permissionSets: this.processData2(data[groupName])
                });
                
            }
        }
        return processedData;
    }
    
    processData2(data){
        let processedData = [];
        for(let psName in data){
            processedData.push({
                permissionSetUrl : this.generateUrl(data[psName]),
                psLabel : psName
            })
        }
        for(var i = 0; i < processedData.length; i++){
            console.log('permission set url --> '+processedData[i].permissionSetUrl);
            console.log('permission set label ---> '+processedData[i].psLabel);
        }
        return processedData;
    }
    
    generateUrl(permissionSetId){
        const baseUrl = window.location.hostname;
        const url = '/lightning/setup/PermSets/page?address=%2F';
        return `${url}${permissionSetId}`;
    }
    handleSwitchToLight(){
        
        const baseUrl=window.location.hostname;
        const fullurl=baseUrl+'/lightning/setup/SetupOneHome/home';
        console.log('full url -->'+fullurl);
        window.open('https://'+fullurl, '_blank');
    }
    handleAll(event){
        const val=event.target.name;
        console.log('the val is 0',val);
        if(val=='Expand'){
            if(this.itemName == 'user'){
                this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassCardsForUsers=true;
                this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppCardsForUsers = true;
                this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageCardsForUsers = true;
                this.template.querySelector('c-object-setting-permission-set-app').showObjectSettingCardsForUsers=true;
                this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedAppsCardsForUsers = true;
                this.template.querySelector('c-system-permission-permission-set-app').showSystemPermissionsCards=true;
            }
            
            else if(this.itemName == 'permissionSet'){
                console.log('this item is :'+this.itemName);
                this.showApexClassSettings=true;
                this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassSettings = true;
                this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppSettings = true;
                this.template.querySelector('c-object-setting-permission-set-app').showObjectSettings = true;
                this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageAccess = true;
                this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedApps = true;
                
            }
            
            
            
        }
        else if(val=='Collapse'){
            if(this.itemName == 'user'){
                this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassCardsForUsers=false;
                this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppCardsForUsers = false;
                this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageCardsForUsers = false;
                this.template.querySelector('c-object-setting-permission-set-app').showObjectSettingCardsForUsers=false;
                this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedAppsCardsForUsers = false;
                this.template.querySelector('c-system-permission-permission-set-app').showSystemPermissionsCards=false;
                
            }
            else if(this.itemName=='permissionSet'){
                this.template.querySelector('c-apex-class-settings-permission-set-app').showApexClassSettings = true;
                this.template.querySelector('c-connected-app-setting-permission-set-app').showConnectedAppSettings = true;
                this.template.querySelector('c-object-setting-permission-set-app').showObjectSettings = true;
                this.template.querySelector('c-vf-page-settings-permission-set-app').showVfPageAccess = true;
                this.template.querySelector('c-assigned-apps-permission-set-app').showAssignedApps = true;
            }
            
            
        }
    }
    compareButtonDisabledMethod()
    {
        
        if((this.user1Name != null  && this.user2Name != null) || (this.permissionSetName1 != null && this.permissionSetName2 != null))
            {
                this.compareButtonDisabled=false;
            }
        else{
                this.compareButtonDisabled=true;
            }
    }
}