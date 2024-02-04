# Microservice  on Kubernetes

This project showcases an api and database stack  deployed on a kubernetes cluster. The database is deployed with a helm chart

## Project structure
  - analytics : API source code folder
  - db  : scripts to populate database
  - deployments : kubernetes deployments files
  - scripts: help scripts

## Project requirements
### Local Environment
1. Python Environment - run Python 3.6+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster
4. `helm` - apply Helm Charts to a Kubernetes cluster
5. `kind` - to try kubernetes in local (optional)

### Remote Resources
1. AWS CodeBuild & AWS Code Pipeline - build Docker images remotely and push it on AWS ECR
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code

## How to use the project

Push your code to github and check that that the image was build and pushed to ecr, then deploy it on Kubernetes

## How to deploy the project

First connect to your cluster

```bash
aws eks --region us-east-1 update-kubeconfig --name your_eks_cluster_name

```

1. Deploy the secrets

```bash
    kubectl apply -f deployments/secrets/database-secret.yaml
    kubectl apply -f deployments/secrets/db-configmap.yaml
```
2. Deploy the database with helm

```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    kubectl apply -f deployments/db/db-volumes.yaml
    helm install analytics-db bitnami/postgresql -f deployments/db/values.yaml

```
3. Populate the database

```bash
chmod u+x ./scripts/database_helper.sh
./scripts/database_helper.sh
```

4. Deploy the API

The api container needs the following variables:
* `DB_USERNAME`
* `DB_PASSWORD`
* `DB_HOST` (defaults to `127.0.0.1`)
* `DB_PORT` (defaults to `5432`)
* `DB_NAME` (defaults to `postgres`)

To use custom secret defined in [database-secret.yaml](./deployments/secrets/database-secret.yaml)

```bash
    helm install analytics-api  -f deployments/analytics/analytics-api.yaml
```
To load secrets from Aws secret managers instead. Update the [secrets-provider-class.yaml](./deployments/secrets/secrets-provider-class.yaml) to match your secrets

```bash
    helm install analytics-api  -f deployments/analytics/analytics-api-aws.yaml
```

5. Check the deployements status with the follwowinfg commands



```bash
helm status <service_name>
kubectl get svc
kubectl get pods
kubectl get svc  <service_name>
kubectl get deployment  <deployment_name>
```

6. To cleanup

To remove everything
```bash
./scripts/cleanup.sh
```

Don't forget to remove the infratructure on Aws to avoid unwanted costs


## Try everything in local

```
kind create cluster --name your_cluster_name
```

Apply same previous steps and have fun !!!


## License


This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.
