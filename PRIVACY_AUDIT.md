# LoopJournal — Privacy Audit (Pre–Privacy Policy)

**Scope:** Full codebase, Info.plist, entitlements, capabilities, dependencies, SDK imports.  
**Purpose:** Data map aligned to Apple’s App Privacy categories; no privacy policy written.

**Principle:** Accuracy over completeness. Only what is **verified in the codebase** is stated as present. If something cannot be verified in the project, it is stated as **not present** or **not verified**.

---

## 1. Permissions Requested

| Permission | Present in code / plist | Where | Notes |
|------------|-------------------------|--------|------|
| **Photo Library (read)** | Code: yes. Plist: **yes** | `LogEntryView.swift`: `PhotosPicker(...)`. `Info.plist`: `NSPhotoLibraryUsageDescription` | Matches privacy policy. |
| **Photo Library (add only)** | Code: yes. Plist: **yes** | `LogEntryView.swift`: `PHPhotoLibrary.requestAuthorization(for: .addOnly)`, `saveImageToPhotos`. `Info.plist`: `NSPhotoLibraryAddUsageDescription` | Optional when user enables “Save photos to device.” Matches policy. |
| **Microphone** | Code: yes. Plist: **yes** | `LogEntryView.swift`: `AVAudioRecorder`, `requestRecordPermission`. `Info.plist`: `NSMicrophoneUsageDescription`. `UIBackgroundModes: audio` | Matches policy. |
| **Face ID / Touch ID** | Code: yes. Plist: **yes** | `AuthManager.swift`: `LAContext`, `deviceOwnerAuthenticationWithBiometrics`. `Info.plist`: `NSFaceIDUsageDescription` | App lock only. Matches policy. |
| **Location** | No | — | **NOT PRESENT** (no key in plist; none used in code). |
| **Camera** | No | `AddEditEntryView.swift` has a comment about PHPicker/UIImagePicker “if needed”; not implemented | **NOT PRESENT** (no key in plist). |
| **Bluetooth, Contacts, Calendar, Health, etc.** | No | — | **NOT PRESENT** |

**Plist vs policy:** All four permissions used in code and described in the privacy policy (Photo Library read/add, Microphone, Face ID) now have usage description strings in `LoopJournal/Info.plist` and `project.yml`. **Unused permissions:** None. No permission keys exist in the plist other than these four; the policy correctly states we do not request location, camera, or other permissions.

---

## 2. Third‑Party SDKs

| SDK / dependency | Present | Where |
|------------------|--------|--------|
| Firebase / Crashlytics / Analytics | **No** | — |
| Ads (AdMob, etc.) | **No** | — |
| Social (Facebook, Twitter SDKs) | **No** | — |
| Other analytics or tracking SDKs | **No** | — |

**Dependencies:** No `Package.resolved`, `Podfile`, or `Carthage` in repo. Only Apple frameworks: **SwiftUI**, **CoreData**, **PhotosUI**, **Photos**, **AVFoundation**, **LocalAuthentication**, **PDFKit**, **Combine**, **os** (Logger).  
**Citation:** Imports across `LoopJournal/*.swift`; `project.pbxproj` / `project.yml` (no SPM/CocoaPods targets).

---

## 3. Network, Endpoints, Cloud Sync

| Item | Present | Where |
|------|--------|--------|
| Custom backend / API calls | **No** | No `URLSession`, `.dataTask`, or custom HTTP in app code. |
| iCloud / CloudKit | **No** | No `NSUbiquitousKeyValueStore`, `CKContainer`, or iCloud entitlements. |
| Cloud sync of journal data | **No** | Core Data uses default local store only. `CoreDataManager.swift`: `NSPersistentContainer` with no remote store. |
| Outbound analytics or tracking endpoints | **No** | — |

**Citation:** `CoreDataManager.swift` (persistent store descriptions); no network-related imports or URLs for sync/analytics.  
**NSAppTransportSecurity:** `NSAllowsArbitraryLoads: false` in `Info.plist` (no arbitrary HTTP).

---

## 4. User Identifiers

| Identifier | Present | Where / notes |
|------------|--------|----------------|
| Account ID / email / sign‑in | **No** | No account system. Sign in with Apple is in `LoopJournal.entitlements` but **not used in code** (no `AuthenticationServices`, `ASAuthorization`). |
| Device ID (e.g. IDFV) for tracking | **No** | No `identifierForVendor` or similar. |
| Advertising identifier (IDFA) | **No** | No `requestTrackingAuthorization` or `ATTrackingManager`. |
| UUID for journal entries | **Yes (on-device only)** | `JournalEntryEntity.uuid` (Core Data); `JournalEntryModel.id` (UUID). Used only as local entity ID; not sent off device. **Citation:** `JournalEntry+CoreData.swift`, `CoreDataManager.swift`, `JournalEntryModel.swift`. |

---

## 5. Data Storage: On‑Device vs External

| Data | Stored | Synced / sent off device |
|------|--------|----------------------------|
| Journal entries (date, mood, note, image, voice URL, link URL) | **Yes** | **No** — Core Data local store only. |
| Voice recordings | **Yes** | **No** — files in app `Document` directory (`LogEntryView.swift`: `newRecordingURL()`). |
| Photos (in entries) | **Yes** | **No** — stored as `imageData` in Core Data. Optional copy to system Photo Library if user enables “Save photos to device” (user’s choice). |
| App lock preference | **Yes** | **No** — `UserDefaults` (`biometricLockEnabled`). **Citation:** `AuthManager.swift`. |
| Settings (e.g. background effects, audio quality, save photos to device) | **Yes** | **No** — `@AppStorage` / `UserDefaults`. |

