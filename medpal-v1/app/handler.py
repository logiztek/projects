"""
================================================================================
MedPal Lambda Handler - AWS Lambda Function for Health Information Assistant
================================================================================

DESCRIPTION:
    This AWS Lambda function serves as the backend handler for MedPal, a health
    information chatbot powered by Claude AI via AWS Bedrock. It receives SMS 
    messages from Twilio, processes them with Claude, and returns health guidance.

WHAT IT DOES (Non-Technical):
    - Receives health questions via SMS (sent by Twilio)
    - Sends the question to Claude AI (an intelligent assistant)
    - Gets back helpful health advice
    - Sends the response back as an SMS message

TECHNICAL FLOW:
    1. Receives HTTP POST request from Twilio with user message
    2. Extracts the user's SMS text from the request
    3. Prepends a safety prompt to ensure responsible health advice
    4. Sends request to AWS Bedrock (Claude model)
    5. Returns response in TwiML format (Twilio XML) for SMS reply

IMPORTANT NOTES:
    - This is NOT a diagnostic tool - it provides general health information
    - Claude is instructed to recommend professional help for serious symptoms
    - Responses are limited to 1500 characters for SMS compatibility
    - Timeout is set to 15 seconds to accommodate API calls

================================================================================
"""

import json
import urllib.parse
import os
import boto3

# ============================================================================
# CONFIGURATION - Environment Variables
# ============================================================================

# Model configuration for AWS Bedrock
# - MODEL_ID: Specifies which Claude model to use (Haiku is fast & cost-effective)
# - Can be overridden via environment variable
MODEL_ID = os.getenv("MODEL_ID", "anthropic.claude-3-haiku-20240307-v1:0")

# AWS region where Bedrock service is deployed
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

# Initialize Bedrock client for AI model inference
bedrock = boto3.client("bedrock-runtime", region_name=AWS_REGION)

# ============================================================================
# SAFETY PROMPT - Instructions for Claude AI
# ============================================================================
# This preamble ensures Claude gives responsible health guidance, not medical
# diagnoses. It sets expectations for safe, supportive responses.

SAFETY_PREAMBLE = (
    "You are MedPal, a general health information assistant. "
    "You do NOT diagnose medical conditions. "
    "Offer practical self-care tips, risk assessment guidance, and information about when to seek professional help. "
    "Be concise, supportive, and encouraging. "
    "If symptoms sound severe or urgent, clearly advise the user to seek immediate medical attention.\n"
)


# ============================================================================
# FUNCTION: call_bedrock()
# ============================================================================
# PURPOSE: Send a prompt to Claude AI via AWS Bedrock and get a response
#
# WHAT IT DOES:
#   - Constructs a properly formatted request for Claude
#   - Sends request to AWS Bedrock
#   - Extracts and returns the AI-generated response
#
# INPUT: prompt (string) - The question/message to send to Claude
# OUTPUT: string - Claude's response/answer

def call_bedrock(prompt: str) -> str:
    """
    Call AWS Bedrock Claude model with a prompt and return the response.
    
    Args:
        prompt: The user message to send to Claude AI
        
    Returns:
        The AI-generated response text
    """
    # Structure the request payload according to Bedrock/Anthropic API format
    payload = {
        "anthropic_version": "bedrock-2023-05-31",  # API version for compatibility
        "max_tokens": 400,  # Limit response length to ~1000 words (4 chars per token)
        "messages": [
            {
                "role": "user",  # Message is from the user
                "content": [
                    {
                        "type": "text",
                        "text": prompt  # The actual message content
                    }
                ]
            }
        ],
    }
    
    # Send the request to Bedrock and receive response
    response = bedrock.invoke_model(
        modelId=MODEL_ID,  # Which AI model to use
        contentType="application/json",  # Request format
        accept="application/json",  # Expected response format
        body=json.dumps(payload),  # Convert payload to JSON string
    )
    
    # Parse the response body from the stream
    response_body = json.loads(response["body"].read())
    
    # Extract the AI-generated text from the response
    return response_body["content"][0]["text"]


