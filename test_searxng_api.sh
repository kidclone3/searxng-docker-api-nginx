#!/bin/bash
# Script để test SearxNG API với API key

API_KEY="sk-searxng-4f0158d9fc0a9750d55e338fef1092f0"
SEARXNG_URL="http://localhost:8088"

echo "=== Testing SearxNG API with API Key ==="
echo ""

# Test 1: Không có API key (should fail)
echo "Test 1: Request WITHOUT API key (should return 401)"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  "${SEARXNG_URL}/search?q=test&format=json" | head -20
echo ""
echo "---"
echo ""

# Test 2: Có API key hợp lệ (should succeed)
echo "Test 2: Request WITH valid API key (should return 200)"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  -H "X-API-Key: ${API_KEY}" \
  "${SEARXNG_URL}/search?q=orange+pi&format=json" | head -20
echo ""
echo "---"
echo ""

# Test 3: API key không hợp lệ (should fail)
echo "Test 3: Request with INVALID API key (should return 401)"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  -H "X-API-Key: invalid-key-123" \
  "${SEARXNG_URL}/search?q=test&format=json" | head -20
echo ""
echo "---"
echo ""

# Test 4: Health check (không cần API key)
echo "Test 4: Health check endpoint (no API key needed)"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  "${SEARXNG_URL}/healthz"
echo ""
echo "---"
echo ""

echo "=== Testing Complete ==="