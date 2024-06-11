import { LightningElement, api } from 'lwc';
import fetchIntegratedUserDetails from '@salesforce/apex/permissionCompareHandlerDifferentOrg.fetchIntegratedUserDetails';

export default class ChildUserDetailsPermissionSetApp extends LightningElement {
    @api showUserDetails;
    @api user1Name;
    @api user2Name; 
    @api user1Details;
    @api user2Details;
    @api namedCredential;
    showIntegratedUserDetails=false;
    @api user2Id;
    user2Map;
    //====================
    orgName;
    //====================

    @api
    handleIntegratedUserDetails(user2){
        fetchIntegratedUserDetails({
            credName:this.namedCredential,
            userName: user2
        }).then(result =>{
            console.log('result ----> ', result);
            //====================
            this.orgName = result.orgName;
            //====================
            for (let key in result) {
                if(key == 'idd'){
                    this.user2Id = result[key];
                }
            }
            console.log('user2Id--> '+this.user2Id);
            this.user2Details = result;
        });
        //console.log('user2Id--> '+this.user2Id);
        this.showIntegratedUserDetails = true;
    }
}