# Performance & Smoothness Pass (Profiling-Based Bottlenecks)

Short list of bottlenecks that were addressed. No redesign; UI looks the same.

## Bottlenecks Addressed

### 1. Main-thread blocking: Core Data save/delete
- **Files:** `LoopJournal/Views/TimelineView.swift`, `LoopJournal/Views/LogEntryView.swift`, `LoopJournal/Views/CoreDataTimelineView.swift`, `LoopJournal/Services/CoreDataManager.swift`
- **Why:** `context.save()` and entity create/delete ran on the main thread, blocking the UI during save/delete.
- **Fix:** Background context for writes: `addEntryInBackground(model:completion:)`, `deleteInBackground(objectID:completion:)`. View context has `automaticallyMergesChangesFromParent = true` so UI updates after merge.

### 2. Main-thread blocking: image decode
- **Files:** `LoopJournal/Views/LogEntryView.swift`, `LoopJournal/Views/CoreDataTimelineView.swift`, `LoopJournal/Views/Components/MediaPreviewView.swift`
- **Why:** `UIImage(data:)` and `UIImage(named:)` decode on the calling thread; used on main thread caused hitches when displaying/saving images.
- **Fix:** Decode on `DispatchQueue.global(qos: .userInitiated)` and assign result on main. CoreDataTimelineView uses `AsyncDecodedImageView`; MediaPreviewView loads asset images on background; LogEntryView decodes for photo save on background.

### 3. Carousel: unnecessary re-renders and heavy list animation
- **Files:** `LoopJournal/Views/TimelineView.swift`
- **Why:** `ForEach(entries.indices, id: \.self)` made identity depend on index, causing extra view updates when order changed; `FetchRequest(animation: .spring())` triggered heavy list animations; preference handler ran every layout and could update state even when `currentIndex` was unchanged.
- **Fix:** `ForEach(Array(entries.enumerated()), id: \.element.objectID)` for stable identity; `animation: .none` on FetchRequest; early-return in `onPreferenceChange` when `nearest == currentIndex`.

### 4. Expensive blur and shadow on cards
- **Files:** `LoopJournal/Views/JournalEntryCard.swift`
- **Why:** `BlurView(style: .systemUltraThinMaterialDark)` and `.shadow(radius: 18, y: 10)` are costly during scroll and composition.
- **Fix:** Replaced blur with semi-opaque overlay (`Color.white.opacity(0.06)`); reduced shadow to `radius: 8, y: 4` for similar look with less cost.

### 5. Mood background and particles: extra compositing
- **Files:** `LoopJournal/Views/JournalEntryCard.swift` (MoodBackgroundView), `LoopJournal/Views/Components/ParticleOverlay.swift`
- **Why:** ZStack of image/gradient + wash + particle overlay caused repeated compositing each frame; particle animations with multiple text layers and blur were expensive.
- **Fix:** `.drawingGroup()` on MoodBackgroundView and on ParticleOverlay so layers are rasterized and composited once per frame.

### 6. CoreDataTimelineView list delete and animation
- **Files:** `LoopJournal/Views/CoreDataTimelineView.swift`
- **Why:** Delete used main-context delete + save; list used `.spring()` animation; image decode in `entryRow` was on main thread.
- **Fix:** Delete via `deleteInBackground(objectID:)`; `animation: .none` on FetchRequest; `AsyncDecodedImageView` for entry thumbnails.

---

## How to Verify

- Build: `xcodebuild -scheme LoopJournal -destination 'platform=iOS Simulator,name=iPhone 17' build`
- Test: `xcodebuild test -scheme LoopJournal -destination 'platform=iOS Simulator,name=iPhone 17'`
- In simulator: swipe carousel quickly, add/delete entries, open timeline list and scroll; UI should stay responsive and smooth.
