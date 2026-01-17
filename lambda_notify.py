import json
import boto3
import os
#Creates SNS client
sns = boto3.client('sns')

#Read the SNS Topic ARN 
TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def handler(event, context):
    #logs incomming events
    print("Event:", json.dumps(event))

    #Gets the "detail" section of the ECS event
    detail = event.get("detail", {})

    #Get thes ECS task status
    last_status = detail.get("lastStatus")
    desired_status = detail.get("desiredStatus")
    task_arn = detail.get("taskArn")
    cluster_arn = detail.get("clusterArn")

    #Builds message of the SNS
    message = f"""
ECS Tast State Change:

Cluster: {cluster_arn}
Task: {task_arn}
Last Status: {last_status}
Desired Status: {desired_status}

Task has stopped or is deprovisioning.
"""
    #Sends out the message using SNS
    sns.publish(
        TopicArn=TOPIC_ARN,
        Subject="ECS Task Stopped Alert",
        Message=message
    )

    return {"status": "sent"}