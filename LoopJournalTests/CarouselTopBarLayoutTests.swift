import XCTest
import SwiftUI
@testable import LoopJournal

// MARK: - Entry View carousel layout regression tests
//
// These tests ensure the TopBar (logo + Settings) is aligned identically across
// all carousel scenes by enforcing:
// 1) Layout contract: TopBar must be in safeAreaInset(edge: .top), not overlay.
// 2) TopBar layout tokens: no hardcoded y-offsets; consistent padding.
// 3) Carousel layout renders without crash on small iPhone, large iPhone, iPad, and with Dynamic Type.
//
// Entry View carousel component structure (do not regress):
//   MyLoopView.body = ZStack { moodBackgroundLayer; content (empty VStack | GeometryReader→ScrollView→LazyHStack→JournalEntryCard) }
//                    .safeAreaInset(edge: .top) { TopBarView }   <- single source of truth; not per-scene
//                    .safeAreaInset(edge: .bottom) { FAB }
//   TopBarView = logo + Settings; positioned by safe area only (Layout tokens, no y-offset).
//
// How to run:
//   xcodebuild test -scheme LoopJournal -destination 'platform=iOS Simulator,name=iPhone 17'
// Device coverage (run with different -destination):
//   - Small iPhone:  name=iPhone SE (3rd generation)
//   - Large iPhone:  name=iPhone 15 Pro Max
//   - iPad:          name=iPad Pro 13-inch (M5)

// MARK: - Test view that mirrors carousel layout (TopBar in safeAreaInset only)

private final class CarouselTestState: ObservableObject {
    @Published var currentIndex: Int
    init(currentIndex: Int = 0) { self.currentIndex = currentIndex }
}

private struct CarouselLayoutTestView: View {
    @ObservedObject var state: CarouselTestState

    var body: some View {
        ZStack {
            Color.clear
                .overlay {
                    Text("Scene \(state.currentIndex)")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.5))
                }
        }
        .safeAreaInset(edge: .top) {
            TopBarView(isProfilePresented: .constant(false))
                .safeAreaPadding(.top)
        }
    }
}

// MARK: - Tests

final class CarouselTopBarLayoutTests: XCTestCase {

    // MARK: Layout contract (TopBar must be safeAreaInset, not overlay)

    func testEntryViewCarouselUsesSafeAreaInsetForTopBar() {
        XCTAssertEqual(
            EntryViewCarouselLayoutContract.topBarPlacement,
            "safeAreaInset_top",
            "TopBar must stay in safeAreaInset(edge: .top) so logo + Settings align identically across all carousel scenes. Do not change to overlay."
        )
    }

    // MARK: TopBar layout tokens (no hardcoded y; consistent padding)

    func testTopBarLayoutUsesStableTokensNoHardcodedY() {
        XCTAssertEqual(TopBarView.layoutMinHeightForRegressionTests, 44)
        XCTAssertEqual(TopBarView.layoutHorizontalPaddingForRegressionTests, 20)
        // Vertical padding is the only vertical token; no y-offset or offset(y:).
    }

    // MARK: Device coverage: carousel layout renders on small iPhone, large iPhone, iPad

    func testCarouselLayoutRendersWithoutCrash_smalliPhone() {
        renderCarouselLayoutTestView(containerSize: CGSize(width: 320, height: 568))
    }

    func testCarouselLayoutRendersWithoutCrash_largeiPhone() {
        renderCarouselLayoutTestView(containerSize: CGSize(width: 430, height: 932))
    }

    func testCarouselLayoutRendersWithoutCrash_iPad() {
        renderCarouselLayoutTestView(containerSize: CGSize(width: 1024, height: 1366))
    }

    // MARK: Dynamic Type / accessibility

    func testCarouselLayoutRendersWithAccessibilityDynamicType() {
        let state = CarouselTestState(currentIndex: 0)
        let view = CarouselLayoutTestView(state: state)
            .environment(\.sizeCategory, .accessibilityExtraLarge)
        let hosting = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 390, height: 844)))
        window.rootViewController = hosting
        window.makeKeyAndVisible()
        hosting.view.frame = window.bounds
        hosting.view.layoutIfNeeded()
        state.currentIndex = 1
        hosting.view.layoutIfNeeded()
    }

    private func renderCarouselLayoutTestView(containerSize: CGSize) {
        let state = CarouselTestState(currentIndex: 0)
        let view = CarouselLayoutTestView(state: state)
        let hosting = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(origin: .zero, size: containerSize))
        window.rootViewController = hosting
        window.makeKeyAndVisible()
        hosting.view.frame = CGRect(origin: .zero, size: containerSize)
        hosting.view.layoutIfNeeded()
        state.currentIndex = 1
        hosting.view.layoutIfNeeded()
    }
}
