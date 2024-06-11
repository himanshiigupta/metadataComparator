/* 
* Name:- permissionCompareHandlerClass
* Date:- 22-01-2024
*/

public class permissionCompareHandlerClass {
    
    //Method to fetch the usersname from org --> 22-01-2024
    @AuraEnabled(cacheable=true)
    public static List<User> fetchUsersNames(){
        //return [SELECT Name FROM User];
        return [SELECT Id, Name, UserName, UserType FROM User where UserType = 'Standard'];
    }
    
    //Method to fetch Permissionset label from org --> 22-01-2024
    @AuraEnabled(cacheable=true)
    public static List<PermissionSet> fetchPermissionSetNames(){
        return [SELECT Label FROM PermissionSet Where (Type = 'Regular' OR Type = 'Session') AND IsCustom = true];
    }
    
    //Method to fetch the permissionSetGroup masterLabel from the org --> 23-01-2024
    @AuraEnabled(cacheable=true)
    public static List<PermissionSetGroup> fetchPermissionSetGroupNames(){
        return [select MasterLabel from PermissionSetGroup];
    }
    /*
//Method to fetch Named Credentials Label from the org --> 23-01-2024
@AuraEnabled(cacheable=true)
public static List<NamedCredential> fetchNamedCredentialLabels(){
return [Select MasterLabel from NamedCredential];
}

*/
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> fetchNamedCredentialLabels(){
        List<NamedCredential> nm= [Select DeveloperName from NamedCredential];
        List<String> NamedCreds=new List<String>();
        Map<String,String> orgNames=new Map<String,String>();
        string orgName;
        for(NamedCredential s:nm){
            NamedCreds.add(s.DeveloperName);
        }
        for(String n : NamedCreds){
            
            HttpRequest request=new HttpRequest();
            String query='SELECT+Name+FROM+Organization';
            
            request.setEndpoint('callout:'+n+'/services/data/v58.0/query?q='+EncodingUtil.urlEncode('select Name from Organization', 'UTF-8'));
            request.setMethod('GET');
            system.debug('Request '+request);
            Http http=new Http();
            HttpResponse response = http.send(request);
            system.debug('the Response is '+response.getBody());
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> records = (List<Object>) jsonResponse.get('records');
                for (Object record : records) {
                    Map<String, Object> recordMap = (Map<String, Object>) record;
                    orgName = (String) recordMap.get('Name');
                    orgNames.put(orgName, n);
                }
            }
            
        }
        system.debug('The orgs Name is '+orgNames);
        return orgNames;
    }
    
    // Wrapper to store user details
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
    
    //Method to fetch user details --> 24-01-2024
    @AuraEnabled(cacheable=true)
    public static UserWrapper fetchUserDetails(String userName){
        User u = [Select Id, Name, UserRole.Name, LocaleSidKey, Profile.UserLicense.Name, Profile.Name, IsActive, LastLoginDate from User
                  Where Name =: userName WITH SECURITY_ENFORCED LIMIT 1];
        UserWrapper uw = new UserWrapper();
        uw.Name = u.Name;
        uw.idd = u.Id;
        uw.LocaleSidKey = u.LocaleSidKey;
        uw.ProfileUserLicenseName = u.Profile.UserLicense.Name;
        uw.ProfileName = u.Profile.Name;
        uw.isActive = u.IsActive;
        System.debug('lastlogindate-> '+u.LastLoginDate);
        uw.LastLoginDate = String.valueOf(u.LastLoginDate);
        if(u.UserRole.Name != null){
            uw.UserRoleName = u.UserRole.Name;
        }
        else{
            uw.UserRoleName = 'N/A';
        }
        System.debug('uw-> '+uw);
        return uw;
    }
    
    //Method to fetch permission set --> 25-01-2024
    /*@AuraEnabled(cacheable=true)
public static List<PermissionSet> fetchPermissionSet(String userName){

user uRec =[SELECT id,name from user WHERE Name=:userName];
List<PermissionSetAssignment> psaList = [SELECT Id, PermissionSetId,PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId =:uRec.Id];
Set<Id> psIds = new Set<Id>();
for(PermissionSetAssignment psa : psaList){
psIds.add(psa.PermissionSetId);
}
List<PermissionSet> psList = [Select Id, Label from PermissionSet Where (Type = 'Regular' OR Type = 'Session') AND IsCustom = true AND Id In : psIds];
System.debug('psdata----> '+psList);
return psList;
}*/
    /*
//Method to fetch permissionSetGroup--> 25-01-2024
@AuraEnabled(cacheable=true)
public static List<PermissionSetAssignment> fetchPermissionSetGroup(String userName){
user uRec =[SELECT id,name from user WHERE Name=:userName];
return [SELECT Id, PermissionSetId,PermissionSet.Label, AssigneeId, Assignee.Name,PermissionSetGroup.MasterLabel, PermissionSetGroup.DeveloperName,PermissionSetGroupId FROM PermissionSetAssignment
WHERE AssigneeId=:uRec.id AND PermissionSetGroupId != Null];  
}
*/
    //Method to fetch permissionSetGroup--> 29-01-2024
    @AuraEnabled(cacheable=true)
    public static Map<string,Map<String, Id>> fetchPermissionSetGroupAndPermissionSet(String userName){
        system.debug('The userName is '+UserName);
        user uRec=[SELECT id,name FROM User WHERE Name=:userName];
        set<id> PermissionGroupId=new set<id>();
        Set<Id> PermissionSetId = new Set<Id>();
        
        List<PermissionSetAssignment> PermissionSetAssignments=[SELECT id,PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel from PermissionSetAssignment where AssigneeId=:uRec.id];
        for(PermissionSetAssignment ps: PermissionSetAssignments){
            if(ps.PermissionSetGroupId != null){
                PermissionGroupId.add(ps.PermissionSetGroupId);
            }
            else{
                PermissionSetId.add(ps.PermissionSetId);
            }
        }
        List<PermissionSetGroupComponent> psGroupComp=[select Id,PermissionSet.Id, PermissionSet.Label, PermissionSetGroup.MasterLabel,PermissionSetGroupId from PermissionSetGroupComponent 
                                                       where PermissionSetGroupId IN :PermissionGroupId];
        
        system.debug('PermissionSetGroupComponent '+psGroupComp);
        Map<string,Map<String, Id>> newMap = new Map<string,Map<String, Id>>();
        
        for(PermissionSetGroupComponent p : psGroupComp){
            Map<String, Id> psNames = new Map<String, Id>();
            if(newMap.containsKey(p.PermissionSetGroup.MasterLabel)){
                psNames = newMap.get(p.PermissionSetGroup.MasterLabel);
                psNames.put(p.PermissionSet.Label, p.PermissionSetId);
                newMap.put(p.PermissionSetGroup.MasterLabel, psNames);
            }
            else{
                Map<String, Id> psMap = new Map<String, Id>();
                psMap.put(p.PermissionSet.Label, p.PermissionSetId);
                newMap.put(p.PermissionSetGroup.MasterLabel, psMap);
            } 
        }
        
        List<PermissionSet> psList = [Select Id, Label from PermissionSet Where (Type = 'Regular' OR Type = 'Session') AND IsCustom = true AND Id In : PermissionSetId];
        Map<String, Id> psNames = new Map<String, Id>();
        for(PermissionSet ps : psList){
            psNames.put(ps.Label, ps.Id);
        }
        newMap.put('Without Group', psNames);
        System.debug('Map values----> '+newMap);
        return newMap;
    }
    
    //Method to fetch Apex Class Permissions for a permission set - 31/01/2024 
    @AuraEnabled(cacheable=true)
    public static List<ApexClass> fetchApexClassPermissions(String psId){
        
        Map<ID,AggregateResult> mapAccess=new Map<Id, AggregateResult>([SELECT SetupEntityId Id
                                                                        FROM SetupEntityAccess where ParentId =: psId And SetupEntityType='ApexClass' GROUP By SetupEntityId]);
        
        List<ApexClass> apexClasses=[Select Id, Name from Apexclass where id in:mapAccess.keyset()];
        
        System.debug(apexClasses);
        return apexClasses;
        
    }
    
    public class ObjectPermissionsWrapper {
        @AuraEnabled
        
        public String sObjectType { get; set; }
        @AuraEnabled
        public Boolean permissionsModifyAllRecords { get; set; }
        @AuraEnabled
        public Boolean permissionsViewAllRecords { get; set; }
        @AuraEnabled
        public Boolean permissionsRead { get; set; }
        @AuraEnabled
        public Boolean permissionsCreate { get; set; }
        @AuraEnabled
        public Boolean permissionsEdit { get; set; }
        @AuraEnabled
        public Boolean permissionsDelete { get; set; }
        
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
    @AuraEnabled(cacheable=true)
    public static List<ObjectPermissionsWrapper> fetchObjectSetting(String psId){
        // Populate allObjMap with SObjectType as key and empty ObjectPermissions as value
        List<AggregateResult> objectNames = [SELECT SObjectType FROM ObjectPermissions GROUP BY SObjectType ORDER BY SObjectType ASC];
        Map<String, ObjectPermissions> allObjMap = new Map<String, ObjectPermissions>();
        for (AggregateResult agr : objectNames) {
            allObjMap.put((String) agr.get('SObjectType'), new ObjectPermissions(SObjectType = (String) agr.get('SObjectType')));
        }
        
        // Fetch ObjectPermissions for the given permission set
        List<ObjectPermissions> opForPs = [SELECT Id, SObjectType, Parent.label, PermissionsModifyAllRecords, PermissionsViewAllRecords, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, ParentId 
                                           FROM ObjectPermissions WHERE ParentId = :psId];
        
        // Populate allObjMap with fetched ObjectPermissions
        for (ObjectPermissions op : opForPs) {
            if (allObjMap.containsKey(op.SObjectType)) {
                allObjMap.put(op.SObjectType, op);
            }
        }
        
        // Create a list to hold the wrapper class instances
        List<ObjectPermissionsWrapper> objPermissionsList = new List<ObjectPermissionsWrapper>();
        
        // Iterate through the map and populate the list
        for (ObjectPermissions objPerm : allObjMap.values()) {
            objPermissionsList.add(new ObjectPermissionsWrapper(
                objPerm.SObjectType,
                objPerm.PermissionsModifyAllRecords,
                objPerm.PermissionsViewAllRecords,
                objPerm.PermissionsRead,
                objPerm.PermissionsCreate,
                objPerm.PermissionsEdit,
                objPerm.PermissionsDelete
            ));
        }
        System.debug(objPermissionsList);
        return objPermissionsList;
    }
    
    
    
    //Method to fetch connected app permissions for a permission set - 01/02/2024
    @AuraEnabled(cacheable=true)
    public static List<ConnectedApplication> fetchConnectedAppSettings(String psId){
        List<SetupEntityAccess> seaList = [Select Id, ParentId, SetupEntityId, SetupEntityType from SetupEntityAccess Where SetupEntityType = 'ConnectedApplication' AND ParentId =: psId];
        Set<Id> appIds = new Set<Id>();
        for(SetupEntityAccess sea : seaList){
            appIds.add(sea.SetupEntityId);
        }
        List<ConnectedApplication> conAppList = [Select Id, Name from ConnectedApplication Where Id In : appIds];
        return conAppList;
    } 
    
    //Method to fetch visualforce page access for a permission set - 02/02/2024
    @AuraEnabled(cacheable=true)
    public static List<ApexPage> fetchVfPageAccess(String psId){
        List<SetupEntityAccess> seaList = [Select Id, ParentId, SetupEntityId, SetupEntityType from SetupEntityAccess Where SetupEntityType = 'ApexPage' AND ParentId =: psId];
        Set<Id> vfPageIds = new Set<Id>();
        for(SetupEntityAccess sea : seaList){
            vfPageIds.add(sea.SetupEntityId);
        }
        List<ApexPage> vfPageList = [Select Id, Name from ApexPage Where Id In : vfPageIds];
        System.debug('vf pages----> '+vfPageList);
        return vfPageList;
    }
    
    //Method to fetch AssignedApp from permissionSet --> 02/02/2024
    @AuraEnabled(cacheable=true)
    public static List<AppMenuItem> fetchAssignedApps(String psId){
        List<SetupEntityAccess> seaList=[SELECT Id, SetupEntityId, ParentId FROM SetupEntityAccess WHERE SetupEntityType != 'ConnectedApplication' AND parentId=:psId];
        Set<id> AssignedAppIds=new Set<id>();
        for(SetupEntityAccess sea: seaList){
            AssignedAppIds.add(sea.SetupEntityId);
            
        }
        List<AppMenuItem> amiList=[SELECT Id, ApplicationId, Name, Label, NamespacePrefix, IsAccessible, IsVisible FROM AppMenuItem
                                   WHERE ApplicationId In : AssignedAppIds];
        system.debug('Assigned App '+amiList);
        return amiList;
        
    }
    
    //Method to fetch Apex Classes access for user -----> 02/02/2024
    @AuraEnabled(cacheable=true)
    public static List<ApexClass> fetchApexClassForUsers(String username){
        User u = [Select Id, Name from User Where Name =: username];
        List<PermissionSetAssignment> psaList = [SELECT id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom from PermissionSetAssignment
                                                 where AssigneeId=:u.id AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true];
        Set<Id> psIds = new Set<Id>();
        for(PermissionSetAssignment psa : psaList){
            psIds.add(psa.PermissionSetId);
        }
        System.debug('psIds ---> '+psIds);
        List<SetupEntityAccess> seaList = [SELECT Id, SetupEntityId, SetupEntityType, ParentId FROM SetupEntityAccess Where SetupEntityType = 'ApexClass' AND ParentId In : psIds];
        List<id> apexClassIds = new List<Id>();
        for(SetupEntityAccess sea : seaList){
            apexClassIds.add(sea.SetupEntityId);
        }
        System.debug('seaList----> '+seaList.size());
        List<ApexClass> apexClasses= [Select Id, Name from ApexClass Where Id In : apexClassIds];
        for(ApexClass a : apexClasses){
            System.debug(a);
        }
        //System.debug('user apex classes ---> '+apexClasses.size());
        return apexClasses;
    }
    
    //Method to Fetch Assigned Apps Setting from User --> 05/02/2024
    @AuraEnabled(cacheable=true)
    public static List<AppMenuItem> fetchAssignedAppsForUsers(String username){
        user uRec=[SELECT id,Name FROM User WHERE name =:userName];
        List<PermissionSetAssignment> psaList = [SELECT id,PermissionSetGroupId, PermissionSetId,PermissionSetGroup.MasterLabel, PermissionSet.IsCustom from PermissionSetAssignment
                                                 where AssigneeId=:uRec.id AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true];
        Set<Id> psIds = new Set<Id>();
        for(PermissionSetAssignment psa : psaList){
            psIds.add(psa.PermissionSetId);
        }
        List<SetupEntityAccess> seaList = [SELECT Id, SetupEntityId, SetupEntityType, ParentId FROM SetupEntityAccess Where SetupEntityType != 'ConnectedApplication' AND ParentId In : psIds];
        List<id> appIds = new List<Id>();
        for(SetupEntityAccess sea : seaList){
            appIds.add(sea.SetupEntityId);
        }
        List<AppMenuItem> amiList=[SELECT Id, ApplicationId, Name, Label, NamespacePrefix, IsAccessible, IsVisible FROM AppMenuItem
                                   WHERE ApplicationId In : appIds];
        return amiList;
    }
    
    //Method to fetch Connected Apps for User --> 05/02/2024
    @AuraEnabled(cacheable=true)
    public static List<ConnectedApplication> fetchAssignedConnectedAppsForUsers(String username){
        user uRec=[SELECT id,Name FROM User WHERE name =:userName];
        List<PermissionSetAssignment> psaList = [SELECT id,PermissionSetGroupId, PermissionSetId,PermissionSetGroup.MasterLabel, PermissionSet.IsCustom from PermissionSetAssignment
                                                 where AssigneeId=:uRec.id AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true];
        Set<Id> psIds = new Set<Id>();
        for(PermissionSetAssignment psa : psaList){
            psIds.add(psa.PermissionSetId);
        }
        List<SetupEntityAccess> seaList = [SELECT Id, SetupEntityId, SetupEntityType, ParentId FROM SetupEntityAccess Where SetupEntityType = 'ConnectedApplication' AND ParentId In : psIds];
        List<id> conAppIds = new List<Id>();
        for(SetupEntityAccess sea : seaList){
            conAppIds.add(sea.SetupEntityId);
        }
        List<ConnectedApplication> conAppList = [Select Id, Name from ConnectedApplication Where Id In : conAppIds];
        return conAppList;
    }
    
    //Method to fetch Vf pages access for User --> 05/02/2024
    @AuraEnabled(cacheable=true)
    public static List<ApexPage> fetchVfPageAccessForUsers(String username){
        User u = [Select Id, Name from User Where Name =: username];
        List<PermissionSetAssignment> psaList = [SELECT id,PermissionSetGroupId, PermissionSetId,PermissionSetGroup.MasterLabel, PermissionSet.IsCustom from PermissionSetAssignment
                                                 where AssigneeId=:u.id AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true];
        Set<Id> psIds = new Set<Id>();
        for(PermissionSetAssignment psa : psaList){
            psIds.add(psa.PermissionSetId);
        }
        List<SetupEntityAccess> seaList = [Select Id, ParentId, SetupEntityId, SetupEntityType from SetupEntityAccess Where SetupEntityType = 'ApexPage' AND ParentId In : psIds];
        Set<Id> vfPageIds = new Set<Id>();
        for(SetupEntityAccess sea : seaList){
            vfPageIds.add(sea.SetupEntityId);
        }
        List<ApexPage> vfPageList = [Select Id, Name from ApexPage Where Id In : vfPageIds];
        System.debug('vf pages----> '+vfPageList);
        return vfPageList;
    }
    
    //Method to fetch Object Setting for User --> 06/02/2024
    @AuraEnabled(cacheable=true)
    public static List<ObjectPermissionsWrapper2> fetchObjectPermissionsForUsers(String username){
        User u = [SELECT id, Name FROM User WHERE Name = :username];
        
        // Fetch all permission set assignments for the user
        List<PermissionSetAssignment> psaList = [
            SELECT id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom
            FROM PermissionSetAssignment
            WHERE AssigneeId = :u.id AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true
        ];
        // Create a set of Permission Set IDs
        
        Set<Id> psIds = new Set<Id>();
        for (PermissionSetAssignment psa : psaList){
            psIds.add(psa.PermissionSetId);
        } 
        // Populate allObjMap with SObjectType as key and empty ObjectPermissionsWrapper as value
        List<AggregateResult> objectNames = [SELECT SObjectType FROM ObjectPermissions GROUP BY SObjectType ORDER BY SObjectType ASC];
        Map<String, ObjectPermissionsWrapper2> allObjMap = new Map<String, ObjectPermissionsWrapper2>();
        for (AggregateResult agr : objectNames) {
            allObjMap.put((String) agr.get('SObjectType'), new ObjectPermissionsWrapper2(
                (String) agr.get('SObjectType'),
                false, false, false, false, false, false
            ));
        }
        
        // Create a map to combine permissions for each object
        Map<String, ObjectPermissionsWrapper2> combinedPermissionsMap = new Map<String, ObjectPermissionsWrapper2>();
        
        // Fetch ObjectPermissions for the user's permission sets
        List<ObjectPermissions> opList = [
            SELECT SObjectType, PermissionsModifyAllRecords, PermissionsViewAllRecords, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete 
            FROM ObjectPermissions 
            WHERE ParentId IN :psIds
        ];
        
        //--------------------------------------------------------------------
        // Populate allObjMap with fetched ObjectPermissions
        for (ObjectPermissions op : opList) {
            if (allObjMap.containsKey(op.SObjectType)) {
                ObjectPermissionsWrapper2 current = allObjMap.get(op.SObjectType);
                current.PermissionsModifyAllRecords = current.PermissionsModifyAllRecords || op.PermissionsModifyAllRecords;
                current.PermissionsViewAllRecords = current.PermissionsViewAllRecords || op.PermissionsViewAllRecords;
                current.PermissionsRead = current.PermissionsRead || op.PermissionsRead;
                current.PermissionsCreate = current.PermissionsCreate || op.PermissionsCreate;
                current.PermissionsEdit = current.PermissionsEdit || op.PermissionsEdit;
                current.PermissionsDelete = current.PermissionsDelete || op.PermissionsDelete;
                allObjMap.put(op.SObjectType, current);
            }
        }
        
        
        
        // Create a list to hold the wrapper class instances
        List<ObjectPermissionsWrapper2> objPermissionsList = new List<ObjectPermissionsWrapper2>();
        
        // Iterate through the map and populate the list
        for (ObjectPermissionsWrapper2 objPerm : allObjMap.values()) {
            objPermissionsList.add(objPerm);
        }
        
        System.debug(objPermissionsList);
        return objPermissionsList;
    }
    
    
    // Wrapper class to hold the combined permissions
    public class ObjectPermissionsWrapper2 {
        @AuraEnabled public String sObjectType;
        @AuraEnabled public Boolean permissionsModifyAllRecords;
        @AuraEnabled public Boolean permissionsViewAllRecords;
        @AuraEnabled public Boolean permissionsRead;
        @AuraEnabled public Boolean permissionsCreate;
        @AuraEnabled public Boolean permissionsEdit;
        @AuraEnabled public Boolean permissionsDelete;
        
        public ObjectPermissionsWrapper2(String SObjectType, Boolean PermissionsModifyAllRecords, Boolean PermissionsViewAllRecords, Boolean PermissionsRead, Boolean PermissionsCreate, Boolean PermissionsEdit, Boolean PermissionsDelete) {
            this.sObjectType = sObjectType;
            this.permissionsModifyAllRecords = permissionsModifyAllRecords;
            this.permissionsViewAllRecords = permissionsViewAllRecords;
            this.permissionsRead = permissionsRead;
            this.permissionsCreate = permissionsCreate;
            this.permissionsEdit = permissionsEdit;
            this.permissionsDelete = permissionsDelete;
        }
    }
    
    
    //Method to fetch SystemPermissions for PermissionSet --> 06/02/2024
    @AuraEnabled(cacheable=true)
    public static map<string,string> fetchSystemPermissionsForPermissionSet(String psId){
        system.debug('psId-->'+psId);
        PermissionSet p = [Select Id, Name, Label, LicenseId, ProfileId, IsOwnedByProfile, IsCustom, PermissionsEmailSingle, PermissionsEmailMass, PermissionsEditTask, PermissionsEditEvent, PermissionsExportReport, PermissionsImportPersonal, PermissionsDataExport, PermissionsManageUsers, PermissionsEditPublicFilters, PermissionsEditPublicTemplates, PermissionsModifyAllData, PermissionsEditBillingInfo, PermissionsManageCases, PermissionsMassInlineEdit, PermissionsEditKnowledge, PermissionsManageKnowledge, PermissionsManageSolutions, PermissionsCustomizeApplication, PermissionsEditReadonlyFields, PermissionsRunReports, PermissionsViewSetup, PermissionsTransferAnyEntity, PermissionsNewReportBuilder, PermissionsActivateContract, PermissionsActivateOrder, PermissionsImportLeads, PermissionsManageLeads, PermissionsTransferAnyLead, PermissionsViewAllData, PermissionsEditPublicDocuments, PermissionsViewEncryptedData, PermissionsEditBrandTemplates, PermissionsEditHtmlTemplates, PermissionsChatterInternalUser, PermissionsManageEncryptionKeys, PermissionsDeleteActivatedContract, PermissionsChatterInviteExternalUsers, PermissionsSendSitRequests, PermissionsApiUserOnly, PermissionsManageRemoteAccess, PermissionsCanUseNewDashboardBuilder, PermissionsManageCategories, PermissionsConvertLeads, PermissionsPasswordNeverExpires, PermissionsUseTeamReassignWizards, PermissionsEditActivatedOrders, PermissionsInstallPackaging, PermissionsPublishPackaging, PermissionsChatterOwnGroups, PermissionsEditOppLineItemUnitPrice, PermissionsCreatePackaging, PermissionsBulkApiHardDelete, PermissionsSolutionImport, PermissionsManageCallCenters, PermissionsManageSynonyms, PermissionsViewContent, PermissionsManageEmailClientConfig, PermissionsEnableNotifications, PermissionsManageDataIntegrations, PermissionsDistributeFromPersWksp, PermissionsViewDataCategories, PermissionsManageDataCategories, PermissionsAuthorApex, PermissionsManageMobile, PermissionsApiEnabled, PermissionsManageCustomReportTypes, PermissionsEditCaseComments, PermissionsTransferAnyCase, PermissionsContentAdministrator, PermissionsCreateWorkspaces, PermissionsManageContentPermissions, PermissionsManageContentProperties, PermissionsManageContentTypes, PermissionsManageExchangeConfig, PermissionsManageAnalyticSnapshots, PermissionsScheduleReports, PermissionsManageBusinessHourHolidays, PermissionsManageEntitlements, PermissionsManageDynamicDashboards, PermissionsCustomSidebarOnAllPages, PermissionsManageInteraction, PermissionsViewMyTeamsDashboards, PermissionsModerateChatter, PermissionsResetPasswords, PermissionsFlowUFLRequired, PermissionsCanInsertFeedSystemFields, PermissionsActivitiesAccess, PermissionsManageKnowledgeImportExport, PermissionsEmailTemplateManagement, PermissionsEmailAdministration, PermissionsManageChatterMessages, PermissionsAllowEmailIC, PermissionsChatterFileLink, PermissionsForceTwoFactor, PermissionsViewEventLogFiles, PermissionsManageNetworks, PermissionsManageAuthProviders, PermissionsRunFlow, PermissionsCreateCustomizeDashboards, PermissionsCreateDashboardFolders, PermissionsViewPublicDashboards, PermissionsManageDashbdsInPubFolders, PermissionsCreateCustomizeReports, PermissionsCreateReportFolders, PermissionsViewPublicReports, PermissionsManageReportsInPubFolders, PermissionsEditMyDashboards, PermissionsEditMyReports, PermissionsViewAllUsers, PermissionsAllowUniversalSearch, PermissionsConnectOrgToEnvironmentHub, PermissionsWorkCalibrationUser, PermissionsCreateCustomizeFilters, PermissionsWorkDotComUserPerm, PermissionsContentHubUser, PermissionsGovernNetworks, PermissionsSalesConsole, PermissionsTwoFactorApi, PermissionsDeleteTopics, PermissionsEditTopics, PermissionsCreateTopics, PermissionsAssignTopics, PermissionsIdentityEnabled, PermissionsIdentityConnect, PermissionsAllowViewKnowledge, PermissionsContentWorkspaces, PermissionsManageSearchPromotionRules, PermissionsCustomMobileAppsAccess, PermissionsViewHelpLink, PermissionsManageProfilesPermissionsets, PermissionsAssignPermissionSets, PermissionsManageRoles, PermissionsManageIpAddresses, PermissionsManageSharing, PermissionsManageInternalUsers, PermissionsManagePasswordPolicies, PermissionsManageLoginAccessPolicies, PermissionsViewPlatformEvents, PermissionsManageCustomPermissions, PermissionsCanVerifyComment, PermissionsManageUnlistedGroups, PermissionsStdAutomaticActivityCapture, PermissionsInsightsAppDashboardEditor, PermissionsManageTwoFactor, PermissionsInsightsAppUser, PermissionsInsightsAppAdmin, PermissionsInsightsAppEltEditor, PermissionsInsightsAppUploadUser, PermissionsInsightsCreateApplication, PermissionsLightningExperienceUser, PermissionsViewDataLeakageEvents, PermissionsConfigCustomRecs, PermissionsSubmitMacrosAllowed, PermissionsBulkMacrosAllowed, PermissionsShareInternalArticles, PermissionsManageSessionPermissionSets, PermissionsManageTemplatedApp, PermissionsUseTemplatedApp, PermissionsSendAnnouncementEmails, PermissionsChatterEditOwnPost, PermissionsChatterEditOwnRecordPost, PermissionsWaveTabularDownload, PermissionsWaveCommunityUser, PermissionsAutomaticActivityCapture, PermissionsImportCustomObjects, PermissionsSalesforceIQInbox, PermissionsDelegatedTwoFactor, PermissionsChatterComposeUiCodesnippet, PermissionsSelectFilesFromSalesforce, PermissionsModerateNetworkUsers, PermissionsMergeTopics, PermissionsSubscribeToLightningReports, PermissionsManagePvtRptsAndDashbds, PermissionsAllowLightningLogin, PermissionsCampaignInfluence2, PermissionsViewDataAssessment, PermissionsRemoveDirectMessageMembers, PermissionsCanApproveFeedPost, PermissionsAddDirectMessageMembers, PermissionsAllowViewEditConvertedLeads, PermissionsShowCompanyNameAsUserBadge, PermissionsAccessCMC, PermissionsViewHealthCheck, PermissionsManageHealthCheck, PermissionsPackaging2, PermissionsManageCertificates, PermissionsCreateReportInLightning, PermissionsPreventClassicExperience, PermissionsHideReadByList, PermissionsListEmailSend, PermissionsFeedPinning, PermissionsChangeDashboardColors, PermissionsManageRecommendationStrategies, PermissionsManagePropositions, PermissionsCloseConversations, PermissionsSubscribeReportRolesGrps, PermissionsSubscribeDashboardRolesGrps, PermissionsUseWebLink, PermissionsHasUnlimitedNBAExecutions, PermissionsViewOnlyEmbeddedAppUser, PermissionsViewAllActivities, PermissionsSubscribeReportToOtherUsers, PermissionsLightningConsoleAllowedForUser, PermissionsSubscribeReportsRunAsUser, PermissionsSubscribeToLightningDashboards, PermissionsSubscribeDashboardToOtherUsers, PermissionsCreateLtngTempInPub, PermissionsAppointmentBookingUserAccess, PermissionsTransactionalEmailSend, PermissionsViewPrivateStaticResources, PermissionsCreateLtngTempFolder, PermissionsApexRestServices, PermissionsConfigureLiveMessage, PermissionsLiveMessageAgent, PermissionsEnableCommunityAppLauncher, PermissionsGiveRecognitionBadge, PermissionsLightningSchedulerUserAccess, PermissionsSalesforceIQInternal, PermissionsUseMySearch, PermissionsLtngPromoReserved01UserPerm, PermissionsManageSubscriptions, PermissionsWaveManagePrivateAssetsUser, PermissionsCanEditDataPrepRecipe, PermissionsAddAnalyticsRemoteConnections, PermissionsManageSurveys, PermissionsUseAssistantDialog, PermissionsUseQuerySuggestions, PermissionsRecordVisibilityAPI, PermissionsViewRoles, PermissionsCanManageMaps, PermissionsLMOutboundMessagingUserPerm, PermissionsModifyDataClassification, PermissionsPrivacyDataAccess, PermissionsQueryAllFiles, PermissionsModifyMetadata, PermissionsManageCMS, PermissionsSandboxTestingInCommunityApp, PermissionsCanEditPrompts, PermissionsViewUserPII, PermissionsManageHubConnections, PermissionsB2BMarketingAnalyticsUser, PermissionsTraceXdsQueries, PermissionsViewSecurityCommandCenter, PermissionsManageSecurityCommandCenter, PermissionsViewAllCustomSettings, PermissionsViewAllForeignKeyNames, PermissionsAddWaveNotificationRecipients, PermissionsHeadlessCMSAccess, PermissionsLMEndMessagingSessionUserPerm, PermissionsConsentApiUpdate, PermissionsPaymentsAPIUser, PermissionsAccessContentBuilder, PermissionsAccountSwitcherUser, PermissionsViewAnomalyEvents, PermissionsManageC360AConnections, PermissionsIsContactCenterAdmin, PermissionsIsContactCenterAgent, PermissionsManageReleaseUpdates, PermissionsViewAllProfiles, PermissionsSkipIdentityConfirmation, PermissionsCanToggleCallRecordings, PermissionsLearningManager, PermissionsSendCustomNotifications, PermissionsPackaging2Delete, PermissionsUseOmnichannelInventoryAPIs, PermissionsViewRestrictionAndScopingRules, PermissionsFSCComprehensiveUserAccess, PermissionsBotManageBots, PermissionsBotManageBotsTrainingData, PermissionsSchedulingLineAmbassador, PermissionsSchedulingFacilityManager, PermissionsOmnichannelInventorySync, PermissionsManageLearningReporting, PermissionsIsContactCenterSupervisor, PermissionsIsotopeCToCUser, PermissionsCanAccessCE, PermissionsUseAddOrderItemSummaryAPIs, PermissionsIsotopeAccess, PermissionsIsotopeLEX, PermissionsQuipMetricsAccess, PermissionsQuipUserEngagementMetrics, PermissionsRemoteMediaVirtualDesktop, PermissionsTransactionSecurityExempt, PermissionsManageStores, PermissionsManageExternalConnections, PermissionsUseReturnOrder, PermissionsUseReturnOrderAPIs, PermissionsUseSubscriptionEmails, PermissionsUseOrderEntry, PermissionsUseRepricing, PermissionsAIViewInsightObjects, PermissionsAICreateInsightObjects, PermissionsViewMLModels, PermissionsLifecycleManagementAPIUser, PermissionsNativeWebviewScrolling, PermissionsViewDeveloperName, PermissionsBypassMFAForUiLogins, PermissionsClientSecretRotation, PermissionsAccessToServiceProcess, PermissionsManageOrchInstsAndWorkItems, PermissionsCMSECEAuthoringAccess, PermissionsCdcReportingCreateReports, PermissionsCdcReportingViewReports, PermissionsCdcReportingManageFolders, PermissionsOmnichannelInventoryBasic, PermissionsDeleteCrMemoAndInvoice, PermissionsEmbeddedMessagingAgent, PermissionsManageNamedCredentials, PermissionsCanInitiateMessagingSessions, PermissionsEditRepricing, PermissionsCanUpdateEmailMessage, PermissionsDownloadPackageVersionZips, PermissionsDigitalLendingUser, PermissionsLoanOfficerUser, PermissionsUnderwriterUser, PermissionsEnableIPFSUpload, PermissionsEnableBCTransactionPolling, PermissionsAccessToComplaintMgmt, PermissionsAccessToDisputeManagement, PermissionsCustomAppsOnFSMobile, PermissionsSegmentIntelligenceUser, PermissionsFSCArcGraphCommunityUser, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, NamespacePrefix, HasActivationRequired, PermissionSetGroupId, Type
                           from PermissionSet Where Id =: psId];
        
        
        Map<String, String> psFieldsMap = new Map<String, String>();
        Map<String, Object> fieldstovalue = p.getPopulatedFieldsAsMap();
        
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('PermissionSet').getDescribe().fields.getMap();
        
        for(String fieldApiName : fieldstovalue.keySet()){
            if(fieldApiName.contains('Permission')){
                object fieldValue=fieldstovalue.get(fieldApiName);
                schema.DescribeFieldResult fieldDescribe=fieldsMap.get(fieldApiName).getDescribe();
                String fieldLabel=fieldDescribe.getLabel();
                
                psFieldsMap.put(fieldLabel,String.valueOf(fieldValue));
            }
            
            
        }
        
        /*//to print map values
for(String fieldLabel : psFieldsMap.keyset()){
system.debug('field label is '+fieldLabel+' and field value is '+psFieldsMap.get(fieldLabel));
}*/
        system.debug('psFieldsMap-->'+psFieldsMap);
        return psFieldsMap;
    }
    
    //Method to fetch SystemPermissions for PermissionSet --> 07/02/2024
    @AuraEnabled(cacheable=true)
    public static Map<String, String> fetchSystemPermissionsForusers(String username) {
        User u = [SELECT Id, Name FROM User WHERE Name = :userName];
        
        List<PermissionSetAssignment> psaList = [
            SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom
            FROM PermissionSetAssignment
            WHERE AssigneeId = :u.Id AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true
        ];
        
        Set<Id> psIds = new Set<Id>();
        for (PermissionSetAssignment psa : psaList) {
            psIds.add(psa.PermissionSetId);   
        }
        
        Map<String, String> psFieldsMap = new Map<String, String>();
        
        for (PermissionSet p : [Select Id, Name, Label, LicenseId, ProfileId, IsOwnedByProfile, IsCustom, PermissionsEmailSingle, PermissionsEmailMass, PermissionsEditTask, PermissionsEditEvent, PermissionsExportReport, PermissionsImportPersonal, PermissionsDataExport, PermissionsManageUsers, PermissionsEditPublicFilters, PermissionsEditPublicTemplates, PermissionsModifyAllData, PermissionsEditBillingInfo, PermissionsManageCases, PermissionsMassInlineEdit, PermissionsEditKnowledge, PermissionsManageKnowledge, PermissionsManageSolutions, PermissionsCustomizeApplication, PermissionsEditReadonlyFields, PermissionsRunReports, PermissionsViewSetup, PermissionsTransferAnyEntity, PermissionsNewReportBuilder, PermissionsActivateContract, PermissionsActivateOrder, PermissionsImportLeads, PermissionsManageLeads, PermissionsTransferAnyLead, PermissionsViewAllData, PermissionsEditPublicDocuments, PermissionsViewEncryptedData, PermissionsEditBrandTemplates, PermissionsEditHtmlTemplates, PermissionsChatterInternalUser, PermissionsManageEncryptionKeys, PermissionsDeleteActivatedContract, PermissionsChatterInviteExternalUsers, PermissionsSendSitRequests, PermissionsApiUserOnly, PermissionsManageRemoteAccess, PermissionsCanUseNewDashboardBuilder, PermissionsManageCategories, PermissionsConvertLeads, PermissionsPasswordNeverExpires, PermissionsUseTeamReassignWizards, PermissionsEditActivatedOrders, PermissionsInstallPackaging, PermissionsPublishPackaging, PermissionsChatterOwnGroups, PermissionsEditOppLineItemUnitPrice, PermissionsCreatePackaging, PermissionsBulkApiHardDelete, PermissionsSolutionImport, PermissionsManageCallCenters, PermissionsManageSynonyms, PermissionsViewContent, PermissionsManageEmailClientConfig, PermissionsEnableNotifications, PermissionsManageDataIntegrations, PermissionsDistributeFromPersWksp, PermissionsViewDataCategories, PermissionsManageDataCategories, PermissionsAuthorApex, PermissionsManageMobile, PermissionsApiEnabled, PermissionsManageCustomReportTypes, PermissionsEditCaseComments, PermissionsTransferAnyCase, PermissionsContentAdministrator, PermissionsCreateWorkspaces, PermissionsManageContentPermissions, PermissionsManageContentProperties, PermissionsManageContentTypes, PermissionsManageExchangeConfig, PermissionsManageAnalyticSnapshots, PermissionsScheduleReports, PermissionsManageBusinessHourHolidays, PermissionsManageEntitlements, PermissionsManageDynamicDashboards, PermissionsCustomSidebarOnAllPages, PermissionsManageInteraction, PermissionsViewMyTeamsDashboards, PermissionsModerateChatter, PermissionsResetPasswords, PermissionsFlowUFLRequired, PermissionsCanInsertFeedSystemFields, PermissionsActivitiesAccess, PermissionsManageKnowledgeImportExport, PermissionsEmailTemplateManagement, PermissionsEmailAdministration, PermissionsManageChatterMessages, PermissionsAllowEmailIC, PermissionsChatterFileLink, PermissionsForceTwoFactor, PermissionsViewEventLogFiles, PermissionsManageNetworks, PermissionsManageAuthProviders, PermissionsRunFlow, PermissionsCreateCustomizeDashboards, PermissionsCreateDashboardFolders, PermissionsViewPublicDashboards, PermissionsManageDashbdsInPubFolders, PermissionsCreateCustomizeReports, PermissionsCreateReportFolders, PermissionsViewPublicReports, PermissionsManageReportsInPubFolders, PermissionsEditMyDashboards, PermissionsEditMyReports, PermissionsViewAllUsers, PermissionsAllowUniversalSearch, PermissionsConnectOrgToEnvironmentHub, PermissionsWorkCalibrationUser, PermissionsCreateCustomizeFilters, PermissionsWorkDotComUserPerm, PermissionsContentHubUser, PermissionsGovernNetworks, PermissionsSalesConsole, PermissionsTwoFactorApi, PermissionsDeleteTopics, PermissionsEditTopics, PermissionsCreateTopics, PermissionsAssignTopics, PermissionsIdentityEnabled, PermissionsIdentityConnect, PermissionsAllowViewKnowledge, PermissionsContentWorkspaces, PermissionsManageSearchPromotionRules, PermissionsCustomMobileAppsAccess, PermissionsViewHelpLink, PermissionsManageProfilesPermissionsets, PermissionsAssignPermissionSets, PermissionsManageRoles, PermissionsManageIpAddresses, PermissionsManageSharing, PermissionsManageInternalUsers, PermissionsManagePasswordPolicies, PermissionsManageLoginAccessPolicies, PermissionsViewPlatformEvents, PermissionsManageCustomPermissions, PermissionsCanVerifyComment, PermissionsManageUnlistedGroups, PermissionsStdAutomaticActivityCapture, PermissionsInsightsAppDashboardEditor, PermissionsManageTwoFactor, PermissionsInsightsAppUser, PermissionsInsightsAppAdmin, PermissionsInsightsAppEltEditor, PermissionsInsightsAppUploadUser, PermissionsInsightsCreateApplication, PermissionsLightningExperienceUser, PermissionsViewDataLeakageEvents, PermissionsConfigCustomRecs, PermissionsSubmitMacrosAllowed, PermissionsBulkMacrosAllowed, PermissionsShareInternalArticles, PermissionsManageSessionPermissionSets, PermissionsManageTemplatedApp, PermissionsUseTemplatedApp, PermissionsSendAnnouncementEmails, PermissionsChatterEditOwnPost, PermissionsChatterEditOwnRecordPost, PermissionsWaveTabularDownload, PermissionsWaveCommunityUser, PermissionsAutomaticActivityCapture, PermissionsImportCustomObjects, PermissionsSalesforceIQInbox, PermissionsDelegatedTwoFactor, PermissionsChatterComposeUiCodesnippet, PermissionsSelectFilesFromSalesforce, PermissionsModerateNetworkUsers, PermissionsMergeTopics, PermissionsSubscribeToLightningReports, PermissionsManagePvtRptsAndDashbds, PermissionsAllowLightningLogin, PermissionsCampaignInfluence2, PermissionsViewDataAssessment, PermissionsRemoveDirectMessageMembers, PermissionsCanApproveFeedPost, PermissionsAddDirectMessageMembers, PermissionsAllowViewEditConvertedLeads, PermissionsShowCompanyNameAsUserBadge, PermissionsAccessCMC, PermissionsViewHealthCheck, PermissionsManageHealthCheck, PermissionsPackaging2, PermissionsManageCertificates, PermissionsCreateReportInLightning, PermissionsPreventClassicExperience, PermissionsHideReadByList, PermissionsListEmailSend, PermissionsFeedPinning, PermissionsChangeDashboardColors, PermissionsManageRecommendationStrategies, PermissionsManagePropositions, PermissionsCloseConversations, PermissionsSubscribeReportRolesGrps, PermissionsSubscribeDashboardRolesGrps, PermissionsUseWebLink, PermissionsHasUnlimitedNBAExecutions, PermissionsViewOnlyEmbeddedAppUser, PermissionsViewAllActivities, PermissionsSubscribeReportToOtherUsers, PermissionsLightningConsoleAllowedForUser, PermissionsSubscribeReportsRunAsUser, PermissionsSubscribeToLightningDashboards, PermissionsSubscribeDashboardToOtherUsers, PermissionsCreateLtngTempInPub, PermissionsAppointmentBookingUserAccess, PermissionsTransactionalEmailSend, PermissionsViewPrivateStaticResources, PermissionsCreateLtngTempFolder, PermissionsApexRestServices, PermissionsConfigureLiveMessage, PermissionsLiveMessageAgent, PermissionsEnableCommunityAppLauncher, PermissionsGiveRecognitionBadge, PermissionsLightningSchedulerUserAccess, PermissionsSalesforceIQInternal, PermissionsUseMySearch, PermissionsLtngPromoReserved01UserPerm, PermissionsManageSubscriptions, PermissionsWaveManagePrivateAssetsUser, PermissionsCanEditDataPrepRecipe, PermissionsAddAnalyticsRemoteConnections, PermissionsManageSurveys, PermissionsUseAssistantDialog, PermissionsUseQuerySuggestions, PermissionsRecordVisibilityAPI, PermissionsViewRoles, PermissionsCanManageMaps, PermissionsLMOutboundMessagingUserPerm, PermissionsModifyDataClassification, PermissionsPrivacyDataAccess, PermissionsQueryAllFiles, PermissionsModifyMetadata, PermissionsManageCMS, PermissionsSandboxTestingInCommunityApp, PermissionsCanEditPrompts, PermissionsViewUserPII, PermissionsManageHubConnections, PermissionsB2BMarketingAnalyticsUser, PermissionsTraceXdsQueries, PermissionsViewSecurityCommandCenter, PermissionsManageSecurityCommandCenter, PermissionsViewAllCustomSettings, PermissionsViewAllForeignKeyNames, PermissionsAddWaveNotificationRecipients, PermissionsHeadlessCMSAccess, PermissionsLMEndMessagingSessionUserPerm, PermissionsConsentApiUpdate, PermissionsPaymentsAPIUser, PermissionsAccessContentBuilder, PermissionsAccountSwitcherUser, PermissionsViewAnomalyEvents, PermissionsManageC360AConnections, PermissionsIsContactCenterAdmin, PermissionsIsContactCenterAgent, PermissionsManageReleaseUpdates, PermissionsViewAllProfiles, PermissionsSkipIdentityConfirmation, PermissionsCanToggleCallRecordings, PermissionsLearningManager, PermissionsSendCustomNotifications, PermissionsPackaging2Delete, PermissionsUseOmnichannelInventoryAPIs, PermissionsViewRestrictionAndScopingRules, PermissionsFSCComprehensiveUserAccess, PermissionsBotManageBots, PermissionsBotManageBotsTrainingData, PermissionsSchedulingLineAmbassador, PermissionsSchedulingFacilityManager, PermissionsOmnichannelInventorySync, PermissionsManageLearningReporting, PermissionsIsContactCenterSupervisor, PermissionsIsotopeCToCUser, PermissionsCanAccessCE, PermissionsUseAddOrderItemSummaryAPIs, PermissionsIsotopeAccess, PermissionsIsotopeLEX, PermissionsQuipMetricsAccess, PermissionsQuipUserEngagementMetrics, PermissionsRemoteMediaVirtualDesktop, PermissionsTransactionSecurityExempt, PermissionsManageStores, PermissionsManageExternalConnections, PermissionsUseReturnOrder, PermissionsUseReturnOrderAPIs, PermissionsUseSubscriptionEmails, PermissionsUseOrderEntry, PermissionsUseRepricing, PermissionsAIViewInsightObjects, PermissionsAICreateInsightObjects, PermissionsViewMLModels, PermissionsLifecycleManagementAPIUser, PermissionsNativeWebviewScrolling, PermissionsViewDeveloperName, PermissionsBypassMFAForUiLogins, PermissionsClientSecretRotation, PermissionsAccessToServiceProcess, PermissionsManageOrchInstsAndWorkItems, PermissionsCMSECEAuthoringAccess, PermissionsCdcReportingCreateReports, PermissionsCdcReportingViewReports, PermissionsCdcReportingManageFolders, PermissionsOmnichannelInventoryBasic, PermissionsDeleteCrMemoAndInvoice, PermissionsEmbeddedMessagingAgent, PermissionsManageNamedCredentials, PermissionsCanInitiateMessagingSessions, PermissionsEditRepricing, PermissionsCanUpdateEmailMessage, PermissionsDownloadPackageVersionZips, PermissionsDigitalLendingUser, PermissionsLoanOfficerUser, PermissionsUnderwriterUser, PermissionsEnableIPFSUpload, PermissionsEnableBCTransactionPolling, PermissionsAccessToComplaintMgmt, PermissionsAccessToDisputeManagement, PermissionsCustomAppsOnFSMobile, PermissionsSegmentIntelligenceUser, PermissionsFSCArcGraphCommunityUser, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, NamespacePrefix, HasActivationRequired, PermissionSetGroupId, Type
                                from PermissionSet Where Id IN : psIds]) {
                                    mergeSystemPermissions(psFieldsMap, p);
                                }
        
        //System.debug('psFieldsMap-->' + psFieldsMap);
        return psFieldsMap;   
    }
    
    // Helper method to merge system permissions of a Permission Set into the map
    public static void mergeSystemPermissions(Map<String, String> psFieldsMap, PermissionSet p) {
        Map<String, Object> fieldToValue = p.getPopulatedFieldsAsMap();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('PermissionSet').getDescribe().fields.getMap();
        system.debug('fieldsMap-->'+fieldsMap);
        
        for (String fieldApiName : fieldToValue.keySet()) {
            if (fieldApiName.contains('Permissions')) { // Assuming system permission fields start with 'Permissions'
                Object fieldValue = fieldToValue.get(fieldApiName);
                Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldApiName).getDescribe();
                system.debug('fieldDescribe-->'+fieldDescribe);
                String fieldLabel = fieldDescribe.getLabel();
                
                // Combine the permission to the map
                if (psFieldsMap.containsKey(fieldLabel)) {
                    // If the permission already exists, check if it's true and don't change if it's already true
                    if (String.valueOf(fieldValue).equals('true')) {
                        psFieldsMap.put(fieldLabel, String.valueOf(fieldValue));
                    }
                } else {
                    // Otherwise, add the permission to the map
                    psFieldsMap.put(fieldLabel, String.valueOf(fieldValue));
                }
            }
        }
    }
}