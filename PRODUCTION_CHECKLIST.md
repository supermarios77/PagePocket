# PagePocket Production Checklist

## ⚠️ REQUIRED CHANGES BEFORE RELEASE

### 1. Bundle ID Consistency ⚠️ CRITICAL

**Current State:**
- Bundle ID in Xcode: `com.bytecraft.PagePocket`
- Product IDs in code: `com.pagepocket.subscription.*`

**Action Required:**
Choose one approach:

**Option A: Change Product IDs to match Bundle ID (Recommended)**
```swift
// Update ProductIDs.swift:
case weekly = "com.bytecraft.PagePocket.subscription.weekly"
case monthly = "com.bytecraft.PagePocket.subscription.monthly"
case yearly = "com.bytecraft.PagePocket.subscription.yearly"
```

**Option B: Change Bundle ID to match Product IDs**
- Update Xcode project settings to use `com.pagepocket`
- Note: This affects your app's identity

### 2. CloudKit Entitlements Setup

**Current State:**
- CloudKit code is implemented ✅
- Entitlements file created ✅
- **NOT YET ADDED TO XCODE PROJECT** ⚠️

**Action Required:**
1. Open Xcode project
2. Select the PagePocket target
3. Go to "Signing & Capabilities" tab
4. Add "CloudKit" capability
5. Or manually add `PagePocket.entitlements` to the target build settings

### 3. App Store Connect Configuration

**Required Steps:**
1. Create subscription products matching your chosen Product IDs
2. Set pricing (suggested):
   - Weekly: $2.99/week
   - Monthly: $4.99/month  
   - Yearly: $39.99/year
3. Configure subscription groups and tiers
4. Add subscription terms and privacy policy

### 4. StoreKit Configuration File (For Testing)

**Current State:** Not created

**Action Required:**
1. In Xcode: File → New → File → StoreKit Configuration File
2. Add three subscription products
3. Match Product IDs exactly
4. Enable "Automatically sign purchases"
5. Set this as your active scheme's StoreKit configuration

### 5. App Capabilities Verification

**Check in Xcode:**
- ✅ CloudKit (needs to be added in Signing & Capabilities)
- ✅ In-App Purchase capability should auto-add with StoreKit 2
- ✅ Network access (already working)

### 6. Info.plist Privacy Keys

**Required for Network Access:**
Add to Info.plist:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### 7. Developer Account & Certificates

**Verify:**
- ✅ Development Team: ARWAMX5JP6
- ✅ Code signing is configured
- ✅ Provisioning profiles valid

### 8. TestFlight Build Configuration

**Build for TestFlight:**
```bash
# Archive in Xcode or command line:
xcodebuild archive \
  -scheme PagePocket \
  -configuration Release \
  -archivePath ~/Desktop/PagePocket.xcarchive \
  -destination 'generic/platform=iOS'
```

### 9. App Store Listing

**Required Information:**
- App description
- Screenshots (all required sizes)
- App preview video (optional but recommended)
- Privacy policy URL
- Support URL
- Category and keywords
- Age rating

### 10. App Review Guidelines Compliance

**Verify:**
- ✅ In-app purchases properly implemented
- ✅ Clear privacy policy link
- ⚠️ CloudKit data handling disclosure needed
- ✅ Proper error handling
- ✅ Subscription terms clearly displayed

### 11. Final Testing

**Test Scenarios:**
- [ ] Free user can save 2 pages (limit enforced)
- [ ] Premium purchase flow works
- [ ] Cloud sync uploads pages (premium only)
- [ ] Restore purchases works
- [ ] Downloads and offline reading work
- [ ] Theme switching works
- [ ] Onboarding displays correctly
- [ ] Settings UI is functional

### 12. CloudKit Dashboard Setup

**After adding CloudKit capability:**
1. Go to CloudKit Dashboard
2. Initialize your container
3. Configure environment (development/production)
4. Set up schema for `SavedPage` record type

**Required Fields in CloudKit Schema:**
- `title` (String)
- `urlString` (String)
- `source` (String)
- `createdAt` (Date/Time)
- `statusRawValue` (String)
- `contentTypeRawValue` (String)
- `htmlContent` (String, optional)
- `lastAccessedAt` (Date/Time, optional)
- `estimatedReadTime` (Double)

## ✅ Already Production Ready

The following are already configured correctly:
- ✅ StoreKit 2 integration with `#if DEBUG` conditional compilation
- ✅ Mock services for development
- ✅ Production services for release builds
- ✅ Premium entitlement checks
- ✅ Error handling
- ✅ Localization
- ✅ MVVM architecture
- ✅ Proper state management
- ✅ Async/await usage
- ✅ No hardcoded credentials

## 📝 Summary

**Critical Issues to Fix:**
1. ⚠️ **Bundle ID vs Product ID mismatch** - MUST FIX
2. ⚠️ **CloudKit entitlements not added to Xcode** - MUST FIX
3. ⚠️ **StoreKit configuration file** - NEEDED FOR TESTING

**Everything Else:**
- Code is production-ready
- Architecture is solid
- No dangerous hardcoded values
- Proper separation of concerns

---

**Priority Order:**
1. Fix Bundle ID consistency
2. Add CloudKit to Xcode capabilities
3. Create products in App Store Connect
4. Create StoreKit configuration for testing
5. Submit to TestFlight
6. Final testing
7. Submit for review

---

**Last Updated:** November 2024

