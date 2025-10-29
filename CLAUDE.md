# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is xDrip4iOS, a continuous glucose monitoring (CGM) application for iOS that supports various glucose monitoring devices and transmitters. The app provides real-time glucose readings, alerts, data visualization, and integration with Nightscout and HealthKit.

## Build and Development Commands

### Fastlane Commands
```bash
# Install dependencies
bundle install

# Build the application (builds sub-projects first)
bundle exec fastlane ios build_xdrip4ios

# Upload to TestFlight
bundle exec fastlane ios release

# Provision identifiers and certificates
bundle exec fastlane ios identifiers
bundle exec fastlane ios certs

# Validate secrets and configuration
bundle exec fastlane ios validate_secrets

# Nuke certificates (emergency use only)
bundle exec fastlane ios nuke_certs
```

### Build Scripts
```bash
# Build sub-projects (BleLibrary, FotaLibrary)
./build_subprojects.sh

# Clean frameworks
./clean_framework.sh

# Test solution (if needed)
./test_solution.sh

# Fix framework references in Xcode project
ruby fix_framework_references.rb
```

### Xcode Development
```bash
# Open project in Xcode
open xdrip.xcworkspace

# Build for specific simulator
xcodebuild -workspace xdrip.xcworkspace -scheme xdrip -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build
```

## Architecture Overview

### Core Architecture
- **Swift/iOS Application**: Primary app written in Swift with some Objective-C components
- **Core Data**: Local data persistence for glucose readings, sensors, alerts, and settings
- **Bluetooth Transmitters**: Support for multiple CGM devices via Bluetooth
- **Multi-target App**: Includes main app, widget extension, watch app, and notification extensions
- **Sub-project Dependencies**: BleLibrary and FotaLibrary frameworks built separately

### Key Components

#### App Structure
- **Main App** (`xDrip/`): Core application with UI and business logic
- **Widget Extension** (`xDrip Widget/`): Home screen widget for glucose display
- **Watch App** (`xDrip Watch App/`): Apple Watch companion app
- **Watch Complication** (`xDrip Watch Complication/`): Watch face complications
- **Notification Extension** (`xDrip Notification Context Extension/`): Rich notifications

#### Core Directories
- **Core Data/**: Data model classes, accessors, and extensions
- **View Controllers/**: UIKit-based view controllers organized by function
- **BluetoothTransmitter/**: Device-specific transmitter implementations
- **BluetoothPeripheral/**: Peripheral device management and communication
- **Managers/**: Core business logic managers (CoreData, Bluetooth, Charts, etc.)
- **Calibration/**: Glucose calibration algorithms and protocols
- **Treatments/**: Insulin/carb treatment tracking
- **Utilities/**: Helper utilities and housekeeping functions
- **SwiftUIViews/**: Modern SwiftUI views for newer features
- **Constants/**: Application-wide constants organized by category

#### Sub-projects
- **RSL_Fota/BleLibrary/**: Bluetooth communication library
- **RSL_Fota/FotaLibrary/**: Firmware Over-The-Air update library
- **Frameworks/**: Built framework outputs

#### Supported Devices
- Dexcom G4 (with xBridge)
- Dexcom G5 and G6
- MiaoMiao 1 and 2
- Blucon
- Bubble
- Droplet 1
- Atom
- Libre 2
- M5Stack/M5StickC (via Bluetooth)

### Key Technologies
- **Swift**: Primary development language
- **UIKit**: Main UI framework (with some SwiftUI components)
- **Core Data**: Local data persistence
- **Bluetooth**: Core Bluetooth framework for device communication
- **HealthKit**: Integration with Apple Health
- **Charts**: Custom glucose charting with Swift Charts
- **Fastlane**: Build automation and deployment
- **Xcodeproj**: Ruby gem for Xcode project manipulation

### Data Flow
1. **Bluetooth Transmitters** receive glucose data from devices
2. **Core Data Managers** persist and retrieve data
3. **Calibration Engine** processes raw glucose values
4. **View Controllers** display data and handle user interaction
5. **Chart Managers** render glucose trends and history
6. **Alert System** monitors for high/low glucose levels
7. **Upload Managers** sync data with Nightscout and other services

## Development Notes

### Environment Variables Required for Build
- `TEAMID`: Apple Developer Team ID
- `GH_PAT`: GitHub Personal Access Token
- `FASTLANE_KEY_ID`: App Store Connect API Key ID
- `FASTLANE_ISSUER_ID`: App Store Connect Issuer ID
- `FASTLANE_KEY`: App Store Connect API Key content
- `GITHUB_WORKSPACE`: GitHub workspace path (CI only)
- `GITHUB_REPOSITORY_OWNER`: Repository owner (CI only)
- `DEVICE_NAME`: iOS device name (CI only)
- `DEVICE_ID`: iOS device ID (CI only)

### External Dependencies
- **Bugly**: Crash reporting framework
- **LibOutshine**: Third-party framework (likely for device communication)
- **Fastlane**: Build automation and deployment
- **Xcodeproj**: Ruby gem for Xcode project manipulation

### Key Configuration Files
- `xdrip.xcodeproj/`: Xcode project configuration
- `xdrip.xcworkspace/`: Xcode workspace (main entry point)
- `fastlane/Fastfile`: Build automation configuration
- `xDrip/Core Data/xdrip.xcdatamodeld/`: Core Data model
- Various `.entitlements` files for app extensions
- `build_subprojects.sh`: Sub-project build script
- `fix_framework_references.rb`: Framework reference fixing script

### Build Process
1. Sub-projects (BleLibrary, FotaLibrary) are built first using `build_subprojects.sh`
2. Frameworks are copied to expected locations
3. Framework references in Xcode project are fixed
4. Main app is built with fastlane
5. Code signing is configured for all targets

### Testing and Quality
- No specific test commands found in repository
- Uses fastlane for CI/CD pipeline
- Crash reporting via Bugly framework
- Multi-target build with automatic code signing