#!/bin/bash

# Script to build sub-projects for Xcode Cloud
# This script builds BleLibrary and FotaLibrary frameworks

set -e

echo "🔧 Building sub-projects frameworks..."

# Create build directories
mkdir -p RSL_Fota/BleLibrary/build/Release
mkdir -p RSL_Fota/FotaLibrary/build/Release

# Build BleLibrary
echo "📱 Building BleLibrary..."
xcodebuild \
  -project RSL_Fota/BleLibrary/BleLibrary.xcodeproj \
  -scheme BleLibrary \
  -configuration Release \
  -derivedDataPath build/BleLibrary \
  -sdk iphoneos \
  ONLY_ACTIVE_ARCH=NO \
  BITCODE_GENERATION_MODE=bitcode \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_ENTITLEMENTS="" \
  CODE_SIGNING_ALLOWED=NO

# Build FotaLibrary  
echo "📱 Building FotaLibrary..."
xcodebuild \
  -project RSL_Fota/FotaLibrary/FotaLibrary.xcodeproj \
  -scheme FotaLibrary \
  -configuration Release \
  -derivedDataPath build/FotaLibrary \
  -sdk iphoneos \
  ONLY_ACTIVE_ARCH=NO \
  BITCODE_GENERATION_MODE=bitcode \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_ENTITLEMENTS="" \
  CODE_SIGNING_ALLOWED=NO

# Copy frameworks to expected locations
echo "📋 Copying frameworks to expected locations..."

# Create target directories
mkdir -p RSL_Fota/BleLibrary/build/Release
mkdir -p RSL_Fota/FotaLibrary/build/Release
mkdir -p Frameworks

# Copy to sub-project locations
cp -R build/BleLibrary/Build/Products/Release-iphoneos/BleLibrary.framework RSL_Fota/BleLibrary/build/Release/ || echo "⚠️  BleLibrary.framework copy failed"
cp -R build/FotaLibrary/Build/Products/Release-iphoneos/FotaLibrary.framework RSL_Fota/FotaLibrary/build/Release/ || echo "⚠️  FotaLibrary.framework copy failed"

# Also copy to project root for easier reference
cp -R build/BleLibrary/Build/Products/Release-iphoneos/BleLibrary.framework Frameworks/ || echo "⚠️  BleLibrary.framework copy to Frameworks failed"
cp -R build/FotaLibrary/Build/Products/Release-iphoneos/FotaLibrary.framework Frameworks/ || echo "⚠️  FotaLibrary.framework copy to Frameworks failed"

# Verify frameworks exist
if [ -d "RSL_Fota/BleLibrary/build/Release/BleLibrary.framework" ]; then
    echo "✅ BleLibrary.framework built successfully"
else
    echo "❌ BleLibrary.framework not found"
    exit 1
fi

if [ -d "RSL_Fota/FotaLibrary/build/Release/FotaLibrary.framework" ]; then
    echo "✅ FotaLibrary.framework built successfully"
else
    echo "❌ FotaLibrary.framework not found"
    exit 1
fi

echo "🎉 All sub-projects built successfully!"

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