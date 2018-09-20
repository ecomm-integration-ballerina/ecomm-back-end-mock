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

endpoint ftp:Client refundSFTPClient {
    protocol: ftp:SFTP,
    host: config:getAsString("ecomm-backend.refund.sftp.host"),
    port: config:getAsInt("ecomm-backend.refund.sftp.port"),
    secureSocket: {
        basicAuth: {
            username: config:getAsString("ecomm-backend.refund.sftp.username"),
            password: config:getAsString("ecomm-backend.refund.sftp.password")
        }
    }
};

function main(string... args) {

    (function() returns error?) onTriggerFunction = generateRefund;
    function(error) onErrorFunction = handleError;

    int interval = config:getAsInt("ecomm-backend.refund.etl.interval");
    int delay = config:getAsInt("ecomm-backend.refund.etl.initialDelay");

    timer = new task:Timer(onTriggerFunction, onErrorFunction,
        interval, delay = delay);

    timer.start();
    // temp hack to keep the process running
    runtime:sleep(20000000);
}

function generateRefund() returns error? {

    int refundId = math:randomInRange(1,10000);
    string refundName = "ZECOMM" + refundId;
    log:printInfo("Generating refund : " + refundName);

    xml refunds = xml `<ZECOMMCREDITMEMO>
            <IDOC BEGIN="1">
            </IDOC>
        </ZECOMMCREDITMEMO>`;

    xml refundHeader = xml `<EDI_DC40 SEGMENT="1">
            <TABNAM>EDI_DC40</TABNAM>
            <MANDT>301</MANDT>
            <DOCNUM>0000002516409006</DOCNUM>
            <DOCREL>740</DOCREL>
            <STATUS>30</STATUS>
            <DIRECT>1</DIRECT>
            <OUTMOD>2</OUTMOD>
            <IDOCTYP>ZMOTOCREDITMEMO</IDOCTYP>
            <MESTYP>ZCREDITMEMO</MESTYP>
            <SNDPOR>SAPECQ</SNDPOR>
            <SNDPRT>LS</SNDPRT>
            <SNDPRN>ECQCLNT301</SNDPRN>
            <RCVPOR>ZCREDTMEMO</RCVPOR>
            <RCVPRT>LS</RCVPRT>
            <RCVPRN>ZMOTO_ECOM</RCVPRN>
            <CREDAT>20180907</CREDAT>
            <CRETIM>094202</CRETIM>
            <SERIAL>20180907094202</SERIAL>
       </EDI_DC40>`;

    // add refund header
    refunds.selectDescendants("IDOC").setChildren(refundHeader);

    int numberOfRefunds = math:randomInRange(1,5);
    xml[] refundArray;
    foreach i in 1 ... numberOfRefunds {
        xml refund = xml `<ZECOMMCREDITMEMO SEGMENT="1">
                    <ZCMTYPE>CREDITMEMO</ZCMTYPE>
                    <ZBLCORD>{{math:randomInRange(1,1000000)}}</ZBLCORD>
                    <ZBLCITEM>1</ZBLCITEM>
                    <DMBTR>{{math:ceil(math:random()*100)}}</DMBTR>
                    <WAERK>USD</WAERK>
                    <AUBEL>{{math:randomInRange(1,1000000)}}</AUBEL>
                    <ZCMNO>{{math:randomInRange(1,1000000)}}</ZCMNO>
                    <AUGRU>MBG: Buyers remorse</AUGRU>
                    <LAND1>US</LAND1>
                    <ZTDMBTR>0.00</ZTDMBTR>
                    <QUANTITY>1.000</QUANTITY>
                    <TIMESTAMP>0</TIMESTAMP>
                    <ZRETID>{{math:randomInRange(1,1000000)}}</ZRETID>
                </ZECOMMCREDITMEMO>`;

        refundArray[i-1] = refund;
    }

    foreach refund in refundArray {
        xml children = refunds.selectDescendants("IDOC").* + refund;
        refunds.selectDescendants("IDOC").setChildren(children);
    }

    // uploading refunds to SFTP
    string refundAsString = <string> refunds;
    io:println(refundAsString);
    io:ByteChannel bchannel = io:createMemoryChannel(refundAsString.toByteArray("UTF-8"));
    string path = config:getAsString("ecomm-backend.refund.sftp.path") + "/original/" + refundName + ".xml";

    log:printInfo("Uploading refund : " + refundName + " to sftp");
    error? filePutErr = refundSFTPClient -> put(path, bchannel);

    return ();
}

function handleError(error e) {
    log:printError("Error in generating refund", err = e);
    timer.stop();
}
