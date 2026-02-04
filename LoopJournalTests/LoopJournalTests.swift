import XCTest
@testable import LoopJournal

final class LoopJournalTests: XCTestCase {
    func testEntryModelSmoke() {
        let entry = JournalEntryModel(
            id: UUID(),
            date: Date(),
            moodEmojis: ["🙂"],
            note: "Test",
            imageData: nil,
            voiceNoteURL: nil,
            linkURL: nil
        )
        XCTAssertEqual(entry.moodEmojis, ["🙂"])
        XCTAssertEqual(entry.note, "Test")
    }
}
