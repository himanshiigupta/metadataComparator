public class ServiceClassForLightning {

    Public Static List<String> fetchIntegratedUser(String nameCred)
    {
        HttpRequest req = new HttpRequest();
        String searchTerm = 'Standard';
        String encodedSearchTerm = EncodingUtil.urlEncode(searchTerm, 'UTF-8');
        String query = 'SELECT+Name+,+UserName+FROM+User+WHERE+UserType+=+\'' + searchTerm + '\'';
        req.setEndpoint('callout:'+nameCred+'/services/data/v58.0/query?q='+query);
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
}