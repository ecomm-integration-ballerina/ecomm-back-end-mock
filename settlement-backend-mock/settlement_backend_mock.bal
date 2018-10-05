import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/math;
import ballerina/io;

endpoint http:Listener paymentListener {
    port: 8286
};

@http:ServiceConfig {
    basePath: "/ecomm-backend/settlement"
}
service SapAPI bind paymentListener {

    @http:ResourceConfig { 
        methods:["POST"],
        path:"/"
    }
    addSettlement (endpoint outboundEp, http:Request req) {
        http:Response res = new;
        xml resp;
        if (math:randomInRange(1,5) == 1) {
            res.statusCode = 500;
            resp = xml `<soapenv:Envelope
                        xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                    <soapenv:Body>
                        <response>
                            <pcmss/>
                            <msg>Errored</msg>
                            <gty>S</gty>
                        </response>
                    </soapenv:Body>
                </soapenv:Envelope>`;
        } else {
            res.statusCode = 201;
            resp = xml `<soapenv:Envelope
                        xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                    <soapenv:Body>
                        <response>
                            <pcmss/>
                            <msg>Success, Total 2 Records are updated, Duplicated Record 1</msg>
                            <gty>S</gty>
                        </response>
                    </soapenv:Body>
                </soapenv:Envelope>`;            
        }

        res.setXmlPayload(resp, contentType= "application/xml");
        outboundEp->respond(res) but { error e => log:printError("Error while responding", err = e) };
    }   
}
