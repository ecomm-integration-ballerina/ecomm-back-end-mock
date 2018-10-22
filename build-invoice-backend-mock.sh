ballerina build invoice-backend-mock
docker build -t rajkumar/invoice-backend-mock:0.1.0 -f invoice-backend-mock/docker/Dockerfile .
docker push rajkumar/invoice-backend-mock:0.1.0
kubectl delete -f invoice-backend-mock/kubernetes/invoice_mock_deployment.yaml
kubectl apply -f invoice-backend-mock/kubernetes/invoice_mock_deployment.yaml