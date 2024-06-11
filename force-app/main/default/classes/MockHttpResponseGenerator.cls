@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    private HttpResponse mockResponse;

    // Constructor to initialize with a single mock response
    public MockHttpResponseGenerator(HttpResponse response) {
        this.mockResponse = response;
    }

    // Method to generate the mock response
    global HttpResponse respond(HttpRequest request) {
        return mockResponse;
    }
}