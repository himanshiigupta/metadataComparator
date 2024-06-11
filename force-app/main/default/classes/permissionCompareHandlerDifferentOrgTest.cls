@isTest
public class permissionCompareHandlerDifferentOrgTest {
    
    @IsTest
    static void testFetchIntegratedUserNames() {
        // Set up the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ConsolidatedMockHttpResponse());
        
        // Call the method to be tested
        List<String> userNames = permissionCompareHandlerDifferentOrg.fetchIntegratedUserNames('myCredentialName');
        System.debug('userNames-> '+userNames);
        
        // Verify the results
        System.assertEquals(1, userNames.size(), 'There should be 2 user names');
        System.assertEquals('Test User - testuser@zordial.com', userNames[0], 'First user name should be Test User - testuser@zordial.com');
    }
    
    
    @IsTest
    static void testFetchIntegratedPermissionSetNames() {
        // Set up the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ConsolidatedMockHttpResponse());
        
        // Call the method to be tested
        List<PermissionSet> permissionSets = permissionCompareHandlerDifferentOrg.fetchIntegratedPermissionSetNames('myCredentialName');
        
        // Verify the results
        System.assertEquals(2, permissionSets.size(), 'There should be 2 permission sets');
        System.assertEquals('Custom Permission Set 1', permissionSets[0].Label, 'First permission set label should be Custom Permission Set 1');
        System.assertEquals('Custom Permission Set 2', permissionSets[1].Label, 'Second permission set label should be Custom Permission Set 2');
        
    }
    
    @IsTest
    static void testFetchIntegratedPermissionSetGroupNames() {
        // Set up the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new ConsolidatedMockHttpResponse());
        
        // Call the method to be tested
        List<String> permissionSetGroupNames = permissionCompareHandlerDifferentOrg.fetchIntegratedPermissionSetGroupNames('myCredentialName');
        
        // Verify the results
        System.assertEquals(2, permissionSetGroupNames.size(), 'There should be 2 permission set group names');
    }
    
    @IsTest
    static void testFetchIntegratedApexClassAccess() {
        // Set up the mock responses
        Test.setMock(HttpCalloutMock.class, new ConsolidatedMockHttpResponse());
        
        // Call the method to be tested
        List<ApexClass> apexClasses = permissionCompareHandlerDifferentOrg.fetchIntegratedApexClassAccess('myCredentialName', '0PS1');
        
        // Verify the results
        System.assertEquals(2, apexClasses.size(), 'There should be 2 Apex classes');
        System.assertEquals('CustomApexClass1', apexClasses[0].Name, 'First Apex class name should be CustomApexClass1');
        System.assertEquals('CustomApexClass2', apexClasses[1].Name, 'Second Apex class name should be CustomApexClass2');
    }
    
    @IsTest
    static void testFetchIntegratedAssignedAppsSettings() {
        // Set up the mock HTTP responses
        Test.setMock(HttpCalloutMock.class, new ConsolidatedMockHttpResponse());
        
        // Define test data
        String credName = 'myCredential';
        String psId = 'testPsId';
        
        // Call the method under test
        List<String> appNames = permissionCompareHandlerDifferentOrg.fetchIntegratedAssignedAppsSettings(credName, psId);
        
        // Validate the results
        System.assertNotEquals(null, appNames);
        System.assertEquals(2, appNames.size());
        System.assertEquals('App1', appNames[0]);
        System.assertEquals('App2', appNames[1]);
    }
    
    @IsTest
    static void testFetchIntegratedConnectedAppSettings() {
        // Set up the mock HTTP responses
        Test.setMock(HttpCalloutMock.class, new ConsolidatedMockHttpResponse());
        
        // Define test data
        String credName = 'myCredential';
        String psId = 'testPsId';
        
        // Call the method under test
        List<String> conApps = permissionCompareHandlerDifferentOrg.fetchIntegratedConnectedAppSettings(credName, psId);
        
        // Validate the results
        System.assertNotEquals(null, conApps);
        System.assertEquals(2, conApps.size());
        System.assertEquals('ConnectedApp1', conApps[0]);
        System.assertEquals('ConnectedApp2', conApps[1]);
    }
    
    
    