# ============================================================================
# FUNCTION: twiml_response()
# ============================================================================
# PURPOSE: Format a text response into TwiML (Twilio XML format)
#
# WHY THIS IS NEEDED:
#   - Twilio requires responses in a specific XML format (TwiML)
#   - This function wraps our text response in that XML structure
#   - Twilio then converts the XML to an SMS and sends it to the user
#
# INPUT: text (string) - The message to send
# OUTPUT: string - Properly formatted TwiML/XML response

def twiml_response(text: str) -> str:
    """
    Format text response as TwiML (Twilio XML markup language).
    
    Args:
        text: The message text to include in the SMS response
        
    Returns:
        TwiML-formatted string that Twilio will process and send as SMS
    """
    return (
        f'<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<Response>\n'
        f'    <Message>{text}</Message>\n'
        f'</Response>'
    )


# ============================================================================
# FUNCTION: lambda_handler()
# ============================================================================
# PURPOSE: Main AWS Lambda handler - Entry point for all incoming requests
#
# WHAT IT DOES:
#   1. Receives incoming SMS from Twilio (via HTTP POST)
#   2. Extracts the user's message from the request
#   3. Sends it to Claude AI with safety instructions
#   4. Catches any errors gracefully
#   5. Returns the response in SMS format
#
# INPUT: 
#   - event: Contains the incoming HTTP request data
#   - context: AWS Lambda context metadata (unused in this function)
#
# OUTPUT: 
#   - dict with statusCode, headers, and body (TwiML/XML response)

def lambda_handler(event, context):
    """
    AWS Lambda handler function - processes incoming Twilio SMS messages.
    
    This function:
    1. Extracts the user's SMS message from the request
    2. Handles empty messages with a greeting
    3. Calls Claude AI to generate health guidance
    4. Returns the response in TwiML format for Twilio
    
    Args:
        event: HTTP request event containing user message
        context: Lambda context (unused)
        
    Returns:
        dict: HTTP response with TwiML-formatted message
    """
    
    # ===== STEP 1: Extract user message from the incoming request =====
    # The request body contains form-encoded data from Twilio
    body = event.get("body") or ""
    
    # Parse the URL-encoded form data
    # Example: "Body=What+is+a+headache" becomes {"Body": ["What is a headache"]}
    params = urllib.parse.parse_qs(body)
    
    # Extract the "Body" parameter (the actual SMS text) and clean it
    user_msg = (params.get("Body", [""])[0]).strip()
    
    # ===== STEP 2: Handle empty messages =====
    # If no message was provided, send a greeting
    if not user_msg:
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/xml"},
            "body": twiml_response("Hi! I'm MedPal. How can I help with your health questions today?"),
        }
    
    # ===== STEP 3: Prepare the prompt for Claude =====
    # Combine the safety instructions with the user's actual message
    prompt = SAFETY_PREAMBLE + f"User: {user_msg}"
    
    # ===== STEP 4: Call Claude AI and handle errors =====
    try:
        # Send the prompt to Claude and get the response
        answer = call_bedrock(prompt)
    except Exception as error:
        # If something goes wrong (API error, network issue, etc.)
        # Return a friendly error message instead of crashing
        print(f"Error calling Bedrock: {error}")  # Log error for debugging
        answer = (
            "Sorry, I'm having trouble accessing my knowledge base right now. "
            "Please try again in a moment or contact a healthcare professional for urgent needs."
        )
    
    # ===== STEP 5: Return response in SMS-compatible format =====
    # SMS has character limits, so we trim the response to 1500 characters
    # (about 300 words, safe for SMS fragmentation)
    return {
        "statusCode": 200,  # HTTP 200 = Success
        "headers": {"Content-Type": "application/xml"},  # Response is XML/TwiML
        "body": twiml_response(answer[:1500]),  # Cap response length for SMS
    }