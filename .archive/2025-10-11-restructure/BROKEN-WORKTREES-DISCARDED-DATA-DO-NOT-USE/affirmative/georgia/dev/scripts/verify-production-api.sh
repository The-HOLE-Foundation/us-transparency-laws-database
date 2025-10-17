#!/bin/bash

# Production API Verification Script
# Verifies Supabase REST API deployment for v0.11.1
# Run this after promoting Development branch to Production

echo "========================================="
echo "Supabase Production API Verification"
echo "========================================="
echo ""

# Configuration
SUPABASE_URL="https://befpnwcokngtrljxskfz.supabase.co"
echo "📍 Testing: $SUPABASE_URL"
echo ""

# Note: Replace ANON_KEY with your actual anon key from Supabase dashboard
# Go to: Project Settings → API → anon/public key
echo "⚠️  IMPORTANT: Update ANON_KEY in this script with your actual key"
echo "   Location: Supabase Dashboard → Project Settings → API"
echo ""

# Placeholder - replace with actual key
ANON_KEY="YOUR_ANON_KEY_HERE"

if [ "$ANON_KEY" = "YOUR_ANON_KEY_HERE" ]; then
    echo "❌ ERROR: Please set ANON_KEY to your actual Supabase anon key"
    echo ""
    echo "To get your anon key:"
    echo "1. Go to https://supabase.com/dashboard"
    echo "2. Select project: befpnwcokngtrljxskfz"
    echo "3. Go to Settings → API"
    echo "4. Copy the 'anon/public' key"
    echo "5. Paste it in this script where it says YOUR_ANON_KEY_HERE"
    exit 1
fi

echo "Running tests..."
echo ""

# Test 1: Jurisdictions Count
echo "1️⃣  Testing jurisdictions table..."
JURISDICTIONS=$(curl -s "${SUPABASE_URL}/rest/v1/jurisdictions?select=count" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Prefer: count=exact")

if echo "$JURISDICTIONS" | grep -q "count"; then
    COUNT=$(echo "$JURISDICTIONS" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    if [ "$COUNT" = "52" ]; then
        echo "   ✅ Jurisdictions count: $COUNT (expected: 52)"
    else
        echo "   ⚠️  Jurisdictions count: $COUNT (expected: 52)"
    fi
else
    echo "   ❌ Failed to query jurisdictions"
    echo "   Response: $JURISDICTIONS"
fi
echo ""

# Test 2: Exemptions Count
echo "2️⃣  Testing exemptions table..."
EXEMPTIONS=$(curl -s "${SUPABASE_URL}/rest/v1/exemptions?select=count" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Prefer: count=exact")

if echo "$EXEMPTIONS" | grep -q "count"; then
    COUNT=$(echo "$EXEMPTIONS" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    if [ "$COUNT" = "365" ]; then
        echo "   ✅ Exemptions count: $COUNT (expected: 365)"
    else
        echo "   ⚠️  Exemptions count: $COUNT (expected: 365)"
    fi
else
    echo "   ❌ Failed to query exemptions"
    echo "   Response: $EXEMPTIONS"
fi
echo ""

# Test 3: Transparency Map View
echo "3️⃣  Testing transparency_map_display view..."
MAP_VIEW=$(curl -s "${SUPABASE_URL}/rest/v1/transparency_map_display?select=jurisdiction_name,jurisdiction_code,response_timeline_days&limit=3" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}")

if echo "$MAP_VIEW" | grep -q "jurisdiction_name"; then
    echo "   ✅ Transparency map view accessible"
    echo "   Sample data:"
    echo "$MAP_VIEW" | python3 -m json.tool 2>/dev/null | head -15 || echo "$MAP_VIEW"
else
    echo "   ❌ Failed to query transparency_map_display"
    echo "   Response: $MAP_VIEW"
fi
echo ""

# Test 4: Exemptions with Jurisdiction Context
echo "4️⃣  Testing exemptions with jurisdiction context..."
CA_EXEMPTIONS=$(curl -s "${SUPABASE_URL}/rest/v1/exemptions?jurisdiction_name=eq.California&select=category,jurisdiction_name,jurisdiction_slug&limit=2" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}")

if echo "$CA_EXEMPTIONS" | grep -q "California"; then
    echo "   ✅ Jurisdiction-enhanced exemptions working"
    echo "   Sample California exemptions:"
    echo "$CA_EXEMPTIONS" | python3 -m json.tool 2>/dev/null | head -10 || echo "$CA_EXEMPTIONS"
else
    echo "   ❌ Failed to query California exemptions"
    echo "   Response: $CA_EXEMPTIONS"
fi
echo ""

# Summary
echo "========================================="
echo "Verification Complete"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. If all tests passed ✅, your production API is ready!"
echo "2. Update .env.production in your React applications"
echo "3. Configure Supabase Authentication (Phase 2)"
echo "4. Generate TypeScript types: npx supabase gen types typescript --linked"
echo ""
