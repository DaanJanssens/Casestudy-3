import boto3
import os

ecs = boto3.client("ecs")
rds = boto3.client("rds")

def handler(event, context):
    cluster = os.environ["ECS_CLUSTER"]
    services = os.environ["ECS_SERVICES"].split(",")
    desired = int(os.environ.get("DESIRED_COUNT", "1"))
    rds_instances = os.environ.get("RDS_INSTANCES", "").split(",")

    for svc in services:
        print(f"Starting ECS service {svc} ...")
        ecs.update_service(
            cluster=cluster,
            service=svc,
            desiredCount= desired
        )

    for db in rds_instances:
        if db:
            print(f"Starting RDS instance {db} ...")
            rds.start_db_instance(DBInstanceIdentifier=db)

    
    return {"status": "started", "services": services, "rds": rds_instances}