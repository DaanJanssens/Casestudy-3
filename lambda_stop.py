import boto3
import os

ecs = boto3.client("ecs")
rds= boto3.client("rds")

def handler(event, context):
    cluster = os.environ["ECS_CLUSTER"]
    services = os.environ["ECS_SERVICES"].split(",")
    rds_instances = os.environ.get("RDS_INSTANCES", "").split(",")

    for svc in services:
        print(f"Stopping ECS service {svc} ...")
        ecs.update_service(
            cluster=cluster,
            service=svc,
            desiredCount=0
        )

    for db in rds_instances:
        if db:
            print(f"Stoppinmg RDS instance {db} ...")
            rds.stop_db_instance(DBInstanceIdentifier=db)

    return {"status": "stopped", "services": services, "rds": rds_instances}