#!/bin/bash
set -xe

APPLICATION_NAME="boanerges"
DEPLOYMENT_GROUP_NAME="production"

REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

DEPLOYMENT_ID=$(aws deploy list-deployments --application-name $APPLICATION_NAME --deployment-group-name $DEPLOYMENT_GROUP_NAME --region $REGION --include-only-statuses "InProgress" --query "deployments[0]" --output text --no-paginate)

GITHUB_TOKEN=$(aws ssm get-parameter --region $REGION --name GITHUB_TOKEN --with-decryption --query Parameter.Value --output text)
COMMIT_SHA=$(aws deploy get-deployment --deployment-id $DEPLOYMENT_ID --query "deploymentInfo.revision.gitHubLocation.commitId" --output text)
REPOSITORY=$(aws deploy get-deployment --deployment-id $DEPLOYMENT_ID --query "deploymentInfo.revision.gitHubLocation.repository" --output text)

FRONTEND_TAG=$([ $REPOSITORY == "lerkasan/boanerges-frontend" ] && echo "sha-$COMMIT_SHA" || echo "latest")
BACKEND_TAG=$([ $REPOSITORY == "lerkasan/boanerges-backend" ] && echo "sha-$COMMIT_SHA" || echo "latest")

export FRONTEND_TAG=$FRONTEND_TAG
export BACKEND_TAG=$BACKEND_TAG

echo $GITHUB_TOKEN | docker login ghcr.io -u lerkasan --password-stdin

cd /home/ubuntu/app

docker compose pull