#!/usr/bin/env bash

set -e
set -u
set -o pipefail

JQ="jq --raw-output --exit-status"

deploy_image() {
    echo "#### Deploying image"
    echo "# Login"
    eval "$(aws ecr get-login --region eu-west-1)"
    echo "# Building"
    docker build -t awesome .
    echo "# Tagging"
    docker tag awesome:latest 567141585396.dkr.ecr.eu-west-1.amazonaws.com/awesome:latest
    echo "# Pushing"
    docker push 567141585396.dkr.ecr.eu-west-1.amazonaws.com/awesome:latest
    echo "Image deployed!"
}

update_service() {
    echo "Creating new task/revision"
    $task = $(aws ecs register-task-definition --cli-input-json file://task.json | $JQ '.taskDefinition.taskDefinitionArn')

    echo "Updating Service"
    aws ecs update-service --cluster $AWS_CLUSTER --service $AWS_SERVICE --task-definition $task

    echo "Updated! Let AWS do the rest"
}

deploy_image
update_service