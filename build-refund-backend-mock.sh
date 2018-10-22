ballerina build refund-backend-mock
docker build -t rajkumar/refund-backend-mock:0.1.0 -f refund-backend-mock/docker/Dockerfile .
docker push rajkumar/refund-backend-mock:0.1.0
kubectl delete -f refund-backend-mock/kubernetes/refund_mock_deployment.yaml
kubectl apply -f refund-backend-mock/kubernetes/refund_mock_deployment.yaml