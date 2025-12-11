data "archive_file" "lambda_zip"{
    type = "zip"
    source_file = "${path.module}/lambda_notify.py"
    output_path = "${path.module}/lambda_notify.zip"
}