resource "aws_cloudwatch_dashboard" "fargate_dashboard" {
  dashboard_name = "fargate-fargate-instances"

  dashboard_body = jsonencode({
    widgets = [

      {
        "type" : "metric",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Fargate CPU Utilization",
          "view" : "timeSeries",
          "region" : "eu-central-1",
          "metrics" : [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              "faregate-cluster",
              "ServiceName",
              "innovatech_web_service"
            ]
          ],
          "stat" : "Average",
          "period" : 60
        }
      },

      {
        "type" : "metric",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Fargate Memory Utilization",
          "view" : "timeSeries",
          "region" : "eu-central-1",
          "metrics" : [
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ClusterName",
              "faregate-cluster",
              "ServiceName",
              "innovatech_web_service"
            ]
          ],
          "stat" : "Average",
          "period" : 60
        }
      },

      {
        "type" : "metric",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Fargate Network (Rx / Tx)",
          "view" : "timeSeries",
          "region" : "eu-central-1",
          "metrics" : [
            [
              "AWS/ECS",
              "NetworkRxBytes",
              "ClusterName",
              "faregate-cluster",
              "ServiceName",
              "innovatech_web_service"
            ],
            [
              "AWS/ECS",
              "NetworkTxBytes",
              "ClusterName",
              "faregate-cluster",
              "ServiceName",
              "innovatech_web_service"
            ]
          ],
          "stat" : "Sum",
          "period" : 60
        }
      },

      {
        "type" : "metric",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Fargate Running Task Count",
          "view" : "timeSeries",
          "region" : "eu-central-1",
          "metrics" : [
            [
              "AWS/ECS",
              "RunningTaskCount",
              "ClusterName",
              "faregate-cluster",
              "ServiceName",
              "innovatech_web_service"
            ]
          ],
          "stat" : "Average",
          "period" : 60
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "rds_dashboard" {
  dashboard_name = "rds-hrappdb-dashboard"

  dashboard_body = jsonencode({
    widgets = [

      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "RDS CPU Utilization",
          "metrics" : [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "hrappdb"]
          ],
          "stat" : "Average",
          "period" : 60,
          "region" : "eu-central-1"
        }
      },


      {
        "type" : "metric",
        "x" : 12,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Free Storage Space",
          "metrics" : [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "hrappdb"]
          ],
          "stat" : "Average",
          "period" : 300,
          "region" : "eu-central-1"
        }
      },


      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Freeable Memory",
          "metrics" : [
            ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "hrappdb"]
          ],
          "stat" : "Average",
          "period" : 300,
          "region" : "eu-central-1"
        }
      },


      {
        "type" : "metric",
        "x" : 12,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Database Connections",
          "metrics" : [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "hrappdb"]
          ],
          "stat" : "Average",
          "period" : 60,
          "region" : "eu-central-1"
        }
      },


      {
        "type" : "metric",
        "x" : 0,
        "y" : 18,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Network Throughput (Receive / Transmit)",
          "metrics" : [
            ["AWS/RDS", "NetworkReceiveThroughput", "DBInstanceIdentifier", "hrappdb"],
            ["AWS/RDS", "NetworkTransmitThroughput", "DBInstanceIdentifier", "hrappdb"]
          ],
          "stat" : "Average",
          "period" : 60,
          "region" : "eu-central-1"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "lambda_monitoring" {
  dashboard_name = "LambdaMonitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          title = "Stop Lambda Invocations",
          view  = "timeSeries",
          metrics = [
            [ "AWS/Lambda", "Invocations", "FunctionName", "auto-shutdown-nonprod" ]
          ],
          region = "eu-central-1",
          period = 300,
          stat   = "Sum"
        }
      },
      {
        type = "metric",
        x = 12,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          title = "Start Lambda Invocations",
          view  = "timeSeries",
          metrics = [
            [ "AWS/Lambda", "Invocations", "FunctionName", "auto-start-nonprod" ]
          ],
          region = "eu-central-1",
          period = 300,
          stat   = "Sum"
        }
      },
      {
        type = "metric",
        x = 0,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          title = "Stop Lambda Errors",
          view  = "timeSeries",
          metrics = [
            [ "AWS/Lambda", "Errors", "FunctionName", "auto-shutdown-nonprod" ]
          ],
          region = "eu-central-1",
          period = 300,
          stat   = "Sum"
        }
      },
      {
        type = "metric",
        x = 12,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          title = "Start Lambda Errors",
          view  = "timeSeries",
          metrics = [
            [ "AWS/Lambda", "Errors", "FunctionName", "auto-start-nonprod" ]
          ],
          region = "eu-central-1",
          period = 300,
          stat   = "Sum"
        }
      },
      {
        type = "metric",
        x = 0,
        y = 12,
        width = 12,
        height = 6,
        properties = {
          title = "Stop Lambda Duration (ms)",
          view  = "timeSeries",
          metrics = [
            [ "AWS/Lambda", "Duration", "FunctionName", "auto-shutdown-nonprod" ]
          ],
          region = "eu-central-1",
          period = 300,
          stat   = "Average"
        }
      },
      {
        type = "metric",
        x = 12,
        y = 12,
        width = 12,
        height = 6,
        properties = {
          title = "Start Lambda Duration (ms)",
          view  = "timeSeries",
          metrics = [
            [ "AWS/Lambda", "Duration", "FunctionName", "auto-start-nonprod" ]
          ],
          region = "eu-central-1",
          period = 300,
          stat   = "Average"
        }
      }
    ]
  })
}