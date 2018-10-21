ballerina build order-signal-backend-mock
docker build -t rajkumar/order-signal-backend-mock:0.1.0 -f order-signal-backend-mock/docker/Dockerfile .
docker push rajkumar/order-signal-backend-mock:0.1.0
kubectl delete -f order-signal-backend-mock/kubernetes/order_signal_backend_mock_deployment.yaml
kubectl apply -f order-signal-backend-mock/kubernetes/order_signal_backend_mock_deployment.yaml