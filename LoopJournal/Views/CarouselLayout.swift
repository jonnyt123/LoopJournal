import SwiftUI

/// **Edit this file to move UI elements.** All carousel screen placement is driven by these values.
/// Change any number to reposition the top bar, entry card, plus button, or tab bar.
struct CarouselLayout {
    // MARK: - Top bar (logo + Settings)
    /// Space (pt) between safe area top and the top bar content.
    static var topBarTopInset: CGFloat = 24
    /// Horizontal padding (pt) inside the top bar (logo from leading edge, settings from trailing).
    static var topBarHorizontalPadding: CGFloat = 20
    /// Vertical padding (pt) inside the top bar.
    static var topBarVerticalPadding: CGFloat = 6
    /// Minimum height (pt) of the top bar.
    static var topBarMinHeight: CGFloat = 44
    /// Space (pt) between logo and "LoopJournal" text.
    static var topBarBrandingSpacing: CGFloat = 8
    /// Space (pt) between top bar icons (list, settings).
    static var topBarIconSpacing: CGFloat = 12

    // MARK: - Entry card (white card on mood background)
    /// Card position: fraction of screen height from top (0 = top, 0.5 = center).
    static var cardTopFraction: CGFloat = 0.08
    /// Card width as fraction of screen width (capped by cardMaxWidth).
    static var cardWidthFraction: CGFloat = 0.82
    /// Card max width (pt).
    static var cardMaxWidth: CGFloat = 360
    /// Card height: fraction of screen height used for min height (then clamped).
    static var cardHeightFraction: CGFloat = 0.5
    /// Card min height (pt).
    static var cardMinHeight: CGFloat = 300
    /// Card max height (pt).
    static var cardMaxHeight: CGFloat = 380
    /// Inner padding (pt) of the card content.
    static var cardContentPadding: CGFloat = 24
    /// Corner radius (pt) of the card.
    static var cardCornerRadius: CGFloat = 28
    /// Delete button inset (pt) from card top-trailing.
    static var cardDeleteButtonInset: CGFloat = 12

    // MARK: - Plus button (add entry)
    /// Space (pt) from trailing edge.
    static var plusButtonTrailingInset: CGFloat = 24
    /// Space (pt) from bottom of the bottom inset area (above tab bar).
    static var plusButtonBottomInset: CGFloat = 12
    /// Plus button diameter (pt).
    static var plusButtonSize: CGFloat = 60

    // MARK: - Bottom tab bar
    /// Extra space (pt) between tab bar and safe area bottom (0 = flush with safe area).
    static var tabBarBottomInset: CGFloat = 0
    /// Horizontal padding (pt) inside the tab bar.
    static var tabBarHorizontalPadding: CGFloat = 24
    /// Vertical padding (pt) inside the tab bar.
    static var tabBarVerticalPadding: CGFloat = 12
    /// Horizontal margin (pt) around the tab bar container.
    static var tabBarOuterHorizontalPadding: CGFloat = 16
    /// Bottom margin (pt) under the tab bar container (before safe area).
    static var tabBarOuterBottomPadding: CGFloat = 16
}
