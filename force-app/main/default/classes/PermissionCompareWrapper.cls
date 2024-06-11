public class PermissionCompareWrapper {
    
    // Wrapper for user details
    public class UserWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public Id idd;
        @AuraEnabled public String UserRoleName;
        @AuraEnabled public String LocaleSidKey;
        @AuraEnabled public String ProfileUserLicenseName;
        @AuraEnabled public String ProfileName;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public String LastLoginDate;
    }

    // Wrapper for Object Permissions
    
    public class ObjectPermissionsWrapper{
        @AuraEnabled public String sObjectType;
        @AuraEnabled public Boolean permissionsModifyAllRecords;
        @AuraEnabled public Boolean permissionsViewAllRecords;
        @AuraEnabled public Boolean permissionsRead;
        @AuraEnabled public Boolean permissionsCreate;
        @AuraEnabled public Boolean permissionsEdit;
        @AuraEnabled public Boolean permissionsDelete;
    
    public ObjectPermissionsWrapper(String sObjectType, Boolean permissionsModifyAllRecords, Boolean permissionsViewAllRecords, 
                                        Boolean permissionsRead, Boolean permissionsCreate, Boolean permissionsEdit, Boolean permissionsDelete) {
                                            this.sObjectType = sObjectType;
                                            this.permissionsModifyAllRecords = permissionsModifyAllRecords;
                                            this.permissionsViewAllRecords = permissionsViewAllRecords;
                                            this.permissionsRead = permissionsRead;
                                            this.permissionsCreate = permissionsCreate;
                                            this.permissionsEdit = permissionsEdit;
                                            this.permissionsDelete = permissionsDelete;
                                        }
    }
    // Wrapper for Object Permissions 2 
    public class ObjectPermissionsWrapper2{
    	@AuraEnabled public String sObjectType;
        @AuraEnabled public Boolean permissionsModifyAllRecords;
        @AuraEnabled public Boolean permissionsViewAllRecords;
        @AuraEnabled public Boolean permissionsRead;
        @AuraEnabled public Boolean permissionsCreate;
        @AuraEnabled public Boolean permissionsEdit;
        @AuraEnabled public Boolean permissionsDelete;
    
         public ObjectPermissionsWrapper2(String SObjectType, Boolean PermissionsModifyAllRecords, Boolean PermissionsViewAllRecords,
                                          Boolean PermissionsRead, Boolean PermissionsCreate, Boolean PermissionsEdit, 
                                          Boolean PermissionsDelete) {
            this.sObjectType = sObjectType;
            this.permissionsModifyAllRecords = permissionsModifyAllRecords;
            this.permissionsViewAllRecords = permissionsViewAllRecords;
            this.permissionsRead = permissionsRead;
            this.permissionsCreate = permissionsCreate;
            this.permissionsEdit = permissionsEdit;
            this.permissionsDelete = permissionsDelete;
        }
    }
    
    // Wrapper for Users (Different Org)
     public class IntegratedUserWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public Id idd;
        @AuraEnabled public String UserRoleName;
        @AuraEnabled public String LocaleSidKey;
        @AuraEnabled public String ProfileUserLicenseName;
        @AuraEnabled public String ProfileName;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public String LastLoginDate;
    }
    
    //Wrapper to store connectedApps data for integrated users 
    public class conAppData{
        @AuraEnabled public Id idd;
        @AuraEnabled public String Name;
    }
    
    //Wrapper to Store assigned apps data
    public class app{
        @AuraEnabled public Id idd;
        @AuraEnabled public String Name;
    }
}