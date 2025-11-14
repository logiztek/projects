# MedPal v1 - Health Information SMS Assistant

## 📋 Project Overview

**MedPal** is an AI-powered SMS chatbot that provides general health information and guidance. Users text health questions to a Twilio phone number, and receive responses from Claude AI via AWS Bedrock.

### What It Does (Non-Technical)
- Users send SMS questions about health topics
- Claude AI analyzes the question and provides helpful information
- Responses include self-care tips, when to seek professional help, and risk assessment
- Safe, responsible, and NOT a replacement for medical professionals

### Architecture (Technical)
```
Twilio SMS → API Gateway → Lambda Function → Bedrock Claude → Response SMS
```

---

## 🗂️ Project Structure

```
medpal-v1/
├── app/
│   ├── handler.py                 # Lambda function code
│   └── lambda.zip                 # Compiled deployment package (auto-generated)
│
├── infra/
│   ├── main.tf                    # Main Terraform configuration
│   ├── variables.tf               # Terraform variables & configuration options
│   ├── terraform.tfvars           # (optional) Custom values
│   └── .terraform/                # (auto-generated) Terraform files
│
├── .github/
│   └── workflows/
│       ├── tf-apply.yml           # GitHub Action: Deploy infrastructure
│       └── tf-destroy.yml         # GitHub Action: Delete infrastructure
│
└── README.md                       # This file
```

---

## 🚀 Quick Start

### Prerequisites
- AWS Account with credentials
- GitHub Account with repository access
- Twilio Account (for SMS integration)

### Step 1: Set Up AWS Credentials in GitHub

1. Go to your AWS Account → Security Credentials
2. Create new Access Key ID and Secret Access Key
3. Go to GitHub Repository → Settings → Secrets and variables → Actions
4. Add these secrets:
   - `AWS_ACCESS_KEY`: Your AWS Access Key ID
   - `AWS_SECRET_KEY`: Your AWS Secret Access Key

### Step 2: Deploy Infrastructure

1. Go to GitHub Actions tab in your repository
2. Select **"Deploy MedPal Infrastructure"** workflow
3. Click **"Run workflow"** button
4. Fill in confirmation field with: `deploy`
5. Click **"Run workflow"**
6. Wait for completion (~2-3 minutes)

### Step 3: Get Webhook URL

1. After deployment completes, go to workflow run details
2. Find artifact **"deployment-outputs"**
3. Download and open `deployment-output.txt`
4. Copy the `webhook_url` value

### Step 4: Configure Twilio

1. Go to Twilio Console → Phone Numbers → Manage Numbers
2. Select your active phone number
3. Scroll to "Messaging" section
4. Set **"A message comes in"** webhook to the `webhook_url` from Step 3
5. Method: **POST**
6. Save changes

### Step 5: Test It!

Send a text message to your Twilio number asking a health question:
```
What's a good remedy for a cold?
```

You should receive an AI-generated response within seconds.

---

## 📝 Configuration

### Using Terraform Variables

