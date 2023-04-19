# terraform {
#   backend "s3" {
#     bucket = "3.devops.candidate.exam"
#     key    = "Liron.Shemer"
#     region = "ap-south-1"
#   }
# }



resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda_sg_"
  vpc_id     = data.aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda_sg"
  }
}

resource "aws_subnet" "private_subnet" {
  #count = length(data.aws_subnet_ids.private.ids)

  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.9.0/24"

  tags = {
    Name = "private-1"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_association" {
  #count          = length(data.aws_subnet_ids.private.ids)
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_lambda_function" "lambda" {
  function_name = "devops-candidate-lambda"
  role          = data.aws_iam_role.lambda.arn
  handler       = "devops-candidate-lambda.lambda_handler"
  runtime       = "python3.8"
  filename      = "lambda-func-python.zip"
  source_code_hash = filebase64sha256("lambda-func-python.zip")

  vpc_config {
    subnet_ids = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
   variables = {
    snid = aws_subnet.private_subnet.id 
   }
  }

  depends_on = [
    aws_route_table_association.private_association,
    aws_security_group.lambda_sg
  ]
}

# data "aws_iam_role" "lambda" {
#   name = "DevOps-Candidate-Lambda-Role"
# }

output "lambda_function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda.arn
}


data "template_file" "lambda" {
 template = "${file("lambda/exam-devops.py")}"
 
 
  # environment {
  #  variables = {
  #   snid = aws_subnet.private_subnet.id 
  #  }
  # }
}

data "archive_file" "lambda" {
  type                    = "zip"
  #source_content_filename = "lambda"
  source_dir = "lambda"
  #source_content          = "${data.template_file.lambda.rendered}"
  output_path             = "lambda-func-python.zip"
}