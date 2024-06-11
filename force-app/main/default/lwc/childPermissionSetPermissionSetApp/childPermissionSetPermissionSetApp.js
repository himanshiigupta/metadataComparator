import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ChildPermissionSetPermissionSetApp extends LightningElement {
    
    @api user1Name;
    @api user2Name;
    @api user1PermissionDetails;
    @api user2PermissionDetails;
    @api showUserPermissionSetDetails=false;
    baseUrl;

    connectedCallback(){
        this.baseUrl = window.location.origin;
    }
    
}