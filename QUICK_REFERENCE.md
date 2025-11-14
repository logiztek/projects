# 🚀 MedPal v1 - Quick Reference Card

## For Different Roles

---

## 👨‍💼 Project Manager

### What is MedPal?
- SMS chatbot for health information
- Powered by Claude AI
- Runs on AWS
- Available immediately after deployment

### Key Metrics
- **Setup Time**: 30 minutes
- **Cost**: ~$10-15/month
- **Uptime**: 99.9% (AWS SLA)
- **Response Time**: 1-3 seconds

### Status Dashboard
- Deploy: GitHub Actions → Run workflow
- Monitor: AWS Console → CloudWatch
- Destroy: GitHub Actions → Run destroy workflow

---

## 👨‍💻 Developer

### Project Layout
```
app/handler.py          → Lambda function (Python)
infra/main.tf           → AWS resources (Terraform)
infra/variables.tf      → Configuration options
.github/workflows/      → Automation scripts
```

### Key Functions
- `lambda_handler()`: Entry point
- `call_bedrock()`: Claude AI integration
- `twiml_response()`: Twilio formatting

### Configuration
```python
MODEL_ID = "anthropic.claude-3-5-haiku-20241022-v1:0"
AWS_REGION = "us-east-1"
TIMEOUT = 15 seconds
MEMORY = 256 MB
```

### Testing Locally
```bash
python app/handler.py
# (Add test event data)
```

### Development Cycle
1. Edit `handler.py`
2. Test locally
3. Commit to git
4. Deploy via `tf-apply.yml`
5. Monitor logs

---

## 🔧 DevOps/Infrastructure

### AWS Resources Created
- **Lambda**: medpal-handler
- **API Gateway**: medpal-api
- **IAM Role**: medpal-lambda-role-*
- **CloudWatch**: /aws/lambda/medpal-handler

### Terraform Commands
```bash
cd infra/
terraform init           # First time setup
terraform plan          # Show changes
terraform apply         # Deploy
terraform destroy       # Remove all
```

### GitHub Actions
```
Workflow              Purpose
─────────────────────────────────
tf-apply.yml          Deploy infrastructure
tf-destroy.yml        Delete infrastructure
```

### Monitoring
```
CloudWatch Logs       → Execution logs
Lambda Metrics        → Invocations, duration, errors
API Gateway Metrics   → Request count, latency
```

### Cost Optimization
- Use Haiku model (fast, cheap)
- Monitor Lambda duration
- Set CloudWatch alarms
- Review API Gateway usage

---

## 🏥 Non-Technical User / PM

### How It Works
1. User texts question to Twilio number
2. Message goes to AWS API
3. Lambda processes request
4. Claude AI generates response
5. SMS sent back with answer

### Monitoring Health
- ✅ Responding to messages
- ✅ No error messages
- ✅ Costs reasonable
- ✅ Users satisfied

### When Something's Wrong
1. Check CloudWatch logs
2. Review GitHub Actions workflow
3. Verify Twilio webhook
4. Check AWS Bedrock status

### Maintenance
- Weekly: Review costs
- Monthly: Check logs for errors
- Quarterly: Optimize prompts

---

## 🔑 Quick Commands

### Deploy
```bash
# Via GitHub UI (Recommended)
1. Actions → Deploy MedPal Infrastructure
2. Run workflow
3. Type "deploy"
4. Wait 5 minutes

# Via Terraform CLI
cd medpal-v1/infra
terraform init
terraform apply -auto-approve
```

### Destroy
```bash
# Via GitHub UI (Recommended)
1. Actions → Destroy MedPal Infrastructure
2. Run workflow
3. Type "destroy"
4. Wait 3 minutes

# Via Terraform CLI
cd medpal-v1/infra
terraform destroy -auto-approve
```

### View Logs
```bash
# AWS Console
Services → CloudWatch → Log Groups
→ /aws/lambda/medpal-handler

# Search for errors
Filter and pattern: "ERROR"
```

### Check Costs
```bash
# AWS Console
Services → Billing → Cost Explorer
→ Filter by date range
```

---

## 📞 Emergency Contacts

