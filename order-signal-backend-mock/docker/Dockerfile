FROM ballerina/ballerina:0.982.0
LABEL maintainer="rajkumarr@wso2.com"

COPY target/order-signal-backend-mock.balx /home/ballerina
COPY order-signal-backend-mock/conf/ballerina.conf /home/ballerina

COPY order-signal-backend-mock/dependencies/packages/dependencies/* /ballerina/runtime/bre/lib/
COPY order-signal-backend-mock/dependencies/packages/balo/* /ballerina/runtime/lib/repo/

EXPOSE 8280

CMD ballerina run order-signal-backend-mock.balx