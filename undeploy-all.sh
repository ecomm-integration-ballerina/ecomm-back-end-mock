kubectl delete -f invoice-backend-mock/kubernetes/invoice_mock_deployment.yaml
kubectl delete -f order-backend-mock/kubernetes/order_backend_mock_deployment.yaml
kubectl delete -f order-signal-backend-mock/kubernetes/order_signal_backend_mock_deployment.yaml
kubectl delete -f settlement-backend-mock/kubernetes/settlement_backend_mock_deployment.yaml