################################################################################
# MedPal v1 - Terraform Main Infrastructure Configuration
################################################################################
#
# DESCRIPTION (Non-Technical):
#   This file defines all the AWS cloud resources needed to run MedPal:
#   - A compute engine (Lambda) that runs the Python code
#   - An API endpoint (API Gateway) that Twilio connects to
#   - Permissions (IAM) that allow these services to work together
#   - Packaging (ZIP file) that bundles the Python code for deployment
#
# DESCRIPTION (Technical):
#   This Terraform configuration creates:
#   1. Lambda IAM Role with permissions for CloudWatch Logs and Bedrock
#   2. Archive/ZIP the handler.py file for Lambda deployment
#   3. Lambda Function that executes the handler code
#   4. HTTP API Gateway v2 for receiving webhooks from Twilio
#   5. Lambda integration with API Gateway
#   6. POST route that triggers Lambda
#   7. API Gateway permissions to invoke Lambda
#
# HOW IT WORKS:
#   User sends SMS → Twilio calls API Gateway endpoint → API Gateway triggers Lambda
#   → Lambda calls Claude AI via Bedrock → Lambda returns response → Twilio sends SMS
#
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


################################################################################
# IAM ROLE - Permissions for Lambda Function
################################################################################
# This role defines what AWS services the Lambda function is allowed to use
# Without this, Lambda cannot call Bedrock or write logs

resource "aws_iam_role" "lambda_role" {
  name_prefix = "${var.project_name}-lambda-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"  # Only Lambda service can assume this role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


################################################################################
# IAM POLICY - What Lambda is Allowed to Do
################################################################################
# This policy gives Lambda permission to:
# 1. Write logs to CloudWatch (for debugging)
# 2. Invoke Bedrock models (to call Claude AI)

resource "aws_iam_role_policy" "lambda_policy" {
  name_prefix = "${var.project_name}-lambda-policy-"
  role        = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # CloudWatch Logs Permission
        # Allows Lambda to write execution logs for debugging and monitoring
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      },
      {
        # AWS Bedrock Permission
        # Allows Lambda to invoke Claude AI models through Bedrock
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "*"
      }
    ]
  })
}


################################################################################
# LAMBDA PACKAGE - Prepare Python Code for Deployment
################################################################################
# This compresses handler.py into a ZIP file that AWS Lambda can execute

data "archive_file" "lambda_zip" {
  type            = "zip"
  source_file     = "${path.module}/../app/handler.py"  # Python file to include
  output_path     = "${path.module}/../app/lambda.zip"  # Where to save ZIP file
  output_base64sha256 = null
}


################################################################################
# LAMBDA FUNCTION - The Core Application
################################################################################
# This is the actual compute resource that runs our Python code
# When triggered by API Gateway, it executes the handler.lambda_handler function

resource "aws_lambda_function" "handler" {
  function_name = "${var.project_name}-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"           # File.function to execute
  runtime       = "python3.12"                       # Python version
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 15                                 # Max execution time in seconds
  memory_size   = 256                                # RAM allocated (MB)

  # Environment variables passed to Python code
  # These can be accessed via os.getenv() in handler.py
  environment {
    variables = {
      MODEL_ID   = var.model_id
    }
  }

  # Ensures Lambda is redeployed if handler.py changes
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}


################################################################################
# API GATEWAY v2 (HTTP API) - Webhook Endpoint
################################################################################
# This creates a public HTTPS endpoint that Twilio can send webhook requests to
# HTTP API v2 is newer, simpler, and cheaper than REST API v1

resource "aws_apigatewayv2_api" "api" {
  name              = "${var.project_name}-api"
  protocol_type     = "HTTP"                  # Use HTTP (not WebSocket)
  cors_configuration {
    allow_origins = ["*"]                     # Accept requests from any origin
    allow_methods = ["POST"]                  # Only allow POST requests
    allow_headers = ["*"]
  }
}


################################################################################
# API GATEWAY INTEGRATION - Connect Lambda to API Gateway
################################################################################
# This integration tells API Gateway how to forward requests to Lambda

resource "aws_apigatewayv2_integration" "lambda_int" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"            # Lambda proxy integration
  integration_uri    = aws_lambda_function.handler.invoke_arn
  payload_format_version = "2.0"              # HTTP API format
}


################################################################################
# API GATEWAY ROUTE - Define POST Endpoint
################################################################################
# This maps POST requests to the root path "/" to the Lambda integration

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /"                        # Match: POST requests to /
  target    = "integrations/${aws_apigatewayv2_integration.lambda_int.id}"
}


################################################################################
# API GATEWAY STAGE - Deployment Configuration
################################################################################
# A "stage" is like an environment (dev, test, prod)
# $default is the default stage that gets auto-deployed

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"                    # Default stage name
  auto_deploy = true                          # Auto-deploy when resources change
}


################################################################################
# LAMBDA PERMISSION - Allow API Gateway to Invoke Lambda
################################################################################
# Security rule: Only API Gateway is allowed to trigger this Lambda function
# Without this, the integration wouldn't work

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowInvokeFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "apigateway.amazonaws.com"  # Service allowed to invoke
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"  # From any route
}


################################################################################
# OUTPUTS - Important Information After Deployment
################################################################################
# These values are displayed after terraform apply completes
# Use the webhook_url to configure Twilio

output "webhook_url" {
  description = "Twilio Webhook URL - Configure this in Twilio console"
  value       = "${aws_apigatewayv2_api.api.api_endpoint}/"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.handler.function_name
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.api.id
}
