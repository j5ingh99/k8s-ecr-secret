#!/bin/bash

export KUBERNETES_SERVICE_PORT=443
export TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
export CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

aws configure set aws_access_key_id $ORIGIN_AWS_ID && aws configure set aws_secret_access_key $ORIGIN_AWS_KEY && aws configure set region $ORIGIN_AWS_REGION && aws configure set output $ORIGIN_AWS_OUTPUT

export ECR_TOKEN=$(aws ecr get-login-password --region $ORIGIN_AWS_REGION)
# echo ${TOKEN}


kubectl config set-cluster default-cluster --server=https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT} --certificate-authority=${CACERT}
kubectl config set-credentials default-credentials --token=${TOKEN}
kubectl config set-context default-context --cluster=default-cluster --user=default-credentials
kubectl config use-context default-context

kubectl delete secret --ignore-not-found $DOCKER_SECRET_NAME -n $NAMESPACE_NAME

kubectl create secret docker-registry $DOCKER_SECRET_NAME \
--docker-server=https://${ORIGIN_AWS_ACCOUNT}.dkr.ecr.${ORIGIN_AWS_REGION}.amazonaws.com \
--docker-username=AWS \
--docker-password=$ECR_TOKEN \
--namespace=$NAMESPACE_NAME \
--save-config

echo "Secret was successfully updated at $(date)"
