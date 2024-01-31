##Locally i used this values , changed them to fit yours

NAMESPACE=default
DATABASE_NAME=postgres
DATABASE_SERVICE=analytics-db-postgresql
DATABASE_SECRET_NAME=eks-db-secrets  # the secret name you are using to store database credentials
PODNAME=$DATABASE_SERVICE-0


###### COMMENT AND UNCOMMENT THE COMMANDS AS YOU NEED THEM


# to export Password
# here admin-password in {.data.admin-password} represents the key declared in your secret to access the password
# change it accordinly
export POSTGRES_PASSWORD=$(kubectl get secret --namespace $NAMESPACE $DATABASE_SECRET_NAME -o jsonpath="{.data.admin-password}" | base64 -d)
echo "$POSTGRES_PASSWORD"



###  To populate the database you can run this lines
### keep in mind that the username postgres, is the one used by default . Adapt the code if you chose to use anothe another name

## copy script to pod
kubectl cp ./db/1_create_tables.sql $NAMESPACE/$PODNAME:/tmp/1_create_tables.sql
kubectl cp ./db/2_seed_users.sql $NAMESPACE/$PODNAME:/tmp/2_seed_users.sql
kubectl cp ./db/3_seed_tokens.sql $NAMESPACE/$PODNAME:/tmp/3_seed_tokens.sql

# #### Populate database

PGPASSWORD="$POSTGRES_PASSWORD" kubectl exec -it -n $NAMESPACE $PODNAME -- psql  -U postgres -d $DATABASE_NAME -p 5432  -f /tmp/1_create_tables.sql
PGPASSWORD="$POSTGRES_PASSWORD" kubectl exec -it -n $NAMESPACE $PODNAME -- psql  -U postgres -d $DATABASE_NAME -p 5432  -f /tmp/2_seed_users.sql
PGPASSWORD="$POSTGRES_PASSWORD" kubectl exec -it -n $NAMESPACE $PODNAME -- psql  -U postgres -d $DATABASE_NAME -p 5432  -f /tmp/3_seed_tokens.sql




# to connect from outside the cluster - port fowarding
# kubectl port-forward --namespace $NAMESPACE svc/analytics-db-postgresql 5432:5432



# # to connect to cluster
# kubectl run db-postgresql-client \
#         --rm --tty -i --restart='Never' \
#         --namespace $NAMESPACE\
#         --image docker.io/bitnami/postgresql:16.1.0-debian-11-r22 \
#         --env="PGPASSWORD=$POSTGRES_PASSWORD" \
#         --command -- psql --host $DATABASE_SERVICE -U postgres -d $DATABASE_NAME -p 5432
