import boto3
import os

# Create AWS clients for ECS and RDS
ecs = boto3.client("ecs")
rds = boto3.client("rds")

def handler(event, context):
    # Read the ECS cluster name from an environment variable
    cluster = os.environ["ECS_CLUSTER"]

    # Read the ECS services to start (comma-separated list)
    services = os.environ["ECS_SERVICES"].split(",")

    # Desired number of running tasks per service (default: 1)
    desired = int(os.environ.get("DESIRED_COUNT", "1"))

    # Read RDS instance identifiers (comma-separated list, optional)
    rds_instances = os.environ.get("RDS_INSTANCES", "").split(",")

    # Scale ECS services up to the desired task count
    for svc in services:
        print(f"Starting ECS service {svc} ...")
        ecs.update_service(
            cluster=cluster,
            service=svc,
            desiredCount=desired
        )

    # Start each specified RDS instance
    for db in rds_instances:
        if db:  # Skip empty values
            print(f"Starting RDS instance {db} ...")
            rds.start_db_instance(DBInstanceIdentifier=db)

    # Return a summary of started resources
    return {
        "status": "started",
        "services": services,
        "rds": rds_instances
    }