    @IsTest
    static void testFetchIntegratedVfPageSettings() {
        // Set up test data
        String credName = 'testCred';
        String psId = 'testPsId';
        
        // Create mock HTTP response for the first callout
        String firstResponse = '{"totalSize":1,"done":true,"records":[{"SetupEntityId":"01p1t00000Ks7ZZ"}]}';
        
        // Create mock HTTP response for the second callout
        String secondResponse = '{"totalSize":1,"done":true,"records":[{"Name":"TestPage"}]}';
        
        // Mock the HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2(firstResponse, secondResponse));
        
        // Call the method under test
        List<ApexPage> result = permissionCompareHandlerDifferentOrg.fetchIntegratedVfPageSettings(credName, psId);
        
        // Assert the expected results
        System.assertEquals(1, result.size());
        System.assertEquals('TestPage', result[0].Name);
    }
    
    
    
    @isTest
    static void testFetchIntegratedSystemPermissions() {
        // Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse4());
        
        // Call the method
        String credName = 'testCredential';
        String psId = '0PS0Y0000008abc';
        Map<String, String> result = permissionCompareHandlerDifferentOrg.fetchIntegratedSystemPermissions(credName, psId);
        
        // Verify the result
        System.assertNotEquals(null, result);
        System.assert(result.containsKey('View All Data'));
        System.assertEquals('true', result.get('View All Data'));
    }
    
    @isTest
    static void testFetchIntegratedUserDetails() {
        // Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse4());
        
        // Call the method
        String credName = 'testCredential';
        String userName = 'Test User';
        permissionCompareHandlerDifferentOrg.IntegratedUserWrapper userDetails = permissionCompareHandlerDifferentOrg.fetchIntegratedUserDetails(credName, userName);
        
        // Verify the result
        System.assertNotEquals(null, userDetails);
        System.assertEquals('Test User', userDetails.Name);
        System.assertEquals('testProfile', userDetails.ProfileName);
    }
    
    @isTest
    static void testFetchIntegratedApexClassForUsers() {
        // Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse4());
        
        // Call the method
        String credName = 'testCredential';
        String username = 'Test User';
        List<ApexClass> apexClasses = permissionCompareHandlerDifferentOrg.fetchIntegratedApexClassForUsers(credName, username);
        
        // Verify the result
        System.assertNotEquals(null, apexClasses);
        System.assertEquals(1, apexClasses.size());
        System.assertEquals('TestApexClass', apexClasses[0].Name);
    }
    
    
    
    
    
