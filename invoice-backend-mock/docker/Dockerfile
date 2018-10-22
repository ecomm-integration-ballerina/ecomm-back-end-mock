FROM ballerina/ballerina:0.982.0
LABEL maintainer="rajkumarr@wso2.com"

COPY target/invoice-backend-mock.balx /home/ballerina
COPY invoice-backend-mock/conf/ballerina.conf /home/ballerina

COPY invoice-backend-mock/dependencies/packages/dependencies/* /ballerina/runtime/bre/lib/
COPY invoice-backend-mock/dependencies/packages/balo/* /ballerina/runtime/lib/repo/

CMD ballerina run invoice-backend-mock.balx