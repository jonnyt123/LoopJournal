import XCTest
import CoreData
@testable import LoopJournal

final class LoopJournalTests: XCTestCase {

    private var manager: CoreDataManager!

    override func setUp() {
        super.setUp()
        manager = CoreDataManager(inMemory: true)
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    // MARK: - Smoke test

    func testEntryModelSmoke() {
        let entry = JournalEntryModel(
            id: UUID(),
            date: Date(),
            updatedAt: Date(),
            moodEmojis: ["🙂"],
            note: "Test",
            imageData: nil,
            voiceNoteURL: nil,
            linkURL: nil
        )
        XCTAssertEqual(entry.moodEmojis, ["🙂"])
        XCTAssertEqual(entry.note, "Test")
    }

    // MARK: - Create

    func testCreateEntry() {
        manager.addEntry(model: makeModel(note: "Hello"))

        let results = fetchAll()
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.note, "Hello")
        XCTAssertNotNil(results.first?.updatedAt, "updatedAt must be set on create")
    }

    func testCreateSetsUpdatedAt() {
        let before = Date()
        manager.addEntry(model: makeModel(note: "Time check"))
        let after = Date()

        let entry = fetchAll().first
        guard let updatedAt = entry?.updatedAt else {
            XCTFail("updatedAt must not be nil after create")
            return
        }
        XCTAssertGreaterThanOrEqual(updatedAt, before)
        XCTAssertLessThanOrEqual(updatedAt, after)
    }

    // MARK: - Update

    func testUpdateEntryNote() {
        manager.addEntry(model: makeModel(note: "Original"))

        guard let entity = fetchAll().first else {
            XCTFail("No entry found")
            return
        }

        let updatedModel = JournalEntryModel(
            id: entity.uuid ?? UUID(),
            date: entity.date ?? Date(),
            updatedAt: Date(),
            moodEmojis: ["😄"],
            note: "Updated",
            imageData: nil,
            voiceNoteURL: nil,
            linkURL: nil
        )
        manager.update(entity, with: updatedModel)

        XCTAssertEqual(entity.note, "Updated")
        XCTAssertEqual(entity.moodEmojisArray, ["😄"])
    }

    func testUpdateBumpsUpdatedAt() {
        manager.addEntry(model: makeModel(note: "Original"))

        guard let entity = fetchAll().first else {
            XCTFail("No entry found")
            return
        }

        let beforeUpdate = Date()
        let updatedModel = JournalEntryModel(
            id: entity.uuid ?? UUID(),
            date: entity.date ?? Date(),
            updatedAt: Date(),
            moodEmojis: entity.moodEmojisArray,
            note: "Edited",
            imageData: nil,
            voiceNoteURL: nil,
            linkURL: nil
        )
        manager.update(entity, with: updatedModel)

        guard let newUpdatedAt = entity.updatedAt else {
            XCTFail("updatedAt must not be nil after update")
            return
        }
        XCTAssertGreaterThanOrEqual(newUpdatedAt, beforeUpdate, "updatedAt must not predate the update call")
    }

    // MARK: - Delete

    func testDeleteEntry() {
        manager.addEntry(model: makeModel(note: "Delete me"))
        XCTAssertEqual(fetchAll().count, 1)

        guard let entity = fetchAll().first else {
            XCTFail("Entry not found")
            return
        }
        manager.delete(entity)

        XCTAssertEqual(fetchAll().count, 0)
    }

    func testDeleteReducesCount() {
        manager.addEntry(model: makeModel(note: "Keep"))
        manager.addEntry(model: makeModel(note: "Remove"))
        XCTAssertEqual(fetchAll().count, 2)

        guard let toDelete = fetchAll().first(where: { $0.note == "Remove" }) else {
            XCTFail("Entry not found")
            return
        }
        manager.delete(toDelete)

        let remaining = fetchAll()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.note, "Keep")
    }

    // MARK: - Persistence reload

    func testPersistenceReload() {
        manager.addEntry(model: makeModel(note: "Persisted"))

        // Re-fetch from the same in-memory context to simulate a reload
        let results = fetchAll()
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.note, "Persisted")
        XCTAssertNotNil(results.first?.updatedAt)
    }

    func testPersistencePreservesAllFields() {
        let id = UUID()
        let now = Date()
        let model = JournalEntryModel(
            id: id,
            date: now,
            updatedAt: now,
            moodEmojis: ["😌", "🧠"],
            note: "Fields check",
            imageData: nil,
            voiceNoteURL: nil,
            linkURL: nil
        )
        manager.addEntry(model: model)

        guard let entity = fetchAll().first else {
            XCTFail("Entry not found")
            return
        }
        XCTAssertEqual(entity.uuid, id)
        XCTAssertEqual(entity.note, "Fields check")
        XCTAssertEqual(entity.moodEmojisArray, ["😌", "🧠"])
    }

    // MARK: - Sorting

    func testSortByUpdatedAtNewestFirst() {
        // Insert two entries with explicitly different updatedAt values so the test
        // doesn't rely on clock resolution.
        manager.addEntry(model: makeModel(note: "First"))
        manager.addEntry(model: makeModel(note: "Second"))

        // Assign stable, distinct timestamps directly on the entities.
        let all = fetchAll()
        guard let first = all.first(where: { $0.note == "First" }),
              let second = all.first(where: { $0.note == "Second" }) else {
            XCTFail("Entries not found")
            return
        }
        let older = Date(timeIntervalSinceNow: -60)
        let newer = Date(timeIntervalSinceNow: -30)
        first.updatedAt = older
        second.updatedAt = newer
        manager.save()

        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntryEntity.updatedAt, ascending: false)]
        let results = (try? manager.context.fetch(request)) ?? []

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.note, "Second", "Most recently updated entry must appear first")
        XCTAssertEqual(results.last?.note, "First")
    }

    func testEditedEntryMovesToTop() {
        manager.addEntry(model: makeModel(note: "Alpha"))
        manager.addEntry(model: makeModel(note: "Beta"))

        // Assign stable, distinct initial timestamps so Alpha appears older than Beta.
        let all = fetchAll()
        guard let alpha = all.first(where: { $0.note == "Alpha" }),
              let beta = all.first(where: { $0.note == "Beta" }) else {
            XCTFail("Entries not found")
            return
        }
        alpha.updatedAt = Date(timeIntervalSinceNow: -120)
        beta.updatedAt = Date(timeIntervalSinceNow: -60)
        manager.save()

        // Edit Alpha so its updatedAt becomes the newest.
        let editedModel = JournalEntryModel(
            id: alpha.uuid ?? UUID(),
            date: alpha.date ?? Date(),
            updatedAt: Date(),
            moodEmojis: alpha.moodEmojisArray,
            note: "Alpha edited",
            imageData: nil,
            voiceNoteURL: nil,
            linkURL: nil
        )
        manager.update(alpha, with: editedModel)

        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntryEntity.updatedAt, ascending: false)]
        let sorted = (try? manager.context.fetch(request)) ?? []

        XCTAssertEqual(sorted.first?.note, "Alpha edited", "Edited entry must sort to the top")
    }

    // MARK: - Helpers

    private func makeModel(note: String) -> JournalEntryModel {
        JournalEntryModel(
            id: UUID(),
            date: Date(),
            updatedAt: Date(),
            moodEmojis: ["🙂"],
            note: note,
            imageData: nil,
            voiceNoteURL: nil,
            linkURL: nil
        )
    }

    private func fetchAll() -> [JournalEntryEntity] {
        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        return (try? manager.context.fetch(request)) ?? []
    }
}
