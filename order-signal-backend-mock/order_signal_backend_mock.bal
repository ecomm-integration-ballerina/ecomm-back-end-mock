import wso2/ftp;
import ballerina/io;
import ballerina/task;
import ballerina/math;
import ballerina/runtime;
import ballerina/log;
import ballerina/http;
import ballerina/config;

int count;
task:Timer? timer;

string[] signals = ["OPEN", "MAKE", "NOT_SHIPPE", "SHIPPED"];

endpoint ftp:Client orderSignalSFTPClient {
    protocol: ftp:SFTP,
    host: config:getAsString("ecomm_backend.order_signal.sftp.host"),
    port: config:getAsInt("ecomm_backend.order_signal.sftp.port"),
    secureSocket: {
        basicAuth: {
            username: config:getAsString("ecomm_backend.order_signal.sftp.username"),
            password: config:getAsString("ecomm_backend.order_signal.sftp.password")
        }
    }
};

public function main(string... args) {

    (function() returns error?) onTriggerFunction = generateOrderSignal;
    function(error) onErrorFunction = handleError;

    int interval = config:getAsInt("ecomm_backend.order_signal.etl.interval");
    int delay = config:getAsInt("ecomm_backend.order_signal.etl.initialDelay");

    timer = new task:Timer(onTriggerFunction, onErrorFunction,
        interval, delay = delay);

    timer.start();
    // temp hack to keep the process running
    runtime:sleep(20000000);
}

function generateOrderSignal() returns error? {

    int orderSignalId = math:randomInRange(1,10000);
    string orderSignalName = "ZECOMMSTAT" + orderSignalId;
    log:printInfo("Generating order-signal : " + orderSignalName);

    string signal = signals[math:randomInRange(0,3)];

    xml orderSignals = xml `<ZECOMMSTAT>
            <IDOC BEGIN="1">
            </IDOC>
        </ZECOMMSTAT>`;

    xml orderSignalHeader = xml `<EDI_DC40 SEGMENT="1">
            <TABNAM>EDI_DC40</TABNAM>
            <MANDT>301</MANDT>
            <DOCNUM>23232323232</DOCNUM>
            <DOCREL>740</DOCREL>
            <STATUS>30</STATUS>
            <DIRECT>1</DIRECT>
            <OUTMOD>2</OUTMOD>
            <IDOCTYP>ZECOMMSTAT</IDOCTYP>
            <MESTYP>ZECOMMSTAT</MESTYP>
            <SNDPOR>DEST</SNDPOR>
            <SNDPRT>LS</SNDPRT>
            <SNDPRN>SDSSSD</SNDPRN>
            <RCVPOR>WSO2_ZECOMM</RCVPOR>
            <RCVPRT>LS</RCVPRT>
            <RCVPRN>ZZECOMM_ECOM</RCVPRN>
            <CREDAT>20101005</CREDAT>
            <CRETIM>132501</CRETIM>
            <SERIAL>232323232323</SERIAL>
            <ARCKEY>urn:uuid:E71B9F5D549232323233191</ARCKEY>
        </EDI_DC40>`;

    // add orderSignal header
    orderSignals.selectDescendants("IDOC").setChildren(orderSignalHeader);

    xml orderDataHeader = xml `<ZECOMMEDK01 SEGMENT="1">
            <ZCONID>27b032daba6f8d645b35db07b2abaf64</ZCONID>
            <BELNR>ballerina-{{math:randomInRange(1,1000)}}</BELNR>
            <ZDATE>20181005T033457</ZDATE>
            <OBELNR>ballerina-{{math:randomInRange(1,1000)}}</OBELNR>
            <CURCY>USD</CURCY>
            <ZORDST>COMPLETED</ZORDST>
            <ZSHIPST>{{signal}}</ZSHIPST>
            <ZMFGSO>4218076063</ZMFGSO>
            <ZMFGCU>MBGB2CUSEB</ZMFGCU>
        </ZECOMMEDK01>`;

    int numberOfLineItems = math:randomInRange(1,3);
    xml[] productLineItemArray;
    xml[] shipmentArray;
    foreach i in 1 ... numberOfLineItems {

        xml productLineItem = xml `<ZECOMMEDP01 SEGMENT="1">
                <ZTEXT>NULL</ZTEXT>
                <ZTAXR>0</ZTAXR>
                <ZPNAME>NULL</ZPNAME>
                <ZQTY>0</ZQTY>
                <ZSHIPID>1</ZSHIPID>
                <ZSMETHOD>UPB</ZSMETHOD>
                <ZCARRIER>UPS</ZCARRIER>
                <ZTRACKNO>{{math:randomInRange(1,1000000)}}</ZTRACKNO>
                <ZSHIPDATE>20181005T110121</ZSHIPDATE>
                <ZSHIPQTY>1.000</ZSHIPQTY>
                <ZPDBID>Null</ZPDBID>
                <ZPROID>01110NARTL</ZPROID>
                <ZSSD>Null</ZSSD>
                <ZLINENO>    0</ZLINENO>
                <ZSHIPST>{{signal}}</ZSHIPST>
            </ZECOMMEDP01>`;

        productLineItemArray[i-1] = productLineItem;

        xml shipment = xml `<ZECOMMEDK02 SEGMENT="1">
            <ZSHIPID>1</ZSHIPID>
            <ZORDST>{{signal}}</ZORDST>
            <ZSHIPST>{{signal}}</ZSHIPST>
            <ZSMETHOD>UPB</ZSMETHOD>
            <ZTRACKNO>{{math:randomInRange(1,1000000)}}</ZTRACKNO>
            <ZCARRIER>UPS</ZCARRIER>
            <ZSHIPDATE>20181005T110121</ZSHIPDATE>
            <ZSSD>Null</ZSSD>
            <ZSPDELAY>Null</ZSPDELAY>
        </ZECOMMEDK02>`;

        shipmentArray[i-1] = shipment;      
    }

    foreach productLineItem in productLineItemArray {
        xml children = orderDataHeader.* + productLineItem;
        orderDataHeader.setChildren(children);
    }

    foreach shipment in shipmentArray {
        xml children = orderDataHeader.* + shipment;
        orderDataHeader.setChildren(children);
    }

    xml children = orderSignals.selectDescendants("IDOC").* + orderDataHeader;
    orderSignals.selectDescendants("IDOC").setChildren(children);
    
    // uploading order-signal to SFTP
    string orderSignalAsString = <string> orderSignals;
    io:ByteChannel bchannel = io:createMemoryChannel(orderSignalAsString.toByteArray("UTF-8"));
    string path = config:getAsString("ecomm_backend.order_signal.sftp.path") + "/original/" + orderSignalName + ".xml";

    log:printInfo("Uploading order-signal : " + orderSignalName + " to sftp");
    error? filePutErr = orderSignalSFTPClient -> put(path, bchannel);

    match filePutErr {
        error err => {
            log:printError("Error while uploading order-signal : " + orderSignalName 
                + " from orderSignalSFTPClient : " + err.message, err = err);
        }
        () => {
            log:printInfo("Uploaded order-signal : " + orderSignalName + " to sftp");           
        }
    }

    return ();
}

function handleError(error e) {
    log:printError("Error in generating order-signal", err = e);
    timer.stop();
}
