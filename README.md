# Projects Repository

This repository contains infrastructure-as-code and application code for various projects managed by logiztek.

## 📦 Projects

### MedPal v1
**Health Information SMS Assistant powered by Claude AI**

A production-ready SMS chatbot that provides health information and guidance through text messages.

- **Status**: Ready for deployment
- **Technology Stack**: 
  - Python (AWS Lambda)
  - Terraform (Infrastructure)
  - GitHub Actions (CI/CD)
  - AWS (Bedrock, Lambda, API Gateway)
  - Twilio (SMS)

**Quick Links**:
- 📖 [Documentation](./medpal-v1/README.md)
- 🚀 [Deploy Now](#quick-start)
- 🐛 [Troubleshooting](./medpal-v1/README.md#-troubleshooting)

---

## 🚀 Quick Start

### Deploy MedPal

1. **Prerequisites**:
   - GitHub Account
   - AWS Account with access keys
   - Twilio Account with SMS-enabled number

2. **Setup GitHub Secrets**:
   - Go to: Settings → Secrets and variables → Actions
   - Add secret `AWS_ACCESS_KEY` (AWS Access Key ID)
   - Add secret `AWS_SECRET_KEY` (AWS Secret Access Key)

3. **Deploy**:
   - Go to: Actions tab → "Deploy MedPal Infrastructure"
   - Click: "Run workflow"
   - Confirm by typing: `deploy`
   - Wait: 2-3 minutes for completion

4. **Configure Twilio**:
   - Get webhook URL from deployment outputs
   - Go to Twilio Console → Phone Numbers
   - Set webhook to the URL provided
   - Test by sending an SMS!

📖 **See [MedPal Documentation](./medpal-v1/README.md) for detailed setup instructions**

---

## 📁 Repository Structure

```
projects/
├── medpal-v1/                          # MedPal SMS Chatbot
│   ├── app/
│   │   └── handler.py                  # Lambda function code
│   ├── infra/
│   │   ├── main.tf                     # AWS infrastructure
│   │   └── variables.tf                # Configuration options
│   └── README.md                       # Project documentation
│
├── .github/
│   └── workflows/
│       ├── tf-apply.yml                # Deploy infrastructure
│       └── tf-destroy.yml              # Destroy infrastructure
│
└── README.md                           # This file
```

---

## 🔧 Technologies Used

### Infrastructure
- **Terraform**: Infrastructure as Code (IaC)
- **AWS**: Cloud platform
  - Lambda: Serverless compute
  - API Gateway: HTTP webhooks
  - Bedrock: AI/ML inference
  - CloudWatch: Monitoring & logs

### Application
- **Python 3.12**: Backend language
- **Claude AI**: AI model provider
- **Twilio**: SMS service provider

### DevOps
- **GitHub Actions**: CI/CD automation
- **Git**: Version control

---

## 📊 Architecture Overview

```
                              ┌─────────────────┐
                              │ Twilio SMS      │
                              │ (Message In)    │
                              └────────┬────────┘
                                       │
                              ┌────────▼────────┐
                              │ API Gateway     │
                              │ (HTTP Endpoint) │
                              └────────┬────────┘
                                       │
                              ┌────────▼──────────┐
                              │ Lambda Function   │
                              │ (handler.py)      │
                              └────────┬──────────┘
                                       │
                              ┌────────▼──────────┐
                              │ AWS Bedrock       │
                              │ (Claude AI)       │
                              └────────┬──────────┘
                                       │
                              ┌────────▼────────┐
                              │ Twilio SMS       │
                              │ (Message Out)    │
                              └─────────────────┘
```

---

## 💰 Cost Breakdown

**MedPal Monthly Costs** (approximate):

| Service | Cost | Notes |
|---------|------|-------|
| Lambda | ~$0.20 | 1M requests included |
| API Gateway | ~$3.50 | Per 1M requests |
| Bedrock (Claude) | Variable | ~$0.001 per SMS |
| Twilio SMS | ~$0.015 | $0.0075 in + out per SMS |
| **Total** | **~$10-15/mo** | For ~1000 conversations |

---

## 🔐 Security Features

### GitHub
- Secrets encrypted at rest
- Credentials never exposed in logs
- Limited token permissions

### AWS
- IAM role with minimal permissions
- Lambda can only call Bedrock + write logs
- HTTPS for all API endpoints
- CloudWatch audit logging

### Twilio
- API credentials stored securely
- Webhook validation
- Message encryption in transit

---

## 📚 Documentation

- **MedPal Setup**: See [medpal-v1/README.md](./medpal-v1/README.md)
- **Terraform Variables**: See [medpal-v1/infra/variables.tf](./medpal-v1/infra/variables.tf)
- **Lambda Code**: See [medpal-v1/app/handler.py](./medpal-v1/app/handler.py)
- **Workflow Details**: See `.github/workflows/`

---

## 🚨 Important Notes

### Billing
- Enable AWS Cost Alerts to avoid surprises
- Monitor Lambda invocations in CloudWatch
- Set billing alerts in AWS Console

### Security
- **Never commit credentials** to git
- Use GitHub Secrets for sensitive data
- Review IAM permissions regularly
- Monitor CloudWatch logs for suspicious activity

### Compliance
- MedPal provides **information only**, NOT medical diagnosis
- Always encourage users to consult healthcare professionals
- Ensure compliance with HIPAA/GDPR if needed (requires additional setup)

---

## 🛠️ Development & Testing

### Local Testing
```bash
# Install dependencies
pip install boto3

# Run handler locally
python medpal-v1/app/handler.py

# Test infrastructure
cd medpal-v1/infra
terraform init
terraform plan
```

### Deployment
```bash
# Via GitHub Actions (Recommended)
# Go to Actions tab → Run workflow

# Via CLI (Advanced)
cd medpal-v1/infra
terraform init
terraform apply
```

### Cleanup
```bash
# Via GitHub Actions (Recommended)
# Go to Actions tab → Destroy workflow → Run with "destroy" confirmation

# Via CLI (Advanced)
cd medpal-v1/infra
terraform destroy
```

---

## 🐛 Troubleshooting

### Common Issues

**SMS not working?**
- Verify Twilio webhook URL in settings
- Check CloudWatch logs in AWS Console
- Ensure Lambda role has Bedrock permissions

**High costs?**
- Check Lambda duration in CloudWatch
- Review API Gateway request count
- Consider cheaper Claude model (Haiku)

**Deployment fails?**
- Verify AWS credentials in GitHub Secrets
- Check Bedrock availability in your region
- Review GitHub Actions logs for errors

**See detailed troubleshooting**: [medpal-v1/README.md#-troubleshooting](./medpal-v1/README.md#-troubleshooting)

---

## 📝 Contributing

To add new features or fix issues:
1. Create a feature branch
2. Make changes
3. Test locally and in staging
4. Submit pull request
5. Review and merge

---

## 📞 Support

For issues:
1. Check project documentation
2. Review CloudWatch logs
3. Check GitHub Actions workflow logs
4. Consult troubleshooting section

---

## 📄 License

MedPal v1 is provided as-is for educational purposes.

**Medical Disclaimer**: MedPal is NOT a medical diagnostic tool. It provides general health information only. Always encourage users to consult qualified healthcare professionals for medical concerns.

---

## 🎯 Roadmap

- [ ] Add conversation history tracking
- [ ] Implement message rate limiting
- [ ] Add error recovery with retry logic
- [ ] Support for additional languages
- [ ] Integration with health resources database
- [ ] User feedback collection system
- [ ] Analytics dashboard

---

**Last Updated**: November 2024
**Repository**: logiztek/projects
