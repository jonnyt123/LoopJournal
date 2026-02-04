import Foundation
import CoreData
import os

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    /// True if the store failed to load; app can still run with empty data.
    private(set) var didFailToLoadStore = false
    private static let logger = Logger(subsystem: "com.loopjournal.app", category: "CoreData")

    private init() {
        let model = CoreDataManager.makeModel()
        container = NSPersistentContainer(name: "LoopJournal", managedObjectModel: model)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }

        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                Self.logger.error("Core Data store failed to load: \(error.localizedDescription)")
                self?.didFailToLoadStore = true
                return
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
        guard !didFailToLoadStore, context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            Self.logger.error("Core Data save failed: \(error.localizedDescription)")
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
        entry.linkURL = model.linkURL
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

    /// Performs delete on a background context so the main thread is not blocked.
    func deleteInBackground(objectID: NSManagedObjectID, completion: (() -> Void)? = nil) {
        let container = self.container
        DispatchQueue.global(qos: .userInitiated).async {
            let bg = container.newBackgroundContext()
            bg.performAndWait {
                let obj = bg.object(with: objectID)
                bg.delete(obj)
                do {
                    try bg.save()
                } catch {
                    Self.logger.error("Background delete save failed: \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async { completion?() }
        }
    }

    /// Performs insert + save on a background context so the main thread is not blocked.
    func addEntryInBackground(model: JournalEntryModel, completion: @escaping () -> Void) {
        let container = self.container
        let modelCopy = model
        DispatchQueue.global(qos: .userInitiated).async {
            let bg = container.newBackgroundContext()
            bg.performAndWait {
                let entry = JournalEntryEntity(context: bg)
                entry.uuid = modelCopy.id
                entry.date = modelCopy.date
                entry.moodEmojisRaw = modelCopy.moodEmojis.joined(separator: ",")
                entry.note = modelCopy.note
                entry.imageData = modelCopy.imageData
                entry.voiceNoteURL = modelCopy.voiceNoteURL
                entry.linkURL = modelCopy.linkURL
                do {
                    try bg.save()
                } catch {
                    Self.logger.error("Background add save failed: \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async { completion() }
        }
    }
}
