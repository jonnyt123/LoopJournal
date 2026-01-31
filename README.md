# LoopJournal - Privacy-First iOS Journaling App

## ✅ Completed Features

### Core Privacy Requirements
- ✅ No social features (no likes, comments, shares, usernames)
- ✅ Offline-first with local Core Data storage
- ✅ App Lock with Face ID / Touch ID toggle
- ✅ Private data export (PDF, image)
- ✅ No external APIs or cloud sharing

### Tab Navigation
- ✅ **My Loop** - Swipe-based timeline of journal entries
- ✅ **Log Entry** - Create new entries with mood selection
- ✅ **Mood Insights** - Personal analytics and trends
- ✅ **Journal Settings** - Security, export, theme options

### UI Components
- ✅ **JournalEntryCard** - Full-screen cards with mood-based gradients
- ✅ **TopBarView** - Minimal branding with privacy indicator
- ✅ **JournalTabBar** - Floating bottom navigation
- ✅ **MediaPreviewView** - Interactive media display
- ✅ **LogEntryView** - Mood selector, text editor, media options
- ✅ **MoodInsightsView** - Charts, streaks, distribution
- ✅ **SettingsView** - Biometric lock, export, data management

### Models
- ✅ **JournalEntry** - Entry with mood, media, date
- ✅ **Mood enum** - Happy, sad, chill, excited, reflective, neutral
- ✅ **MediaType** - Photo, voice, link
- ✅ **Theme support** - Dark, neon, retro, pastel

## 📁 Project Structure
```
LoopJournal/
├── App.swift
├── Models/
│   ├── JournalEntry.swift (Mood enum + gradients)
│   └── DummyData.swift (7 sample entries)
├── ViewModels/
│   └── TimelineViewModel.swift
├── Views/
│   ├── JournalEntryCard.swift
│   ├── TimelineView.swift (MainContentView + MyLoopView)
│   ├── LogEntryView.swift
│   ├── MoodInsightsView.swift
│   ├── SettingsView.swift
│   └── Components/
│       ├── TopBarView.swift
│       ├── BottomTabBar.swift
│       └── MediaPreviewView.swift
├── project.yml
└── README.md
```

## 🚀 To Run
```bash
cd /Users/jonny/LoopJournal
open LoopJournal.xcodeproj
```
Select any simulator or device running iOS 17.0+ and press ⌘R.

## 📱 TestFlight
Install LoopJournal from TestFlight and run it directly on any iOS device running 17.0+.

## 🎨 Features
- TikTok-inspired vertical swipe navigation
- Mood-based animated gradients
- Spinning record animation for mood indicator
- Haptic feedback on interactions
- Dark theme with cyan/purple/pink accents
- Face ID / Touch ID app lock (toggleable)
- Export entries as PDF or image
- Mood distribution charts and streaks
- On-device storage only