### If SMS Not Working
1. Check Twilio webhook URL
2. Review Lambda logs
3. Verify Bedrock access
4. Check API Gateway health

### If Costs Are High
1. Check Lambda duration
2. Review request count
3. Consider cheaper model
4. Check for bugs/loops

### If Deployment Fails
1. Check GitHub secrets
2. Verify AWS permissions
3. Review Terraform logs
4. Check AWS service status

---

## 📊 Important Numbers

| Item | Value |
|------|-------|
| Setup Time | 30 min |
| Deployment Time | 5-7 min |
| Lambda Timeout | 15 sec |
| Lambda Memory | 256 MB |
| SMS Response Time | 1-3 sec |
| Monthly Cost | $10-15 |
| Free Lambda Requests | 1 million |
| AWS SLA Uptime | 99.9% |

---

## 🔒 Security Reminders

- ❌ Never commit AWS credentials
- ✅ Use GitHub Secrets
- ❌ Never share access keys
- ✅ Review IAM permissions monthly
- ❌ Don't give Lambda full AWS access
- ✅ Monitor CloudWatch logs for suspicious activity
- ❌ Don't use personal AWS accounts
- ✅ Set up billing alerts

---

## 📚 File Reference

| File | Purpose | Audience |
|------|---------|----------|
| handler.py | Lambda code | Developers |
| main.tf | AWS resources | DevOps |
| variables.tf | Configuration | All |
| tf-apply.yml | Deploy workflow | DevOps |
| tf-destroy.yml | Destroy workflow | DevOps |
| README.md | Full docs | All |
| SETUP_GUIDE.md | Step-by-step | Everyone |

---

## ✅ Pre-Deployment Checklist

- [ ] AWS account ready
- [ ] AWS credentials created
- [ ] GitHub secrets added
- [ ] Bedrock model enabled
- [ ] Twilio account created
- [ ] Twilio number assigned
- [ ] Repository cloned/forked
- [ ] Ready to deploy

---

## 🎯 After Deployment

- [ ] Get webhook URL from outputs
- [ ] Configure Twilio webhook
- [ ] Send test SMS
- [ ] Verify response received
- [ ] Check CloudWatch logs
- [ ] Review costs
- [ ] Share number with users
- [ ] Set up monitoring

---

## 🚨 Critical Information

### Never
- Commit secrets to git
- Share AWS access keys
- Give Lambda full AWS permissions
- Expose webhook URL publicly
- Use production credentials for testing

### Always
- Use GitHub Secrets
- Enable Bedrock model access
- Monitor costs
- Review logs regularly
- Keep code updated
- Test before deploying changes

### Remember
- MedPal is NOT medical diagnosis
- Always encourage professional help
- Comply with healthcare regulations
- Keep data private
- Follow company policies

---

## 💡 Pro Tips

1. **Monitor Costs**: Set AWS billing alerts to $50/month
2. **Faster Responses**: Use Haiku model (default)
3. **Better Logs**: Add more print statements for debugging
4. **Auto-Scaling**: Lambda handles concurrent requests automatically
5. **Low Latency**: Choose region close to users
6. **Security**: Enable Twilio webhook validation
7. **Analytics**: Log messages to analyze usage patterns
8. **Redundancy**: Run in multiple regions for failover

---

## 🔗 Quick Links

| Resource | URL |
|----------|-----|
| AWS Console | https://console.aws.amazon.com |
| GitHub Repository | https://github.com/logiztek/projects |
| Twilio Console | https://www.twilio.com/console |
| Bedrock Documentation | https://docs.aws.amazon.com/bedrock/ |
| Terraform Docs | https://www.terraform.io/docs |
| GitHub Actions | https://docs.github.com/en/actions |

---

## 📝 Notes

### Version
- MedPal v1.0
- Release: November 2024
- Status: Production-Ready

### Support
- 📖 Read README.md
- 🚀 Check SETUP_GUIDE.md
- 🐛 Review PROJECT_SUMMARY.md
- 💬 Check code comments

---

**Last Updated**: November 14, 2024
**Quick Ref Version**: 1.0
