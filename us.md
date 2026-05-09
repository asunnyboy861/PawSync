# PawSync - iOS Development Guide

## Executive Summary

**PawSync** is a comprehensive pet health management app for the US market, built with SwiftUI and SwiftData. It solves the three biggest pain points pet owners face: data loss, unreliable reminders, and inability to share records with veterinarians.

**Product Vision**: "The pet health app that actually works — and won't lose your data"

**Target Audience**: US pet owners (66% of US households own pets, ~87M homes), primarily dog and cat owners who need reliable health tracking, vaccination reminders, and vet-ready records.

**Three Differentiation Pillars**:
1. **Zero Data Loss** — Local snapshots + CloudKit sync + crash recovery
2. **Never Miss Again** — Four-layer progressive reminder system (7 days / 2 days / today / overdue)
3. **Vet-Ready** — One-tap PDF report + family sharing

**Key Metrics**:
- US pet health app market: $2.8B (2025), CAGR 18.2%
- 34% of users experienced pet health data loss
- 41% report unreliable reminders
- Only 12% of existing apps offer PDF export
- Only 8% support family sharing

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **11pets** | Cloud sync, PDF export, multi-pet, vet sharing | No offline mode, $3.99/mo, limited free features (3), no AI, no family sharing, no widget | More free features (8+), cheaper ($2.99/mo), offline-first, AI insights, family sharing, widget |
| **Pawprint** | Medical records, feeding instructions, photo sharing, reminders | No cloud sync reliability, no PDF vet report, no AI, no family sharing, no health score | CloudKit sync, PDF vet reports, AI health advice, family sharing, health score engine |
| **PawAI** | AI-powered care plans, symptom tracking, habit tracker, smart reminders | New app (limited track record), no PDF export, no family sharing, no backup/recovery, no widget | Proven data safety (backup+sync), PDF vet reports, family sharing, widget, lower price |
| **PetDesk** | Vet appointment booking, prescription management | Very expensive ($9.99/mo), limited free features (4), no family sharing, no AI, no offline mode | 70% cheaper, offline-first, AI insights, family sharing, more free features |

