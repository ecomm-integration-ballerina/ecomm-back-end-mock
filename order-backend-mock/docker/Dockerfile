FROM ballerina/ballerina:0.982.0
LABEL maintainer="rajkumarr@wso2.com"

COPY target/order-backend-mock.balx /home/ballerina
COPY order-backend-mock/conf/ballerina.conf /home/ballerina

EXPOSE 8280

CMD ballerina run order-backend-mock.balx