# CloudKit Setup Guide for PagePocket

## Quick Setup (5 minutes)

Your `PagePocket.entitlements` file already exists and is correctly configured. You just need to link it in Xcode.

### Step-by-Step Instructions

1. **Open Xcode Project**
   - Open `iOS-App/PagePocket.xcodeproj` (or `.xcworkspace` if you have one)

2. **Select the Target**
   - Click on the "PagePocket" project in the left sidebar
   - Select the "PagePocket" target (not the project)

3. **Add CloudKit Capability (Method 1 - Recommended)**
   - Go to the **"Signing & Capabilities"** tab
   - Click the **"+ Capability"** button (top left)
   - Search for and add **"CloudKit"**
   - Xcode will automatically:
     - Add the CloudKit capability
     - Link the entitlements file
     - Configure the container identifier

4. **Verify Entitlements File is Linked (Method 2 - If Method 1 didn't work)**
   - Go to the **"Build Settings"** tab
   - Search for "Code Signing Entitlements"
   - Ensure `PagePocket/PagePocket.entitlements` is set as the value
   - If it's not there, add it manually

5. **Verify the Setup**
   - In "Signing & Capabilities", you should see:
     - ✅ CloudKit capability added
     - ✅ Container: `iCloud.com.bytecraft.PagePocket` (or similar)
     - ✅ Entitlements file linked

## What Happens Next

### For Development
- The app will continue using `MockCloudSyncService` in DEBUG builds
- CloudKit won't actually be used until you build for release

### For Production
- Release builds will use `CloudKitSyncService`
- CloudKit will automatically initialize when a premium user saves a page
- You'll need to set up the CloudKit schema in CloudKit Dashboard (see below)

## CloudKit Dashboard Setup (After Adding Capability)

Once you've added the CloudKit capability in Xcode:

1. **Go to CloudKit Dashboard**
   - Visit: https://icloud.developer.apple.com/dashboard
   - Sign in with your Apple Developer account
   - Select your app: `com.bytecraft.PagePocket`

2. **Initialize the Container**
   - If prompted, click "Initialize" to create your CloudKit container
   - This creates the database schema

3. **Create Record Type: `SavedPage`**
   - Go to "Schema" → "Record Types"
   - Click "+" to create a new record type
   - Name it: `SavedPage`
   - Add the following fields:

   | Field Name | Type | Required |
   |------------|------|----------|
   | `title` | String | Yes |
   | `urlString` | String | Yes |
   | `source` | String | Yes |
   | `createdAt` | Date/Time | Yes |
   | `statusRawValue` | String | Yes |
   | `contentTypeRawValue` | String | Yes |
   | `htmlContent` | String | No |
   | `lastAccessedAt` | Date/Time | No |
   | `estimatedReadTime` | Double | Yes |

4. **Set Indexes** (Optional but Recommended)
   - Add an index on `createdAt` for faster queries
   - Add an index on `urlString` for duplicate detection

5. **Deploy to Production**
   - Once you're done testing in Development environment
   - Go to "Deploy Schema Changes" → "Deploy to Production"

## Testing CloudKit

### In Development (DEBUG)
- Uses `MockCloudSyncService` - no actual CloudKit calls
- Test the sync UI and flow

### In Release Build
1. Build for Release or TestFlight
2. Sign in to iCloud on your device
3. Upgrade to premium (or use TestFlight with sandbox account)
4. Save a page
5. It should automatically upload to iCloud
6. Check CloudKit Dashboard → Data → Private Database to verify

### Testing Checklist
- [ ] CloudKit capability added in Xcode
- [ ] Entitlements file linked
- [ ] CloudKit container initialized in dashboard
- [ ] SavedPage record type created
- [ ] Test in Release build with premium subscription
- [ ] Verify page uploads to CloudKit dashboard
- [ ] Test sync on multiple devices (if you have them)

## Troubleshooting

### "CloudKit not available" error
- Check that CloudKit capability is enabled
- Verify iCloud account is signed in on device
- Check device has internet connection

### "Container not found" error
- Go to CloudKit Dashboard and initialize the container
- Wait a few minutes for propagation

### "Quota exceeded" error
- User's iCloud storage is full
- App will show appropriate error message

### Sync not working in production
- Verify you're using a Release build (not DEBUG)
- Check that `#if DEBUG` is correctly using mock vs real service
- Ensure premium subscription is active

## Current Configuration

Your entitlements file is already correct:
```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.$(CFBundleIdentifier)</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

This will create a container like: `iCloud.com.bytecraft.PagePocket`

## Next Steps After Setup

1. ✅ Add CloudKit capability in Xcode (this guide)
2. ✅ Initialize CloudKit container in dashboard
3. ✅ Create SavedPage record type
4. Test with TestFlight build
5. Deploy schema to production
6. Ready for App Store submission!

---

**Estimated Time:** 5-10 minutes for Xcode setup, 15-20 minutes for CloudKit Dashboard setup

**Status:** Code is ready, just needs Xcode configuration ✅

