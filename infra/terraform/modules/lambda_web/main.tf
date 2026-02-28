resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-web-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "eks_access" {
  name = "${var.project_name}-lambda-eks-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.eks_access.arn
}

resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda-web-sg"
  description = "Security group for Lambda Web"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-lambda-web-sg"
    }
  )
}

data "archive_file" "dummy" {
  type        = "zip"
  output_path = "${path.module}/dummy.zip"

  source {
    content  = "exports.handler = async () => ({ statusCode: 200, body: 'placeholder' });"
    filename = "index.js"
  }
}

resource "aws_lambda_function" "web" {
  function_name = "${var.project_name}-web"
  description   = "Andere Boxing Web SSR"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "server/index.handler"
  runtime       = "nodejs22.x"
  architectures = ["arm64"]
  memory_size   = 512
  timeout       = 30

  filename         = data.archive_file.dummy.output_path
  source_code_hash = data.archive_file.dummy.output_base64sha256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      last_modified,
      environment,
      description,
      memory_size,
      timeout,
    ]
  }
}

resource "aws_lambda_function_url" "web" {
  function_name      = aws_lambda_function.web.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_lambda_permission" "function_url" {
  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.web.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_cloudwatch_log_group" "web_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.web.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}
