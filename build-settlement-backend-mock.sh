ballerina build settlement-backend-mock
docker build -t rajkumar/settlement-backend-mock:0.1.0 -f settlement-backend-mock/docker/Dockerfile .
docker push rajkumar/settlement-backend-mock:0.1.0
kubectl delete -f settlement-backend-mock/kubernetes/settlement_backend_mock_deployment.yaml
kubectl apply -f settlement-backend-mock/kubernetes/settlement_backend_mock_deployment.yaml