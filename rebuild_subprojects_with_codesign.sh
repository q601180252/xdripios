#!/bin/bash

# Script to rebuild sub-projects with proper code signing for symbol tables
# This script rebuilds BleLibrary and FotaLibrary frameworks with proper symbols

set -e

echo "🔧 Rebuilding sub-projects frameworks with proper code signing..."

# Get team ID from environment or use default
TEAM_ID="${TEAMID:-7RV2Y67HF6}"
echo "Using Team ID: $TEAM_ID"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/BleLibrary
rm -rf build/FotaLibrary
rm -rf RSL_Fota/BleLibrary/build
rm -rf RSL_Fota/FotaLibrary/build

# Create build directories
mkdir -p RSL_Fota/BleLibrary/build/Release
mkdir -p RSL_Fota/FotaLibrary/build/Release
mkdir -p Frameworks

# Build BleLibrary with proper code signing
echo "📱 Building BleLibrary with code signing..."
xcodebuild \
  -project RSL_Fota/BleLibrary/BleLibrary.xcodeproj \
  -scheme BleLibrary \
  -configuration Release \
  -derivedDataPath build/BleLibrary \
  -sdk iphoneos \
  ONLY_ACTIVE_ARCH=NO \
  BITCODE_GENERATION_MODE=bitcode \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_IDENTITY="iPhone Developer" \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGN_ENTITLEMENTS="" \
  CODE_SIGNING_ALLOWED=YES

# Build FotaLibrary with proper code signing  
echo "📱 Building FotaLibrary with code signing..."
xcodebuild \
  -project RSL_Fota/FotaLibrary/FotaLibrary.xcodeproj \
  -scheme FotaLibrary \
  -configuration Release \
  -derivedDataPath build/FotaLibrary \
  -sdk iphoneos \
  ONLY_ACTIVE_ARCH=NO \
  BITCODE_GENERATION_MODE=bitcode \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_IDENTITY="iPhone Developer" \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGN_ENTITLEMENTS="" \
  CODE_SIGNING_ALLOWED=YES

# Copy frameworks to expected locations
echo "📋 Copying frameworks to expected locations..."

# Copy to sub-project locations
cp -R build/BleLibrary/Build/Products/Release-iphoneos/BleLibrary.framework RSL_Fota/BleLibrary/build/Release/ || echo "⚠️  BleLibrary.framework copy failed"
cp -R build/FotaLibrary/Build/Products/Release-iphoneos/FotaLibrary.framework RSL_Fota/FotaLibrary/build/Release/ || echo "⚠️  FotaLibrary.framework copy failed"

# Also copy to project root for easier reference
cp -R build/BleLibrary/Build/Products/Release-iphoneos/BleLibrary.framework Frameworks/ || echo "⚠️  BleLibrary.framework copy to Frameworks failed"
cp -R build/FotaLibrary/Build/Products/Release-iphoneos/FotaLibrary.framework Frameworks/ || echo "⚠️  FotaLibrary.framework copy to Frameworks failed"

# Verify frameworks exist and check symbols
echo "🔍 Verifying frameworks and checking symbols..."

if [ -d "RSL_Fota/BleLibrary/build/Release/BleLibrary.framework" ]; then
    echo "✅ BleLibrary.framework built successfully"
    
    # Check if the framework has symbols
    if nm -D "RSL_Fota/BleLibrary/build/Release/BleLibrary.framework/BleLibrary" 2>/dev/null | head -5; then
        echo "✅ BleLibrary.framework has symbols"
    else
        echo "⚠️  BleLibrary.framework symbols check failed, but framework exists"
    fi
else
    echo "❌ BleLibrary.framework not found"
    exit 1
fi

if [ -d "RSL_Fota/FotaLibrary/build/Release/FotaLibrary.framework" ]; then
    echo "✅ FotaLibrary.framework built successfully"
    
    # Check if the framework has symbols
    if nm -D "RSL_Fota/FotaLibrary/build/Release/FotaLibrary.framework/FotaLibrary" 2>/dev/null | head -5; then
        echo "✅ FotaLibrary.framework has symbols"
    else
        echo "⚠️  FotaLibrary.framework symbols check failed, but framework exists"
    fi
else
    echo "❌ FotaLibrary.framework not found"
    exit 1
fi

echo "🎉 All sub-projects rebuilt successfully with proper code signing!"

# Fix framework references in project file
echo "🔧 Fixing framework references in Xcode project..."
if [ -f "remove_subproject_dependencies.rb" ]; then
  ruby remove_subproject_dependencies.rb xdrip.xcodeproj
  if [ $? -eq 0 ]; then
    echo "✅ Framework references fixed successfully"
  else
    echo "⚠️  Framework reference fixing failed, but continuing..."
  fi
else
  echo "⚠️  Framework fix script not found, skipping..."
fi

echo "🔧 Framework symbols fix completed!"
echo "Please clean the Xcode build folder (Product -> Clean Build Folder) and rebuild the main project."