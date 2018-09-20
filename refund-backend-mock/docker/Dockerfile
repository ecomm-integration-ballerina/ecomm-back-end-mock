FROM ballerina/ballerina:0.981.1
LABEL maintainer="rajkumarr@wso2.com"

COPY target/refund.balx /home/ballerina
COPY refund/conf/ballerina.conf /home/ballerina

COPY refund/dependencies/packages/dependencies/* /ballerina/runtime/bre/lib/
COPY refund/dependencies/packages/balo/* /ballerina/runtime/lib/repo/

CMD ballerina run refund.balx