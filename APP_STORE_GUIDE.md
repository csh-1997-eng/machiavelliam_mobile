# Flutter App Store Submission Guide

## Overview
This guide will walk you through the complete process of preparing and submitting your Flutter "Hello World" app to the Apple App Store.

## Prerequisites
- ✅ Flutter installed and configured
- ✅ Xcode installed (latest version recommended)
- ✅ Apple Developer Account ($99/year)
- ✅ macOS development machine

## Step 1: Apple Developer Account Setup

### 1.1 Create Apple Developer Account
1. Go to [developer.apple.com](https://developer.apple.com)
2. Sign up for Apple Developer Program ($99/year)
3. Complete identity verification process
4. Wait for approval (can take 24-48 hours)

### 1.2 Configure App ID
1. Log into [App Store Connect](https://appstoreconnect.apple.com)
2. Go to "Certificates, Identifiers & Profiles"
3. Click "Identifiers" → "+" → "App IDs"
4. Create new App ID with:
   - Description: "Hello World Flutter App"
   - Bundle ID: `com.yourcompany.helloworld` (replace with your domain)
   - Capabilities: None needed for basic app

## Step 2: Update App Configuration

### 2.1 Update Bundle Identifier
Current bundle ID: `com.example.helloWorldFlutter`

You need to change this to a unique identifier:
1. Open `ios/Runner.xcodeproj/project.pbxproj`
2. Find and replace `com.example.helloWorldFlutter` with your unique bundle ID
3. Example: `com.yourcompany.helloworld`

### 2.2 Update App Display Name
1. Edit `ios/Runner/Info.plist`
2. Change `CFBundleDisplayName` from "Hello World Flutter" to your desired app name
3. Change `CFBundleName` from "hello_world_flutter" to your app name

### 2.3 Update Version Information
In `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Version 1.0.0, Build 1
```

## Step 3: App Store Connect Setup

### 3.1 Create New App
1. Go to App Store Connect
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: "Hello World App" (or your chosen name)
   - Primary Language: English
   - Bundle ID: Select the one you created
   - SKU: A unique identifier (e.g., "helloworld2024")

### 3.2 App Information
Fill in required fields:
- App Category: Utilities
- Content Rights: Check "No" (unless you have third-party content)
- Age Rating: Complete questionnaire (likely 4+ for basic app)

## Step 4: Prepare App Assets

### 4.1 App Icon Requirements
Create icons in these sizes:
- 1024×1024 (App Store)
- 180×180 (iPhone)
- 120×120 (iPhone)
- 167×167 (iPad Pro)
- 152×152 (iPad)
- 76×76 (iPad)

Replace files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 4.2 Screenshots
You'll need screenshots for:
- iPhone 6.7" Display (iPhone 15 Pro Max)
- iPhone 6.5" Display (iPhone 14 Plus, etc.)
- iPad Pro (6th generation) 12.9" Display

### 4.3 App Description
Prepare:
- App description (up to 4000 characters)
- Keywords (up to 100 characters)
- Support URL
- Marketing URL (optional)

## Step 5: Code Signing and Provisioning

### 5.1 Automatic Signing (Recommended)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project → Runner target
3. Go to "Signing & Capabilities"
4. Check "Automatically manage signing"
5. Select your Team (Apple Developer Account)
6. Xcode will automatically create provisioning profiles

### 5.2 Manual Signing (Advanced)
If you prefer manual signing:
1. Create Distribution Certificate in Apple Developer Portal
2. Create App Store Provisioning Profile
3. Download and install both in Xcode

## Step 6: Build for App Store

### 6.1 Archive the App
1. In Xcode, select "Any iOS Device" as target
2. Product → Archive
3. Wait for build to complete

### 6.2 Validate and Upload
1. In Organizer window, select your archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Choose "Upload"
5. Select "Automatically manage signing"
6. Click "Upload"

## Step 7: App Store Connect Configuration

### 7.1 App Information
1. Go to your app in App Store Connect
2. Fill in all required fields:
   - App Description
   - Keywords
   - Support URL
   - Privacy Policy URL (required)

### 7.2 Pricing and Availability
1. Set price (Free or Paid)
2. Choose availability territories
3. Set release date

### 7.3 App Review Information
1. Contact information
2. Demo account (if needed)
3. Notes for reviewer

## Step 8: Submit for Review

### 8.1 Final Checks
- [ ] All required fields completed
- [ ] Screenshots uploaded
- [ ] App icon uploaded
- [ ] App builds successfully
- [ ] Tested on device/simulator

### 8.2 Submit
1. Click "Submit for Review"
2. Wait for review (typically 24-48 hours)
3. Check email for status updates

## Step 9: Post-Submission

### 9.1 Review Process
- Apple will review your app
- You may receive feedback requiring changes
- Respond to any review notes

### 9.2 Release
- Once approved, you can release immediately or schedule release
- App will be available on App Store within 24 hours

## Troubleshooting

### Common Issues:

1. **Code Signing Errors**
   - Ensure Apple Developer Account is active
   - Check bundle identifier matches App Store Connect
   - Verify certificates are valid

2. **Build Errors**
   - Clean build folder (Product → Clean Build Folder)
   - Delete DerivedData
   - Update Flutter and dependencies

3. **Upload Failures**
   - Check internet connection
   - Verify app size is under 4GB
   - Ensure all required metadata is complete

## Commands Reference

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Build for iOS
flutter build ios --release

# Open iOS project in Xcode
open ios/Runner.xcworkspace

# Check Flutter doctor
flutter doctor
```

## Next Steps After Approval

1. Monitor app performance in App Store Connect
2. Respond to user reviews
3. Plan updates and new features
4. Consider marketing and promotion

## Resources

- [Flutter iOS Deployment Guide](https://docs.flutter.dev/deployment/ios)
- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

---

**Note**: This is a basic guide. For production apps, consider additional requirements like privacy policy, terms of service, and compliance with App Store guidelines.
