@isTest
public class PermissionCompareHandlerClassTest {

    // Helper method to create test data
    private static void createTestData() {
        // Create test users
        User u1 = new User(
            Alias = 'test1',
            Email = 'test1@example.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'U1',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test1zordial@example.com'
        );
        insert u1;

        User u2 = new User(
            Alias = 'test2',
            Email = 'test2@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test2zordial@example.com'
        );
        insert u2;

        // Create test Permission Sets
        PermissionSet ps1 = new PermissionSet(
            Name = 'TestPermissionSet1',
            Label = 'Test Permission Set 1'
        );
        insert ps1;

        PermissionSet ps2 = new PermissionSet(
            Name = 'TestPermissionSet2',
            Label = 'Test Permission Set 2'
        );
        insert ps2;

        // Create test Permission Set Groups
        PermissionSetGroup psg1 = new PermissionSetGroup(
            DeveloperName = 'TestPermissionSetGroup1',
            MasterLabel = 'Test Permission Set Group 1'
        );
        insert psg1;

        // Create test Permission Set Assignments
        PermissionSetAssignment psa1 = new PermissionSetAssignment(
            AssigneeId = u1.Id,
            PermissionSetId = ps1.Id
        );
        insert psa1;

        PermissionSetAssignment psa2 = new PermissionSetAssignment(
            AssigneeId = u2.Id,
            PermissionSetId = ps2.Id
        );
        insert psa2;
    }

    // Test method to fetch user names
    @isTest
    public static void testFetchUsersNames() {
        createTestData();
        Test.startTest();
        List<User> users = permissionCompareHandlerClass.fetchUsersNames();
        Test.stopTest();
        System.assert(users.size() > 0, 'User list should not be empty');
    }

    // Test method to fetch Permission Set names
    @isTest
    public static void testFetchPermissionSetNames() {
        createTestData();
        Test.startTest();
        List<PermissionSet> permissionSets = permissionCompareHandlerClass.fetchPermissionSetNames();
        Test.stopTest();
        System.assert(permissionSets.size() > 0, 'Permission Set list should not be empty');
    }

    // Test method to fetch Permission Set Group names
    @isTest
    public static void testFetchPermissionSetGroupNames() {
        createTestData();
        Test.startTest();
        List<PermissionSetGroup> permissionSetGroups = permissionCompareHandlerClass.fetchPermissionSetGroupNames();
        Test.stopTest();
        System.assert(permissionSetGroups.size() > 0, 'Permission Set Group list should not be empty');
    }

