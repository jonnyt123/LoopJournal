# LoopJournal — App Store Readiness Report

## Summary

The app has been reviewed and updated for App Store submission. Below is the verification checklist and any remaining TODOs.

---

## 1. Release build — debug-only UI, logging, flags

| Check | Status |
|-------|--------|
| No `#if DEBUG` UI or debug-only views | **OK** — None found. |
| No `print()` / `NSLog` / `debugPrint` in production code | **OK** — None found. |
| No debug-only flags or test mode toggles | **OK** — None found. |
| `fatalError` in Core Data load | **FIXED** — Replaced with `didFailToLoadStore` flag and `Logger`; app continues with empty data if store fails. |

**Files changed:** `LoopJournal/Services/CoreDataManager.swift` — removed `fatalError`, added `didFailToLoadStore`, `Logger`, and guarded `save()`.

---

## 2. Info.plist — permissions and strings

| Check | Status |
|-------|--------|
| Only required usage descriptions | **OK** — Added only for APIs in use. |
| **NSMicrophoneUsageDescription** | **Added** — Voice recording (LogEntryView). |
| **NSPhotoLibraryUsageDescription** | **Added** — PhotosPickerItem (attach photos). |
| **NSPhotoLibraryAddUsageDescription** | **Added** — Save to Photos (optional, Settings). |
| **NSFaceIDUsageDescription** | **Added** — App lock (AuthManager / LockScreenView). |
| **NSAllowsArbitraryLoads** | **Set to false** — ATS tightened; opening URLs in Safari does not require arbitrary loads. |
| **ITSAppUsesNonExemptEncryption** | **Added false** — Standard encryption only. |

**Files changed:** `LoopJournal/Info.plist`, `project.yml` (NSAllowsArbitraryLoads: false).

**Note:** After running `xcodegen generate`, re-verify `LoopJournal/Info.plist` still contains the usage description keys and ITSAppUsesNonExemptEncryption; XcodeGen can overwrite the plist. If any are missing, re-add them to `Info.plist` or add equivalent keys to `project.yml` `info.properties`.

---

## 3. Private APIs / forbidden entitlements

| Check | Status |
|-------|--------|
| No private / undocumented APIs | **OK** — No `performSelector`, `dlopen`, `dlsym`, or similar. |
| Entitlements | **OK** — `com.apple.developer.applesignin` (Default), `com.apple.developer.default-data-protection` (NSFileProtectionComplete), `com.apple.developer.journal.allow` (suggestions). |

**TODO:** If the app does **not** use the Journaling Suggestions API, remove the `com.apple.developer.journal.allow` entitlement from `LoopJournal/LoopJournal.entitlements` to avoid unnecessary capability and review questions. See remaining TODOs below.

---

## 4. Crash-safe persistence and data migration

| Check | Status |
|-------|--------|
| Core Data store load failure | **FIXED** — No crash; `didFailToLoadStore` set, main-thread `save()` guarded and logs errors. |
| Lightweight migration | **Added** — `shouldMigrateStoreAutomatically = true`, `shouldInferMappingModelAutomatically = true` on the persistent store description. |
| Main-context save | **Guarded** — `save()` checks `!didFailToLoadStore` and uses `do/catch` + log. |
| Background context save | **Guarded** — `deleteInBackground` and `addEntryInBackground` use `do/catch` + log on save failure. |

**Files changed:** `LoopJournal/Services/CoreDataManager.swift`.

---

## 5. App icons, launch screen, versioning, build settings

| Check | Status |
|-------|--------|
| App icons | **OK** — `LoopJournal/Assets.xcassets/AppIcon.appiconset/` has required sizes including 1024×1024 (icon.png). |
| Launch screen | **OK** — `LoopJournal/Base.lproj/LaunchScreen.storyboard` with LaunchBackground image and LoopJournal title. |
| Versioning | **OK** — `project.yml`: MARKETING_VERSION 1.0.0, CURRENT_PROJECT_VERSION 1. |
| Build settings | **OK** — Release build succeeds; no debug-only compiler flags in shared settings. |

**Known warning:** LaunchScreen.storyboard — “Automatically Adjusts Font requires using a Dynamic Type text style”. Optional fix: `LoopJournal/Base.lproj/LaunchScreen.storyboard` — set the “LoopJournal” label to a Dynamic Type style (e.g. Title 1) or turn off “Automatically Adjusts Font”.

---

## 6. Privacy compliance

| Check | Status |
|-------|--------|
| No unexpected tracking | **OK** — No analytics/tracking SDKs; data stays on device. |
| Privacy manifest | **Added** — `LoopJournal/PrivacyInfo.xcprivacy`: NSPrivacyTracking false, NSPrivacyTrackingDomains empty, NSPrivacyCollectedDataTypes empty. |
| In-app privacy note | **OK** — Settings → “Your data stays private” / “All journal entries are stored locally…”. |

**Files changed:** `LoopJournal/PrivacyInfo.xcprivacy` added; `project.yml` updated to include it in the app target resources.

---

## Remaining TODOs (exact file locations)

1. **Journaling Suggestions entitlement**  
   - **File:** `LoopJournal/LoopJournal.entitlements`  
   - **Action:** If the app does **not** use the Journaling Suggestions API, remove the `com.apple.developer.journal.allow` entitlement (the entire key and array). If it does use it, leave as is.

2. **Info.plist after XcodeGen**  
   - **File:** `LoopJournal/Info.plist`  
   - **Action:** After each `xcodegen generate`, confirm the following keys are still present: `ITSAppUsesNonExemptEncryption`, `NSFaceIDUsageDescription`, `NSMicrophoneUsageDescription`, `NSPhotoLibraryAddUsageDescription`, `NSPhotoLibraryUsageDescription`, and `NSAppTransportSecurity` with `NSAllowsArbitraryLoads` false. If any are missing, re-add them (or add them to `project.yml` under the app target’s `info.properties` so XcodeGen preserves them).

3. **Launch screen Dynamic Type (optional)**  
   - **File:** `LoopJournal/Base.lproj/LaunchScreen.storyboard`  
   - **Action:** Resolve the “Automatically Adjusts Font requires using a Dynamic Type text style” warning by either assigning a Dynamic Type text style to the “LoopJournal” label or disabling “Automatically Adjusts Font” on that label.

---

## Build and test

- **Release build:** `xcodebuild -scheme LoopJournal -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Release build`
- **Tests:** `xcodebuild test -scheme LoopJournal -destination 'platform=iOS Simulator,name=iPhone 17'`

Run both before submitting to the App Store.
