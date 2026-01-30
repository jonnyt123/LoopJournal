import Foundation
import SwiftUI

struct JournalEntryModel: Identifiable {
    let id: UUID
    let date: Date
    let moodEmojis: [String]
    let note: String
    let imageData: Data?
    let voiceNoteURL: URL?
}

extension JournalEntryModel {
    init(entity: JournalEntryEntity) {
        self.id = entity.uuid ?? UUID()
        self.date = entity.date ?? Date()
        self.moodEmojis = entity.moodEmojisArray
        self.note = entity.note ?? ""
        self.imageData = entity.imageData
        self.voiceNoteURL = entity.voiceNoteURL
    }
}
