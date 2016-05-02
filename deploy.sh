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
    task=$(aws ecs register-task-definition --cli-input-json file://task.json | $JQ '.taskDefinition.taskDefinitionArn')
    echo "New Task: $task"

    # Fix: update-service doesn't stop current task
    revision=$(echo $task | cut -d: -f7)
    prev_revision=$(($revision-1))

    prev_task="$(echo $task | cut -d: -f1-6):$prev_revision"
    
    echo "Stopping current task: $prev_task"
    aws ecs stop-task --task awesomeTask

    echo "Updating Service"
    aws ecs update-service --cluster $AWS_CLUSTER --service $AWS_SERVICE --task-definition $task

    echo "Updated! Let AWS do the rest"
}

deploy_image
update_service