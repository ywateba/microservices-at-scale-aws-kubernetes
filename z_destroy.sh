NAMESPACE=default
PODNAME=analytics-db-postgresql-0
SERVICE_NAME=analytics-api



kubectl delete deployment  $SERVICE_NAME  -n $NAMESPACE
kubectl delete service $SERVICE_NAME  -n $NAMESPACE
kubectl delete configmap db-env  -n $NAMESPACE
kubectl delete secret eks-db-secrets -n $NAMESPACE
kubectl delete pv postgres-volume -n $NAMESPACE
kubectl delete pvc postgres-pv-claim  -n $NAMESPACE
