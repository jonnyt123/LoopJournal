import Foundation
import CoreData

@objc(JournalEntryEntity)
public class JournalEntryEntity: NSManagedObject {
    public var id: NSManagedObjectID { objectID }
}

extension JournalEntryEntity: Identifiable {}

extension JournalEntryEntity: MoodEmojisProvider {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntryEntity> {
        NSFetchRequest<JournalEntryEntity>(entityName: "JournalEntryEntity")
    }
    @NSManaged var uuid: UUID?
    @NSManaged var date: Date?
    @NSManaged @objc(moodEmojis) var moodEmojisRaw: String? // comma-separated
    @NSManaged var note: String?
    @NSManaged var imageData: Data?
    @NSManaged public var voiceNoteURL: URL?
    @NSManaged var linkURL: URL?

    var moodEmojisArray: [String] {
        (moodEmojisRaw ?? "")
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    public var moodEmojis: [String] { moodEmojisArray }
    public var noteText: String { note ?? "" }
    public var entryDate: Date { date ?? Date() }
}
