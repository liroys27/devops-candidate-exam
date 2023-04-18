terraform {
  backend "s3" {
    bucket = "3.devops.candidate.exam"
    key    = "Liron.Shemer"
    region = "ap-south-1"
  }
}



resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda_sg_"

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
  count = length(data.aws_subnet_ids.private.ids)

  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.${count + 1}.0/24"

  tags = {
    Name = "private-${count + 1}"
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
  count          = length(data.aws_subnet_ids.private.ids)
  subnet_id      = element(data.aws_subnet_ids.private.ids, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_lambda_function" "lambda" {
  function_name = "devops-candidate-lambda"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  vpc_config {
    subnet_ids = data.aws_subnet_ids.private.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [
    aws_route_table_association.private_association,
    aws_security_group.lambda_sg
  ]
}

data "aws_iam_role" "lambda" {
  name = "DevOps-Candidate-Lambda-Role"
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda.arn
}