**Competitive Moat**: PawSync offers 8+ free features (vs. competitors' 2-4), the lowest subscription price ($2.99/mo vs. $3.99-$9.99), and unique features no competitor provides together: four-layer reminders + CloudKit sync + PDF vet reports + family sharing + AI insights + widget.

## Apple Design Guidelines Compliance

### Human Interface Guidelines (HIG) Adherence

- **Layout**: Adaptive layouts using SwiftUI's built-in responsive system; content fills screen edges; controls overlay content per HIG
- **Navigation**: Standard Tab Bar with 4 tabs (Pets, Reminders, Reports, Settings) — users expect familiar iOS navigation
- **Typography**: SF Pro system font with full Dynamic Type support (xSmall to xxxLarge); health score numbers use SF Pro Rounded
- **Color**: Sage Green (#4A7C59) primary — avoids clinical blue/purple; uses Apple system colors for success/warning/danger
- **Dark Mode**: Full support via Asset Catalog Any/Dark variants; background Midnight (#000000), cards Charcoal (#1C1C1E)
- **Accessibility**: VoiceOver labels on all controls; WCAG AA color contrast (4.5:1); color-blind friendly (icons + text, not color alone); reduce motion support
- **Haptic Feedback**: Subtle haptics on quick action buttons and save confirmations
- **Progressive Disclosure**: Onboarding shows only 4 required fields; advanced settings behind "More"

### App Store Review Guidelines Compliance

- **1.4 Physical Harm**: App includes disclaimer — "This app is not a substitute for professional veterinary advice. Always consult your veterinarian for medical decisions." AI health suggestions are informational only.
- **2.1 App Completeness**: All features fully functional; no placeholder content; no beta features
- **2.3 Accurate Metadata**: App description, screenshots, and keywords accurately represent functionality
- **3.1.1 In-App Purchase**: Subscription managed via StoreKit 2; free tier provides 8+ substantive features; no paywall blocking core functionality
- **3.1.2 Subscriptions**: Clear subscription terms; 7-day free trial; monthly/yearly/lifetime options; easy cancellation
- **5.1.1 Data Collection**: Minimal data collection; pet health data stored locally and in user's iCloud (CloudKit Private DB); no data sold to third parties
- **5.1.3 Health Data**: App does not claim to diagnose or treat; AI suggestions are informational; privacy policy clearly discloses all data practices

### Privacy Nutrition Labels (App Store)

| Data Type | Collected | Linked to User | Used for Tracking |
|-----------|-----------|----------------|-------------------|
| Contact Info (email) | Yes (support) | Yes | No |
| Health & Fitness (pet records) | Yes | Yes | No |
| Photos (pet photos) | Yes | No | No |
| Identifiers (device ID) | Yes | No | No |
| Usage Data | Yes | No | No |

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), no UIKit mixing
- **Data Persistence**: SwiftData with @Model macro for local-first storage
- **Cloud Sync**: CloudKit Private DB for cross-device sync
- **Notifications**: UserNotifications framework with time-sensitive alerts
- **Payments**: StoreKit 2 for subscription management
- **Charts**: Swift Charts for health trend visualization
- **PDF Generation**: PDFKit for veterinary report export
- **Widget**: WidgetKit for home screen pet card
- **AI**: OpenAI API (cloud) for health suggestions and symptom analysis
- **Barcode**: AVFoundation + Vision framework for medication barcode scanning
- **Architecture**: MVVM — strict Model-View-ViewModel separation
- **Minimum Version**: iOS 17.0 (required for SwiftData)

## Module Structure

```
PawSync/
├── PawSyncApp.swift
├── Models/
│   ├── Pet.swift
│   ├── Vaccination.swift
│   ├── Medication.swift
│   ├── HealthRecord.swift
│   ├── Reminder.swift
│   └── VaccinationTemplate.swift
├── ViewModels/
│   ├── PetListViewModel.swift
│   ├── PetDetailViewModel.swift
│   ├── VaccinationViewModel.swift
│   ├── MedicationViewModel.swift
│   ├── ReminderViewModel.swift
│   ├── HealthScoreViewModel.swift
│   ├── ReportViewModel.swift
│   └── SubscriptionViewModel.swift
├── Views/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   └── AddPetView.swift
│   ├── Pets/
│   │   ├── PetListView.swift
│   │   ├── PetCardView.swift
│   │   └── PetDetailView.swift
│   ├── Vaccinations/
│   │   ├── VaccinationListView.swift
│   │   └── AddVaccinationView.swift
│   ├── Medications/
│   │   ├── MedicationListView.swift
│   │   └── AddMedicationView.swift
│   ├── Reminders/
│   │   ├── ReminderListView.swift
│   │   └── AddReminderView.swift
│   ├── Reports/
│   │   └── HealthReportView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── HealthScoreRing.swift
│       ├── QuickActionButton.swift
│       ├── WeightTrendChart.swift
│       └── ReminderCard.swift
├── Services/
│   ├── ReminderEngine.swift
│   ├── BackupManager.swift
│   ├── CloudKitSync.swift
│   ├── HealthReportGenerator.swift
│   ├── HealthScoreCalculator.swift
│   └── SubscriptionManager.swift
├── Extensions/
│   ├── Date+Extensions.swift
│   ├── Color+Extensions.swift
│   └── View+Extensions.swift
├── Resources/
│   ├── Assets.xcassets
│   └── VaccinationTemplates.json
├── PawSyncWidget/
│   ├── PawSyncWidget.swift
│   └── PawSyncWidgetBundle.swift
└── PawSyncTests/
    ├── HealthScoreCalculatorTests.swift
    ├── BackupManagerTests.swift
    └── ReminderEngineTests.swift
```

## Implementation Flow

### Phase 1: Foundation (Models + Data Layer)
1. Create SwiftData models: Pet, Vaccination, Medication, HealthRecord, Reminder
2. Set up ModelContainer with CloudKit configuration
3. Implement BackupManager with local snapshot rotation (7 snapshots)
4. Implement CloudKit sync service (Private DB, background push)

### Phase 2: Core Features (CRUD + Reminders)
1. Build Pet CRUD views (list, add, detail, edit)
2. Build Vaccination views with AAHA template data
3. Build Medication views with frequency tracking
4. Implement four-layer ReminderEngine (7d/2d/today/overdue)
5. Implement HealthScoreCalculator (5-dimension weighted scoring)

### Phase 3: Value-Added Features
1. Build PDF veterinary report generator (PDFKit)
2. Implement family sharing via CloudKit shared zone
3. Integrate OpenAI API for AI health suggestions
4. Build Swift Charts weight trend visualization
5. Implement StoreKit 2 subscription management
6. Build WidgetKit home screen pet card

### Phase 4: Polish & Launch
1. Implement onboarding flow (3 steps, 60 seconds)
2. Add dark mode support across all views
3. Add VoiceOver and Dynamic Type support
4. Write unit tests for core engines
5. App Store metadata and submission

## UI/UX Design Specifications

### Color Scheme

| Purpose | Color | Hex |
|---------|-------|-----|
| Primary | Sage Green | #4A7C59 |
| Accent / CTA | Warm Amber | #E8A838 |
| Background | Cloud White | #F8F9FA |
| Card Background | Pure White | #FFFFFF |
| Success / Healthy | Fresh Green | #34C759 |
| Warning / Attention | Warm Orange | #FF9500 |
| Danger / Overdue | Alert Red | #FF3B30 |
| Primary Text | Ink Black | #1C1C1E |
| Secondary Text | Steel Gray | #8E8E93 |
| Dark BG | Midnight | #000000 |
| Dark Card | Charcoal | #1C1C1E |

### Typography

- System font: SF Pro (all styles)
- Health score numbers: SF Pro Rounded, 48pt Bold
- Numeric values (weight/temp): SF Mono for alignment
- Full Dynamic Type support: xSmall through xxxLarge

### Layout Rules

- Card corner radius: 16pt
- Card padding: 16pt
- Card shadow: 0 2pt 8pt rgba(0,0,0,0.08)
- Card spacing: 12pt
- Quick Action buttons: 72x72pt, 16pt corner radius
- Tab Bar: 4 tabs (Pets, Reminders, Reports, Settings)
- Navigation: Standard SwiftUI NavigationStack

### Animations

| Interaction | Animation | Duration | Curve |
|-------------|-----------|----------|-------|
| Page transition | Slide + Fade | 0.35s | easeInOut |
| Card tap | Scale 0.95 → 1.0 | 0.15s | spring |
| Save success | Card bounce + checkmark | 0.4s | spring(damping:0.7) |
| Health score change | Color gradient + number roll | 0.8s | spring(damping:0.6) |
| Reminder bell | Shake animation | 0.5s | easeInOut |
| Weight trend line | Left-to-right draw | 0.6s | easeOut |
| Delete | Slide out + fade | 0.3s | easeIn |
| Tab switch | Crossfade | 0.2s | easeInOut |

### Accessibility

- Dynamic Type: All text supports xSmall to xxxLarge
- VoiceOver: All controls have accessibilityLabel
- Color contrast: WCAG AA standard (4.5:1 minimum)
- Color-blind friendly: Icons + text, not color alone
- Reduce motion: Respects UIAccessibility.isReduceMotionEnabled
- One-handed use: Primary action buttons in lower half of screen

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming following Swift API Design Guidelines
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI/SwiftData/CloudKit
- MVVM architecture: strict separation of Model, ViewModel, View
- Async/await for all asynchronous operations — no callback nesting
- try/await with local fallback strategy for error handling
- SwiftData @Model macro for all persistent models
- Pure SwiftUI — no UIKit mixing
- Each ViewModel paired with unit tests

## Monetization Model

**Type**: Freemium with Subscription (站内订阅B模式)

**Free Tier** (8+ features):
- Add pets (up to 3)
- Vaccination records + templates
- Medication tracking
- Four-layer progressive reminders
- Weight recording + trend chart
- Health score
- CloudKit sync
- Local backup + restore

**Pro Tier** ($2.99/month | $19.99/year | $49.99 lifetime):
- Unlimited pets
- PDF veterinary reports
- Family sharing
- AI health suggestions (10/month)
- AI symptom analysis (5/month)
- Barcode scanner
- Home screen widget
- Custom reminder sounds
- CSV data export

**Pricing Psychology**:
- Year plan shows monthly equivalent ($1.67/mo) — anchoring effect
- Year plan labeled "Save 44%" — loss aversion
- Year plan button "Most Popular" — social proof
- Lifetime labeled "Best Value" — value anchoring

## Build & Deployment Checklist

- [ ] Xcode project configured with bundle ID com.zzoutuo.PawSync
- [ ] iOS 17.0 minimum deployment target
- [ ] CloudKit capability enabled (Private DB)
- [ ] Push Notifications capability enabled
- [ ] App Group configured for widget data sharing
- [ ] StoreKit 2 subscription products configured in App Store Connect
- [ ] Privacy policy URL accessible (HTTPS, no login required)
- [ ] App Store metadata: title, subtitle, keywords, description, screenshots
- [ ] App icon: 1024x1024 Sage Green gradient with white paw + sync arrow
- [ ] All SwiftData models have CloudKit sync enabled
- [ ] Four-layer reminder system tested with UNUserNotificationCenter
- [ ] Health score calculator unit tests passing
- [ ] Backup manager snapshot rotation verified
- [ ] PDF report generation tested
- [ ] Dark mode verified on all views
- [ ] VoiceOver navigation tested end-to-end
- [ ] Dynamic Type tested at all sizes
- [ ] Widget displays pet health data correctly
- [ ] Subscription purchase flow tested with StoreKit Testing in Xcode

## GitHub Reference Projects

| Project | URL | Reference Value |
|---------|-----|-----------------|
| Pawsylo (Primary) | https://github.com/ajithdhev/Pawsylo | SwiftUI+SwiftData architecture, Pet CRUD, vaccination records, medication management, health score engine |
| PetFlow | https://github.com/Lukieboy/PetFlow | Medication tracking UI design, card-based layout |
| pet-tracker | https://github.com/aakashsriram1/pet-tracker | AI health pattern recognition, data sync design |
| PetCare | https://github.com/Jhonatan19991/PetCare | AI dermatology analysis functionality |
