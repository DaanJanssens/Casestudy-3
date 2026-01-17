import boto3
import os

# Create AWS clients for ECS and RDS
ecs = boto3.client("ecs")
rds = boto3.client("rds")

def handler(event, context):
    # Read the ECS cluster name from an environment variable
    cluster = os.environ["ECS_CLUSTER"]

    # Read the ECS services to stop (comma-separated list)
    services = os.environ["ECS_SERVICES"].split(",")

    # Read RDS instance identifiers (comma-separated list, optional)
    rds_instances = os.environ.get("RDS_INSTANCES", "").split(",")

    # Scale ECS services down to zero running tasks
    for svc in services:
        print(f"Stopping ECS service {svc} ...")
        ecs.update_service(
            cluster=cluster,
            service=svc,
            desiredCount=0
        )

    # Stop each specified RDS instance
    for db in rds_instances:
        if db:  # Skip empty values
            print(f"Stopping RDS instance {db} ...")
            rds.stop_db_instance(DBInstanceIdentifier=db)

    # Return a summary of stopped resources
    return {
        "status": "stopped",
        "services": services,
        "rds": rds_instances
    }