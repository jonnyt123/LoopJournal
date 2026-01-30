import SwiftUI
import PDFKit

/// Settings screen with privacy controls and export options
struct SettingsView: View {
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntryEntity.date, ascending: false)]
    ) private var entries: FetchedResults<JournalEntryEntity>
    @ObservedObject var authManager = AuthManager.shared
    @State private var showingExportOptions = false
    @State private var showingDeleteConfirmation = false
    @State private var showingTutorialAlert = false

    @AppStorage("backgroundEffectsEnabled") private var backgroundEffectsEnabled = true
    @AppStorage("savePhotosToDevice") private var savePhotosToDevice = false
    @AppStorage("audioQuality") private var audioQuality = AudioQuality.standard.rawValue
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday = true
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.1, green: 0.1, blue: 0.15)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                let screenWidth = UIScreen.main.bounds.width
                let horizontalPadding: CGFloat = screenWidth < 380 ? 12 : 16
                List {
                    appearanceSection
                    journalSection
                    mediaSection
                    privacySection
                    dataSection
                    helpSection
                    aboutSection
                    privacyNoticeSection
                }
                .scrollContentBackground(.hidden)
                .padding(.horizontal, horizontalPadding)
            }
            .navigationTitle("Journal Settings")
            .navigationBarTitleDisplayMode(UIScreen.main.bounds.width < 380 ? .inline : .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .confirmationDialog("Export Options", isPresented: $showingExportOptions) {
                Button("Export as PDF") {
                    exportAsPDF()
                }
                Button("Export as CSV") {
                    exportAsCSV()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Everything", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your journal entries, moods, and media. This action cannot be undone.")
            }
            .alert("Tutorial Reset", isPresented: $showingTutorialAlert) {
                Button("OK") {}
            } message: {
                Text("The tutorial will show the next time you open the app.")
            }
            .sheet(isPresented: $showShareSheet, onDismiss: { exportURL = nil }) {
                if let exportURL = exportURL {
                    ShareFileViewController(url: exportURL)
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section {
            Toggle(isOn: $backgroundEffectsEnabled) {
                Label("✨ Background Effects", systemImage: "sparkles")
                    .foregroundColor(.white)
            }
            .tint(.cyan)
        } header: {
            Text("APPEARANCE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var journalSection: some View {
        Section {
            Toggle(isOn: $weekStartsOnMonday) {
                Label("Week Starts on Monday", systemImage: "calendar")
                    .foregroundColor(.white)
            }
            .tint(.cyan)
        } header: {
            Text("JOURNAL")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var mediaSection: some View {
        Section {
            Toggle(isOn: $savePhotosToDevice) {
                Label("Save Photos to Device", systemImage: "photo.on.rectangle")
                    .foregroundColor(.white)
            }
            .tint(.cyan)

            Picker("Audio Quality", selection: $audioQuality) {
                ForEach(AudioQuality.allCases) { quality in
                    Text(quality.title).tag(quality.rawValue)
                }
            }
        } header: {
            Text("MEDIA")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var privacySection: some View {
        Section {
            HStack {
                Label("App Lock", systemImage: "lock.fill")
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { authManager.isLockEnabled },
                    set: { enabled in
                        if enabled {
                            enableAppLock()
                        } else {
                            disableAppLock()
                        }
                    }
                ))
                .labelsHidden()
                .tint(.cyan)
            }
            HStack {
                Label(authManager.biometricType.displayName, systemImage: authManager.biometricType.iconName)
                    .foregroundColor(.white)
                Spacer()
                Text(authManager.isLockEnabled ? "Enabled" : "Disabled")
                    .foregroundColor(authManager.isLockEnabled ? .cyan : .gray)
                    .font(.system(size: 14, weight: .medium))
            }
            if !authManager.isBiometricAvailable {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("No biometric hardware available")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        } header: {
            Text("SECURITY & PRIVACY")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var dataSection: some View {
        Section {
            Button(action: { showingExportOptions = true }) {
                HStack {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                        .foregroundColor(.cyan)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            Button(action: { showingDeleteConfirmation = true }) {
                HStack {
                    Label("Clear All Data", systemImage: "trash.fill")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        } header: {
            Text("DATA MANAGEMENT")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var helpSection: some View {
        Section {
            Button(action: {
                hasSeenTutorial = false
                showingTutorialAlert = true
            }) {
                HStack {
                    Label("Replay Tutorial", systemImage: "questionmark.circle")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        } header: {
            Text("HELP")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle.fill")
                    .foregroundColor(.white)
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.white.opacity(0.5))
            }
            HStack {
                Label("Storage Used", systemImage: "internaldrive.fill")
                    .foregroundColor(.white)
                Spacer()
                Text("\(calculateStorageUsed()) MB")
                    .foregroundColor(.white.opacity(0.5))
            }
        } header: {
            Text("ABOUT")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var privacyNoticeSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your data stays private")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text("All journal entries are stored locally on your device. No data is ever sent to external servers.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("PRIVACY")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private func enableAppLock() {
        Task {
            await authManager.authenticate()

            // Only enable lock if authentication was successful
            if authManager.isAuthenticated {
                authManager.setLockEnabled(true)
            } else {
                // Authentication failed, keep lock disabled
                if authManager.authenticationError != nil {
                    // Show error
                }
            }
        }
    }

    private func disableAppLock() {
        authManager.setLockEnabled(false)
    }

    private func calculateStorageUsed() -> String {
        let bytes = entries.reduce(0) { partial, entry in
            let imageBytes = entry.imageData?.count ?? 0
            let noteBytes = (entry.note ?? "").utf8.count
            return partial + imageBytes + noteBytes
        }
        let mb = Double(bytes) / (1024.0 * 1024.0)
        return String(format: "%.1f", mb)
    }

    private func exportAsPDF() {
        let journalEntries = entries.compactMap { JournalEntry(entity: $0) }
        PDFExportService.exportAll(entries: journalEntries) { url in
            if let url = url {
                self.exportURL = url
                self.showShareSheet = true
            }
        }
    }

    private func exportAsCSV() {
        let header = "date,moodEmojis,note"
        let rows = entries.map { entry -> String in
            let date = (entry.date ?? Date()).ISO8601Format()
            let mood = entry.moodEmojisArray.joined(separator: " ")
            let note = (entry.note ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(date)\",\"\(mood)\",\"\(note)\""
        }
        let csv = ([header] + rows).joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("LoopJournalEntries.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
            showShareSheet = true
        } catch {
            // Ignore for now
        }
    }

    private func deleteAllData() {
        for entry in entries {
            context.delete(entry)
        }
        try? context.save()
    }

}

// UIKit wrapper for UIActivityViewController (file share)
private struct ShareFileViewController: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activity.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .markupAsPDF,
            .print,
            .copyToPasteboard,
            .message,
            .mail,
            .airDrop,
            .openInIBooks
        ]
        return activity
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
