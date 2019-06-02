#!/bin/bash
read -p "please Enter your Task_Family" TASK_FAMILY

if [ -z "$TASK_FAMILY" ]; then
   echo "exit: No Task Family specified"
   exit;
fi

read -p "please Enter the service name you want to update" SERVICE_NAME
if [ -z "$SERVICE_NAME" ]; then
   echo "exit: No Service Name specified"
   exit;
fi

read -p "Enter your new Docker Image with tags please" NEW_DOCKER_IMAGE
if [ -z "$NEW_DOCKER_IMAGE" ]; then
   echo "exit: No Docker Image Specified "
   exit;
fi


read -p "please Enter your cluster name" CLUSTER_NAME
if [ -z "$CLUSTER_NAME" ]; then
   echo "exit: No Cluster Name Specified "
   exit;
fi


OLD_TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --output json)
NEW_TASK_DEF=$(echo $OLD_TASK_DEF | jq --arg NDI $NEW_DOCKER_IMAGE '.taskDefinition.containerDefinitions[0].image=$NDI')
FINAL_TASK=$(echo $NEW_TASK_DEF | jq '.taskDefinition|{family: .family, volumes: .volumes, containerDefinitions: .containerDefinitions}')
aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json "$(echo $FINAL_TASK)"
aws ecs update-service --service $SERVICE_NAME --task-definition $TASK_FAMILY --cluster $CLUSTER_NAME
