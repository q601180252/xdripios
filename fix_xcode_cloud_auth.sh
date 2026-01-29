#!/bin/bash

# Xcode Cloud Authentication Fix Script
# This script helps resolve Xcode Cloud API 401 authentication errors

echo "🔧 Xcode Cloud Authentication Fix"
echo "================================"

# 1. Check Xcode version
echo "📱 Checking Xcode version..."
XCODE_VERSION=$(xcodebuild -version | head -1)
echo "   Xcode version: $XCODE_VERSION"

# 2. Check developer account status
echo ""
echo "🔑 Checking developer accounts..."
ACCOUNTS=$(defaults read com.apple.dt.Xcode IDEAccounts)
if [ $? -eq 0 ]; then
    echo "   ✅ Developer accounts found"
    echo "   Account count: $(echo "$ACCOUNTS" | grep -c "DTSDeveloperAccount")"
else
    echo "   ❌ No developer accounts found"
fi

# 3. Check for Xcode Cloud configuration
echo ""
echo "☁️  Checking Xcode Cloud configuration..."
if [ -d "$HOME/Library/Developer/XcodeCloud" ]; then
    echo "   ✅ Xcode Cloud configuration exists"
else
    echo "   ⚠️  Xcode Cloud configuration not found"
fi

# 4. Check keychain access
echo ""
echo "🔐 Checking keychain access..."
security list-keychains | grep -E "(Xcode|Developer)" || echo "   ⚠️  No Xcode-specific keychains found"

# 5. Check network connectivity
echo ""
echo "🌐 Checking network connectivity..."
if curl -s https://api.apple-cloudkit.com > /dev/null 2>&1; then
    echo "   ✅ Apple CloudKit API reachable"
else
    echo "   ❌ Apple CloudKit API unreachable"
fi

if curl -s https://appstoreconnect.apple.com > /dev/null 2>&1; then
    echo "   ✅ App Store Connect reachable"
else
    echo "   ❌ App Store Connect unreachable"
fi

# 6. Check for Xcode preferences corruption
echo ""
echo "🔍 Checking Xcode preferences..."
XCODE_PREFS="$HOME/Library/Preferences/com.apple.dt.Xcode.plist"
if [ -f "$XCODE_PREFS" ]; then
    echo "   ✅ Xcode preferences file exists"
else
    echo "   ❌ Xcode preferences file missing"
fi

# 7. Check for Xcode Cloud cache
echo ""
echo "🗂️  Checking Xcode Cloud cache..."
XCODE_CLOUD_CACHE="$HOME/Library/Caches/com.apple.dt.XcodeCloud"
if [ -d "$XCODE_CLOUD_CACHE" ]; then
    echo "   ✅ Xcode Cloud cache exists"
    CACHE_SIZE=$(du -sh "$XCODE_CLOUD_CACHE" | cut -f1)
    echo "   Cache size: $CACHE_SIZE"
else
    echo "   ⚠️  Xcode Cloud cache not found"
fi

# 8. Check system date and time
echo ""
echo "🕐 Checking system date and time..."
echo "   Current time: $(date)"
echo "   Timezone: $(timezone)"

# 9. Check for proxy settings
echo ""
echo "🔌 Checking network proxy settings..."
NETWORK_SERVICE=$(networksetup -listallnetworkservices | head -1)
if [ -n "$NETWORK_SERVICE" ]; then
    PROXY_STATUS=$(networksetup -getwebproxy "$NETWORK_SERVICE")
    echo "   Proxy status: $(echo "$PROXY_STATUS" | grep "Enabled" | cut -d: -f2 | xargs)"
else
    echo "   ⚠️  Could not determine network service"
fi

echo ""
echo "💡 Xcode Cloud Authentication Troubleshooting Steps:"
echo "================================================"
echo "1. Restart Xcode completely"
echo "2. Go to Xcode → Preferences → Accounts"
echo "3. Remove your developer account and re-add it"
echo "4. Ensure you have Xcode Cloud permissions in App Store Connect"
echo "5. Check that your Apple Developer account is in good standing"
echo "6. Clear Xcode Cloud cache: rm -rf ~/Library/Caches/com.apple.dt.XcodeCloud"
echo "7. Reset Xcode preferences: rm ~/Library/Preferences/com.apple.dt.Xcode.plist"
echo "8. Check system date/time is correct"
echo "9. Disable any VPN or proxy connections"
echo "10. Try accessing App Store Connect directly in a web browser"

echo ""
echo "🔧 If the problem persists:"
echo "1. Contact Apple Developer Support"
echo "2. Check Apple System Status page for service outages"
echo "3. Try setting up Xcode Cloud on a different Mac"
echo "4. Verify your Apple ID has the necessary developer permissions"