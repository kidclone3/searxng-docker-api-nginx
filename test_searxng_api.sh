#!/bin/bash
# Script để test SearxNG API với API key
# Đọc API key từ .env (không hardcode trong script)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
    echo "ERROR: .env not found. Run: cp .env.searxng.example .env  (or generate keys)"
    exit 1
fi

# shellcheck disable=SC1091
source "$SCRIPT_DIR/.env"
API_KEY="${SEARXNG_API_KEY:?SEARXNG_API_KEY not set in .env}"
SEARXNG_URL="${SEARXNG_URL:-http://127.0.0.1:8088}"

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
  -H "X-API-Key: invalid-key-12345" \
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
