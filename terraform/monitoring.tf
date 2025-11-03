resource "aws_cloudwatch_log_group" "nginx_access" {
  name              = "/aws/nginx/access"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-nginx-access-logs"
  }
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  name              = "/aws/nginx/error"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-nginx-error-logs"
  }
}
