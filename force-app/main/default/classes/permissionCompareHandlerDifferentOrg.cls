public class permissionCompareHandlerDifferentOrg {
    
    //Method to fetch the usersname from different org--> 09/02/2024
    @AuraEnabled(cacheable=true)
    public static List<String> fetchIntegratedUserNames(string credName) {
        HttpRequest req = new HttpRequest();
        String searchTerm = 'Standard';
        String encodedSearchTerm = EncodingUtil.urlEncode(searchTerm, 'UTF-8');
        String query = 'SELECT+Name+,+UserName+FROM+User+WHERE+UserType+=+\'' + searchTerm + '\'';
        req.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+query);
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('resBody---> '+res.getBody());
        List<String> userNames = new List<String>();
        if (res.getStatusCode() == 200) {
            // Deserialize JSON response
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('jsonResponse--> '+jsonResponse);
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for (Object record : records) {
                Map<String, Object> recordMap = (Map<String, Object>) record;
                //String firstName = (String) recordMap.get('FirstName');
                //String lastName = (String) recordMap.get('LastName');
                String fullName = (String) recordMap.get('Name');
                String username = (String) recordMap.get('Username');
                String s = fullName + ' - ' + username;
                userNames.add(s);
            }
        } else {
            System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
        System.debug('usernames--> '+userNames);
        return userNames; 
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PermissionSet> fetchIntegratedPermissionSetNames(string credName) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+EncodingUtil.urlEncode('SELECT Id, Label FROM PermissionSet WHERE (Type = \'Regular\' OR Type = \'Session\') AND IsCustom = true', 'UTF-8'));
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        System.debug('resBody---> '+res.getBody());
        List<PermissionSet> permissionSetNames = new List<PermissionSet>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            List<PermissionSet> psList = new List<PermissionSet>();
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                PermissionSet p = new PermissionSet();
                p.Label = (String) recordMap.get('Label');
                p.Id = (String) recordMap.get('Id');
                //String label = (String) recordMap.get('Label');
                permissionSetNames.add(p);
            }
        }
        System.debug('permissionSets--> '+permissionSetNames);
        return permissionSetNames;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> fetchIntegratedPermissionSetGroupNames(string credName) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+EncodingUtil.urlEncode('select MasterLabel from PermissionSetGroup', 'UTF-8'));
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('resBody---> '+res.getBody());
        List<String> permissionSetGroupNames = new List<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                System.debug('recordMap --- > '+recordMap);
                String label = (String) recordMap.get('MasterLabel');
                permissionSetGroupNames.add(label);
            }
        }
        System.debug('permissionSetGroupNames----> '+permissionSetGroupNames);
        return permissionSetGroupNames;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ApexClass> fetchIntegratedApexClassAccess(String credName, String psId){
        HttpRequest req = new HttpRequest();
        String PsIdd=EncodingUtil.urlEncode(String.escapeSingleQuotes(psId),'UTF-8');
        String seacrhTerm = EncodingUtil.urlEncode('ApexClass', 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q=Select+SetupEntityId+FROM+SetupEntityAccess+Where+ParentId=\''+PsIdd+'\'+AND+SetupEntityType=\''+seacrhTerm+'\'');
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> apexClassIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String setupEntityId = (String) recordMap.get('SetupEntityId');
                apexClassIds.add((String)setupEntityId);
            }
        }
        List<String> idList = new List<String>(apexClassIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'SELECT Id, Name FROM ApexClass WHERE Id IN (' + idString + ')';
        String encodedQuery = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req1 = new HttpRequest();
        req1.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery);
        System.debug(req.getEndpoint());
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        List<ApexClass> apexClasses = new List<ApexClass>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                ApexClass a = new ApexClass();
                a.Name = (String) recordMap.get('Name');
                a.Id = (Id)recordMap.get('Id');
                apexClasses.add(a);
            }
        }
        System.debug('apexClasses--> '+apexClasses);
        return apexClasses;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<permissionCompareHandlerClass.ObjectPermissionsWrapper2> fetchIntegratedObjectSetting(String credName, String psId){
        HttpRequest requ = new HttpRequest();
        String qry = 'SELECT SObjectType FROM ObjectPermissions GROUP BY SObjectType ORDER BY SObjectType ASC';    
        String encodedQry = EncodingUtil.urlEncode(qry, 'UTF-8');
        requ.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQry);
        System.debug(requ.getEndpoint());
        requ.setMethod('GET');
        Http ht = new Http();
        HttpResponse response = ht.send(requ);
        Map<String, permissionCompareHandlerClass.ObjectPermissionsWrapper2> allObjMap = new Map<String, permissionCompareHandlerClass.ObjectPermissionsWrapper2>();
        if(response.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                allObjMap.put((String) recordMap.get('SobjectType'), new permissionCompareHandlerClass.ObjectPermissionsWrapper2(
                    (String) recordMap.get('SobjectType'),
                    false, false, false, false, false, false
                ));
            }
        }
        
        HttpRequest req = new HttpRequest();
        String PsIdd=EncodingUtil.urlEncode(String.escapeSingleQuotes(psId),'UTF-8'); 
        String quer='SELECT Id, SObjectType,Parent.label, PermissionsModifyAllRecords, PermissionsViewAllRecords, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete,ParentId FROM ObjectPermissions Where parent.id=\''+PsIdd+'\'';
        string query=EncodingUtil.urlEncode(quer,'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+query);
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                System.debug('recordMap---> '+recordMap);
                String key = (String)recordMap.get('SobjectType');
                if(allObjMap.containsKey(key)){
                    permissionCompareHandlerClass.ObjectPermissionsWrapper2 current = allObjMap.get(key);
                    current.PermissionsModifyAllRecords = current.PermissionsModifyAllRecords || (Boolean)recordMap.get('PermissionsModifyAllRecords');
                    current.PermissionsViewAllRecords = current.PermissionsViewAllRecords || (Boolean)recordMap.get('PermissionsViewAllRecords');
                    current.PermissionsRead = current.PermissionsRead || (Boolean)recordMap.get('PermissionsRead');
                    current.PermissionsCreate = current.PermissionsCreate || (Boolean)recordMap.get('PermissionsCreate');
                    current.PermissionsEdit = current.PermissionsEdit || (Boolean)recordMap.get('PermissionsEdit');
                    current.PermissionsDelete = current.PermissionsDelete || (Boolean)recordMap.get('PermissionsDelete');
                    allObjMap.put(key, current);
                }
            }
        }
        //system.debug('Response --->'+res.getBody());
        //List<objectPermissionsData> ObjectPerList=new List<objectPermissionsData>();
        List<permissionCompareHandlerClass.ObjectPermissionsWrapper2> objPermissionsList = new List<permissionCompareHandlerClass.ObjectPermissionsWrapper2>(allObjMap.values());
        for (permissionCompareHandlerClass.ObjectPermissionsWrapper2 objPerm : allObjMap.values()) {
            objPermissionsList.add(objPerm);
        }
        return objPermissionsList;
    }   
    
    @AuraEnabled(cacheable=true)
    public static List<String> fetchIntegratedAssignedAppsSettings(String credName, String psId){
        HttpRequest req = new HttpRequest();
        String PsIdd=EncodingUtil.urlEncode(String.escapeSingleQuotes(psId),'UTF-8');
        String searchTerm = EncodingUtil.urlEncode('ConnectedApplication', 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q=Select+SetupEntityId+FROM+SetupEntityAccess+Where+ParentId=\''+PsIdd+'\'+AND+SetupEntityType!=\''+searchTerm+'\'');
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> appIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String setupEntityId = (String) recordMap.get('SetupEntityId');
                appIds.add((String)setupEntityId);
            }
        }
        List<String> idList = new List<String>(appIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'SELECT Id, ApplicationId,Label FROM AppMenuItem WHERE ApplicationId In (' + idString + ')';
        String encodedQuery = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req1 = new HttpRequest();
        req1.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery);
        System.debug(req1.getEndpoint());
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        List<String> appNames = new List<String>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String Label = (String) recordMap.get('Label');
                appNames.add(Label);
            }
        }
        System.debug('appNames--> '+appNames);
        return appNames;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> fetchIntegratedConnectedAppSettings(String credName, String psId){
        HttpRequest req = new HttpRequest();
        String PsIdd=EncodingUtil.urlEncode(String.escapeSingleQuotes(psId),'UTF-8');
        String searchTerm = EncodingUtil.urlEncode('ConnectedApplication', 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q=Select+SetupEntityId+FROM+SetupEntityAccess+Where+ParentId=\''+PsIdd+'\'+AND+SetupEntityType=\''+searchTerm+'\'');
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> conAppIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String setupEntityId = (String) recordMap.get('SetupEntityId');
                conAppIds.add((String)setupEntityId);
            }
        }
        List<String> idList = new List<String>(conAppIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'Select Id, Name from ConnectedApplication Where Id In (' + idString + ')';
        String encodedQuery = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req1 = new HttpRequest();
        req1.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery);
        System.debug(req1.getEndpoint());
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        List<String> conApps = new List<String>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String Name = (String) recordMap.get('Name');
                conApps.add(Name);
            }
        }
        System.debug('conAppNames---> '+conApps);
        return conApps;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ApexPage> fetchIntegratedVfPageSettings(String credName, String psId){
        HttpRequest req = new HttpRequest();
        String PsIdd=EncodingUtil.urlEncode(String.escapeSingleQuotes(psId),'UTF-8');
        String searchTerm = EncodingUtil.urlEncode('ApexPage', 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q=Select+SetupEntityId+FROM+SetupEntityAccess+Where+ParentId=\''+PsIdd+'\'+AND+SetupEntityType=\''+searchTerm+'\'');
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> vfPageIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String setupEntityId = (String) recordMap.get('SetupEntityId');
                vfPageIds.add((String)setupEntityId);
            }
        }
        List<String> idList = new List<String>(vfPageIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'Select Id, Name from ApexPage Where Id In (' + idString + ')';
        String encodedQuery = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req1 = new HttpRequest();
        req1.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery);
        System.debug(req1.getEndpoint());
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        List<ApexPage> vfPages = new List<ApexPage>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record; 
                ApexPage a = new ApexPage();
                a.Name = (String) recordMap.get('Name');
                a.Id = (Id) recordMap.get('Id');
                vfPages.add(a);
            }
        }
        System.debug('vfPages---> '+vfPages);
        return vfPages;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> fetchIntegratedSystemPermissions(String credName, String psId){
        System.debug('credName---> '+credName);
        System.debug('psId---> '+psId);
        HttpRequest req = new HttpRequest();
        String psIdd = EncodingUtil.urlEncode(String.escapeSingleQuotes(psId), 'UTF-8');
        String query = 'Select Id, Name, Label, LicenseId, ProfileId, IsOwnedByProfile, IsCustom, PermissionsEmailSingle, PermissionsEmailMass, PermissionsEditTask, PermissionsEditEvent, PermissionsExportReport, PermissionsImportPersonal, PermissionsDataExport, PermissionsManageUsers, PermissionsEditPublicFilters, PermissionsEditPublicTemplates, PermissionsModifyAllData, PermissionsEditBillingInfo, PermissionsManageCases, PermissionsMassInlineEdit, PermissionsEditKnowledge, PermissionsManageKnowledge, PermissionsManageSolutions, PermissionsCustomizeApplication, PermissionsEditReadonlyFields, PermissionsRunReports, PermissionsViewSetup, PermissionsTransferAnyEntity, PermissionsNewReportBuilder, PermissionsActivateContract, PermissionsActivateOrder, PermissionsImportLeads, PermissionsManageLeads, PermissionsTransferAnyLead, PermissionsViewAllData, PermissionsEditPublicDocuments, PermissionsViewEncryptedData, PermissionsEditBrandTemplates, PermissionsEditHtmlTemplates, PermissionsChatterInternalUser, PermissionsManageEncryptionKeys, PermissionsDeleteActivatedContract, PermissionsChatterInviteExternalUsers, PermissionsSendSitRequests, PermissionsApiUserOnly, PermissionsManageRemoteAccess, PermissionsCanUseNewDashboardBuilder, PermissionsManageCategories, PermissionsConvertLeads, PermissionsPasswordNeverExpires, PermissionsUseTeamReassignWizards, PermissionsEditActivatedOrders, PermissionsInstallPackaging, PermissionsPublishPackaging, PermissionsChatterOwnGroups, PermissionsEditOppLineItemUnitPrice, PermissionsCreatePackaging, PermissionsBulkApiHardDelete, PermissionsSolutionImport, PermissionsManageCallCenters, PermissionsManageSynonyms, PermissionsViewContent, PermissionsManageEmailClientConfig, PermissionsEnableNotifications, PermissionsManageDataIntegrations, PermissionsDistributeFromPersWksp, PermissionsViewDataCategories, PermissionsManageDataCategories, PermissionsAuthorApex, PermissionsManageMobile, PermissionsApiEnabled, PermissionsManageCustomReportTypes, PermissionsEditCaseComments, PermissionsTransferAnyCase, PermissionsContentAdministrator, PermissionsCreateWorkspaces, PermissionsManageContentPermissions, PermissionsManageContentProperties, PermissionsManageContentTypes, PermissionsManageExchangeConfig, PermissionsManageAnalyticSnapshots, PermissionsScheduleReports, PermissionsManageBusinessHourHolidays, PermissionsManageEntitlements, PermissionsManageDynamicDashboards, PermissionsCustomSidebarOnAllPages, PermissionsManageInteraction, PermissionsViewMyTeamsDashboards, PermissionsModerateChatter, PermissionsResetPasswords, PermissionsFlowUFLRequired, PermissionsCanInsertFeedSystemFields, PermissionsActivitiesAccess, PermissionsManageKnowledgeImportExport, PermissionsEmailTemplateManagement, PermissionsEmailAdministration, PermissionsManageChatterMessages, PermissionsAllowEmailIC, PermissionsChatterFileLink, PermissionsForceTwoFactor, PermissionsViewEventLogFiles, PermissionsManageNetworks, PermissionsManageAuthProviders, PermissionsRunFlow, PermissionsCreateCustomizeDashboards, PermissionsCreateDashboardFolders, PermissionsViewPublicDashboards, PermissionsManageDashbdsInPubFolders, PermissionsCreateCustomizeReports, PermissionsCreateReportFolders, PermissionsViewPublicReports, PermissionsManageReportsInPubFolders, PermissionsEditMyDashboards, PermissionsEditMyReports, PermissionsViewAllUsers, PermissionsAllowUniversalSearch, PermissionsConnectOrgToEnvironmentHub, PermissionsWorkCalibrationUser, PermissionsCreateCustomizeFilters, PermissionsWorkDotComUserPerm, PermissionsContentHubUser, PermissionsGovernNetworks, PermissionsSalesConsole, PermissionsTwoFactorApi, PermissionsDeleteTopics, PermissionsEditTopics, PermissionsCreateTopics, PermissionsAssignTopics, PermissionsIdentityEnabled, PermissionsIdentityConnect, PermissionsAllowViewKnowledge, PermissionsContentWorkspaces, PermissionsManageSearchPromotionRules, PermissionsCustomMobileAppsAccess, PermissionsViewHelpLink, PermissionsManageProfilesPermissionsets, PermissionsAssignPermissionSets, PermissionsManageRoles, PermissionsManageIpAddresses, PermissionsManageSharing, PermissionsManageInternalUsers, PermissionsManagePasswordPolicies, PermissionsManageLoginAccessPolicies, PermissionsViewPlatformEvents, PermissionsManageCustomPermissions, PermissionsCanVerifyComment, PermissionsManageUnlistedGroups, PermissionsStdAutomaticActivityCapture, PermissionsInsightsAppDashboardEditor, PermissionsManageTwoFactor, PermissionsInsightsAppUser, PermissionsInsightsAppAdmin, PermissionsInsightsAppEltEditor, PermissionsInsightsAppUploadUser, PermissionsInsightsCreateApplication, PermissionsLightningExperienceUser, PermissionsViewDataLeakageEvents, PermissionsConfigCustomRecs, PermissionsSubmitMacrosAllowed, PermissionsBulkMacrosAllowed, PermissionsShareInternalArticles, PermissionsManageSessionPermissionSets, PermissionsManageTemplatedApp, PermissionsUseTemplatedApp, PermissionsSendAnnouncementEmails, PermissionsChatterEditOwnPost, PermissionsChatterEditOwnRecordPost, PermissionsWaveTabularDownload, PermissionsWaveCommunityUser, PermissionsAutomaticActivityCapture, PermissionsImportCustomObjects, PermissionsSalesforceIQInbox, PermissionsDelegatedTwoFactor, PermissionsChatterComposeUiCodesnippet, PermissionsSelectFilesFromSalesforce, PermissionsModerateNetworkUsers, PermissionsMergeTopics, PermissionsSubscribeToLightningReports, PermissionsManagePvtRptsAndDashbds, PermissionsAllowLightningLogin, PermissionsCampaignInfluence2, PermissionsViewDataAssessment, PermissionsRemoveDirectMessageMembers, PermissionsCanApproveFeedPost, PermissionsAddDirectMessageMembers, PermissionsAllowViewEditConvertedLeads, PermissionsShowCompanyNameAsUserBadge, PermissionsAccessCMC, PermissionsViewHealthCheck, PermissionsManageHealthCheck, PermissionsPackaging2, PermissionsManageCertificates, PermissionsCreateReportInLightning, PermissionsPreventClassicExperience, PermissionsHideReadByList, PermissionsListEmailSend, PermissionsFeedPinning, PermissionsChangeDashboardColors, PermissionsManageRecommendationStrategies, PermissionsManagePropositions, PermissionsCloseConversations, PermissionsSubscribeReportRolesGrps, PermissionsSubscribeDashboardRolesGrps, PermissionsUseWebLink, PermissionsHasUnlimitedNBAExecutions, PermissionsViewOnlyEmbeddedAppUser, PermissionsViewAllActivities, PermissionsSubscribeReportToOtherUsers, PermissionsLightningConsoleAllowedForUser, PermissionsSubscribeReportsRunAsUser, PermissionsSubscribeToLightningDashboards, PermissionsSubscribeDashboardToOtherUsers, PermissionsCreateLtngTempInPub, PermissionsAppointmentBookingUserAccess, PermissionsTransactionalEmailSend, PermissionsViewPrivateStaticResources, PermissionsCreateLtngTempFolder, PermissionsApexRestServices, PermissionsConfigureLiveMessage, PermissionsLiveMessageAgent, PermissionsEnableCommunityAppLauncher, PermissionsGiveRecognitionBadge, PermissionsLightningSchedulerUserAccess, PermissionsSalesforceIQInternal, PermissionsUseMySearch, PermissionsLtngPromoReserved01UserPerm, PermissionsManageSubscriptions, PermissionsWaveManagePrivateAssetsUser, PermissionsCanEditDataPrepRecipe, PermissionsAddAnalyticsRemoteConnections, PermissionsManageSurveys, PermissionsUseAssistantDialog, PermissionsUseQuerySuggestions, PermissionsRecordVisibilityAPI, PermissionsViewRoles, PermissionsCanManageMaps, PermissionsLMOutboundMessagingUserPerm, PermissionsModifyDataClassification, PermissionsPrivacyDataAccess, PermissionsQueryAllFiles, PermissionsModifyMetadata, PermissionsManageCMS, PermissionsSandboxTestingInCommunityApp, PermissionsCanEditPrompts, PermissionsViewUserPII, PermissionsManageHubConnections, PermissionsB2BMarketingAnalyticsUser, PermissionsTraceXdsQueries, PermissionsViewSecurityCommandCenter, PermissionsManageSecurityCommandCenter, PermissionsViewAllCustomSettings, PermissionsViewAllForeignKeyNames, PermissionsAddWaveNotificationRecipients, PermissionsHeadlessCMSAccess, PermissionsLMEndMessagingSessionUserPerm, PermissionsConsentApiUpdate, PermissionsPaymentsAPIUser, PermissionsAccessContentBuilder, PermissionsAccountSwitcherUser, PermissionsViewAnomalyEvents, PermissionsManageC360AConnections, PermissionsIsContactCenterAdmin, PermissionsIsContactCenterAgent, PermissionsManageReleaseUpdates, PermissionsViewAllProfiles, PermissionsSkipIdentityConfirmation, PermissionsCanToggleCallRecordings, PermissionsLearningManager, PermissionsSendCustomNotifications, PermissionsPackaging2Delete, PermissionsUseOmnichannelInventoryAPIs, PermissionsViewRestrictionAndScopingRules, PermissionsFSCComprehensiveUserAccess, PermissionsBotManageBots, PermissionsBotManageBotsTrainingData, PermissionsSchedulingLineAmbassador, PermissionsSchedulingFacilityManager, PermissionsOmnichannelInventorySync, PermissionsManageLearningReporting, PermissionsIsContactCenterSupervisor, PermissionsIsotopeCToCUser, PermissionsCanAccessCE, PermissionsUseAddOrderItemSummaryAPIs, PermissionsIsotopeAccess, PermissionsIsotopeLEX, PermissionsQuipMetricsAccess, PermissionsQuipUserEngagementMetrics, PermissionsRemoteMediaVirtualDesktop, PermissionsTransactionSecurityExempt, PermissionsManageStores, PermissionsManageExternalConnections, PermissionsUseReturnOrder, PermissionsUseReturnOrderAPIs, PermissionsUseSubscriptionEmails, PermissionsUseOrderEntry, PermissionsUseRepricing, PermissionsAIViewInsightObjects, PermissionsAICreateInsightObjects, PermissionsViewMLModels, PermissionsLifecycleManagementAPIUser, PermissionsNativeWebviewScrolling, PermissionsViewDeveloperName, PermissionsBypassMFAForUiLogins, PermissionsClientSecretRotation, PermissionsAccessToServiceProcess, PermissionsManageOrchInstsAndWorkItems, PermissionsCMSECEAuthoringAccess, PermissionsCdcReportingCreateReports, PermissionsCdcReportingViewReports, PermissionsCdcReportingManageFolders, PermissionsOmnichannelInventoryBasic,PermissionsDeleteCrMemoAndInvoice, PermissionsEmbeddedMessagingAgent, PermissionsManageNamedCredentials, PermissionsCanInitiateMessagingSessions, PermissionsEditRepricing, PermissionsCanUpdateEmailMessage, PermissionsDownloadPackageVersionZips, PermissionsDigitalLendingUser, PermissionsLoanOfficerUser, PermissionsUnderwriterUser, PermissionsEnableIPFSUpload, PermissionsEnableBCTransactionPolling, PermissionsAccessToComplaintMgmt, PermissionsAccessToDisputeManagement, PermissionsCustomAppsOnFSMobile, PermissionsSegmentIntelligenceUser, PermissionsFSCArcGraphCommunityUser, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, NamespacePrefix, HasActivationRequired, PermissionSetGroupId, Type FROM PermissionSet WHERE Id =\''+PsIdd+'\'';
            String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('resBody---> '+res.getBody());
        Map<String, String> psFieldsMap = new Map<String, String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            Object obj = records[0];
            Map<String, Object> recordMap = (Map<String, Object>) obj;
            Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('PermissionSet').getDescribe().fields.getMap();
            for(String fieldApiName : recordMap.keySet()){
                if(fieldApiName.contains('Permission')){
                    object fieldValue=recordMap.get(fieldApiName);
                    schema.DescribeFieldResult fieldDescribe=fieldsMap.get(fieldApiName).getDescribe();
                    String fieldLabel=fieldDescribe.getLabel();
                    psFieldsMap.put(fieldLabel,String.valueOf(fieldValue));
                }
            }
            for(String key : psFieldsMap.keySet()){
                System.debug('field---> '+key+' value----> '+psFieldsMap.get(key));
            }
        }
        return psFieldsMap;
    }
    
    //***************For Users****************//
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
    
    //Method to fetch Different Org's User Details
    @AuraEnabled(cacheable=true)
    public static IntegratedUserWrapper fetchIntegratedUserDetails(String credName, String userName){
        HttpRequest req = new HttpRequest();
        String query = 'Select Id, Name, UserRole.Name, LocaleSidKey, Profile.UserLicense.Name, Profile.Name, IsActive, LastLoginDate from User Where Name =\''+userName+'\'';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('resBody---> '+res.getBody());
        IntegratedUserWrapper userdata = new IntegratedUserWrapper();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                System.debug('recordMap-> '+recordMap);
                userdata.idd = (Id)recordMap.get('Id');
                userdata.isActive = (Boolean)recordMap.get('IsActive');
                userdata.LocaleSidKey = (String)recordMap.get('LocaleSidKey');
                String dt = (String)recordMap.get('LastLoginDate');
                if(dt != null){
                    String cleanedDateStr = dt.substring(0, dt.length() - 5);
                    cleanedDateStr = cleanedDateStr.replace('T', ' ');
                    DateTime lastLoginDate = DateTime.valueOf(cleanedDateStr);
                    userdata.LastLoginDate = lastLoginDate.format('yyyy-MM-dd HH:mm:ss');
                }
                else{
                    userdata.LastLoginDate = '';
                }
                userdata.Name = (String)recordMap.get('Name');
                Map<String, Object> ProfileMap = (Map<String, Object>)recordMap.get('Profile');
                Map<String, Object> LicenseMap = (Map<String, Object>)ProfileMap.get('UserLicense');
                Map<String, Object> RoleMap = (Map<String, Object>)recordMap.get('UserRole');
                System.debug('roleMap-> '+RoleMap);
                userdata.ProfileName = (String)ProfileMap.get('Name');
                if(RoleMap != null){
                    userdata.UserRoleName = (String)RoleMap.get('Name');
                }
                else{
                    userdata.UserRoleName = 'N/A';
                }
                userdata.ProfileUserLicenseName = (String)LicenseMap.get('Name');
            }
        }
        System.debug('integrated user details--> '+userdata);
        return userdata;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ApexClass> fetchIntegratedApexClassForUsers(String credName, String username){
        HttpRequest reqq = new HttpRequest();
        String queryy = 'Select Id from User Where Name =\''+username+'\'';
        String encodedQueryy = EncodingUtil.urlEncode(queryy, 'UTF-8');
        reqq.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQueryy);
        reqq.setMethod('GET');
        Http httpp = new Http();
        HttpResponse resp = httpp.send(reqq);
        Id userId;
        if(resp.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            Map<String, Object> recordMap = (Map<String, Object>) records[0];
            userId = (Id)recordMap.get('Id');
        }
        HttpRequest req = new HttpRequest();
        String userIdd = EncodingUtil.urlEncode(String.escapeSingleQuotes(userId), 'UTF-8');
        String query = 'SELECT id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom FROM PermissionSetAssignment WHERE AssigneeId = \'' + userIdd + '\' AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> psIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Id psId = (Id)recordMap.get('PermissionSetId');
                psIds.add((String)psId);
            }
        }
        List<String> permissionSets = new List<String>(psIds);
        HttpRequest req1 = new HttpRequest();
        String psidString = '\'' + String.join(permissionSets, '\',\'') + '\'';
        String searchTerm = 'ApexClass';
        String query1 = 'SELECT Id, SetupEntityId, SetupEntityType, ParentId FROM SetupEntityAccess WHERE SetupEntityType = \'' + searchTerm + '\' AND ParentId IN (' + psidString + ')';
        String encodedQuery1 = EncodingUtil.urlEncode(query1, 'UTF-8'); // Encoding the entire query string for URL
        req1.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery1);
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug('res1Body---> '+res1.getBody());
        Set<String> apexClassIds = new Set<String>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String setupEntityId = (String) recordMap.get('SetupEntityId');
                apexClassIds.add((String)setupEntityId);
            }
        }
        List<String> idList = new List<String>(apexClassIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'SELECT Id, Name FROM ApexClass WHERE Id IN (' + idString + ')';
        String encodedQuery3 = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req3 = new HttpRequest();
        req3.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery3);
        req3.setMethod('GET');
        Http http3 = new Http();
        HttpResponse res3 = http3.send(req3);
        List<ApexClass> apexClasses = new List<ApexClass>();
        if(res3.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res3.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                ApexClass a = new ApexClass();
                a.Name = (String) recordMap.get('Name');
                a.Id = (Id)recordMap.get('Id');
                apexClasses.add(a);
            }
        }
        System.debug('apexClasses--> '+apexClasses);
        return apexClasses;
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
    
    //Method to Fetch Assigned Apps Setting from User
    @AuraEnabled(cacheable=true)
    public static List<app> fetchIntegratedAssignedAppsForUsers(String credName, String username){
        HttpRequest reqq = new HttpRequest();
        String queryy = 'Select Id from User Where Name =\''+username+'\'';    
        String encodedQueryy = EncodingUtil.urlEncode(queryy, 'UTF-8');
        reqq.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQueryy);
        reqq.setMethod('GET');
        Http httpp = new Http();
        HttpResponse resp = httpp.send(reqq);
        Id userId;
        if(resp.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            Map<String, Object> recordMap = (Map<String, Object>) records[0];
            userId = (Id)recordMap.get('Id');
        }
        HttpRequest req = new HttpRequest();
        String userIdd = EncodingUtil.urlEncode(String.escapeSingleQuotes(userId), 'UTF-8');
        String query = 'SELECT id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom FROM PermissionSetAssignment WHERE AssigneeId = \'' + userIdd + '\' AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> psIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Id psId = (Id)recordMap.get('PermissionSetId');
                psIds.add((String)psId);
            }
        }
        List<String> permissionSets = new List<String>(psIds);
        HttpRequest req1 = new HttpRequest();
        String psidString = '\'' + String.join(permissionSets, '\',\'') + '\'';
        String searchTerm = 'ConnectedApplication';
        String query1 = 'SELECT Id, SetupEntityId, SetupEntityType, ParentId FROM SetupEntityAccess WHERE SetupEntityType != \'' + searchTerm + '\' AND ParentId IN (' + psidString + ')';
        String encodedQuery1 = EncodingUtil.urlEncode(query1, 'UTF-8'); // Encoding the entire query string for URL
        req1.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery1);
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug('res1Body---> '+res1.getBody());
        Set<String> appIds = new Set<String>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String setupEntityId = (String) recordMap.get('SetupEntityId');
                appIds.add((String)setupEntityId);
            }
        }
        List<String> idList = new List<String>(appIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'SELECT Id, ApplicationId, Name, Label FROM AppMenuItem WHERE ApplicationId In (' + idString + ')';
        String encodedQuery3 = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req3 = new HttpRequest();
        req3.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery3);
        req3.setMethod('GET');
        Http http3 = new Http();
        HttpResponse res3 = http3.send(req3);
        System.debug('res3.getBody()-> '+res3.getBody());
        List<app> appList = new List<app>();
        if(res3.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res3.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                app ap = new app();
                ap.idd = (Id)recordMap.get('Id');
                ap.Name = (String) recordMap.get('Label');
                appList.add(ap);
            }
        }
        System.debug('appList--> '+appList);
        return appList;
    }
    
    //Method to fetch connected App for Integrated Users
    @AuraEnabled(cacheable=true)
    public static List<conAppData> fetchIntegratedConnectedAppsForUsers(String credName, String username){
        HttpRequest reqq = new HttpRequest();
        String queryy = 'Select Id from User Where Name =\''+username+'\'';    
        String encodedQueryy = EncodingUtil.urlEncode(queryy, 'UTF-8');
        reqq.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQueryy);
        reqq.setMethod('GET');
        Http httpp = new Http();
        HttpResponse resp = httpp.send(reqq);
        Id userId;
        if(resp.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            Map<String, Object> recordMap = (Map<String, Object>) records[0];
            userId = (Id)recordMap.get('Id');
        }
        HttpRequest req = new HttpRequest();
        String userIdd = EncodingUtil.urlEncode(String.escapeSingleQuotes(userId), 'UTF-8');
        String query = 'SELECT id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom FROM PermissionSetAssignment WHERE AssigneeId = \'' + userIdd + '\' AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> psIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Id psId = (Id)recordMap.get('PermissionSetId');
                psIds.add((String)psId);
            }
        }
        List<String> permissionSets = new List<String>(psIds);
        HttpRequest req1 = new HttpRequest();
        String psidString = '\'' + String.join(permissionSets, '\',\'') + '\'';
        String searchTerm = 'ConnectedApplication';
        String query1 = 'SELECT Id, SetupEntityId, SetupEntityType, ParentId FROM SetupEntityAccess WHERE SetupEntityType = \'' + searchTerm + '\' AND ParentId IN (' + psidString + ')';
        String encodedQuery1 = EncodingUtil.urlEncode(query1, 'UTF-8'); // Encoding the entire query string for URL
        req1.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery1);
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug('res1Body---> '+res1.getBody());
        Set<String> appIds = new Set<String>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String setupEntityId = (String) recordMap.get('SetupEntityId');
                appIds.add((String)setupEntityId);
            }
        }
        List<String> idList = new List<String>(appIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'Select Id, Name from ConnectedApplication Where Id In (' + idString + ')';
        String encodedQuery3 = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req3 = new HttpRequest();
        req3.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery3);
        req3.setMethod('GET');
        Http http3 = new Http();
        HttpResponse res3 = http3.send(req3);
        System.debug('res3.getBody()-> '+res3.getBody());
        List<conAppData> conappList = new List<conAppData>();
        if(res3.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res3.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                conAppData ap = new conAppData();
                ap.idd = (Id)recordMap.get('Id');
                ap.Name = (String) recordMap.get('Name');
                conappList.add(ap);
            }
        }
        System.debug('conappList--> '+conappList);
        return conappList;
    }
    
    //Method to fetch Vf Page Access for Integrated Users
    @AuraEnabled(cacheable=true)
    public static List<ApexPage> fetchIntegratedVfPageAccessForUsers(String credName, String username){
        HttpRequest reqq = new HttpRequest();
        String queryy = 'Select Id from User Where Name =\''+username+'\'';    
        String encodedQueryy = EncodingUtil.urlEncode(queryy, 'UTF-8');
        reqq.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQueryy);
        reqq.setMethod('GET');
        Http httpp = new Http();
        HttpResponse resp = httpp.send(reqq);
        Id userId;
        if(resp.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            Map<String, Object> recordMap = (Map<String, Object>) records[0];
            userId = (Id)recordMap.get('Id');
        }
        HttpRequest req = new HttpRequest();
        String userIdd = EncodingUtil.urlEncode(String.escapeSingleQuotes(userId), 'UTF-8');
        String query = 'SELECT id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom FROM PermissionSetAssignment WHERE AssigneeId = \'' + userIdd + '\' AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> psIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Id psId = (Id)recordMap.get('PermissionSetId');
                psIds.add((String)psId);
            }
        }
        List<String> permissionSets = new List<String>(psIds);
        HttpRequest req1 = new HttpRequest();
        String psidString = '\'' + String.join(permissionSets, '\',\'') + '\'';
        String searchTerm = 'ApexPage';
        String query1 = 'SELECT Id, SetupEntityId, SetupEntityType, ParentId FROM SetupEntityAccess WHERE SetupEntityType = \'' + searchTerm + '\' AND ParentId IN (' + psidString + ')';
        String encodedQuery1 = EncodingUtil.urlEncode(query1, 'UTF-8'); // Encoding the entire query string for URL
        req1.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery1);
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug('res1Body---> '+res1.getBody());
        Set<String> vfPageIds = new Set<String>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                String setupEntityId = (String) recordMap.get('SetupEntityId');
                vfPageIds.add((String)setupEntityId);
            }
        }
        List<String> idList = new List<String>(vfPageIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'Select Id, Name from ApexPage Where Id In (' + idString + ')';
        String encodedQuery3 = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req3 = new HttpRequest();
        req3.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery3);
        req3.setMethod('GET');
        Http http3 = new Http();
        HttpResponse res3 = http3.send(req3);
        System.debug('res3.getBody()-> '+res3.getBody());
        List<ApexPage> vfPageList = new List<ApexPage>();
        if(res3.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res3.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                ApexPage ap = new ApexPage();
                ap.Id = (Id)recordMap.get('Id');
                ap.Name = (String) recordMap.get('Name');
                vfPageList.add(ap);
            }
        }
        System.debug('vfPageList--> '+vfPageList);
        return vfPageList;
    }
    
    //Method to fetch Object Settings for Integrated Users
    @AuraEnabled(cacheable=true)
    public static List<permissionCompareHandlerClass.ObjectPermissionsWrapper2> fetchIntegratedObjectSettingsForUsers(String credName, String username){
        HttpRequest reqq = new HttpRequest();
        String queryy = 'Select Id from User Where Name =\''+username+'\'';    
        String encodedQueryy = EncodingUtil.urlEncode(queryy, 'UTF-8');
        reqq.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQueryy);
        reqq.setMethod('GET');
        Http httpp = new Http();
        HttpResponse resp = httpp.send(reqq);
        Id userId;
        if(resp.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            Map<String, Object> recordMap = (Map<String, Object>) records[0];
            userId = (Id)recordMap.get('Id');
        }
        
        HttpRequest requ = new HttpRequest();
        String qry = 'SELECT SObjectType FROM ObjectPermissions GROUP BY SObjectType ORDER BY SObjectType ASC';    
        String encodedQry = EncodingUtil.urlEncode(qry, 'UTF-8');
        requ.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQry);
        requ.setMethod('GET');
        Http ht = new Http();
        HttpResponse response = ht.send(requ);
        System.debug('response body-> '+response.getBody());
        Map<String, permissionCompareHandlerClass.ObjectPermissionsWrapper2> allObjMap = new Map<String, permissionCompareHandlerClass.ObjectPermissionsWrapper2>();
        if(response.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                allObjMap.put((String) recordMap.get('SobjectType'), new permissionCompareHandlerClass.ObjectPermissionsWrapper2(
                    (String) recordMap.get('SobjectType'),
                    false, false, false, false, false, false
                ));
            }
        }
        
        HttpRequest req = new HttpRequest();
        String userIdd = EncodingUtil.urlEncode(String.escapeSingleQuotes(userId), 'UTF-8');
        String query = 'SELECT id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom FROM PermissionSetAssignment WHERE AssigneeId = \'' + userIdd + '\' AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> psIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Id psId = (Id)recordMap.get('PermissionSetId');
                psIds.add((String)psId);
            }
        }
        List<String> permissionSets = new List<String>(psIds);
        HttpRequest req1 = new HttpRequest();
        String psidString = '\'' + String.join(permissionSets, '\',\'') + '\'';
        String query1 = 'SELECT Id, PermissionsModifyAllRecords, PermissionsViewAllRecords, SobjectType, Parent.label, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, ParentId FROM ObjectPermissions WHERE Parent.Id IN (' + psidString + ')';
        String encodedQuery1 = EncodingUtil.urlEncode(query1, 'UTF-8'); // Encoding the entire query string for URL
        req1.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery1);
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug('res1Body---> '+res1.getBody());
        
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                System.debug('recordMap---> '+recordMap);
                String key = (String)recordMap.get('SobjectType');
                if(allObjMap.containsKey(key)){
                    permissionCompareHandlerClass.ObjectPermissionsWrapper2 current = allObjMap.get(key);
                    current.PermissionsModifyAllRecords = current.PermissionsModifyAllRecords || (Boolean)recordMap.get('PermissionsModifyAllRecords');
                    current.PermissionsViewAllRecords = current.PermissionsViewAllRecords || (Boolean)recordMap.get('PermissionsViewAllRecords');
                    current.PermissionsRead = current.PermissionsRead || (Boolean)recordMap.get('PermissionsRead');
                    current.PermissionsCreate = current.PermissionsCreate || (Boolean)recordMap.get('PermissionsCreate');
                    current.PermissionsEdit = current.PermissionsEdit || (Boolean)recordMap.get('PermissionsEdit');
                    current.PermissionsDelete = current.PermissionsDelete || (Boolean)recordMap.get('PermissionsDelete');
                    allObjMap.put(key, current);
                }
            }
        }
        List<permissionCompareHandlerClass.ObjectPermissionsWrapper2> objPermissionsList = new List<permissionCompareHandlerClass.ObjectPermissionsWrapper2>(allObjMap.values());
        for (permissionCompareHandlerClass.ObjectPermissionsWrapper2 objPerm : allObjMap.values()) {
            objPermissionsList.add(objPerm);
        }
        return objPermissionsList;
    }
    
    //Method to fetch integrated system permissions for users
    @AuraEnabled(cacheable=true)
    public static Map<String, String> fetchIntegratedSystemPermissionsForUsers(String credName, String username){
        HttpRequest reqq = new HttpRequest();
        String queryy = 'Select Id from User Where Name =\''+username+'\'';    
        String encodedQueryy = EncodingUtil.urlEncode(queryy, 'UTF-8');
        reqq.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQueryy);
        reqq.setMethod('GET');
        Http httpp = new Http();
        HttpResponse resp = httpp.send(reqq);
        Id userId;
        if(resp.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            Map<String, Object> recordMap = (Map<String, Object>) records[0];
            userId = (Id)recordMap.get('Id');
        }
        HttpRequest req = new HttpRequest();
        String userIdd = EncodingUtil.urlEncode(String.escapeSingleQuotes(userId), 'UTF-8');
        String query = 'SELECT id, PermissionSetGroupId, PermissionSetId, PermissionSetGroup.MasterLabel, PermissionSet.IsCustom FROM PermissionSetAssignment WHERE AssigneeId = \'' + userIdd + '\' AND PermissionSetGroupId = null AND PermissionSet.IsCustom = true';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> psIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Id psId = (Id)recordMap.get('PermissionSetId');
                psIds.add((String)psId);
            }
        }
        List<String> permissionSets = new List<String>(psIds);
        HttpRequest req1 = new HttpRequest();
        String psidString = '\'' + String.join(permissionSets, '\',\'') + '\'';
        String query1 = 'Select Id, Name, Label, LicenseId, ProfileId, IsOwnedByProfile, IsCustom, PermissionsEmailSingle, PermissionsEmailMass, PermissionsEditTask, PermissionsEditEvent, PermissionsExportReport, PermissionsImportPersonal, PermissionsDataExport, PermissionsManageUsers, PermissionsEditPublicFilters, PermissionsEditPublicTemplates, PermissionsModifyAllData, PermissionsEditBillingInfo, PermissionsManageCases, PermissionsMassInlineEdit, PermissionsEditKnowledge, PermissionsManageKnowledge, PermissionsManageSolutions, PermissionsCustomizeApplication, PermissionsEditReadonlyFields, PermissionsRunReports, PermissionsViewSetup, PermissionsTransferAnyEntity, PermissionsNewReportBuilder, PermissionsActivateContract, PermissionsActivateOrder, PermissionsImportLeads, PermissionsManageLeads, PermissionsTransferAnyLead, PermissionsViewAllData, PermissionsEditPublicDocuments, PermissionsViewEncryptedData, PermissionsEditBrandTemplates, PermissionsEditHtmlTemplates, PermissionsChatterInternalUser, PermissionsManageEncryptionKeys, PermissionsDeleteActivatedContract, PermissionsChatterInviteExternalUsers, PermissionsSendSitRequests, PermissionsApiUserOnly, PermissionsManageRemoteAccess, PermissionsCanUseNewDashboardBuilder, PermissionsManageCategories, PermissionsConvertLeads, PermissionsPasswordNeverExpires, PermissionsUseTeamReassignWizards, PermissionsEditActivatedOrders, PermissionsInstallPackaging, PermissionsPublishPackaging, PermissionsChatterOwnGroups, PermissionsEditOppLineItemUnitPrice, PermissionsCreatePackaging, PermissionsBulkApiHardDelete, PermissionsSolutionImport, PermissionsManageCallCenters, PermissionsManageSynonyms, PermissionsViewContent, PermissionsManageEmailClientConfig, PermissionsEnableNotifications, PermissionsManageDataIntegrations, PermissionsDistributeFromPersWksp, PermissionsViewDataCategories, PermissionsManageDataCategories, PermissionsAuthorApex, PermissionsManageMobile, PermissionsApiEnabled, PermissionsManageCustomReportTypes, PermissionsEditCaseComments, PermissionsTransferAnyCase, PermissionsContentAdministrator, PermissionsCreateWorkspaces, PermissionsManageContentPermissions, PermissionsManageContentProperties, PermissionsManageContentTypes, PermissionsManageExchangeConfig, PermissionsManageAnalyticSnapshots, PermissionsScheduleReports, PermissionsManageBusinessHourHolidays, PermissionsManageEntitlements, PermissionsManageDynamicDashboards, PermissionsCustomSidebarOnAllPages, PermissionsManageInteraction, PermissionsViewMyTeamsDashboards, PermissionsModerateChatter, PermissionsResetPasswords, PermissionsFlowUFLRequired, PermissionsCanInsertFeedSystemFields, PermissionsActivitiesAccess, PermissionsManageKnowledgeImportExport, PermissionsEmailTemplateManagement, PermissionsEmailAdministration, PermissionsManageChatterMessages, PermissionsAllowEmailIC, PermissionsChatterFileLink, PermissionsForceTwoFactor, PermissionsViewEventLogFiles, PermissionsManageNetworks, PermissionsManageAuthProviders, PermissionsRunFlow, PermissionsCreateCustomizeDashboards, PermissionsCreateDashboardFolders, PermissionsViewPublicDashboards, PermissionsManageDashbdsInPubFolders, PermissionsCreateCustomizeReports, PermissionsCreateReportFolders, PermissionsViewPublicReports, PermissionsManageReportsInPubFolders, PermissionsEditMyDashboards, PermissionsEditMyReports, PermissionsViewAllUsers, PermissionsAllowUniversalSearch, PermissionsConnectOrgToEnvironmentHub, PermissionsWorkCalibrationUser, PermissionsCreateCustomizeFilters, PermissionsWorkDotComUserPerm, PermissionsContentHubUser, PermissionsGovernNetworks, PermissionsSalesConsole, PermissionsTwoFactorApi, PermissionsDeleteTopics, PermissionsEditTopics, PermissionsCreateTopics, PermissionsAssignTopics, PermissionsIdentityEnabled, PermissionsIdentityConnect, PermissionsAllowViewKnowledge, PermissionsContentWorkspaces, PermissionsManageSearchPromotionRules, PermissionsCustomMobileAppsAccess, PermissionsViewHelpLink, PermissionsManageProfilesPermissionsets, PermissionsAssignPermissionSets, PermissionsManageRoles, PermissionsManageIpAddresses, PermissionsManageSharing, PermissionsManageInternalUsers, PermissionsManagePasswordPolicies, PermissionsManageLoginAccessPolicies, PermissionsViewPlatformEvents, PermissionsManageCustomPermissions, PermissionsCanVerifyComment, PermissionsManageUnlistedGroups, PermissionsStdAutomaticActivityCapture, PermissionsInsightsAppDashboardEditor, PermissionsManageTwoFactor, PermissionsInsightsAppUser, PermissionsInsightsAppAdmin, PermissionsInsightsAppEltEditor, PermissionsInsightsAppUploadUser, PermissionsInsightsCreateApplication, PermissionsLightningExperienceUser, PermissionsViewDataLeakageEvents, PermissionsConfigCustomRecs, PermissionsSubmitMacrosAllowed, PermissionsBulkMacrosAllowed, PermissionsShareInternalArticles, PermissionsManageSessionPermissionSets, PermissionsManageTemplatedApp, PermissionsUseTemplatedApp, PermissionsSendAnnouncementEmails, PermissionsChatterEditOwnPost, PermissionsChatterEditOwnRecordPost, PermissionsWaveTabularDownload, PermissionsWaveCommunityUser, PermissionsAutomaticActivityCapture, PermissionsImportCustomObjects, PermissionsSalesforceIQInbox, PermissionsDelegatedTwoFactor, PermissionsChatterComposeUiCodesnippet, PermissionsSelectFilesFromSalesforce, PermissionsModerateNetworkUsers, PermissionsMergeTopics, PermissionsSubscribeToLightningReports, PermissionsManagePvtRptsAndDashbds, PermissionsAllowLightningLogin, PermissionsCampaignInfluence2, PermissionsViewDataAssessment, PermissionsRemoveDirectMessageMembers, PermissionsCanApproveFeedPost, PermissionsAddDirectMessageMembers, PermissionsAllowViewEditConvertedLeads, PermissionsShowCompanyNameAsUserBadge, PermissionsAccessCMC, PermissionsViewHealthCheck, PermissionsManageHealthCheck, PermissionsPackaging2, PermissionsManageCertificates, PermissionsCreateReportInLightning, PermissionsPreventClassicExperience, PermissionsHideReadByList, PermissionsListEmailSend, PermissionsFeedPinning, PermissionsChangeDashboardColors, PermissionsManageRecommendationStrategies, PermissionsManagePropositions, PermissionsCloseConversations, PermissionsSubscribeReportRolesGrps, PermissionsSubscribeDashboardRolesGrps, PermissionsUseWebLink, PermissionsHasUnlimitedNBAExecutions, PermissionsViewOnlyEmbeddedAppUser, PermissionsViewAllActivities, PermissionsSubscribeReportToOtherUsers, PermissionsLightningConsoleAllowedForUser, PermissionsSubscribeReportsRunAsUser, PermissionsSubscribeToLightningDashboards, PermissionsSubscribeDashboardToOtherUsers, PermissionsCreateLtngTempInPub, PermissionsAppointmentBookingUserAccess, PermissionsTransactionalEmailSend, PermissionsViewPrivateStaticResources, PermissionsCreateLtngTempFolder, PermissionsApexRestServices, PermissionsConfigureLiveMessage, PermissionsLiveMessageAgent, PermissionsEnableCommunityAppLauncher, PermissionsGiveRecognitionBadge, PermissionsLightningSchedulerUserAccess, PermissionsSalesforceIQInternal, PermissionsUseMySearch, PermissionsLtngPromoReserved01UserPerm, PermissionsManageSubscriptions, PermissionsWaveManagePrivateAssetsUser, PermissionsCanEditDataPrepRecipe, PermissionsAddAnalyticsRemoteConnections, PermissionsManageSurveys, PermissionsUseAssistantDialog, PermissionsUseQuerySuggestions, PermissionsRecordVisibilityAPI, PermissionsViewRoles, PermissionsCanManageMaps, PermissionsLMOutboundMessagingUserPerm, PermissionsModifyDataClassification, PermissionsPrivacyDataAccess, PermissionsQueryAllFiles, PermissionsModifyMetadata, PermissionsManageCMS, PermissionsSandboxTestingInCommunityApp, PermissionsCanEditPrompts, PermissionsViewUserPII, PermissionsManageHubConnections, PermissionsB2BMarketingAnalyticsUser, PermissionsTraceXdsQueries, PermissionsViewSecurityCommandCenter, PermissionsManageSecurityCommandCenter, PermissionsViewAllCustomSettings, PermissionsViewAllForeignKeyNames, PermissionsAddWaveNotificationRecipients, PermissionsHeadlessCMSAccess, PermissionsLMEndMessagingSessionUserPerm, PermissionsConsentApiUpdate, PermissionsPaymentsAPIUser, PermissionsAccessContentBuilder, PermissionsAccountSwitcherUser, PermissionsViewAnomalyEvents, PermissionsManageC360AConnections, PermissionsIsContactCenterAdmin, PermissionsIsContactCenterAgent, PermissionsManageReleaseUpdates, PermissionsViewAllProfiles, PermissionsSkipIdentityConfirmation, PermissionsCanToggleCallRecordings, PermissionsLearningManager, PermissionsSendCustomNotifications, PermissionsPackaging2Delete, PermissionsUseOmnichannelInventoryAPIs, PermissionsViewRestrictionAndScopingRules, PermissionsFSCComprehensiveUserAccess, PermissionsBotManageBots, PermissionsBotManageBotsTrainingData, PermissionsSchedulingLineAmbassador, PermissionsSchedulingFacilityManager, PermissionsOmnichannelInventorySync, PermissionsManageLearningReporting, PermissionsIsContactCenterSupervisor, PermissionsIsotopeCToCUser, PermissionsCanAccessCE, PermissionsUseAddOrderItemSummaryAPIs, PermissionsIsotopeAccess, PermissionsIsotopeLEX, PermissionsQuipMetricsAccess, PermissionsQuipUserEngagementMetrics, PermissionsRemoteMediaVirtualDesktop, PermissionsTransactionSecurityExempt, PermissionsManageStores, PermissionsManageExternalConnections, PermissionsUseReturnOrder, PermissionsUseReturnOrderAPIs, PermissionsUseSubscriptionEmails, PermissionsUseOrderEntry, PermissionsUseRepricing, PermissionsAIViewInsightObjects, PermissionsAICreateInsightObjects, PermissionsViewMLModels, PermissionsLifecycleManagementAPIUser, PermissionsNativeWebviewScrolling, PermissionsViewDeveloperName, PermissionsBypassMFAForUiLogins, PermissionsClientSecretRotation, PermissionsAccessToServiceProcess, PermissionsManageOrchInstsAndWorkItems, PermissionsCMSECEAuthoringAccess, PermissionsCdcReportingCreateReports, PermissionsCdcReportingViewReports, PermissionsCdcReportingManageFolders, PermissionsOmnichannelInventoryBasic, PermissionsDeleteCrMemoAndInvoice, PermissionsEmbeddedMessagingAgent, PermissionsManageNamedCredentials, PermissionsCanInitiateMessagingSessions, PermissionsEditRepricing, PermissionsCanUpdateEmailMessage, PermissionsDownloadPackageVersionZips, PermissionsDigitalLendingUser, PermissionsLoanOfficerUser, PermissionsUnderwriterUser, PermissionsEnableIPFSUpload, PermissionsEnableBCTransactionPolling, PermissionsAccessToComplaintMgmt, PermissionsAccessToDisputeManagement, PermissionsCustomAppsOnFSMobile, PermissionsSegmentIntelligenceUser, PermissionsFSCArcGraphCommunityUser, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, NamespacePrefix, HasActivationRequired, PermissionSetGroupId, Type from PermissionSet Where Id IN (' + psidString + ')';
            String encodedQuery1 = EncodingUtil.urlEncode(query1, 'UTF-8'); // Encoding the entire query string for URL
        req1.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery1);
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug('res1Body---> '+res1.getBody());
        Map<String, String> psFieldsMap = new Map<String, String>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                mergeSystemPermissions(psFieldsMap, recordMap);
            }
        }
        System.debug('psFieldsMap---> '+psFieldsMap);
        return psFieldsMap;
    }
    
    // Helper method to merge system permissions of a Permission Set into the map
    public static void mergeSystemPermissions(Map<String, String> psFieldsMap, Map<String, Object> recordMap) {
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('PermissionSet').getDescribe().fields.getMap();
        system.debug('fieldsMap-->'+fieldsMap);
        
        for(String fieldApiName : recordMap.keySet()){
            if (fieldApiName.contains('Permissions')) { // Assuming system permission fields start with 'Permissions'
                Object fieldValue = recordMap.get(fieldApiName);
                Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldApiName).getDescribe();
                String fieldLabel = fieldDescribe.getLabel();
                
                // Combine the permission to the map
                if(psFieldsMap.containsKey(fieldLabel)){
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
    
    //Method to fetch Integrated Permission Set Groups and permission sets for users
    @AuraEnabled(cacheable=true)
    public static Map<string,Map<String, Id>> fetchIntegratedPermissionSetGroupAndPermissionSet(String credName, String username){
        HttpRequest reqq = new HttpRequest();
        String queryy = 'Select Id from User Where Name =\''+username+'\'';    
        String encodedQueryy = EncodingUtil.urlEncode(queryy, 'UTF-8');
        reqq.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQueryy);
        reqq.setMethod('GET');
        Http httpp = new Http();
        HttpResponse resp = httpp.send(reqq);
        Id userId;
        if(resp.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            Map<String, Object> recordMap = (Map<String, Object>) records[0];
            userId = (Id)recordMap.get('Id');
        }
        HttpRequest req = new HttpRequest();
        String userIdd = EncodingUtil.urlEncode(String.escapeSingleQuotes(userId), 'UTF-8');
        String query = 'SELECT id,PermissionSetGroupId, PermissionSetId,PermissionSetGroup.MasterLabel from PermissionSetAssignment where AssigneeId = \'' + userIdd + '\'';
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Set<String> psIds = new Set<String>();
        Set<String> psGroupIds = new Set<String>();
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Id psId = (Id)recordMap.get('PermissionSetId');
                Id groupId = (Id)recordMap.get('PermissionSetGroupId');
                if(groupId != null){
                    psGroupIds.add((String)groupId);
                }
                else{
                    psIds.add((String)psId);
                }
            }
        }
        List<String> permissionSetGroups = new List<String>(psGroupIds);
        HttpRequest req1 = new HttpRequest();
        String psGroupidString = '\'' + String.join(permissionSetGroups, '\',\'') + '\'';
        String query1 = 'Select Id,PermissionSet.Id,  PermissionSetGroup.MasterLabel,PermissionSetGroupId from PermissionSetGroupComponent where PermissionSetGroupId IN (' + psGroupidString + ')';
        String encodedQuery1 = EncodingUtil.urlEncode(query1, 'UTF-8'); // Encoding the entire query string for URL
        req1.setEndpoint('callout:'+credName+'/services/data/v59.0/query?q='+encodedQuery1);
        req1.setMethod('GET');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug('res1Body---> '+res1.getBody());
        Map<string,Map<String, Id>> newMap = new Map<string,Map<String, Id>>();
        if(res1.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Map<String, Object> psGroupMap = (Map<String, Object>)recordMap.get('PermissionSetGroup');
                Map<String, Object> psMapp = (Map<String, Object>)recordMap.get('PermissionSet');
                Map<String, Id> psNames = new Map<String, Id>();
                if(newMap.containsKey((String)psGroupMap.get('MasterLabel'))){
                    psNames = newMap.get((String)psGroupMap.get('MasterLabel'));
                    psNames.put((String)psMapp.get('Label'), (Id)psMapp.get('Id'));
                    newMap.put((String)psGroupMap.get('MasterLabel'), psNames);
                }
                else{
                    Map<String, Id> psMap = new Map<String, Id>();
                    psMap.put((String)psMapp.get('Label'), (Id)psMapp.get('Id'));
                    newMap.put((String)psGroupMap.get('MasterLabel'), psMap);
                    System.debug('newMap values--> '+newMap);
                }
            }
        }
        List<String> idList = new List<String>(psIds);
        String idString = '\'' + String.join(idList, '\',\'') + '\'';
        String queryString = 'SELECT Id, Label FROM PermissionSet WHERE (Type = \'Regular\' OR Type = \'Session\') AND IsCustom = true AND Id IN (' + idString + ')';
        String encodedQuery3 = EncodingUtil.urlEncode(queryString, 'UTF-8');
        HttpRequest req3 = new HttpRequest();
        req3.setEndpoint('callout:'+credName+'/services/data/v58.0/query?q='+encodedQuery3);
        req3.setMethod('GET');
        Http http3 = new Http();
        HttpResponse res3 = http3.send(req3);
        System.debug('res3.getBody()-> '+res3.getBody());
        Map<String, Id> psNames = new Map<String, Id>();
        if(res3.getStatusCode() == 200){
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res3.getBody());
            List<Object> records = (List<Object>) jsonResponse.get('records');
            for(Object record : records){
                Map<String, Object> recordMap = (Map<String, Object>) record;
                psNames.put((String)recordMap.get('Label'), (Id)recordMap.get('Id'));
            }
        }
        newMap.put('Without Group', psNames);
        System.debug('Map values----> '+newMap);
        return newMap;
    }
}