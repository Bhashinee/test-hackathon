import ballerina/io;
import ballerina/http;
import ballerina/grpc;

int port = 8080;
string consuleApi = "http://localhost:8500/v1";
service backend on new http:Listener(port) {
    @http:ResourceConfig {
        path: "/api"
    }
    resource function backendApi(http:Caller caller, http:Request request) {
        var response = caller->respond("Hello World");
        if (response is error) {
            io:println("error occured while responding");
        }
    }

    @http:ResourceConfig {
        path: "/deployInConsule"
    }
    resource function deployInConsule(http:Caller caller, http:Request request) {
        http:Client consuleClient = new (consuleApi + "/agent/service/register");
        json registerPayload = {"ID": "bal12", "Name": "ballerina2", "tags": ["balService"], "port": port };
        var response = consuleClient->put("", registerPayload);
        if (response is http:Response) {
            if (response.statusCode == 200) {
                var result = caller->respond("success");
            }
        }
    }
}