import Foundation

/// Dummy data for previewing the timeline with 7 journal entries.
struct DummyData {
    static let entries: [JournalEntry] = [
        JournalEntry(id: UUID(), date: Date().addingTimeInterval(-6*86400), moodEmojis: ["😄"], note: "Had an amazing day at the park! The weather was perfect and I felt so alive and grateful for this beautiful day.", media: .photo(imageName: "photo1"), mood: .happy, theme: .defaultDark),
        JournalEntry(id: UUID(), date: Date().addingTimeInterval(-5*86400), moodEmojis: ["😌"], note: "Quiet morning, slow music, and a cup of tea.", media: .voice(audioName: "voice1"), mood: .calm, theme: .neon),
        JournalEntry(id: UUID(), date: Date().addingTimeInterval(-4*86400), moodEmojis: ["🎧"], note: "Deep focus session — finished a long task.", media: .link(url: URL(string: "https://youtube.com")!), mood: .focused, theme: .retro),
        JournalEntry(id: UUID(), date: Date().addingTimeInterval(-3*86400), moodEmojis: ["😢"], note: "Felt a bit down today, but writing helps me process.", media: nil, mood: .sad, theme: .defaultDark),
        JournalEntry(id: UUID(), date: Date().addingTimeInterval(-2*86400), moodEmojis: ["🧠"], note: "Knocked out my to-do list and cleared my head.", media: .link(url: URL(string: "https://spotify.com")!), mood: .productive, theme: .neon),
        JournalEntry(id: UUID(), date: Date().addingTimeInterval(-1*86400), moodEmojis: ["💭"], note: "Reflecting on how the week went and what I learned.", media: .photo(imageName: "photo2"), mood: .reflective, theme: .scrapbook),
        JournalEntry(id: UUID(), date: Date(), moodEmojis: ["🌈"], note: "Idea spark! Planning something new and exciting.", media: .photo(imageName: "photo3"), mood: .inspired, theme: .retro)
    ]
}
