import SwiftUI
import CoreData

/// Main content view with tab navigation for My Loop, Log Entry, Insights, Settings
struct MainContentView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntryEntity.date, ascending: false)]
    ) private var insightEntries: FetchedResults<JournalEntryEntity>
    @State private var selectedTab: JournalTabBar.TabSelection = .myLoop
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Content based on selected tab
            switch selectedTab {
            case .myLoop:
                MyLoopView()
            case .insights:
                MoodInsightsView(entries: Array(insightEntries), onClose: {
                    selectedTab = .myLoop
                })
            case .timeline:
                MyLoopView()
            }
            
            // Bottom tab bar overlay
            VStack {
                Spacer()
                JournalTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea()
        }
        .statusBarHidden(selectedTab == .myLoop)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .timeline {
                NotificationCenter.default.post(name: .openTimelineList, object: nil)
                selectedTab = .myLoop
            }
        }
    }
}

/// My Loop view - Timeline of journal entries with swipe navigation
struct MyLoopView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest private var entries: FetchedResults<JournalEntryEntity>
    @State private var currentIndex: Int = 0
    @State private var showingSettings = false
    @State private var showingLogEntry = false
    @State private var showingList = false
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    init() {
        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntryEntity.date, ascending: false)]
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = true
        _entries = FetchRequest(fetchRequest: request, animation: .spring())
    }
    
    var body: some View {
        ZStack {
            moodBackgroundLayer

            // Main content with swipe cards
            if entries.isEmpty {
                VStack(spacing: 12) {
                    Text("No entries yet")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Tap + to add your first moment.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                GeometryReader { proxy in
                    let screenWidth = max(proxy.size.width, 1)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(entries.indices, id: \.self) { index in
                                let entry = entries[index]
                                JournalEntryCard(
                                    entry: entry,
                                    showBackground: false,
                                    onDelete: {
                                        context.delete(entry)
                                        try? context.save()
                                    }
                                )
                                .frame(width: screenWidth, height: proxy.size.height)
                                .background(
                                    GeometryReader { itemProxy in
                                        Color.clear
                                            .preference(
                                                key: CardCenterPreferenceKey.self,
                                                value: [index: itemProxy.frame(in: .named("carousel")).midX]
                                            )
                                    }
                                )
                            }
                        }
                    }
                    .coordinateSpace(name: "carousel")
                    .onPreferenceChange(CardCenterPreferenceKey.self) { centers in
                        let screenCenter = screenWidth / 2
                        if let nearest = centers.min(by: { abs($0.value - screenCenter) < abs($1.value - screenCenter) })?.key {
                            if nearest != currentIndex {
                                currentIndex = nearest
                            }
                        }
                    }
                }
            }
            
            // Top bar
            VStack {
                TopBarView(isProfilePresented: $showingSettings)
                    .padding(.top, 8)
                
                Spacer()
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button(action: { showingLogEntry = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: .cyan.opacity(0.5), radius: 10, y: 5)

                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
            }
            .padding(.bottom, 96)
        }
        .onChange(of: currentIndex) { _, _ in
            hapticGenerator.prepare()
            hapticGenerator.impactOccurred()
        }
        .onChange(of: entries.count) { _, newCount in
            if newCount == 0 {
                currentIndex = 0
            } else if currentIndex > newCount - 1 {
                currentIndex = max(0, newCount - 1)
            }
        }
        .sheet(isPresented: $showingLogEntry) {
            LogEntryView()
                .environment(\.managedObjectContext, context)
        }
        .sheet(isPresented: $showingList) {
            CoreDataTimelineView()
                .environment(\.managedObjectContext, context)
        }
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openTimelineList)) { _ in
            showingList = true
        }
    }

    @ViewBuilder private var moodBackgroundLayer: some View {
        if entries.isEmpty {
            Color.black.ignoresSafeArea()
        } else {
            let baseIndex = min(max(currentIndex, 0), entries.count - 1)
            MoodBackgroundView(moodEmojis: entries[baseIndex].moodEmojis, showEffects: true)
                .ignoresSafeArea()
        }
    }
}

extension Notification.Name {
    static let openTimelineList = Notification.Name("openTimelineList")
}

private struct CardCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

#Preview {
    MainContentView()
}
