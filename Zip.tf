data "archive_file" "lambda_zip"{
    type = "zip"
    source_file = "${path.module}/lambda_notify.py"
    output_path = "${path.module}/lambda_notify.zip"
}

data "archive_file" "stop_env_zip" {
    type = "zip"
    source_file = "${path.module}/lambda_stop.py"
    output_path = "${path.module}/lambda_stop.zip"
}

data "archive_file" "start_env_zip" {
    type = "zip"
    source_file = "${path.module}/lambda_start.py"
    output_path = "${path.module}/lambda_start.zip"
}