public class MainClassForLightning {

    @AuraEnabled(cacheable=true)
    public static List<String> fetchIntegratedUserNames(string credName) {
        return ServiceClassForLightning.fetchIntegratedUser(credName);
    }
}