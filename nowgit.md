# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | PawSync |
| **Git URL** | git@github.com:asunnyboy861/PawSync.git |
| **Repo URL** | https://github.com/asunnyboy861/PawSync |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/PawSync/ | ✅ Active |
| Support | https://asunnyboy861.github.io/PawSync/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/PawSync/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/PawSync/terms.html | ✅ Active |

## Repository Structure

```
PawSync/
├── PawSync/                       # iOS App Source Code
│   ├── PawSync.xcodeproj/         # Xcode Project
│   ├── PawSync/                   # Swift Source Files
│   │   ├── Views/
│   │   │   ├── Components/        # Design System & Reusable Components
│   │   │   ├── Dashboard/         # Home Dashboard
│   │   │   ├── Health/            # Health Records & AI Assistant
│   │   │   ├── Vaccination/       # Vaccination Management
│   │   │   ├── Medication/        # Medication Tracking
│   │   │   ├── Weight/            # Weight Monitoring
│   │   │   ├── Onboarding/        # Add Pet Flow
│   │   │   ├── Settings/          # Settings, Paywall, Support
│   │   │   └── MainTabView.swift  # Tab Navigation
│   │   ├── Models/                # SwiftData Models
│   │   ├── Services/              # Business Logic & API
│   │   └── ViewModels/            # View Models
│   └── ...
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── keytext.md
├── capabilities.md
├── icon.md
├── price.md
└── nowgit.md
```
