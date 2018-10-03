FROM ballerina/ballerina:0.981.1
LABEL maintainer="rajkumarr@wso2.com"

COPY target/refund-backend-mock.balx /home/ballerina
COPY refund-backend-mock/conf/ballerina.conf /home/ballerina

COPY refund-backend-mock/dependencies/packages/dependencies/* /ballerina/runtime/bre/lib/
COPY refund-backend-mock/dependencies/packages/balo/* /ballerina/runtime/lib/repo/

CMD ballerina run refund-backend-mock.balx