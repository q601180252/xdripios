#!/bin/bash

# Xcode Cloud Build Script
# This script builds the project for Xcode Cloud without subproject dependencies

set -e

echo "🚀 Starting Xcode Cloud build..."

# Clean any existing subproject references that might cause issues
echo "🧹 Cleaning project references..."
if [ -f "remove_subproject_dependencies.rb" ]; then
    ruby remove_subproject_dependencies.rb xdrip.xcodeproj
fi

# Verify frameworks exist
echo "📋 Verifying frameworks..."
if [ ! -d "Frameworks/BleLibrary.framework" ]; then
    echo "❌ BleLibrary.framework not found in Frameworks/"
    exit 1
fi

if [ ! -d "Frameworks/FotaLibrary.framework" ]; then
    echo "❌ FotaLibrary.framework not found in Frameworks/"
    exit 1
fi

# Check if frameworks have symbols
echo "🔍 Checking framework symbols..."
if ! nm "Frameworks/BleLibrary.framework/BleLibrary" 2>/dev/null | head -3 > /dev/null; then
    echo "❌ BleLibrary.framework symbols missing"
    exit 1
fi

if ! nm "Frameworks/FotaLibrary.framework/FotaLibrary" 2>/dev/null | head -3 > /dev/null; then
    echo "❌ FotaLibrary.framework symbols missing"
    exit 1
fi

echo "✅ All frameworks verified successfully"

# Build the project
echo "🔨 Building project..."
xcodebuild \
    -workspace xdrip.xcworkspace \
    -scheme xdrip \
    -configuration "$CONFIGURATION" \
    -destination "$DESTINATION" \
    -allowProvisioningUpdates \
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
    PROVISIONING_PROFILE_SPECIFIER="$PROVISIONING_PROFILE_SPECIFIER" \
    DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"

echo "🎉 Xcode Cloud build completed successfully!"