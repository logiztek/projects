################################################################################
# MedPal v1 - Terraform Variables Definition
################################################################################
#
# DESCRIPTION (Non-Technical):
#   These are configuration options that can be changed without editing the
#   Terraform code. Think of them as "settings" for your infrastructure.
#
# HOW TO USE:
#   1. To override a default value, create a file called "terraform.tfvars"
#   2. Add your custom values there: project_name = "my-custom-name"
#   3. Or pass them on command line: terraform apply -var="project_name=custom"
#
# DEFAULTS:
#   If you don't override these, the default values below will be used
#
################################################################################

# ============================================================================
# Project Name - Used to Prefix All AWS Resources
# ============================================================================
# Non-Technical: This is the name that will appear in AWS for all resources
# Technical: All AWS resources will be named "medpal-*" to keep them organized
#
# Example: If project_name = "medpal", Lambda will be named "medpal-handler"
#          and API Gateway will be named "medpal-api"

variable "project_name" {
  description = "Project name used as prefix for all AWS resources"
  type        = string
  default     = "medpal"
  
  # Validation ensures the name is valid for AWS resource naming
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}


# ============================================================================
# AWS Region - Where Infrastructure Will Be Deployed
# ============================================================================
# Non-Technical: This is the geographic location (data center) where your
#                application will run. Choose the region closest to your users.
# Technical: AWS regions contain availability zones with actual data centers
#
# Common regions:
#   us-east-1       = N. Virginia (default, good for US-based users)
#   us-west-2       = Oregon
#   eu-west-1       = Ireland (for European users)
#   ap-southeast-1  = Singapore (for Asian users)

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
  
  # Validation ensures it's a known AWS region format
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be a valid region code (e.g., us-east-1)."
  }
}


# ============================================================================
# Model ID - Which Claude AI Model to Use
# ============================================================================
# Non-Technical: This specifies which version of Claude AI to use.
#                Different models have different speeds and costs.
# Technical: Bedrock model IDs specify version, size, and capabilities
#
# Available Claude models via Bedrock:
#   anthropic.claude-3-5-haiku-20241022-v1:0    = Fastest, cheapest (recommended)
#   anthropic.claude-3-5-sonnet-20241022-v2:0   = Balanced
#   anthropic.claude-3-opus-20250219-v1:0       = Most capable, slowest, most expensive
#
# RECOMMENDATION:
#   Use Haiku for MedPal (fast responses for SMS, low cost)
#   Haiku = ~1-2 second response time, ~$0.00008 per SMS

variable "model_id" {
  description = "AWS Bedrock Claude model ID to use for AI inference"
  type        = string
  default     = "anthropic.claude-3-5-haiku-20241022-v1:0"
  
  # Users can see valid options in the error message
  validation {
    condition     = can(regex("^anthropic\\.claude-", var.model_id))
    error_message = "Model ID must be a valid Anthropic Claude model from Bedrock."
  }
}


# ============================================================================
# Lambda Memory - RAM Allocated to Lambda Function
# ============================================================================
# Non-Technical: More memory = faster execution but higher cost
#                256 MB is usually enough for processing short SMS messages
# Technical: Lambda pricing is based on GB-seconds (memory × duration)
#            More memory = faster CPU allocation
#
# Values: 128 to 10240 MB (in 1 MB increments)
# Typical for SMS processing: 256 MB (default for this use case)

variable "lambda_memory_size" {
  description = "Memory allocated to Lambda function in MB"
  type        = number
  default     = 256
  
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory must be between 128 and 10240 MB."
  }
}


# ============================================================================
# Lambda Timeout - Maximum Execution Time
# ============================================================================
# Non-Technical: The longest time Lambda will wait for a response before giving up
#                15 seconds is plenty for SMS responses
# Technical: If Lambda exceeds this time, it's killed and returns a timeout error
#
# Max value: 900 seconds (15 minutes)
# For API Gateway requests: Recommended max is 30 seconds
# For our use case: 15 seconds (typical Claude response: 1-3 seconds)

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 15
  
  validation {
    condition     = var.lambda_timeout >= 3 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 3 and 900 seconds."
  }
}


# ============================================================================
# Environment Variables for Application
# ============================================================================
# Non-Technical: These are settings passed to your Python application
#                The application can read them with os.getenv()
# Technical: Lambda environment variables are encrypted at rest by default
#
# These match the environment variable names used in handler.py:
#   - AWS_REGION: Sets the AWS region for boto3 client
#   - MODEL_ID: Sets which Claude model to use

variable "environment_variables" {
  description = "Additional environment variables for Lambda"
  type        = map(string)
  default = {
    # Add any additional environment variables here
    # Example: "LOG_LEVEL" = "DEBUG"
  }
}


# ============================================================================
# Tags - Labels for AWS Resources (Optional)
# ============================================================================
# Non-Technical: Tags help you organize and identify resources in AWS
#                Useful for cost tracking and resource management
# Technical: Tags are key-value pairs that can be used with IAM policies
#            and for cost allocation in billing
#
# Example usage:
#   terraform apply -var='tags={"Environment"="prod", "Team"="platform"}'

variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
  default = {
    Project     = "MedPal"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
