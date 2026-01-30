import Foundation
import SwiftUI

/// ViewModel for managing the timeline of journal entries.
class TimelineViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = DummyData.entries
    @Published var currentIndex: Int = 0
    
    /// Move to the next entry (swipe up)
    func nextEntry() {
        guard currentIndex < entries.count - 1 else { return }
        currentIndex += 1
    }
    
    /// Move to the previous entry (swipe down)
    func previousEntry() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
    
    /// Get the currently visible entry
    var currentEntry: JournalEntry {
        entries[currentIndex]
    }
}
