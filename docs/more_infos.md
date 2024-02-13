# More Infos

This project showcases an api and database stack  deployed on a kubernetes cluster

## Project structure
  - analytics : API source code folder
  - db  : scripts to populate database
  - deployments : kubernetes deployments files
  - scripts: help scripts

## Project requirements
#### Local Environment
1. Python Environment - run Python 3.6+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster
4. `helm` - apply Helm Charts to a Kubernetes cluster
5. `kind` - to try kubernetes in local

#### Remote Resources
1. AWS CodeBuild - build Docker images remotely
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS - run applications in k8s
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code

### How to deploy the project

With a c


Using `kind`  you can try Kubernetes in local. First install kind and check the documentation

1- Create your cluster

```bash
kind create cluster --name <name_of_cluster>
```

To switch to this cluster , if it does not happen automatically, run :

```bash
kubectl config use-context <name_of_cluster>
```

2. Create a namespace (optional)

```bash
kubectl create ns your_name_space # mine is analytics, feel free to chose your own or just use the default one
```

if you dont create a namespace, everzthing will be done in the `default` name space,
and you can ignore all the `-n  <your_name_space>` instructions

3. Set Online secret store (can skip for the local part , intend for eks to get secrets from aws)

This store will alow us to access some aws secrets, create with secrets managers.

```bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver

helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws
```
4- Create all your secrets on AWS you can use  the console , or AWCLI (intented for eks)

The secret we used in this projet is named <b>secrets/analytics/db</b> on aws secrets managers  and  has the following structure:
```json
{
    "admin-password":"your_admin_password",
    "database": "your_database_name"
}
```

You can add other secrets if you want. Make sure your cluster has the permissions to access aws secrets .


5. Deploy the secrets and configmaps


```bash
kubectl apply -f deployments/analytics/db-configmap.yaml -n  <your_name_space>  #for non sensitives values
kubectl apply -f deployments/secrets/database-secret.yaml -n  <your_name_space>  #for local use only
kubectl apply -f deployments/secrets/secrets-provider-class.yaml -n  <your_name_space> # for secrets
```


####  Configure a Database
Set up a Postgres database using a Helm Chart.


1. Set up Bitnami Repo
```bash
helm repo add <REPO_NAME> https://charts.bitnami.com/bitnami
```


2- Create your volumes and persistence claims - not needed if you are working locally

```bash
kubectl apply -f deployments/db/db-volumes.yaml -n  <your_name_space>
```

3- Adjust the configuration of the database by tweaking [the configuration file](./deployments/db/values.yaml). Your can use [the reference included](./deployments/postgres-reference-values.yaml) for the postgres helm chart.

4. Install PostgreSQL Helm Chart

```bash
helm install <SERVICE_NAME> <REPO_NAME>/postgresql -f deployments/db/values.yaml -n  <your_name_space> # to install in your namespace
```

This should set up a Postgre deployment at `<SERVICE_NAME>-postgresql.<your_name_space>.svc.cluster.local` in your Kubernetes cluster. You can verify it by running `kubectl get svc`

By default, it will create a username `postgres`. The password can be retrieved with the following command:
```bash
export POSTGRES_PASSWORD=$(kubectl get secret --namespace <your_name_space> <SECRET_NAME_USED_FOR_SERVICE> -o jsonpath="{.data.postgres-password}" | base64 -d)

echo $POSTGRES_PASSWORD
```

It should be the same as the one defined in your secrets

<sup><sub>* The instructions are adapted from [Bitnami's PostgreSQL Helm Chart](https://artifacthub.io/packages/helm/bitnami/postgresql).</sub></sup>

5. Test Database Connection

The database is accessible within the cluster. This means that when you will have some issues connecting to it via your local environment. You can either connect to a pod that has access to the cluster _or_ connect remotely via [`Port Forwarding`](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

* Connecting Via Port Forwarding
```bash
kubectl port-forward --namespace <your_name_space> svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d <database_name> -p 5432
```

* Connecting Via a Pod
```bash
kubectl exec -it <POD_NAME> bash
PGPASSWORD="<PASSWORD HERE>" psql postgres://postgres@<SERVICE_NAME>:5432/<database_name> -c <COMMAND_HERE>
```

6. Run Seed Files
We will need to run the seed files in `db/` in order to create the tables and populate them with data.

```bash
kubectl port-forward --namespace your_name_space svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d <database_name> -p 5432 < your_sql_filename.sql
```

So the files are ./db/{1_create_tables.sql, 2_seed_users.sql,3_seed_tokens.sql}
You can use [this script](./z_database_helper.sh) for help

7. Deploy the app (more instructions at the bottom of the file )

in local just start the server by using [this script](./analytics/start-server.sh) after activating port forwarding

You can still deploy on local cluster if you want by running the follwowing commands

```bash

kubectl apply -f deployments/analytics/analytics-api-local.yaml -n  <your_name_space> # for the application
```

But before that , ou will first need to build a local docker image of the app . (maybe also push it on dockerhub in a repository)

```bash
docker build -t name_repository/app_name:tag ./analytics
#then
docker login
# enter credential

# then
docker push name_repository/app_name:tag
```

to make the image available in your local cluster , run :

```bash
 kind load docker-image name_repository/app_name:tag --name your_local_cluster_name

```

To check if everything is working , acrivate port forwarding for port 5000 too.

10: Check the status

The follwoing commands will help you check if everything went well

```bash
# to check the status of the helm chart deployed
heml list -n  <your_name_space>
helm status <SERVICE_NAME> -n  <your_name_space>


# to check the services
kubectl get svc  -n  <your_name_space> # for all services
#or

kubectl get svc <SERVICE_NAME> -n  <your_name_space> # for a particular service


# To check the deployments

kubectl get deployment -n  <your_name_space> # for the deployments
kubectl describe deployment <SERVICE_NAME> -n  <your_name_space>

# to check the pods

kubectl get pods -n  <your_name_space> # for the deployments
kubectl describe pod/<pod_id>  -n  <your_name_space> # decribe a specific pod
kubectl logs pod/<pod_id>  -n  <your_name_space>  # get the logs


```

### 2. Running  on EKS

####  Connect to your cluster on eks
```bash
aws eks --region us-east-1 update-kubeconfig --name your_eks_cluster_name

```


#### change the context

```bash
kubectl config use-context <name_of_eks_cluster>
```
#### Repeat same steps as in local , including the steps intended for eks.

Deploy all the pv, pvc , configmap and secrets before deploying the database.



In particular if you want to use secrets from aws
```bash
kubectl apply -f deployments/secrets/secrets-provider-class -n  <your_name_space>  #  for secrets stored in aws
```

#### Deploy the app

##### Application image

Upon pushing your code on github the image build should start. Check its completed correctly and make sure is the same used in your stack


##### Deploy


```bash

#to use the simple secrets
kubectl apply -f deployments/analytics/analytics-api-eks.yaml -n  <your_name_space>

# to use aws secrets
kubectl apply -f deployments/analytics/analytics-api-eks-aws.yaml -n  <your_name_space>
```


#### To update your deployments

```bash
# to change the app image
kubectl set image deployment/my-deployment my-container=my-image:tag


# to scale
kubectl scale deployment <deployment-name> --replicas=<num-replicas>

# for others things, modify the deployment file and...
kubectl apply -f deployment.yaml
