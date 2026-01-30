import SwiftUI
import CoreData

/// Mood Insights view showing personal mood trends and analytics
struct MoodInsightsView: View {
    let entries: [JournalEntryEntity]
    var onClose: (() -> Void)? = nil
    
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
                
                ScrollView {
                    let screenWidth = UIScreen.main.bounds.width
                    let sectionSpacing: CGFloat = screenWidth < 380 ? 16 : 24
                    let horizontalPadding: CGFloat = screenWidth < 380 ? 14 : 20
                    VStack(spacing: sectionSpacing) {
                        // Mood Summary Cards
                        moodSummarySection
                        
                        // Weekly Mood Chart
                        weeklyMoodChart
                        
                        // Mood Distribution
                        moodDistributionSection
                        
                        // Recent Mood Streak
                        moodStreakSection
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, screenWidth < 380 ? 12 : 16)
                }
            }
            .navigationTitle("Mood Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if let onClose = onClose {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: onClose) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
            .toolbarBackground(Color.black.opacity(0.5), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    // MARK: - Mood Summary Section
    
    private var moodSummarySection: some View {
        let screenWidth = UIScreen.main.bounds.width
        return VStack(alignment: .leading, spacing: screenWidth < 380 ? 12 : 16) {
            Text("This Week")
                .font(.system(size: screenWidth < 380 ? 16 : 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            let columns: [GridItem] = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            LazyVGrid(columns: columns, spacing: screenWidth < 380 ? 12 : 16) {
                MoodSummaryCard(
                    title: "Average",
                    emoji: mostFrequentMood?.emoji ?? "😐",
                    subtitle: mostFrequentMood?.rawValue.capitalized ?? "Neutral"
                )
                
                MoodSummaryCard(
                    title: "Entries",
                    emoji: "📝",
                    subtitle: "\(entries.count) total"
                )
                
                MoodSummaryCard(
                    title: "Best Day",
                    emoji: "🏆",
                    subtitle: bestDayOfWeek
                )
            }
        }
    }
    
    // MARK: - Weekly Mood Chart
    
    private var weeklyMoodChart: some View {
        let screenWidth = UIScreen.main.bounds.width
        return VStack(alignment: .leading, spacing: screenWidth < 380 ? 12 : 16) {
            Text("Mood Timeline")
                .font(.system(size: screenWidth < 380 ? 16 : 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(last7Days, id: \.self) { date in
                    MoodTimelineRow(
                        date: date,
                        mood: moodForDate(date)
                    )
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Mood Distribution Section
    
    private var moodDistributionSection: some View {
        let screenWidth = UIScreen.main.bounds.width
        return VStack(alignment: .leading, spacing: screenWidth < 380 ? 12 : 16) {
            Text("Mood Distribution")
                .font(.system(size: screenWidth < 380 ? 16 : 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(moodPercentages, id: \.mood) { item in
                    MoodDistributionBar(
                        mood: item.mood,
                        percentage: item.percentage,
                        color: moodColor(for: item.mood)
                    )
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Mood Streak Section
    
    private var moodStreakSection: some View {
        let screenWidth = UIScreen.main.bounds.width
        return VStack(alignment: .leading, spacing: screenWidth < 380 ? 12 : 16) {
            Text("Streaks")
                .font(.system(size: screenWidth < 380 ? 16 : 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            let columns: [GridItem] = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            LazyVGrid(columns: columns, spacing: screenWidth < 380 ? 12 : 16) {
                StreakCard(
                    title: "Happy Streak",
                    days: calculateStreak(for: .happy),
                    color: .yellow
                )
                
                StreakCard(
                    title: "Calm Streak",
                    days: calculateStreak(for: .calm),
                    color: .mint
                )
                
                StreakCard(
                    title: "Logged Days",
                    days: calculateLoggedStreak(),
                    color: .cyan
                )
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var mostFrequentMood: Mood? {
        let moodCounts = Dictionary(grouping: moods, by: { $0 })
            .mapValues { $0.count }
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private var bestDayOfWeek: String {
        let dayCounts = Dictionary(grouping: entries, by: { Calendar.current.component(.weekday, from: $0.entryDate) })
            .mapValues { $0.count }
        if let bestDay = dayCounts.max(by: { $0.value < $1.value })?.key {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let dateComponents = DateComponents(weekday: bestDay)
            if let date = Calendar.current.date(from: dateComponents) {
                return formatter.string(from: date)
            }
        }
        return "N/A"
    }
    
    private var last7Days: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: -day, to: Date())
        }.reversed()
    }
    
    private var moodPercentages: [(mood: Mood, percentage: Double)] {
        let total = Double(moods.count)
        guard total > 0 else { return [] }
        
        let moodCounts = Dictionary(grouping: moods, by: { $0 })
            .mapValues { Double($0.count) }
        
        return Mood.allCases.compactMap { mood in
            guard let count = moodCounts[mood] else { return nil }
            return (mood, count / total * 100)
        }.sorted { $0.percentage > $1.percentage }
    }
    
    // MARK: - Helper Methods
    
    private func moodForDate(_ date: Date) -> Mood? {
        let calendar = Calendar.current
        return entries.first { calendar.isDate($0.entryDate, inSameDayAs: date) }
            .flatMap { moodFromEntry($0) }
    }
    
    private func moodColor(for mood: Mood) -> Color {
        switch mood {
        case .happy: return .yellow
        case .sad: return .blue
        case .calm: return .mint
        case .focused: return .purple
        case .reflective: return .indigo
        case .productive: return .green
        case .inspired: return .orange
        case .angry: return .red
        case .anxious: return .teal
        }
    }
    
    private func calculateStreak(for mood: Mood) -> Int {
        let sortedEntries = entries.sorted { $0.entryDate > $1.entryDate }
        var streak = 0
        
        for entry in sortedEntries {
            if moodFromEntry(entry) == mood {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    private func calculateLoggedStreak() -> Int {
        let calendar = Calendar.current
        let sortedDates = Set(entries.map { calendar.startOfDay(for: $0.entryDate) })
            .sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var streak = 1
        var currentDate = sortedDates[0]
        
        for i in 1..<sortedDates.count {
            let dayDifference = calendar.dateComponents([.day], from: sortedDates[i], to: currentDate).day ?? 0
            if dayDifference == 1 {
                streak += 1
                currentDate = sortedDates[i]
            } else {
                break
            }
        }
        return streak
    }

    private var moods: [Mood] {
        entries.flatMap { entry in
            entry.moodEmojisArray.compactMap { moodFromToken($0) }
        }
    }

    private func moodFromEntry(_ entry: JournalEntryEntity) -> Mood? {
        moodFromTokens(entry.moodEmojisArray)
    }

    private func moodFromTokens(_ tokens: [String]) -> Mood? {
        for token in tokens {
            if let mood = moodFromToken(token) {
                return mood
            }
        }
        return nil
    }

    private func moodFromToken(_ token: String) -> Mood? {
        switch token.lowercased() {
        case "happy", "😃", "😄", "😊", "😁", "🙂", "🥳":
            return .happy
        case "sad", "😔", "😢", "😞", "☹️", "🙁", "😿":
            return .sad
        case "calm", "😌", "😇", "🧘", "😴", "🫶":
            return .calm
        case "focused", "🎧":
            return .focused
        case "reflective", "💭", "🤔":
            return .reflective
        case "productive", "🧠":
            return .productive
        case "inspired", "🌈":
            return .inspired
        case "angry", "😡":
            return .angry
        case "anxious", "😰":
            return .anxious
        default:
            return nil
        }
    }
}

// MARK: - Supporting Views

struct MoodSummaryCard: View {
    let title: String
    let emoji: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 32))
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            
            Text(subtitle)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct MoodTimelineRow: View {
    let date: Date
    let mood: Mood?
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(dayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                Text(dayNumber)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 50)
            
            if let mood = mood {
                Text(mood.emoji)
                    .font(.system(size: 24))
                    .frame(width: 36, height: 36)
                    .background(moodColor.opacity(0.2))
                    .clipShape(Circle())
                
                Text(mood.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "minus")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 36, height: 36)
                
                Text("No entry")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.vertical, 8)
    }
    
    private var moodColor: Color {
        guard let mood = mood else { return .gray }
        switch mood {
        case .happy: return .yellow
        case .sad: return .blue
        case .calm: return .mint
        case .focused: return .purple
        case .reflective: return .indigo
        case .productive: return .green
        case .inspired: return .orange
        case .angry: return .red
        case .anxious: return .teal
        }
    }
}

struct MoodDistributionBar: View {
    let mood: Mood
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(mood.emoji)
                    .font(.system(size: 16))
                Text(mood.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(percentage))%")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (percentage / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct StreakCard: View {
    let title: String
    let days: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("\(days)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Mood Extension

extension Mood {
    var emoji: String {
        switch self {
        case .happy: return "😄"
        case .sad: return "😢"
        case .calm: return "😌"
        case .focused: return "🎧"
        case .reflective: return "💭"
        case .productive: return "🧠"
        case .inspired: return "🌈"
        case .angry: return "😡"
        case .anxious: return "😰"
        }
    }
}

#Preview {
    MoodInsightsView(entries: [])
}
