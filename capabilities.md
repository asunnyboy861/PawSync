# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities are required:

| Requirement | Keywords Found | Priority |
|-------------|---------------|----------|
| Cloud Sync | 同步, sync, iCloud, CloudKit, 云端 | P0 |
| Reminders | 通知, notification, 提醒, alert, reminder, 四层递进 | P0 |
| Subscriptions | 购买, 订阅, 会员, premium, StoreKit, 月订阅, 年订阅 | P0 |
| Background Processing | 后台, background, 刷新, refresh, 后台同步 | P1 |
| Camera/Photos | 相机, 拍照, 照片, camera, photo, 条码扫描 | P1 |
| Widget Data Sharing | Widget, 小组件, App Group | P1 |
| Family Sharing | 家人, family, 共享, share, CloudKit共享 | P2 |

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications | ✅ Configured | Xcode Signing & Capabilities |
| In-App Purchase | ✅ Configured | StoreKit 2 (code-level) |
| Background Modes (Remote Notification) | ✅ Configured | Xcode Signing & Capabilities |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| iCloud (CloudKit) | ⏳ Pending | 1. Add iCloud capability in Xcode 2. Check CloudKit checkbox 3. Create container: iCloud.com.zzoutuo.PawSync 4. Enable CloudKit in SwiftData ModelContainer configuration |
| App Groups | ⏳ Pending | 1. Add App Groups capability 2. Create group: group.com.zzoutuo.PawSync 3. Share UserDefaults/FileManager between main app and widget |
| Camera/Photo Library | ⏳ Pending | 1. Add NSCameraUsageDescription to Info.plist: "PawSync needs camera access to scan medication barcodes and take pet photos" 2. Add NSPhotoLibraryUsageDescription: "PawSync needs photo library access to select pet photos" |

## No Configuration Needed

| Capability | Reason |
|------------|--------|
| HealthKit | App tracks pet health, not human health — HealthKit not applicable |
| Apple Watch | No watchOS companion app in current scope |
| Location Services | No location-based features required |
| Siri | No Siri integration in current scope |
| Sign in with Apple | No account system — app uses device-local + CloudKit identity |
| Maps | No map features required |

## Entitlements Required

```xml
<!-- iCloud + CloudKit -->
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.zzoutuo.PawSync</string>
</array>
<key>com.apple.developer.ubiquity-container-identifiers</key>
<array>
    <string>iCloud.com.zzoutuo.PawSync</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>

<!-- Push Notifications -->
<key>aps-environment</key>
<string>development</string>

<!-- App Groups (for Widget) -->
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.zzoutuo.PawSync</string>
</array>
```

## Info.plist Keys Required

| Key | Value |
|-----|-------|
| NSCameraUsageDescription | PawSync needs camera access to scan medication barcodes and take pet photos |
| NSPhotoLibraryUsageDescription | PawSync needs photo library access to select pet photos |
| UIBackgroundModes | remote-notification |

## Verification
- Build succeeded after configuration: Pending (will verify in build step)
- All entitlements correct: Pending
