variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "zone1" {
  description = "Availability zone voor subnet"
  type        = string
  default     = "eu-central-1a"
}

variable "zone2" {
  description = "Availability zone voor subnet"
  type        = string
  default     = "eu-central-1b"
}

variable "vpc_cidr" {
  description = "CIDR block voor de VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "db_user" {
  description = "Username for DB account"
  type        = string
  default     = "Admin"
}

variable "db_password" {
  description = "Password for DB account"
  type        = string
  sensitive   = true
  default     = "Toetsenbord1!"
}

variable "alert_email" {
  description = "Email to send alert to"
  type = string
  default = "555086@student.fontys.nl"

}
variable "ecs_cluster_name" {
  type    = string
  default = "faregate-cluster"  
}

variable "fargate_services" {
  type    = list(string)
  default = ["innovatech_web_service"] 
}

variable "rds" {
  type    = list(string)
  default = ["hrappdb"]
}

variable "desired_day_count" {
  type    = number
  default = 1 
}