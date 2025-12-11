import json
import boto3
import os

sns = boto3.client('sns')

TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def handler(event, context):
    print("Event:", json.dumps(event))

    detail = event.get("detail", {})
    last_status = detail.get("lastStatus")
    desired_status = detail.get("desiredStatus")
    task_arn = detail.get("taskArn")
    cluster_arn = detail.get("clusterArn")

    message = f"""
ECS Tast State Change:

Cluster: {cluster_arn}
Task: {task_arn}
Last Status: {last_status}
Desired Status: {desired_status}

Task has stopped or is deprovisioning.
"""
    
    sns.publish(
        TopicArn=TOPIC_ARN,
        Subject="ECS Task Stopped Alert",
        Message=message
    )

    return {"status": "sent"}