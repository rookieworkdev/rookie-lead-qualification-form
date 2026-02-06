#!/bin/bash

# Webhook Signature Verification Tests
# =====================================
# Tests HMAC-SHA256 signature verification on the webhook endpoint.
#
# Usage:
#   ./tests/webhook-signature.sh [API_URL]
#
# Examples:
#   ./tests/webhook-signature.sh                                    # Uses production URL
#   ./tests/webhook-signature.sh https://rookie-api.vercel.app      # Explicit URL
#   ./tests/webhook-signature.sh http://localhost:3000              # Local testing

API_URL="${1:-https://rookie-api.vercel.app}"
WEBHOOK_ENDPOINT="$API_URL/api/webhook"

# Load secret from environment or .env file
if [ -z "$WEBHOOK_SECRET" ]; then
  if [ -f .env ]; then
    export $(grep WEBHOOK_SECRET .env | xargs)
  fi
fi

if [ -z "$WEBHOOK_SECRET" ]; then
  echo "Error: WEBHOOK_SECRET not set. Set it in environment or .env file."
  exit 1
fi

echo "Testing webhook signature verification"
echo "======================================="
echo "Endpoint: $WEBHOOK_ENDPOINT"
echo ""

# Test payload
BODY='{"name":"Test User","email":"test@example.com","company":"Test Company","message":"This is a test message for webhook signature verification"}'

# ------------------------------------------------------------------------------
# Test 1: Request WITHOUT signature (should fail with 401)
# ------------------------------------------------------------------------------
echo "Test 1: Request WITHOUT signature"
echo "---------------------------------"
echo "Expected: 401 Unauthorized"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$BODY")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response: $RESPONSE_BODY"
echo "Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "401" ]; then
  echo "✅ PASSED"
else
  echo "❌ FAILED (expected 401, got $HTTP_CODE)"
fi
echo ""

# ------------------------------------------------------------------------------
# Test 2: Request WITH INVALID signature (should fail with 401)
# ------------------------------------------------------------------------------
echo "Test 2: Request WITH INVALID signature"
echo "--------------------------------------"
echo "Expected: 401 Unauthorized"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "x-webhook-signature: invalid_signature_here" \
  -d "$BODY")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response: $RESPONSE_BODY"
echo "Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "401" ]; then
  echo "✅ PASSED"
else
  echo "❌ FAILED (expected 401, got $HTTP_CODE)"
fi
echo ""

# ------------------------------------------------------------------------------
# Test 3: Request WITH VALID signature (should succeed with 200)
# ------------------------------------------------------------------------------
echo "Test 3: Request WITH VALID signature"
echo "------------------------------------"
echo "Expected: 200 OK"
echo ""

# Generate HMAC-SHA256 signature
SIGNATURE=$(echo -n "$BODY" | openssl dgst -sha256 -hmac "$WEBHOOK_SECRET" | cut -d' ' -f2)

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "x-webhook-signature: $SIGNATURE" \
  -d "$BODY")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response: $RESPONSE_BODY"
echo "Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ PASSED"
else
  echo "❌ FAILED (expected 200, got $HTTP_CODE)"
fi
echo ""

echo "======================================="
echo "Tests complete"
