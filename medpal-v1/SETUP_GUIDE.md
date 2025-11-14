# MedPal v1 - Complete Setup Guide

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [AWS Account Setup](#aws-account-setup)
3. [GitHub Setup](#github-setup)
4. [Twilio Setup](#twilio-setup)
5. [Deploy Infrastructure](#deploy-infrastructure)
6. [Test & Verify](#test--verify)
7. [Monitor & Maintain](#monitor--maintain)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:

- [ ] **AWS Account**: https://aws.amazon.com
- [ ] **GitHub Account**: https://github.com
- [ ] **Twilio Account**: https://www.twilio.com (free trial available)
- [ ] **Basic Terminal Knowledge**: For running commands
- [ ] **Text Editor**: For editing configuration files

### Estimated Time
- Setup: 15-20 minutes
- Deployment: 3-5 minutes
- Testing: 5 minutes
- **Total**: ~30 minutes

---

## AWS Account Setup

### Step 1: Create/Access AWS Account

1. Go to https://aws.amazon.com
2. Click **"Sign In to the Console"** (or create account if new)
3. Sign in with your credentials
4. You should see the AWS Management Console dashboard

### Step 2: Enable AWS Bedrock

MedPal needs permission to use Bedrock (Claude AI service).

1. Go to **Services** → Search for **"Bedrock"**
2. Click **"Bedrock"**
3. In the left sidebar, click **"Model access"**
4. Click **"Manage model access"** (top right button)
5. Look for **"Claude"** models in the list
6. Click the checkbox next to Claude models
7. Click **"Save changes"** (bottom right)
8. Wait for model access to be granted (~1-2 minutes)

✅ **Bedrock is now enabled in your region**

### Step 3: Create AWS Access Keys

1. Go to **IAM** → **Users** → Your username
2. Click **"Create access key"** (under "Access keys" section)
3. Select **"Command Line Interface (CLI)"** use case
4. Click **"Next"**
5. Click **"Create access key"**
6. **IMPORTANT**: Download the `.csv` file with your credentials
   - Store it securely
   - Do NOT commit to GitHub
   - Do NOT share with anyone

You now have:
- `AWS_ACCESS_KEY`: (looks like: AKIA...)
- `AWS_SECRET_KEY`: (long random string)

---

## GitHub Setup

### Step 1: Fork or Clone Repository

Option A: If you have repository access
```bash
git clone https://github.com/logiztek/projects.git
cd projects
```

Option B: If you need to fork
1. Go to https://github.com/logiztek/projects
2. Click **"Fork"** (top right)
3. Clone your forked repository:
```bash
git clone https://github.com/YOUR_USERNAME/projects.git
cd projects
```

### Step 2: Add AWS Credentials as GitHub Secrets

1. Go to your repository on GitHub
2. Click **"Settings"** (top navigation)
3. In left sidebar, click **"Secrets and variables"** → **"Actions"**
4. Click **"New repository secret"** button

**Create First Secret (AWS Access Key)**
- Name: `AWS_ACCESS_KEY`
- Value: Your Access Key ID from AWS (AKIA...)
- Click **"Add secret"**

**Create Second Secret (AWS Secret Key)**
- Name: `AWS_SECRET_KEY`
- Value: Your Secret Access Key from AWS
- Click **"Add secret"**

✅ **GitHub Secrets are now configured**

### Step 3: Verify Workflows Are Visible

1. Go to **"Actions"** tab in your repository
2. You should see:
   - ✅ Deploy MedPal Infrastructure
   - ✅ Destroy MedPal Infrastructure

If workflows don't appear, make sure `.github/workflows/` directory exists.

---

## Twilio Setup

### Step 1: Create Twilio Account

1. Go to https://www.twilio.com/try-twilio
2. Sign up (free trial available)
3. Complete verification steps
4. You'll be given a trial phone number (like +1-XXX-XXX-XXXX)

### Step 2: Note Your Phone Number

1. Go to Twilio Console → **Phone Numbers** → **Manage Numbers**
2. Find your active phone number
3. Copy it for later (you'll need it after deployment)

### Step 3: Get Twilio Webhook Ready (Save for Later)

After MedPal deploys, you'll need to:
1. Go to **Phone Numbers** → your number
2. Scroll to **"Messaging"** section
3. Find **"A message comes in"** field
4. Paste the Webhook URL (from deployment outputs)
5. Method: **POST**
6. Save

*We'll do this after deployment*

---

## Deploy Infrastructure

### Step 1: Start Deployment Workflow

1. Go to your repository on GitHub
2. Click **"Actions"** tab
3. In left sidebar, click **"Deploy MedPal Infrastructure"**
4. Click **"Run workflow"** dropdown
5. You'll see input fields:
   - Environment: Select **"production"**
   - Confirm: Type **`deploy`** exactly
6. Click **"Run workflow"** button

### Step 2: Monitor Deployment

The workflow will run through these steps:
1. ✓ Checkout code (30 seconds)
2. ✓ Setup Terraform (1 minute)
3. ✓ Validate configuration (30 seconds)
4. ✓ Plan changes (1 minute)
5. ✓ Apply changes (2-3 minutes)
6. ✓ Capture outputs (30 seconds)

Total time: **~5-7 minutes**

### Step 3: Get Deployment Outputs

1. Deployment is complete when workflow shows ✅ **"All checks passed"**
2. Scroll down in the workflow run
3. Look for **"Artifacts"** section
4. Download **"deployment-outputs"**
5. Extract and open `deployment-output.txt`
6. Find and copy the `webhook_url` (looks like: `https://xxxxx.execute-api.us-east-1.amazonaws.com/`)

### Step 4: Configure Twilio Webhook

1. Go to Twilio Console → **Phone Numbers** → **Manage Numbers**
2. Click your active phone number
3. Scroll to **"Messaging"** section
4. Under **"A message comes in"**:
   - Paste the `webhook_url` from deployment outputs
   - Method: **POST**
5. Click **"Save"**

✅ **Infrastructure is deployed and connected!**

---

## Test & Verify

### Step 1: Test with Your Phone

1. From any phone, send a text to your Twilio number:
   ```
   What helps with a sore throat?
   ```

2. Wait 2-5 seconds for a response

3. You should receive an SMS with health advice from Claude AI

### Step 2: Test Different Questions

Try these to verify it's working:
- "Is this a fever?" (simple question)
- "Should I see a doctor for a headache?" (guidance question)
- "Tell me about cold symptoms" (information question)

### Step 3: Check Logs

If something goes wrong:
1. Go to **AWS Console** → **CloudWatch** → **Log Groups**
2. Find log group: `/aws/lambda/medpal-handler`
3. Click to view logs
4. Look for errors or issues

---

## Monitor & Maintain

### Daily
- Monitor incoming messages
- Check for errors in CloudWatch

### Weekly
- Review AWS Cost Explorer for unexpected charges
- Check Lambda invocation metrics

### Monthly
- Review CloudWatch Logs for issues
- Update prompts if needed (in handler.py)
- Monitor performance metrics

### Set Up Cost Alerts (Recommended)

1. Go to **AWS Console** → **Billing**
2. Click **"Budgets"** → **"Create budget"**
3. Set monthly spending limit (e.g., $50)
4. Add email for alerts
5. Save

---

## Troubleshooting

### SMS Not Being Received

**Problem**: Text to Twilio number, no response

**Solutions**:
1. Verify Twilio webhook URL is correct
   - Go to Twilio Console → Phone Numbers → your number
   - Check webhook URL matches deployment output
   
2. Check Lambda logs
   - AWS Console → CloudWatch → Log Groups → `/aws/lambda/medpal-handler`
   - Look for error messages
   
3. Verify Bedrock access
   - AWS Console → Bedrock → Model access
   - Ensure Claude models are enabled

### High Costs

**Problem**: Unexpected AWS charges

**Solutions**:
1. Check Lambda invocation count
   - AWS Console → Lambda → medpal-handler → Monitoring
   - Review CloudWatch metrics
   
2. Check API Gateway requests
   - AWS Console → API Gateway → medpal-api → Metrics
   
3. Review Bedrock usage
   - AWS Console → Bedrock → Usage

### Deployment Failed

**Problem**: GitHub Actions workflow failed

**Solutions**:
1. Check GitHub Actions logs
   - Go to Actions → Failed workflow → Click workflow → See error
   
2. Verify AWS credentials
   - Settings → Secrets → Verify AWS_ACCESS_KEY and AWS_SECRET_KEY exist
   
3. Check AWS permissions
   - Ensure credentials have permissions for:
     - Lambda, API Gateway, IAM, Bedrock

### Terraform Lock Issue

**Problem**: "Error acquiring the lock"

**Solutions**:
1. This usually resolves itself after 5 minutes
2. If persistent:
   - Run: `terraform init` to reinitialize
   - Or run destroy workflow to clean up

---

## Next Steps

After successful setup:

1. **Customize Responses**: Edit `SAFETY_PREAMBLE` in `app/handler.py`
2. **Track Metrics**: Set up CloudWatch alarms
3. **Improve Performance**: Monitor Lambda duration
4. **Scale Usage**: Share Twilio number with users
5. **Collect Feedback**: Track user satisfaction

---

## Quick Reference

### Important URLs
- AWS Console: https://console.aws.amazon.com
- GitHub Repository: https://github.com/logiztek/projects
- Twilio Console: https://www.twilio.com/console

### Key Values to Keep
- Twilio Phone Number: +1-XXX-XXX-XXXX
- Webhook URL: https://xxxxx.execute-api...
- Lambda Function Name: medpal-handler

### Useful AWS Paths
- CloudWatch Logs: Services → CloudWatch → Log Groups
- Lambda Function: Services → Lambda → Functions
- API Gateway: Services → API Gateway
- Bedrock: Services → Bedrock

---

## Support

- 📖 See [MedPal README](./README.md) for detailed documentation
- 🐛 Check troubleshooting section above
- 📊 Review CloudWatch logs for errors
- 💬 Check GitHub Issues for common problems

---

**Congratulations! 🎉 MedPal is now live!**

Your health information SMS chatbot is ready to assist users with health questions.

Remember: MedPal provides **information only**, not medical diagnosis. Always encourage users to consult healthcare professionals for urgent concerns.
