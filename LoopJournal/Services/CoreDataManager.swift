import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }
    
    private init() {
        let model = CoreDataManager.makeModel()
        container = NSPersistentContainer(name: "LoopJournal", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error.localizedDescription)")
            }
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "JournalEntryEntity"
        entity.managedObjectClassName = NSStringFromClass(JournalEntryEntity.self)

        func attribute(_ name: String, type: NSAttributeType, optional: Bool = true) -> NSAttributeDescription {
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = optional
            return attr
        }

        let uuid = attribute("uuid", type: .UUIDAttributeType)
        let date = attribute("date", type: .dateAttributeType)
        let moodEmojis = attribute("moodEmojis", type: .stringAttributeType)
        let note = attribute("note", type: .stringAttributeType)
        let imageData = attribute("imageData", type: .binaryDataAttributeType)
        imageData.allowsExternalBinaryDataStorage = true
        let voiceNoteURL = attribute("voiceNoteURL", type: .URIAttributeType)
        let linkURL = attribute("linkURL", type: .URIAttributeType)

        entity.properties = [uuid, date, moodEmojis, note, imageData, voiceNoteURL, linkURL]
        model.entities = [entity]
        return model
    }
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
    
    func addEntry(model: JournalEntryModel) {
        let entry = JournalEntryEntity(context: context)
        entry.uuid = model.id
        entry.date = model.date
        entry.moodEmojisRaw = model.moodEmojis.joined(separator: ",")
        entry.note = model.note
        entry.imageData = model.imageData
        entry.voiceNoteURL = model.voiceNoteURL
        save()
    }
    
    func delete(_ entry: JournalEntryEntity) {
        context.delete(entry)
        save()
    }
    
    func update(_ entry: JournalEntryEntity, with model: JournalEntryModel) {
        entry.date = model.date
        entry.moodEmojisRaw = model.moodEmojis.joined(separator: ",")
        entry.note = model.note
        entry.imageData = model.imageData
        entry.voiceNoteURL = model.voiceNoteURL
        save()
    }
}
