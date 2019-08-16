import ballerina/http;
import ballerina/io;
import ballerina/crypto;
import ballerina/encoding;

string consuleAgentApi = "http://localhost:8500/v1";
public function main(string... args) {
    // Register the service in consule. Ideally this should happen in the service start up phase.
    // Since in Ballerina there is no way of knowing the service has started succesfully, a different 
    // client will be used to register the service.
    http:Client registerClient = new("http://localhost:8080/backend/deployInConsule");
    var registerdeResponse = registerClient->get("/");
    if (registerdeResponse is http:Response) {
        if (registerdeResponse.statusCode == 200) {
            http:Client healthClient = new(consuleAgentApi + "/health/service/ballerina");
            var healthResp = healthClient->get("");
            if (healthResp is http:Response) {
                // Do a health check before calling the endpoint.
                boolean status = validateStatus(healthResp);
                if (status == true) {
                    string url = getEndpointUrl();
                    io:println(url);
                    http:Client httpClient = new(url);
                    var response = httpClient->get("/");
                    io:println(response);
                }
            }
        }
    }
}

public function getEndpointUrl() returns @tainted string {
    http:Client clientEp = new (consuleAgentApi + "/kv/prod");
    var result = clientEp->get("");
    string url = "";

    if (result is http:Response) {  
        var jsonPayload = result.getJsonPayload();        
        if (jsonPayload is json[]) {
            var jsonValue = jsonPayload[0].Value; 
            io:println(jsonValue); 
            if (jsonValue is json) {
                string base64EncodedUrl = jsonValue.toString();
                io:println(base64EncodedUrl);
                var urlByteArray = encoding:decodeBase64(base64EncodedUrl);
                if (urlByteArray is byte[]) {
                    url =  encoding:byteArrayToString(urlByteArray);
                }
            } 
        }
    }
    return url;
}

public function validateStatus(http:Response registerResponse) returns boolean {
    var registerJsonPayload = registerResponse.getJsonPayload();
    io:println(registerJsonPayload);
    if (registerJsonPayload is json[]) {
        var node = registerJsonPayload[0];  
        var checks = node.Checks;
        if (checks is json[]) {
            var output = checks[0].Output;
            io:println(output);
            if (output is json) {
                io:println("--------------------------returning true---------------");
                return true;
            }
        }
    }
    return false;
}
