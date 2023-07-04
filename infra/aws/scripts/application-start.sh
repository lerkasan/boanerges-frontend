#!/bin/bash
set -xe

APPLICATION_NAME="boanerges"
DEPLOYMENT_GROUP_NAME="production"

REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

DEPLOYMENT_ID=$(aws deploy list-deployments --application-name $APPLICATION_NAME --deployment-group-name $DEPLOYMENT_GROUP_NAME --region $REGION --include-only-statuses "InProgress" --query "deployments[0]" --output text --no-paginate)

COMMIT_SHA=$(aws deploy get-deployment --region $REGION --deployment-id $DEPLOYMENT_ID --query "deploymentInfo.revision.gitHubLocation.commitId" --output text)
REPOSITORY=$(aws deploy get-deployment --region $REGION --deployment-id $DEPLOYMENT_ID --query "deploymentInfo.revision.gitHubLocation.repository" --output text)

GITHUB_TOKEN=$(aws ssm get-parameter --region $REGION --name GITHUB_TOKEN --with-decryption --query Parameter.Value --output text)

DB_HOST=$(aws ssm get-parameter --region $REGION --name ${APPLICATION_NAME}_database_host --with-decryption --query Parameter.Value --output text)
DB_NAME=$(aws ssm get-parameter --region $REGION --name ${APPLICATION_NAME}_database_name --with-decryption --query Parameter.Value --output text)
DB_USERNAME=$(aws ssm get-parameter --region $REGION --name ${APPLICATION_NAME}_database_username --with-decryption --query Parameter.Value --output text)
DB_PASSWORD=$(aws ssm get-parameter --region $REGION --name ${APPLICATION_NAME}_database_password --with-decryption --query Parameter.Value --output text)

FRONTEND_TAG=$([ $REPOSITORY == "lerkasan/boanerges-frontend" ] && echo "sha-$COMMIT_SHA" || echo "latest")
BACKEND_TAG=$([ $REPOSITORY == "lerkasan/boanerges-backend" ] && echo "sha-$COMMIT_SHA" || echo "latest")

export DB_HOST=$DB_HOST
export DB_NAME=$DB_NAME
export DB_USERNAME=$DB_USERNAME
export DB_PASSWORD=$DB_PASSWORD
export FRONTEND_TAG=$FRONTEND_TAG
export BACKEND_TAG=$BACKEND_TAG

echo $GITHUB_TOKEN | docker login ghcr.io -u lerkasan --password-stdin

cd /home/ubuntu/app

docker compose up -d