Edit `medpal-v1/infra/terraform.tfvars` (create if doesn't exist):

```hcl
# Change project name (used in AWS resource names)
project_name = "my-medpal"

# Change AWS region (us-east-1, eu-west-1, etc.)
aws_region = "us-east-1"

# Use different Claude model (must be available in Bedrock)
model_id = "anthropic.claude-3-5-haiku-20241022-v1:0"

# Adjust Lambda memory (256 MB is recommended for this use case)
lambda_memory_size = 256

# Adjust Lambda timeout (15 seconds is recommended)
lambda_timeout = 15
```

Then redeploy with:
```bash
cd medpal-v1/infra
terraform apply
```

---

## 💰 Cost Estimation

**Monthly Costs (Approximate):**
- Lambda: ~$0.20/month (1M requests free, then $0.20/1M)
- API Gateway: ~$3.50/month (1M requests = $3.50)
- Bedrock (Claude Haiku): ~$0.001/SMS (varies by request)
- Twilio SMS: ~$0.0075 inbound, $0.0075 outbound per SMS

**Example:** 1,000 conversations/month ≈ $10-15/month

---

## 🔧 File Descriptions

### `app/handler.py`
- **Purpose**: AWS Lambda function entry point
- **What it does**:
  1. Receives SMS from Twilio
  2. Extracts user message
  3. Sends to Claude AI via Bedrock
  4. Returns response in TwiML format for SMS
- **Language**: Python 3.12
- **External Dependencies**: boto3

### `infra/main.tf`
- **Purpose**: Defines all AWS infrastructure
- **Resources Created**:
  - IAM Role & Policy (permissions)
  - Lambda Function (compute)
  - API Gateway (webhook endpoint)
  - Lambda Integration & Routes
  - CloudWatch Logs (debugging)
- **Language**: HCL (HashiCorp Configuration Language)

### `infra/variables.tf`
- **Purpose**: Configuration options for Terraform
- **Key Variables**:
  - `project_name`: Prefix for all AWS resources
  - `aws_region`: Geographic region for deployment
  - `model_id`: Which Claude model to use
  - `lambda_memory_size`: RAM allocated
  - `lambda_timeout`: Max execution time

### `.github/workflows/tf-apply.yml`
- **Purpose**: Automated deployment workflow
- **Triggers**: Manual (workflow_dispatch)
- **Steps**: Checkout → Setup Terraform → Validate → Plan → Apply
- **Output**: Deployment outputs with webhook URL

### `.github/workflows/tf-destroy.yml`
- **Purpose**: Automated infrastructure destruction
- **Triggers**: Manual with confirmation
- **Safety**: Requires typing "destroy" to prevent accidents
- **Impact**: Deletes ALL MedPal resources from AWS

---

## 🔐 Security Notes

### What's Secure
- AWS credentials stored as GitHub Secrets (encrypted)
- Lambda has minimal IAM permissions (only Bedrock + CloudWatch)
- API Gateway uses HTTPS (encrypted in transit)
- Bedrock API calls are encrypted

### What You Should Know
- Claude AI can access user messages (per Anthropic's privacy policy)
- Twilio has access to messages (SMS provider)
- CloudWatch logs store interaction metadata
- API endpoint is publicly accessible (rate limiting recommended)

### Recommendations
- Monitor costs regularly in AWS Console
- Review CloudWatch logs for debugging
- Consider adding request authentication for production
- Enable Twilio message queuing for high volume

---

## 🐛 Troubleshooting

### SMS not being received
1. Check Twilio webhook URL is correct
2. Verify webhook method is POST
3. Check CloudWatch logs in AWS console
4. Ensure Lambda has permissions (IAM role)

### High costs
1. Check Lambda execution duration (CloudWatch Logs)
2. Review API Gateway request count (CloudWatch Metrics)
3. Reduce `lambda_memory_size` if possible
4. Consider switching to cheaper Claude model

### Deployment fails
1. Verify AWS credentials are correct
2. Check AWS region has Bedrock available
3. Ensure Terraform directory has write permissions
4. Review GitHub Actions workflow logs for errors

### Terraform state conflicts
1. Run: `terraform init` to reinitialize
2. Check for lock files: `rm -rf .terraform.lock.hcl`
3. Run: `terraform refresh` to sync state

---

## 📚 Learning Resources

### AWS Services Used
- **Lambda**: Compute service for running code
- **API Gateway**: HTTP endpoint for webhooks
- **IAM**: Access control and permissions
- **Bedrock**: AI model inference service
- **CloudWatch**: Logging and monitoring

### External Services
- **Twilio**: SMS service
- **Claude**: AI model by Anthropic
- **GitHub Actions**: CI/CD automation

### Links
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Twilio SMS Documentation](https://www.twilio.com/docs/sms)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## 🗑️ Cleanup

To completely remove MedPal and stop charges:

1. Go to GitHub Actions tab
2. Select **"Destroy MedPal Infrastructure"** workflow
3. Click **"Run workflow"** button
4. Type **`destroy`** in confirmation field
5. Click **"Run workflow"**
6. Wait for completion

⚠️ **Warning**: This permanently deletes all AWS resources. To restart, run the deploy workflow again.

---

## 📞 Support

For issues or questions:
1. Check AWS CloudWatch Logs for error messages
2. Review GitHub Actions workflow logs
3. Check Twilio webhook delivery logs
4. Consult the troubleshooting section above

---

## 📄 License

This project is provided as-is for educational and medical information purposes.

**IMPORTANT**: MedPal is NOT a medical diagnostic tool. It provides general health information only. Always encourage users to consult healthcare professionals for medical concerns.

---

## 🎯 Next Steps

After successful deployment:
1. ✅ Test with sample SMS messages
2. ✅ Monitor logs in AWS CloudWatch
3. ✅ Review costs in AWS Billing
4. ✅ Configure error notifications (optional)
5. ✅ Share Twilio number with users
6. ✅ Gather feedback and improve prompts

---

**Last Updated**: November 2024
