ballerina build order-backend-mock
docker build -t rajkumar/order-backend-mock:0.1.0 -f order-backend-mock/docker/Dockerfile .
docker push rajkumar/order-backend-mock:0.1.0
kubectl delete -f order-backend-mock/kubernetes/order_backend_mock_deployment.yaml
kubectl create -f order-backend-mock/kubernetes/order_backend_mock_deployment.yaml
kubectl create -f order-backend-mock/kubernetes/order_backend_mock_svc.yaml