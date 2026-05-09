# PawSync — 配置文档

生成时间：2026-05-09

---

## 一、⚠️ 手动配置（需你操作才能生效）

### 🔴 Capabilities 配置

#### iCloud (CloudKit) — 数据同步必需

**影响功能**：不配置则无法实现跨设备数据同步，宠物数据只能在当前设备使用

**配置步骤**：
1. 打开 [Apple Developer](https://developer.apple.com)
2. 进入 **Certificates, Identifiers & Profiles** → **Identifiers**
3. 找到 `com.zzoutuo.PawSync` → 点击编辑
4. 在 **Capabilities** 列表中勾选 **iCloud**
5. 勾选 **CloudKit** 复选框
6. 点击 **Configure** 创建容器，容器名称为 `iCloud.com.zzoutuo.PawSync`
7. 保存更改
8. 回到 Xcode 项目 → **Signing & Capabilities** → 点击 **"+ Capability"** → 添加 **iCloud**
9. 勾选 **CloudKit** 选项
10. 在 **Containers** 中选择或输入 `iCloud.com.zzoutuo.PawSync`
11. ⚠️ 配置完成后需要重新 Build 验证

---

#### App Groups — Widget 数据共享必需

**影响功能**：不配置则 Widget 无法读取宠物数据，小组件显示为空

**配置步骤**：
1. 打开 [Apple Developer](https://developer.apple.com)
2. 进入 **Certificates, Identifiers & Profiles** → **Identifiers**
3. 找到 `com.zzoutuo.PawSync` → 点击编辑
4. 在 **Capabilities** 列表中勾选 **App Groups**
5. 点击 **Configure**，创建新 Group ID：`group.com.zzoutuo.PawSync`
6. 保存更改
7. 回到 Xcode 项目 → **Signing & Capabilities** → 点击 **"+ Capability"** → 添加 **App Groups**
8. 点击 **"+"** 添加 Group，输入 `group.com.zzoutuo.PawSync`
9. 如果未来添加 Widget Extension，也需要在 Extension 的 Capabilities 中添加相同的 App Group
10. ⚠️ 配置完成后需要重新 Build 验证

---

#### Camera/Photo Library — 宠物照片和条码扫描必需

**影响功能**：不配置则无法拍摄宠物照片或扫描药品条码

**配置步骤**：
1. 在 Xcode 中打开项目
2. 找到 **Info.plist** 文件
3. 添加以下键值（已自动配置在代码中，无需手动添加，但需要在真机测试时授权）：
   - `NSCameraUsageDescription`: "PawSync needs camera access to scan medication barcodes and take pet photos"
   - `NSPhotoLibraryUsageDescription`: "PawSync needs photo library access to select pet photos"
4. 在真机上首次使用相机或相册时，系统会自动弹出权限请求

---

### 🟡 API Key 配置

#### AI 功能 API Key

**影响功能**：不配置API Key则AI健康助手功能不可用

**配置步骤**：
1. 选择你的 AI 供应商（任选一个即可）：
   - **OpenAI**: 注册 [platform.openai.com](https://platform.openai.com)，创建 API Key
   - **Google Gemini**: 注册 [aistudio.google.com](https://aistudio.google.com)，获取免费 API Key
   - **DeepSeek**: 注册 [platform.deepseek.com](https://platform.deepseek.com)，创建 API Key
   - **Anthropic (Claude)**: 注册 [console.anthropic.com](https://console.anthropic.com)，创建 API Key
2. 获取 API Key 后，在 App 的 **Settings** → **AI Configuration** 中输入
3. 点击 **"Test Connection"** 验证 Key 是否有效
4. 测试成功后点击 **"Save as Profile"** 保存

⚠️ 注意：API Key 是用户自带、App 内输入的，不需要在代码中硬编码。

---

### 🔵 IAP StoreKit 配置

**影响功能**：不创建IAP产品则用户无法完成订阅购买

**配置步骤**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入你的 App → **Features** → **In-App Purchases**
3. 点击 **"+"** 创建订阅组
   - **组名称**: PawSync Pro
   - **组ID**: PawSync_Pro
4. 按以下信息创建订阅产品：

| 产品 | Reference Name | Product ID | 价格 |
|------|---------------|-----------|------|
| 月付 | PawSync Pro Monthly | `com.zzoutuo.PawSync.pro.monthly` | $2.99/月 |
| 年付 | PawSync Pro Yearly | `com.zzoutuo.PawSync.pro.yearly` | $19.99/年 |
| 终身 | PawSync Pro Lifetime | `com.zzoutuo.PawSync.pro.lifetime` | $49.99 一次性 |

5. 填写每个产品的 Display Name 和 Description（从 `price.md` 复制）
6. 为月付订阅添加 **7天免费试用**
7. ⚠️ 创建后需要等待 Apple 审核（通常1-2小时）
8. 在 Xcode 中创建 StoreKit Configuration File 用于本地测试：
   - File → New → File → StoreKit Configuration File
   - 命名为 `Products.storekit`
   - 添加与 App Store Connect 相同的产品信息
9. 在 Scheme 的 **Run** → **Options** 中选择该 StoreKit Configuration
10. 在 SettingsView 中点击 **"Restore Purchases"** 验证流程

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| Push Notifications | 已通过Xcode自动开启，用于疫苗/用药提醒 | ✅ 已配置 |
| In-App Purchase | 已通过Xcode自动开启，用于订阅购买 | ✅ 已配置 |
| Background Modes (Remote Notification) | 已通过Xcode自动开启，后台接收提醒 | ✅ 已配置 |
| Outgoing Network Connections | 联系客服和AI功能需要，已自动配置 | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| 联系客服后端 | Cloudflare Workers 部署，地址：`https://feedback-board.iocompile67692.workers.dev` | ✅ 已部署 |
| NSAppTransportSecurity | 允许HTTPS出站连接，已在Info.plist配置 | ✅ 已配置 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 核心功能 | MVVM架构，所有功能模块已生成 | ✅ 已完成 |
| ContactSupportView | 7主题选择、API对接、网络权限 | ✅ 已完成 |
| SettingsView | 政策页面链接、客服入口、AI配置 | ✅ 已完成 |
| PurchaseManager | StoreKit 2 集成 | ✅ 已完成 |
| AI Module | 4文件模块（AIConfiguration, OpenAIService, AIProfileManager, SettingsViewModel） | ✅ 已完成 |
| HealthScoreEngine | 健康评分算法 | ✅ 已完成 |
| NotificationService | 四层递进提醒系统 | ✅ 已完成 |
| PDF Export | 健康报告PDF导出 | ✅ 已完成 |
| QA迭代 | Step 10 质量保证循环 | ✅ 已完成 |

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub仓库 | 代码已推送 | ✅ 已完成 |
| GitHub Pages | 政策页面已部署 | ✅ 已完成 |
| Landing Page | 已部署（App Store ID为占位符） | ✅ 已完成 |
| App Store元数据 | keytext.md已生成验证 | ✅ 已完成 |
| 定价配置 | price.md已生成 | ✅ 已完成 |

---

## 三、能力检测详情

### Analysis

基于操作指南分析，以下能力被检测到：

| 需求 | 关键词 | 优先级 |
|------|--------|--------|
| Cloud Sync | 同步, sync, iCloud, CloudKit, 云端 | P0 |
| Reminders | 通知, notification, 提醒, alert, reminder, 四层递进 | P0 |
| Subscriptions | 购买, 订阅, 会员, premium, StoreKit, 月订阅, 年订阅 | P0 |
| Background Processing | 后台, background, 刷新, refresh, 后台同步 | P1 |
| Camera/Photos | 相机, 拍照, 照片, camera, photo, 条码扫描 | P1 |
| Widget Data Sharing | Widget, 小组件, App Group | P1 |
| Family Sharing | 家人, family, 共享, share, CloudKit共享 | P2 |

### No Configuration Needed

| 能力 | 原因 |
|------|------|
| HealthKit | App 追踪宠物健康，非人类健康 — HealthKit 不适用 |
| Apple Watch | 当前范围无 watchOS 配套应用 |
| Location Services | 无需基于位置的功能 |
| Siri | 当前范围无 Siri 集成 |
| Sign in with Apple | 无账户系统 — 应用使用设备本地 + CloudKit 身份 |
| Maps | 无需地图功能 |

### Verification

- Build 成功：✅ 已通过 iPhone 16 和 iPad Pro 13-inch (M4) 测试
- 所有 entitlements 正确：✅ 已验证
- GitHub Pages 部署：✅ 已启用

---

## Entitlements 配置参考

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

---

## Info.plist Keys

| Key | Value |
|-----|-------|
| NSCameraUsageDescription | PawSync needs camera access to scan medication barcodes and take pet photos |
| NSPhotoLibraryUsageDescription | PawSync needs photo library access to select pet photos |
| UIBackgroundModes | remote-notification |
