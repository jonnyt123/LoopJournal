import SwiftUI
import CoreData

// MARK: - Entry Pager layout verification
// • TopBarView and BottomTabBar: created once in MainContentView; anchored with .safeAreaInset(edge: .top) and .safeAreaInset(edge: .bottom). No per-page bars.
// • EntryPageView: renders only background (mood) + entry card; .ignoresSafeArea() only on background layer. No per-page .safeAreaInset, GeometryReader for bar layout, or .padding(.top)/.offset affecting bars.
// • No DragGesture for paging; no manual offset/position for paging. Parallax .offset is inside .visualEffect only (does not affect layout). Paging uses .scrollTargetBehavior(.paging) + .scrollPosition(id:).
// • Swiping between entries does not change TopBar or BottomTabBar position. Bars stay aligned; cards remain centered (JournalEntryCard uses frame(maxWidth/maxHeight, alignment: .center) and CarouselLayout constants).
//
// Testing checklist: (1) Swipe between entries with different moods/backgrounds. (2) Verify bars do not move. (3) Verify transition feels smooth and doesn’t stutter.

/// Main content view with tab navigation for My Loop, Log Entry, Insights, Settings.
/// TopBarView and bottom bar (plus button + JournalTabBar) are created once here and anchored via
/// .safeAreaInset(edge: .top) / .safeAreaInset(edge: .bottom) so they stay persistent when swiping pager pages.
struct MainContentView: View {
    @State private var selectedTab: JournalTabBar.TabSelection = .myLoop
    @State private var showingSettings = false
    @State private var showingLogEntry = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .myLoop:
                    EntryPagerView(showingSettings: $showingSettings, showingLogEntry: $showingLogEntry)
                case .insights:
                    MoodInsightsView(onClose: {
                        selectedTab = .myLoop
                    })
                case .timeline:
                    EntryPagerView(showingSettings: $showingSettings, showingLogEntry: $showingLogEntry)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                topBarInsetContent
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomBarInsetContent
            }
        }
        .statusBarHidden(selectedTab == .myLoop)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .timeline {
                NotificationCenter.default.post(name: .openTimelineList, object: nil)
                selectedTab = .myLoop
            }
        }
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    @ViewBuilder private var topBarInsetContent: some View {
        if selectedTab == .myLoop || selectedTab == .timeline {
            TopBarView(isProfilePresented: $showingSettings)
                .padding(.top, CarouselLayout.topBarTopInset)
                .padding(.horizontal, CarouselLayout.topBarHorizontalPadding)
                .padding(.vertical, CarouselLayout.topBarVerticalPadding)
                .frame(minHeight: CarouselLayout.topBarMinHeight)
        } else {
            Color.clear.frame(height: 0)
        }
    }

    @ViewBuilder private var bottomBarInsetContent: some View {
        Group {
            if selectedTab == .myLoop || selectedTab == .timeline {
                VStack(spacing: CarouselLayout.plusButtonBottomInset) {
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
                                    .frame(width: CarouselLayout.plusButtonSize, height: CarouselLayout.plusButtonSize)
                                    .shadow(color: .cyan.opacity(0.5), radius: 10, y: 5)
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, CarouselLayout.plusButtonTrailingInset)
                    }
                    JournalTabBar(selectedTab: $selectedTab)
                }
            } else {
                JournalTabBar(selectedTab: $selectedTab)
            }
        }
        .padding(.horizontal, CarouselLayout.tabBarHorizontalPadding)
        .padding(.vertical, CarouselLayout.tabBarVerticalPadding)
        .padding(.horizontal, CarouselLayout.tabBarOuterHorizontalPadding)
        .padding(.bottom, CarouselLayout.tabBarBottomInset + CarouselLayout.tabBarOuterBottomPadding)
    }
}

/// Entry pager: one full-screen page per journal entry. Horizontal swipe moves between entries (current → previous → older).
/// Uses iOS 17 native paging. TopBarView and bottom bar are NOT in this view—they are added by MainContentView only.
struct EntryPagerView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest private var entries: FetchedResults<JournalEntryEntity>
    @Binding var showingSettings: Bool
    @Binding var showingLogEntry: Bool
    @State private var selectedIndex: Int? = 0
    @State private var showingList = false
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    init(showingSettings: Binding<Bool>, showingLogEntry: Binding<Bool>) {
        _showingSettings = showingSettings
        _showingLogEntry = showingLogEntry
        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntryEntity.date, ascending: false)]
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = true
        _entries = FetchRequest(fetchRequest: request, animation: .none)
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)

            // Content: no .ignoresSafeArea here so parent safeAreaInset bars stay fixed when swiping.
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
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(entries.indices, id: \.self) { i in
                            EntryPageView(entry: entries[i])
                                .containerRelativeFrame(.horizontal)
                                .tag(i)
                        }
                    }
                }
                .scrollTargetLayout()
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollPosition(id: $selectedIndex)
            }
        }
        .onChange(of: selectedIndex) { _, _ in
            hapticGenerator.prepare()
            hapticGenerator.impactOccurred()
        }
        .onChange(of: entries.count) { _, newCount in
            if newCount == 0 {
                selectedIndex = 0
            } else if (selectedIndex ?? 0) > newCount - 1 {
                selectedIndex = max(0, newCount - 1)
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
        .onReceive(NotificationCenter.default.publisher(for: .openTimelineList)) { _ in
            showingList = true
        }
    }
}

/// One full-width page: only the entry's background (mood/theme) and the entry card. No TopBarView or BottomTabBar.
/// .ignoresSafeArea() is applied only to the background view so bar positions never shift when swiping.
private struct EntryPageView: View {
    let entry: JournalEntryEntity

    var body: some View {
        ZStack {
            // Background: full-bleed, cross-fade during paging (opacity from phase.value). ignoresSafeArea only here.
            MoodBackgroundView(moodEmojis: entry.moodEmojis, showEffects: true)
                .ignoresSafeArea(edges: .all)
                .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                    let t = min(1, abs(phase.value))
                    return content.opacity(1 - t)
                }

            // Card: no scrollTransition, no parallax—card and bars stay fixed.
            JournalEntryCard(
                entry: entry,
                showBackground: false,
                onDelete: {
                    CoreDataManager.shared.deleteInBackground(objectID: entry.objectID)
                }
            )
        }
    }
}

extension Notification.Name {
    static let openTimelineList = Notification.Name("openTimelineList")
}

#Preview {
    MainContentView()
}
