#!/bin/bash

# Cursor Background Agent API Script
# This script executes a request to the Cursor Background Agent API

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Cursor Background Agent API Request${NC}"
echo "=================================="

# Check if required environment variables are set
MISSING_VARS=()

if [ -z "$CURSOR_API_KEY" ]; then
    MISSING_VARS+=("CURSOR_API_KEY")
fi

if [ -z "$CURSOR_PROMPT" ]; then
    MISSING_VARS+=("CURSOR_PROMPT")
fi

if [ -z "$CURSOR_REPOSITORY" ]; then
    MISSING_VARS+=("CURSOR_REPOSITORY")
fi

# If any required variables are missing, show error and exit
if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo -e "${RED}❌ Error: The following required environment variables are not set:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo -e "${RED}   - $var${NC}"
    done
    echo ""
    echo -e "${YELLOW}Please set them with:${NC}"
    echo "export CURSOR_API_KEY=\"your_api_key_here\""
    echo "export CURSOR_PROMPT=\"your_prompt_here\""
    echo "export CURSOR_REPOSITORY=\"https://github.com/your-org/your-repo\""
    echo ""
    echo -e "${YELLOW}Optional variables:${NC}"
    echo "export CURSOR_MODEL=\"sonnet-4\"  # Default: Auto"
    exit 1
fi

echo -e "${YELLOW}📂 Using repository:${NC} $CURSOR_REPOSITORY"

# Set default model if not provided
if [ -z "$CURSOR_MODEL" ]; then
    CURSOR_MODEL="Auto"
    echo -e "${YELLOW}🤖 Model not specified, using default:${NC} $CURSOR_MODEL"
else
    echo -e "${YELLOW}🤖 Using model:${NC} $CURSOR_MODEL"
fi

echo -e "${YELLOW}📝 Using prompt:${NC} $CURSOR_PROMPT"
echo -e "${YELLOW}🔑 Using API key:${NC} ${CURSOR_API_KEY:0:8}..." # Show only first 8 chars for security
echo ""

# Execute the curl request
echo -e "${GREEN}📡 Sending request to Cursor API...${NC}"
echo ""

# Escape special characters in the prompt for JSON
ESCAPED_PROMPT=$(printf '%s\n' "$CURSOR_PROMPT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')

# Create JSON payload using jq for proper escaping (fallback to manual if jq not available)
if command -v jq &> /dev/null; then
    JSON_PAYLOAD=$(jq -n \
        --arg prompt "$CURSOR_PROMPT" \
        --arg model "$CURSOR_MODEL" \
        --arg repo "$CURSOR_REPOSITORY" \
        --arg ref "main" \
        '{
            prompt: {
                text: $prompt
            },
            model: $model,
            source: {
                repository: $repo,
                ref: $ref
            }
        }')
else
    # Fallback if jq is not available
    JSON_PAYLOAD="{
        \"prompt\": {
            \"text\": \"${ESCAPED_PROMPT}\"
        },
        \"model\": \"${CURSOR_MODEL}\",
        \"source\": {
            \"repository\": \"${CURSOR_REPOSITORY}\",
            \"ref\": \"main\"
        }
    }"
fi

echo -e "${YELLOW}📦 JSON Payload:${NC}"
echo "$JSON_PAYLOAD"
echo ""

# Execute the curl request
RESPONSE=$(curl --request POST \
  --url https://api.cursor.com/v0/agents \
  --header "Authorization: Bearer ${CURSOR_API_KEY}" \
  --header 'Content-Type: application/json' \
  --data "$JSON_PAYLOAD" \
  --silent \
  --show-error \
  --write-out "HTTPSTATUS:%{http_code}")

# Extract HTTP status and body
HTTP_STATUS=$(echo "$RESPONSE" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
HTTP_BODY=$(echo "$RESPONSE" | sed -E 's/HTTPSTATUS:[0-9]*$//')

echo -e "${YELLOW}📊 HTTP Status:${NC} $HTTP_STATUS"
echo -e "${YELLOW}📋 Response:${NC}"
echo "$HTTP_BODY"

if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 201 ]; then
    echo ""
    echo -e "${GREEN}✅ Request completed successfully!${NC}"
else
    echo ""
    echo -e "${RED}❌ Request failed with status $HTTP_STATUS${NC}"
    exit 1
fi
