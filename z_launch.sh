kubectl apply -f deployments/secrets/databse-secret..yaml
kubectl apply -f deployments/analytics/db-configmap.yaml
sleep 10
kubectl apply -f deployments/analytics/analytics-api.yaml