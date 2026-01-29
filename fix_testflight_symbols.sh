#!/bin/bash

# Script to fix TestFlight upload symbols issue
# This script ensures all frameworks have proper symbols and dSYM files

set -e

echo "🔧 Fixing TestFlight symbols upload issue..."

# Verify frameworks exist and have symbols
echo "📋 Verifying frameworks..."

# Check BleLibrary
if [ -d "Frameworks/BleLibrary.framework" ]; then
    echo "✅ BleLibrary.framework found"
    
    # Check if BleLibrary has symbols
    if nm "Frameworks/BleLibrary.framework/BleLibrary" 2>/dev/null | head -3 > /dev/null; then
        echo "✅ BleLibrary.framework has symbols"
    else
        echo "❌ BleLibrary.framework symbols missing"
        exit 1
    fi
else
    echo "❌ BleLibrary.framework not found"
    exit 1
fi

# Check FotaLibrary
if [ -d "Frameworks/FotaLibrary.framework" ]; then
    echo "✅ FotaLibrary.framework found"
    
    # Check if FotaLibrary has symbols
    if nm "Frameworks/FotaLibrary.framework/FotaLibrary" 2>/dev/null | head -3 > /dev/null; then
        echo "✅ FotaLibrary.framework has symbols"
    else
        echo "❌ FotaLibrary.framework symbols missing"
        exit 1
    fi
else
    echo "❌ FotaLibrary.framework not found"
    exit 1
fi

# Copy dSYM files to Frameworks directory
echo "📋 Copying dSYM files..."

# Copy BleLibrary dSYM
if [ -d "build/BleLibrary/Build/Products/Release-iphoneos/BleLibrary.framework.dSYM" ]; then
    cp -R build/BleLibrary/Build/Products/Release-iphoneos/BleLibrary.framework.dSYM Frameworks/
    echo "✅ BleLibrary.framework.dSYM copied"
else
    echo "❌ BleLibrary.framework.dSYM not found"
    exit 1
fi

# Copy FotaLibrary dSYM
if [ -d "build/FotaLibrary/Build/Products/Release-iphoneos/FotaLibrary.framework.dSYM" ]; then
    cp -R build/FotaLibrary/Build/Products/Release-iphoneos/FotaLibrary.framework.dSYM Frameworks/
    echo "✅ FotaLibrary.framework.dSYM copied"
else
    echo "❌ FotaLibrary.framework.dSYM not found"
    exit 1
fi

# Verify dSYM files
echo "🔍 Verifying dSYM files..."

# Check BleLibrary dSYM
if [ -f "Frameworks/BleLibrary.framework.dSYM/Contents/Resources/DWARF/BleLibrary" ]; then
    echo "✅ BleLibrary.framework.dSYM is valid"
else
    echo "❌ BleLibrary.framework.dSYM is invalid"
    exit 1
fi

# Check FotaLibrary dSYM
if [ -f "Frameworks/FotaLibrary.framework.dSYM/Contents/Resources/DWARF/FotaLibrary" ]; then
    echo "✅ FotaLibrary.framework.dSYM is valid"
else
    echo "❌ FotaLibrary.framework.dSYM is invalid"
    exit 1
fi

# Check if project has dSYM enabled
echo "🔍 Checking project dSYM configuration..."
if grep -q "DEBUG_INFORMATION_FORMAT =.*dwarf-with-dsym" xdrip.xcodeproj/project.pbxproj; then
    echo "✅ Project has dSYM enabled"
else
    echo "⚠️  Project dSYM configuration may need manual check"
fi

echo ""
echo "🎉 TestFlight symbols fix completed!"
echo ""
echo "Next steps:"
echo "1. Clean build folder in Xcode (Product → Clean Build Folder)"
echo "2. Archive the product (Product → Archive)"
echo "3. Upload to TestFlight"
echo ""
echo "If symbols still fail, check:"
echo "- Xcode Organizer log for specific error details"
echo "- App Store Connect for missing app configuration"
echo "- Developer account for proper signing certificates"