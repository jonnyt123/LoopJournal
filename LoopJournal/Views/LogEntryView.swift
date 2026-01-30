import SwiftUI
import CoreData
import PhotosUI
import AVFoundation
import Photos

/// View for logging a new journal entry
struct LogEntryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMoods: Set<Mood> = []
    @State private var journalText: String = ""
    @State private var isSaving = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingLinkSheet = false
    @State private var linkText: String = ""
    @State private var selectedLinkURL: URL?
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var recordingURL: URL?
    @State private var recordingError: String?

    @AppStorage("savePhotosToDevice") private var savePhotosToDevice = false
    @AppStorage("audioQuality") private var audioQuality = AudioQuality.standard.rawValue
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.08, blue: 0.15),
                        Color(red: 0.12, green: 0.12, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    let screenWidth = UIScreen.main.bounds.width
                    let headerSize: CGFloat = screenWidth < 380 ? 24 : 28
                    let sectionSpacing: CGFloat = screenWidth < 380 ? 24 : 32
                    VStack(spacing: sectionSpacing) {
                        // Header
                        VStack(spacing: 8) {
                            Text("How are you feeling?")
                                .font(.system(size: headerSize, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Select your mood(s) to capture this moment")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, screenWidth < 380 ? 12 : 20)
                        
                        // Mood Selector
                        moodSelectorSection
                        
                        // Journal Entry Text
                        journalTextSection
                        
                        // Media Options
                        mediaSection
                        
                        // Save Button
                        saveButton
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, screenWidth < 380 ? 16 : 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Log Entry")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.black.opacity(0.3), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onDisappear {
            if isRecording {
                stopRecording()
            }
        }
    }
    
    // MARK: - Mood Selector Section
    
    private var moodSelectorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Mood")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 90), spacing: 12)
            ], spacing: 16) {
                ForEach(Mood.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMoods.contains(mood),
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedMoods.contains(mood) {
                                    selectedMoods.remove(mood)
                                } else {
                                    selectedMoods.insert(mood)
                                }
                            }
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    )
                }
            }
            
            // Selected mood indicator
            if !selectedMoods.isEmpty {
                HStack {
                    Text("Selected:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    ForEach(Array(selectedMoods), id: \.self) { mood in
                        Text(mood.emoji + " " + mood.rawValue.capitalized)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: moodGradientColors(for: mood),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - Journal Text Section
    
    private var journalTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Thoughts")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            TextEditor(text: $journalText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(minHeight: 120, maxHeight: 200)
                .scrollContentBackground(.hidden)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 4)
            
            if journalText.isEmpty {
                Text("What's on your mind? Write whatever feels right...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal, 32)
                    .padding(.top, -110)
                    .allowsHitTesting(false)
            }
            
            Text("\(journalText.count) characters")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 8)
        }
    }
    
    // MARK: - Media Section
    
    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Media (Optional)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    MediaOptionLabel(
                        icon: "camera.fill",
                        label: "Photo",
                        gradientColors: [.cyan, .blue]
                    )
                }
                
                MediaOptionButton(
                    icon: isRecording ? "stop.fill" : "mic.fill",
                    label: isRecording ? "Stop" : "Voice",
                    gradientColors: isRecording ? [.red, .orange] : [.pink, .red]
                ) {
                    toggleRecording()
                }
                
                MediaOptionButton(
                    icon: "link",
                    label: "Link",
                    gradientColors: [.orange, .yellow]
                ) {
                    showingLinkSheet = true
                }
            }

            if let recordingURL = recordingURL {
                Text("Voice note ready: \(recordingURL.lastPathComponent)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            } else if isRecording {
                Text("Recording...")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.red.opacity(0.8))
            } else if let recordingError = recordingError {
                Text(recordingError)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.red.opacity(0.8))
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem = newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        selectedImageData = data
                    }
                }
            }
        }
        .sheet(isPresented: $showingLinkSheet) {
            NavigationView {
                VStack(spacing: 16) {
                    Text("Add a Link")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    TextField("https://example.com", text: $linkText)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(24)
                .navigationTitle("Link")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingLinkSheet = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            let trimmed = linkText.trimmingCharacters(in: .whitespacesAndNewlines)
                            selectedLinkURL = URL(string: trimmed)
                            showingLinkSheet = false
                        }
                        .disabled(linkText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        Button(action: saveEntry) {
            HStack(spacing: 12) {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text("Save Entry")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: canSave
                                ? [.cyan, .purple, .pink]
                                : [.gray, .gray.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: canSave ? .cyan.opacity(0.4) : .clear, radius: 10, y: 5)
        }
        .disabled(!canSave || isSaving)
    }
    
    // MARK: - Helpers
    
    private var canSave: Bool {
        !selectedMoods.isEmpty && !journalText.isEmpty
    }
    
    private func moodGradientColors(for mood: Mood) -> [Color] {
        switch mood {
        case .happy: return [.yellow, .pink]
        case .sad: return [.blue, .purple]
        case .calm: return [.mint, .cyan]
        case .focused: return [.purple, .blue]
        case .reflective: return [.indigo, .teal]
        case .productive: return [.green, .teal]
        case .inspired: return [.orange, .pink]
        case .angry: return [.red, .orange]
        case .anxious: return [.teal, .indigo]
        }
    }
    
    private func saveEntry() {
        guard canSave else { return }
        if isRecording {
            stopRecording()
        }
        isSaving = true
        let entry = JournalEntryEntity(context: context)
        entry.uuid = UUID()
        entry.date = Date()
        entry.moodEmojisRaw = selectedMoods
            .map(\.emoji)
            .joined(separator: ",")
        entry.note = journalText
        entry.imageData = selectedImageData
        entry.voiceNoteURL = recordingURL
        entry.linkURL = selectedLinkURL
        try? context.save()
        if savePhotosToDevice, let data = selectedImageData, let image = UIImage(data: data) {
            saveImageToPhotos(image)
        }
        isSaving = false
        dismiss()
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        recordingError = nil
        let session = AVAudioSession.sharedInstance()
        let handlePermission: (Bool) -> Void = { granted in
            DispatchQueue.main.async {
                guard granted else {
                    recordingError = "Microphone access is required to record."
                    return
                }
                do {
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                    try session.setActive(true)
                    let url = newRecordingURL()
                    let quality = AudioQuality(rawValue: audioQuality) ?? .standard
                    let settings = recordingSettings(for: quality)
                    let recorder = try AVAudioRecorder(url: url, settings: settings)
                    recorder.prepareToRecord()
                    recorder.record()
                    audioRecorder = recorder
                    recordingURL = nil
                    isRecording = true
                } catch {
                    recordingError = "Unable to start recording."
                }
            }
        }

        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission(completionHandler: handlePermission)
        } else {
            session.requestRecordPermission(handlePermission)
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        recordingURL = audioRecorder?.url
        audioRecorder = nil
        isRecording = false
    }

    private func newRecordingURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("voice-\(UUID().uuidString).m4a")
    }

    private func recordingSettings(for quality: AudioQuality) -> [String: Any] {
        switch quality {
        case .standard:
            return [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]
        case .high:
            return [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
        }
    }

    private func saveImageToPhotos(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
}

// MARK: - Supporting Views

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    private var gradientColors: [Color] {
        switch mood {
        case .happy: return [.yellow, .pink]
        case .sad: return [.blue, .purple]
        case .calm: return [.mint, .cyan]
        case .focused: return [.purple, .blue]
        case .reflective: return [.indigo, .teal]
        case .productive: return [.green, .teal]
        case .inspired: return [.orange, .pink]
        case .angry: return [.red, .orange]
        case .anxious: return [.teal, .indigo]
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ? gradientColors : gradientColors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.white.opacity(0.5) : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    
                    Text(mood.emoji)
                        .font(.system(size: 32))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                Text(mood.rawValue.capitalized)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct MediaOptionButton: View {
    let icon: String
    let label: String
    let gradientColors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            MediaOptionLabel(icon: icon, label: label, gradientColors: gradientColors)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct MediaOptionLabel: View {
    let icon: String
    let label: String
    let gradientColors: [Color]

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 60)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    LogEntryView()
}
