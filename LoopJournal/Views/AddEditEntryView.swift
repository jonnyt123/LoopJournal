import SwiftUI
import CoreData

struct AddEditEntryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var moodEmojis: String = ""
    @State private var note: String = ""
    @State private var imageData: Data? = nil
    @State private var date: Date = Date()
    @State private var voiceNoteURL: URL? = nil
    var entry: JournalEntryEntity?
    
    var isEditing: Bool { entry != nil }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mood Emojis (comma separated)")) {
                    TextField("e.g. 😊,😎", text: $moodEmojis)
                }
                Section(header: Text("Note")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
                Section(header: Text("Date")) {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                }
                Section(header: Text("Photo (optional)")) {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(12)
                    }
                    Button("Select Photo") {
                        selectPhoto()
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .disabled(moodEmojis.isEmpty || note.isEmpty)
                }
            }
            .onAppear {
                if let entry = entry {
                    moodEmojis = entry.moodEmojisRaw ?? ""
                    note = entry.note ?? ""
                    imageData = entry.imageData
                    date = entry.date ?? Date()
                }
            }
        }
    }
    
    private func save() {
        let entryObj = entry ?? JournalEntryEntity(context: context)
        entryObj.uuid = entryObj.uuid ?? UUID()
        entryObj.moodEmojisRaw = moodEmojis
        entryObj.note = note
        entryObj.imageData = imageData
        entryObj.date = date
        try? context.save()
        dismiss()
    }
    
    private func selectPhoto() {
        // Implement with PHPickerViewController or UIImagePickerController if needed
    }
}