    // Test method to fetch Named Credential Labels
    @isTest
    public static void testFetchNamedCredentialLabels() {
        createTestData();

        // Mock HTTP responses
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"records":[{"Name":"Test Org 1"}]}');
        response.setStatusCode(200);

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:TestNamedCredential1/services/data/v58.0/query?q=select%20Name%20from%20Organization');
        request.setMethod('GET');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));

        Test.startTest();
        Map<String, String> namedCredentials = permissionCompareHandlerClass.fetchNamedCredentialLabels();
        Test.stopTest();
        System.assert(namedCredentials.size() > 0, 'Named Credential list should not be empty');
    }

    // Test method to fetch user details
    @isTest
    public static void testFetchUserDetails() {
        createTestData();
        Test.startTest();
        permissionCompareHandlerClass.UserWrapper userDetails = permissionCompareHandlerClass.fetchUserDetails('U1 Test');
        Test.stopTest();
        System.assertEquals(userDetails.LocaleSidKey, 'en_US');
    }

    // Additional test methods for other methods...

    @isTest
    public static void testFetchApexClassPermissions() {
        createTestData();
        Test.startTest();
        List<ApexClass> apexClasses = permissionCompareHandlerClass.fetchApexClassPermissions('TestPermissionSet1');
        Test.stopTest();
        System.assert(apexClasses.size() == 0, 'Apex class permissions list should not be empty');
    }

    @isTest
    public static void testFetchObjectSetting() {
        createTestData();
        Test.startTest();
        List<permissionCompareHandlerClass.ObjectPermissionsWrapper> objectPermissions = permissionCompareHandlerClass.fetchObjectSetting('TestPermissionSet1');
        Test.stopTest();
        System.assert(objectPermissions.size() > 0, 'Object Permissions list should not be empty');
    }

    @isTest
    public static void testFetchConnectedAppSettings() {
        createTestData();
        Test.startTest();
        List<ConnectedApplication> connectedApps = permissionCompareHandlerClass.fetchConnectedAppSettings('TestPermissionSet1');
        Test.stopTest();
        System.assert(connectedApps.size() == 0, 'Connected Apps list should not be empty');
    }

    @isTest
    public static void testFetchVfPageAccess() {
        createTestData();
        Test.startTest();
        List<ApexPage> vfPages = permissionCompareHandlerClass.fetchVfPageAccess('TestPermissionSet1');
        Test.stopTest();
        System.assert(vfPages.size() == 0, 'Visualforce Pages list should not be empty');
    }

    @isTest
    public static void testFetchAssignedApps() {
        createTestData();
        Test.startTest();
        List<AppMenuItem> assignedApps = permissionCompareHandlerClass.fetchAssignedApps('TestPermissionSet1');
        Test.stopTest();
        System.assert(assignedApps.size() == 0, 'Assigned Apps list should not be empty');
    }
    
    // Test method for fetchSystemPermissionsForPermissionSet
    @IsTest
    public static void testFetchSystemPermissionsForPermissionSet() {
        PermissionSet testPS = createTestPermissionSet('TestPS');
        testPS.PermissionsApiEnabled = true;
        update testPS;

        Test.startTest();
        Map<String, String> result = permissionCompareHandlerClass.fetchSystemPermissionsForPermissionSet(testPS.Id);
        Test.stopTest();

        System.assertEquals('true', result.get('API Enabled'), 'Expected API Enabled permission');
    }
    
    //Test method for fetchApexClassForUsers
	@IsTest
    public static void testFetchApexClassForUsers(){
        createTestData();
        Test.startTest();
        List<ApexClass> apexClasses = permissionCompareHandlerClass.fetchApexClassForUsers('U1 Test');
        Test.stopTest();
        System.assert(apexClasses.size() == 0, 'Apex class permissions list should not be empty');
    }

	@IsTest
    public static void testFetchAssignedAppsForUsers(){
        createTestData();
        Test.startTest();
        List<AppMenuItem> assignedApps = permissionCompareHandlerClass.fetchAssignedAppsForUsers('U1 Test');
        Test.stopTest();
        System.assert(assignedApps.size() == 0, 'Assigned Apps list should not be empty');
    }  

	@isTest
    public static void testFetchConnectedAppSettingsForUsers() {
        createTestData();
        Test.startTest();
        List<ConnectedApplication> connectedApps = permissionCompareHandlerClass.fetchAssignedConnectedAppsForUsers('U1 Test');
        Test.stopTest();
        System.assert(connectedApps.size() == 0, 'Connected Apps list should not be empty');
    }

    @isTest
    public static void testFetchVfPageAccessForUsers() {
        createTestData();
        Test.startTest();
        List<ApexPage> vfPages = permissionCompareHandlerClass.fetchVfPageAccessForUsers('U1 Test');
        Test.stopTest();
        System.assert(vfPages.size() == 0, 'Visualforce Pages list should not be empty');
    }

	@isTest
    public static void testFetchObjectSettingForUsers() {
        createTestData();
        Test.startTest();
        List<permissionCompareHandlerClass.ObjectPermissionsWrapper2> objectPermissions = permissionCompareHandlerClass.fetchObjectPermissionsForUsers('U1 Test');
        Test.stopTest();
        System.assert(objectPermissions.size() > 0, 'Object Permissions list should not be empty');
    }

	@IsTest
    public static void testFetchSystemPermissionsForUsers() {
        createTestData();
		PermissionSet p = [Select Id, Name, PermissionsApiEnabled FROM PermissionSet WHERE Name = 'TestPermissionSet1'];
        p.PermissionsApiEnabled = true;
        update p;
        
        Test.startTest();
        Map<String, String> result = permissionCompareHandlerClass.fetchSystemPermissionsForusers('U1 Test');
        Test.stopTest();

        System.assertEquals('true', result.get('API Enabled'), 'Expected API Enabled permission');
    }

    private static PermissionSet createTestPermissionSet(String label) {
        PermissionSet testPS = new PermissionSet(
            Name = label,
            Label = label
        );
        insert testPS;
        return testPS;
    }

    private static PermissionSetGroup createTestPermissionSetGroup(String label) {
        PermissionSetGroup testPSG = new PermissionSetGroup(
            MasterLabel = label,
            DeveloperName = label
        );
        insert testPSG;
        return testPSG;
    }

    private static ApexClass createTestApexClass(String name) {
        ApexClass testClass = new ApexClass(
            Name = name,
            Body = 'public class ' + name + ' {}'
        );
        return testClass;
    }

    private static ApexPage createTestApexPage(String name) {
        ApexPage testVfPage = new ApexPage(
            Name = name,
            Markup = '<apex:page>Test Page</apex:page>'
        );
        return testVfPage;
    }
}