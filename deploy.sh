#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

JQ="jq --raw-output --exit-status"
tag=$(date "+%Y-%m-%d_%H%M%S")
# Branch must be defined outside
branch="master"

deploy_image() {
    echo "#### Deploying image"
    echo "# Working on branch $branch"
    echo "# Login"
    eval "$(aws ecr get-login --region eu-west-1)"
    echo "# Building"
    # Pull to avoid re-build chached
    docker pull 567141585396.dkr.ecr.eu-west-1.amazonaws.com/awesome:$branch
    docker build -t awesome .
    echo "# Tagging"
    docker tag awesome 567141585396.dkr.ecr.eu-west-1.amazonaws.com/awesome:$tag
    docker tag awesome 567141585396.dkr.ecr.eu-west-1.amazonaws.com/awesome:$branch
    echo "# Pushing"
    docker push 567141585396.dkr.ecr.eu-west-1.amazonaws.com/awesome:$tag
    docker push 567141585396.dkr.ecr.eu-west-1.amazonaws.com/awesome:$branch
    echo "Image deployed!"
}

update_service() {
    # The best option is update-stack because allow rollback if deployment fails

    echo "Updating Task definition"
    sed s/_TAG_/$tag/g task.json > task2.json

    echo "Creating new task/revision"
    task=$(aws ecs register-task-definition --cli-input-json file://task2.json | $JQ '.taskDefinition.taskDefinitionArn')
    echo "New Task: $task"

    echo "Updating Service"
    aws ecs update-service --cluster $AWS_CLUSTER --service $AWS_SERVICE --task-definition $task

    echo "Updated! Let AWS do the rest"
}

deploy_image
update_service