**Citation:** `CoreDataManager.swift` (model, no remote store); `LogEntryView.swift` (voice path, optional `saveImageToPhotos`); `AuthManager.swift`; `SettingsView.swift`.  
**Entitlement:** `com.apple.developer.default-data-protection` = `NSFileProtectionComplete` in `LoopJournal.entitlements`.

---

## 6. App Tracking Transparency (ATT)

| Item | Present | Where |
|------|--------|--------|
| ATT / tracking authorization | **No** | No `requestTrackingAuthorization` or `ATTrackingManager`. **Citation:** repo grep. |
| Privacy manifest (tracking) | **Declared false** | `LoopJournal/PrivacyInfo.xcprivacy`: `NSPrivacyTracking` = false, `NSPrivacyTrackingDomains` = empty array. |

---

## 7. Children

| Item | Present | Where |
|------|--------|--------|
| Age gate / under-13 flow | **No** | — |
| COPPA‑specific logic | **No** | — |
| “Designed for children” / Kids category | **No** | — |

**Conclusion:** App does not target or exclude children in code; age rating would be set in App Store Connect.

---

## 8. User Ability to Delete Data

| Capability | Present | Where |
|------------|--------|--------|
| Delete a single entry | **Yes** | Trash on entry card: `JournalEntryCard` → `onDelete` → `CoreDataManager.shared.deleteInBackground(objectID:)`. Timeline list: `CoreDataTimelineView` → `onDelete(perform: delete)` → `deleteInBackground`. **Citation:** `TimelineView.swift`, `JournalEntryCard.swift`, `CoreDataTimelineView.swift`, `CoreDataManager.swift`. |
| Delete all data | **Yes** | Settings: “Delete All Data” → `deleteAllData()` deletes all `JournalEntryEntity` and saves context. **Citation:** `SettingsView.swift` (alert, `deleteAllData()`). |

---

## 9. Data Map (Apple’s Categories)

### Data Used to Track You

**NOT PRESENT** (verified in codebase).

- No third‑party tracking SDKs (no such imports or dependencies).
- No ATT or IDFA usage (grep: no `requestTrackingAuthorization`, `ATTrackingManager`).
- Privacy manifest: `NSPrivacyTracking` false, `NSPrivacyTrackingDomains` empty.
- **Citation:** `PrivacyInfo.xcprivacy`; codebase search for tracking/analytics APIs.

---

### Data Linked to You

Data that is stored or used in a way that could be linked to the user (here: the device user), and that the app “collects” in Apple’s sense (including local storage). Only what is **verified in the codebase** is listed.

| Data type (Apple‑style) | Verified in code? | Stored / used where | Sent off device? |
|------------------------|-------------------|----------------------|------------------|
| **User Content** (journal text, mood selections, photos attached to entries, voice recordings, links user adds) | **Yes** | Core Data (`JournalEntryEntity`: note, moodEmojisRaw, imageData, voiceNoteURL, linkURL, date, uuid); voice files in app Documents. Optional copy to system Photo Library if user enables setting. **Citation:** `CoreDataManager.swift`, `JournalEntry+CoreData.swift`, `LogEntryView.swift`. | **No** — no transmission in codebase. |
| **Identifiers** (account, device ID, etc.) | **Not present** | No account or device-identifier collection in code. Entry `uuid` is local entity ID only; not sent. | **No** |
| **Sensitive data** (e.g. health, precise location) | **Not present** | — | — |
| **Biometric** (Face ID / Touch ID) | **Not collected** | Used only for app lock (LocalAuthentication); no biometric data stored or transmitted. **Citation:** `AuthManager.swift`, `LoopJournal.entitlements`. | **No** |

---

### Data Not Linked to You

**NOT PRESENT** (verified in codebase).

- No analytics or crash-reporting SDKs; no collection of diagnostics or usage data in code.
- `PrivacyInfo.xcprivacy`: `NSPrivacyCollectedDataTypes` = empty array.
- **Citation:** No such SDKs or APIs in project; `PrivacyInfo.xcprivacy`.

---

## 10. Entitlements & Capabilities (Summary)

| Entitlement / capability | File | Purpose / verification |
|--------------------------|------|------------------------|
| **Sign in with Apple** | `LoopJournal.entitlements`: `com.apple.developer.applesignin` (Default) | Declared in entitlements. **Not present in code:** no `AuthenticationServices` or `ASAuthorization` imports or calls. |
| **Data protection** | `LoopJournal.entitlements`: `com.apple.developer.default-data-protection` = `NSFileProtectionComplete` | **Verified** in entitlements file. |
| **Journaling Suggestions** | `LoopJournal.entitlements`: `com.apple.developer.journal.allow` = `suggestions` | Declared in entitlements. **Not verified in codebase:** no `Journal` framework usage found; system behavior with this entitlement not verified. |

---

## 11. Summary Checklist

- **Permissions:** Photo Library (read + add), Microphone, Face ID used in code; usage description keys **not** in current `Info.plist`/`project.yml` (add before release).
- **Third‑party SDKs:** None; Apple frameworks only.
- **Network / cloud:** No custom backend, no iCloud sync, no analytics endpoints.
- **Identifiers:** No account, no IDFA/IDFV for tracking; only local entry UUIDs.
- **Storage:** All journal and app data on-device; optional save to Photos at user’s choice.
- **ATT:** Not present; privacy manifest declares no tracking.
- **Children:** No age gate or COPPA logic in code.
- **Deletion:** Single-entry delete and “Delete All Data” in Settings.

---

*Audit complete. No privacy policy drafted. Use this data map when filling App Store Connect privacy labels and when writing the policy later.*
