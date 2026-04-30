# ⬇️ Cydius

A beautiful dark iOS app with orange accent — browse and sideload IPA files with a smooth Scarlet/Esign-inspired UI.

## Features
- Smooth dark UI, black + orange theme
- Browse featured apps with category filters
- Live install pipeline with circular progress ring
- Hacker-style terminal log during install
- Installed apps tab
- iOS 16+ compatible

## How to get the IPA

### Option 1 — GitHub Actions (easiest)
1. Fork or push this repo to your GitHub
2. Go to **Actions** tab → **Build Cydius IPA** → **Run workflow**
3. Download `Cydius.ipa` from the Artifacts section

### Option 2 — Build locally in Xcode
1. Open `Cydius.xcodeproj` in Xcode 15+
2. Set your Team in Signing & Capabilities
3. Product → Archive → Distribute → Ad Hoc or Development
4. Export the `.ipa`

## How to sideload onto your iPhone

### Via Sideloadly (recommended)
1. Download [Sideloadly](https://sideloadly.io) on your Mac/PC
2. Connect your iPhone via USB
3. Drag `Cydius.ipa` into Sideloadly
4. Enter your Apple ID
5. Hit Start — done!

### Via AltStore
1. Install [AltStore](https://altstore.io) on your iPhone
2. Open AltStore → My Apps → + → select `Cydius.ipa`

### Via TrollStore (if supported)
1. Open `Cydius.ipa` directly in TrollStore
2. Tap Install — permanent install, no 7-day limit!

## Requirements
- iPhone with iOS 16.0+
- Xcode 15+ (to build)
- Free Apple ID works fine with Sideloadly

## Structure
```
Cydius/
├── CydiusApp.swift          # App entry point
├── ContentView.swift        # Tab navigation
├── Models/
│   └── AppModel.swift       # Data models
├── ViewModels/
│   └── AppStore.swift       # Install logic & state
├── Views/
│   ├── HomeView.swift       # Browse screen
│   ├── InstallSheetView.swift  # Install progress UI
│   ├── InstalledView.swift  # Installed apps
│   └── SettingsView.swift   # Settings
└── Assets.xcassets/
```

## Credits
UI inspired by Scarlet & eSign. Built with SwiftUI.