    @isTest
    static void testFetchIntegratedAssignedAppsForUsers() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator5());
        
        String credName = 'TestCred';
        String username = 'testuser@example.com';
        
        Test.startTest();
        List<permissionCompareHandlerDifferentOrg.app> result = permissionCompareHandlerDifferentOrg.fetchIntegratedAssignedAppsForUsers(credName, username);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('0AMxx0000000003AAA', result[0].idd);
        System.assertEquals('Test App', result[0].Name);
    }
    
    @isTest
    static void testFetchIntegratedConnectedAppsForUsers() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator5());
        
        String credName = 'TestCred';
        String username = 'testuser@example.com';
        
        Test.startTest();
        List<permissionCompareHandlerDifferentOrg.conAppData> result = permissionCompareHandlerDifferentOrg.fetchIntegratedConnectedAppsForUsers(credName, username);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('0CAxx0000000004AAA', result[0].idd);
        System.assertEquals('Connected App', result[0].Name);
    }
    
    
    @isTest
    static void testFetchIntegratedVfPageAccessForUsers() {
        // Mock HTTP response for fetching user
        HttpResponse userResponse = new HttpResponse();
        userResponse.setHeader('Content-Type', 'application/json');
        userResponse.setBody('{"totalSize":1,"done":true,"records":[{"Id":"0055g00000KHwAuAAL"}]}');
        userResponse.setStatusCode(200);
        
        // Mock HTTP response for fetching PermissionSetAssignment
        HttpResponse psAssignmentResponse = new HttpResponse();
        psAssignmentResponse.setHeader('Content-Type', 'application/json');
        psAssignmentResponse.setBody('{"totalSize":1,"done":true,"records":[{"PermissionSetId":"0Pa5g0000072u56CAA"}]}');
        psAssignmentResponse.setStatusCode(200);
        
        // Mock HTTP response for fetching SetupEntityAccess
        HttpResponse setupEntityAccessResponse = new HttpResponse();
        setupEntityAccessResponse.setHeader('Content-Type', 'application/json');
        setupEntityAccessResponse.setBody('{"totalSize":1,"done":true,"records":[{"SetupEntityId":"0J05g00009tFSt6CAG"}]}');
        setupEntityAccessResponse.setStatusCode(200);
        
        // Mock HTTP response for fetching ApexPage
        HttpResponse apexPageResponse = new HttpResponse();
        apexPageResponse.setHeader('Content-Type', 'application/json');
        apexPageResponse.setBody('{"totalSize":1,"done":true,"records":[{"Id":"0665g00000VgYOXAA3","Name":"TestPage"}]}');
        apexPageResponse.setStatusCode(200);
        
        // Set mock responses
        Test.setMock(HttpCalloutMock.class, new MultiMockHttpResponse(new Map<Integer, HttpResponse>{
            1 => userResponse,
                2 => psAssignmentResponse,
                3 => setupEntityAccessResponse,
                4 => apexPageResponse
                }));
        
        Test.startTest();
        List<ApexPage> result = permissionCompareHandlerDifferentOrg.fetchIntegratedVfPageAccessForUsers('MyCredentialName', 'Test User');
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('0665g00000VgYOXAA3', result[0].Id);
        System.assertEquals('TestPage', result[0].Name);
    }
    
    @isTest
    static void testFetchIntegratedSystemPermissionsForUsers() {
        // Mock HTTP response for fetching user
        HttpResponse userResponse = new HttpResponse();
        userResponse.setHeader('Content-Type', 'application/json');
        userResponse.setBody('{"totalSize":1,"done":true,"records":[{"Id":"0055g00000KHwAuAAL"}]}');
        userResponse.setStatusCode(200);
        
        // Mock HTTP response for fetching PermissionSetAssignment
        HttpResponse psAssignmentResponse = new HttpResponse();
        psAssignmentResponse.setHeader('Content-Type', 'application/json');
        psAssignmentResponse.setBody('{"totalSize":1,"done":true,"records":[{"PermissionSetId":"0Pa5g0000072u56CAA"}]}');
        psAssignmentResponse.setStatusCode(200);
        
        // Mock HTTP response for fetching PermissionSet
        HttpResponse permissionSetResponse = new HttpResponse();
        permissionSetResponse.setHeader('Content-Type', 'application/json');
        permissionSetResponse.setBody('{"totalSize":1,"done":true,"records":[{"Id":"0Pa5g0000072u56CAA","PermissionsEditTask":true}]}');
        permissionSetResponse.setStatusCode(200);
        
        // Set mock responses
        Test.setMock(HttpCalloutMock.class, new MultiMockHttpResponse(new Map<Integer, HttpResponse>{
            1 => userResponse,
                2 => psAssignmentResponse,
                3 => permissionSetResponse
                }));
        
        Test.startTest();
        Map<String, String> result = permissionCompareHandlerDifferentOrg.fetchIntegratedSystemPermissionsForUsers('MyCredentialName', 'Test User');
        Test.stopTest();
        
        System.assertEquals(false, result.containsKey('PermissionsEditTask'));
    }
    
    
    
    @IsTest
    static void testFetchIntegratedPermissionSetGroupAndPermissionSet() {
        
        // Mock HTTP callout responses
        Test.setMock(HttpCalloutMock.class, new FetchIntegratedPermissionSetGroupAndPermissionSetMock());
        
        // Call the method
        Map<String, Map<String, Id>> result = permissionCompareHandlerDifferentOrg.fetchIntegratedPermissionSetGroupAndPermissionSet('test_cred', 'testuser@example.com');
        
        // Assertions to validate the returned map
        System.assertNotEquals(null, result);
        System.assert(result.containsKey('Without Group'), 'Without Group key should be present');
    }
    
    // Implement the mock class
    private class FetchIntegratedPermissionSetGroupAndPermissionSetMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String endpoint = req.getEndpoint();
            
            if (endpoint.contains('/services/data/v59.0/query?q=Select+Id+from+User+Where+Name')) {
                res.setStatusCode(200);
                res.setBody('{"records":[{"Id":"0050a0000000001"}]}');
            } else if (endpoint.contains('/services/data/v59.0/query?q=SELECT+id,PermissionSetGroupId,PermissionSetId,PermissionSetGroup.MasterLabel+from+PermissionSetAssignment')) {
                res.setStatusCode(200);
                res.setBody('{"records":[{"PermissionSetId":"0PS0a0000000001","PermissionSetGroupId":null},{"PermissionSetId":"0PS0a0000000002","PermissionSetGroupId":"0PG0a0000000001"}]}');
            } else if (endpoint.contains('/services/data/v59.0/query?q=Select+Id,PermissionSet.Id,PermissionSetGroup.MasterLabel,PermissionSetGroupId+from+PermissionSetGroupComponent')) {
                res.setStatusCode(200);
                res.setBody('{"records":[{"PermissionSetGroup":{"MasterLabel":"Test Permission Set Group"},"PermissionSet":{"Id":"0PS0a0000000002","Label":"Grouped Permission Set"}}]}');
            } else if (endpoint.contains('/services/data/v58.0/query?q=SELECT+Id,Label+FROM+PermissionSet+WHERE+(Type+=+\'Regular\'+OR+Type+=+\'Session\')+AND+IsCustom+=+true+AND+Id+IN')) {
                res.setStatusCode(200);
                res.setBody('{"records":[{"Id":"0PS0a0000000001","Label":"Test Permission Set"}]}');
            }
            
            return res;
        }
    }
    
    // Mock class to simulate HTTP responses
    private class MockHttpResponseGenerator1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String endpoint = req.getEndpoint();
            
            // First callout response: SetupEntityAccess query
            if (endpoint.contains('SetupEntityAccess')) {
                res.setStatusCode(200);
                res.setBody('{"records": [{"SetupEntityId": "conAppId1"}, {"SetupEntityId": "conAppId2"}]}');
            }
            // Second callout response: ConnectedApplication query
            else if (endpoint.contains('ConnectedApplication')) {
                res.setStatusCode(200);
                res.setBody('{"records": [{"Name": "ConnectedApp1"}, {"Name": "ConnectedApp2"}]}');
            }
            
            return res;
        }
    }
    
    private class ConsolidatedMockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            String endpoint = req.getEndpoint();
            String jsonResponse;
            
            if (endpoint.contains('SetupEntityAccess')) {
                jsonResponse = '{ "totalSize": 2, "done": true, "records": [{} , {}] }';
            } else if (endpoint.contains('AppMenuItem')) {
                jsonResponse = '{ "totalSize": 2, "done": true, "records": [{ "Label": "App1" }, { "Label": "App2" }] }';
            } else if (endpoint.contains('ConnectedApplication')) {
                jsonResponse = '{ "totalSize": 2, "done": true, "records": [{ "Name": "ConnectedApp1" }, { "Name": "ConnectedApp2" }] }';
            } else if (endpoint.contains('PermissionSet')) {
                jsonResponse = '{ "totalSize": 2, "done": true, "records": [{ "Label": "Custom Permission Set 1" }, { "Label": "Custom Permission Set 2" }] }';
            } else if (endpoint.contains('PermissionSetGroup')) {
                jsonResponse = '{ "totalSize": 2, "done": true, "records": [{ "MasterLabel": "Permission Set Group 1" }, { "MasterLabel": "Permission Set Group 2" }] }';
            } else if (endpoint.contains('ApexClass')) {
                jsonResponse = '{ "totalSize": 2, "done": true, "records": [{ "Name": "CustomApexClass1" }, { "Name": "CustomApexClass2" }] }';
            } else if (endpoint.contains('User')) {
                jsonResponse = '{ "records": [{ "Id": "005xx000001Sv6zAAC", "Name": "Test User", "Username" : "testuser@zordial.com", "UserRole": { "Name": "TestRole" }, "LocaleSidKey": "en_US", "Profile": { "Name": "testProfile", "UserLicense": { "Name": "testLicense" } }, "IsActive": true, "LastLoginDate": "2023-01-01T00:00:00.000+0000" }] }';
            } else if (endpoint.contains('PermissionSetAssignment')) {
                jsonResponse = '{ "records": [{ "PermissionSetId": "0PSxx0000000001AAA" }] }';
            } else {
                jsonResponse = '{ "error": "Unsupported endpoint" }';
                res.setStatusCode(404);
            }
            
            res.setBody(jsonResponse);
            return res;
        }
    }
    
    // Mock class to handle multiple HTTP callouts in a single test
    public class MultiMockHttpResponse implements HttpCalloutMock {
        private Map<Integer, HttpResponse> responses;
        private Integer currentStep;
        
        public MultiMockHttpResponse(Map<Integer, HttpResponse> responses) {
            this.responses = responses;
            this.currentStep = 1;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = responses.get(currentStep);
            currentStep++;
            return response;
        }
    }
    
    // Test class for the mock responses
    private class MockHttpResponseGenerator5 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('User')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"records": [{"Id": "005xx000001Sv6zAAC"}]}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('PermissionSetAssignment')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"records": [{"PermissionSetId": "0PSxx0000000001AAA"}]}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('SetupEntityAccess')) {
                res.setHeader('Content-Type', 'application/json');
                if (req.getEndpoint().contains('ConnectedApplication')) {
                    res.setBody('{"records": [{"SetupEntityId": "0SOxx0000000001AAA"}]}');
                } else {
                    res.setBody('{"records": [{"SetupEntityId": "0SOxx0000000002AAA"}]}');
                }
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('AppMenuItem')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"records": [{"Id": "0AMxx0000000003AAA", "Label": "Test App"}]}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('ConnectedApplication')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"records": [{"Id": "0CAxx0000000004AAA", "Name": "Connected App"}]}');
                res.setStatusCode(200);
            } else {
                res.setStatusCode(404);
            }
            return res;
        }
    }
    
    // Mock class to simulate HTTP responses
    private class MockHttpResponse4 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('PermissionSet')) {
                res.setBody('{"records": [{"Id": "0PS0Y0000008abc", "Name": "Test Permission Set", "PermissionsViewAllData": true}]}');
            } else if (req.getEndpoint().contains('User')) {
                res.setBody('{"records": [{"Id": "0050Y0000008xyz", "Name": "Test User", "UserRole": {"Name": "TestRole"}, "LocaleSidKey": "en_US", "Profile": {"Name": "testProfile", "UserLicense": {"Name": "testLicense"}}, "IsActive": true, "LastLoginDate": "2023-01-01T00:00:00.000+0000"}]}');
            } else if (req.getEndpoint().contains('PermissionSetAssignment')) {
                res.setBody('{"records": [{"PermissionSetId": "0PS0Y0000008abc"}]}');
            } else if (req.getEndpoint().contains('SetupEntityAccess')) {
                res.setBody('{"records": [{"SetupEntityId": "01p0Y0000008def"}]}');
            } else if (req.getEndpoint().contains('ApexClass')) {
                res.setBody('{"records": [{"Id": "01p0Y0000008def", "Name": "TestApexClass"}]}');
            }
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class MockHttpResponseGenerator2 implements HttpCalloutMock {
        private String firstResponse;
        private String secondResponse;
        private Integer callCount = 0;
        
        public MockHttpResponseGenerator2(String firstResponse, String secondResponse) {
            this.firstResponse = firstResponse;
            this.secondResponse = secondResponse;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            
            if (callCount == 0) {
                res.setBody(firstResponse);
            } else {
                res.setBody(secondResponse);
            }
            callCount++;
            return res;
        }
    }
    
    // Mock class for PermissionSet response
    private class MockPermissionSetHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            String jsonResponse = '{' +
                '"totalSize": 2,' +
                '"done": true,' +
                '"records": [' +
                '{ "Label": "Custom Permission Set 1"},' +
                '{ "Label": "Custom Permission Set 2"}' +
                ']' +
                '}';
            res.setBody(jsonResponse);
            return res;
        }
    }
    
}