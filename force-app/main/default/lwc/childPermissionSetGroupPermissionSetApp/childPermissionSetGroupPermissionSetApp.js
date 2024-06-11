import { LightningElement,api } from 'lwc';

export default class ChildPermissionSetGroupPermissionSetApp extends LightningElement {

    @api user1Name;
    @api user2Name;
    
    @api showUserPermissionSetGroups;
    @api user1PermissionSetGroupMap;
    @api user2PermissionSetGroupMap;
    @api permissionSetsWithoutGroup;
    @api user1PermissionSetsWithoutGroup;
    @api user2PermissionSetsWithoutGroup;
    
    get noData(){
        if((this.user1PermissionSetGroupMap == undefined || this.user1PermissionSetGroupMap.length == 0)&&(this.user1PermissionSetsWithoutGroup == undefined || this.user1PermissionSetsWithoutGroup.length == 0)){
            return true;
        }
        else{
            return false;
        }
    }
    get noData2(){
        if((this.user2PermissionSetGroupMap == undefined || this.user2PermissionSetGroupMap.length == 0)&&(this.user2PermissionSetsWithoutGroup == undefined || this.user2PermissionSetsWithoutGroup.length == 0)){
            return true;
        }
        else{
            return false;
        }
    }
    navigateToPermissionSet1(event){
        const name = event.target.name;
        let psUrl;
        if(name == 'button1'){
            psUrl = event.target.dataset.url1;
        }
        else if(name == 'button2'){
            psUrl = event.target.dataset.url2;
        }
        window.open(psUrl,'_blank');
    }

    navigateToPermissionSet2(event){
        const name = event.target.name;
        let psUrl;
        if(name == 'button3'){
            psUrl = event.target.dataset.url3;
        }
        else if(name == 'button4'){
            psUrl = event.target.dataset.url4;
        }
        window.open(psUrl,'_blank');
    }


}