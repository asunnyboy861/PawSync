# Pricing Configuration

## Monetization Model: Subscription (Freemium + IAP)

PawSync uses a freemium model: free download with substantial free features, and a Pro subscription for premium capabilities.

## Subscription Group
- **Group Name**: PawSync Pro
- **Group ID**: PawSync_Pro

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: PawSync Pro Monthly
- **Product ID**: `com.zzoutuo.PawSync.pro.monthly`
- **Price**: $2.99 per month
- **Display Name**: PawSync Pro Monthly
- **Description**: Full pet health suite with AI insights
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: PawSync Pro Yearly
- **Product ID**: `com.zzoutuo.PawSync.pro.yearly`
- **Price**: $19.99 per year (44% savings vs monthly)
- **Display Name**: PawSync Pro Yearly
- **Description**: Best value — save 44% annually
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: PawSync Pro Lifetime
- **Product ID**: `com.zzoutuo.PawSync.pro.lifetime`
- **Price**: $49.99 one-time
- **Display Name**: PawSync Pro Lifetime
- **Description**: Pay once, own forever — no recurring fees
- **Note**: Lifetime includes all Pro features EXCEPT AI (AI has ongoing API costs and requires monthly/yearly subscription)

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid monthly subscription)
- **Applies to**: Monthly subscription only

## Free vs Pro Feature Matrix

| Feature | Free | Pro |
|---------|------|-----|
| Add pets (up to 3) | ✅ | ✅ Unlimited |
| Vaccination records + templates | ✅ | ✅ |
| Medication tracking | ✅ | ✅ |
| Four-layer progressive reminders | ✅ | ✅ |
| Weight recording + trend chart | ✅ | ✅ |
| Health score | ✅ | ✅ |
| CloudKit sync | ✅ | ✅ |
| Local backup + restore | ✅ | ✅ |
| PDF veterinary reports | ❌ | ✅ |
| Family sharing | ❌ | ✅ |
| AI health suggestions | ❌ | ✅ (10/month) |
| AI symptom analysis | ❌ | ✅ (5/month) |
| Barcode scanner | ❌ | ✅ |
| Home screen widget | ❌ | ✅ |
| Custom reminder sounds | ❌ | ✅ |
| CSV data export | ❌ | ✅ |

**Free features count: 8** (competitors average 2-3)
**Pro features count: 16**

## Pricing Psychology Strategy

1. Year plan shows monthly equivalent ($1.67/mo) — anchoring effect
2. Year plan labeled "Save 44%" — loss aversion
3. Year plan button "Most Popular" — social proof
4. Lifetime labeled "Best Value" — value anchoring
5. Monthly price as anchor makes yearly look exceptional

## AI Feature Usage Limits (API Cost Management)

| AI Feature | Monthly Subscription | Yearly Subscription | Lifetime |
|------------|---------------------|---------------------|----------|
| AI Health Suggestions | 10/month | 10/month | ❌ Not included |
| AI Symptom Analysis | 5/month | 5/month | ❌ Not included |
| AI Skin Analysis | 3/month | 3/month | ❌ Not included |

**Rationale**: AI features use OpenAI API with per-call costs (~$0.03-$0.08/call). Monthly/yearly subscriptions cover these ongoing costs. Lifetime purchase does not include AI to avoid losses on API usage.

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms included in Terms of Use
- [x] Cancellation instructions included in Support page
- [x] Pricing clearly stated in paywall UI
- [x] 7-day free trial terms included
- [x] Restore purchases functionality implemented
- [x] No dark patterns — free tier provides real value
- [x] Subscription management link to Settings

## StoreKit 2 Implementation Plan

### PurchaseManager.swift Requirements
1. Product fetching via Product.products(for:)
2. Purchase flow with product.purchase()
3. Transaction listener via Transaction.updates
4. Current entitlement check via Transaction.currentEntitlements
5. Restore purchases via AppStore.sync()
6. Subscription status tracking (currentTier published property)

### Paywall UI Rules
- Show all 3 tiers side by side
- Highlight "Most Popular" on yearly plan
- Show monthly equivalent on yearly plan
- Include "Restore Purchases" link
- Include "Terms of Use" and "Privacy Policy" links
- No manipulative urgency ("Limited time!" etc.)
