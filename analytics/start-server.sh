#only for local test

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default uda-postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
DB_USERNAME=postgres DB_PASSWORD="$POSTGRES_PASSWORD"   python app.py python app.py