data "aws_nat_gateway" "nat" {
  id = "nat-04bad8be564a37c70"
}

data "aws_vpc" "vpc" {
  id = "vpc-00bf0d10a6a41600c"
}

data "aws_iam_role" "lambda" {
  name = "DevOps-Candidate-Lambda-Role"
}

data "aws_iam_policy" "lambda" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# data "archive_file" "lambda_function" {
#   type        = "zip"
#   source_content_filename = "exam-devops.py"
#   output_path = "lambda_function.zip"
# }
