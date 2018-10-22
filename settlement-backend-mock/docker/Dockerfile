FROM ballerina/ballerina:0.982.0
LABEL maintainer="rajkumarr@wso2.com"

COPY target/settlement-backend-mock.balx /home/ballerina
COPY settlement-backend-mock/conf/ballerina.conf /home/ballerina

EXPOSE 8280

CMD ballerina run settlement-backend-mock.balx