# AGENTS.md

Local instructions for Codex and other agents working on LoopJournal.

## Scope and priority
- Applies to work inside `/Users/jonny/LoopJournal/LoopJournal.xcodeproj`.
- If instructions conflict, follow the most specific instructions closest to the files being edited.

## Project overview
- iOS app: LoopJournal (SwiftUI).
- Xcode project is generated from `project.yml` (XcodeGen).
- App target: `LoopJournal`, iOS 17.0, Swift 5.9.

## Workflow expectations (default for this repo)
- Make small, focused changes; avoid unrelated refactors.
- Prefer clarifying questions if intent is ambiguous.
- Keep privacy-first assumptions intact (offline-first, no external APIs).

## Editing rules
- Use ASCII unless the file already includes non-ASCII.
- Prefer `apply_patch` for single-file edits.
- Avoid editing generated files directly unless requested.
- If project settings change, update `project.yml` and regenerate the Xcode project.

## Build and run
- Open project: `open /Users/jonny/LoopJournal/LoopJournal.xcodeproj`
- Simulator: iPhone 14+ recommended.
- CLI build (optional):
  - `xcodebuild -project /Users/jonny/LoopJournal/LoopJournal.xcodeproj -scheme LoopJournal -destination 'platform=iOS Simulator,name=iPhone 14' build`

## XcodeGen
- Source of truth: `/Users/jonny/LoopJournal/project.yml`.
- Regenerate after changes: `xcodegen --spec /Users/jonny/LoopJournal/project.yml`
- Do not hand-edit `.xcodeproj` contents unless explicitly asked.

## Testing
- Run the smallest relevant tests when feasible.
- If tests are not run, say so explicitly in the response.
- If no tests exist, state that and suggest a manual smoke check.

## Code style
- Follow existing SwiftUI patterns and naming.
- Keep view code declarative; push logic into view models when appropriate.
- Prefer small, composable views in `LoopJournal/Views`.

## Data and privacy
- Keep data local (Core Data / on-device storage).
- No networking or external APIs without explicit request.
- Be careful with permissions and Info.plist changes.

## Communication
- Summarize what changed and why.
- Reference files by path.
- Offer next steps (tests, build, run) when helpful.
