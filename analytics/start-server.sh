#only for local test

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default eks-db-secrets -o jsonpath="{.data.postgres-password}" | base64 -d)
DB_USERNAME=postgres DB_PASSWORD="password"   python app.py python app.py
