import SwiftUI

/// Layout contract for the Entry Pager (single source for bar placement). TopBar and bottom bar are added once at parent via safeAreaInset.
/// Used by regression tests to enforce that bars are not overlays.
enum EntryViewCarouselLayoutContract {
    /// Must be "safeAreaInset_top" so TopBar stays in safeAreaInset(edge: .top); do not change to overlay.
    static let topBarPlacement = "safeAreaInset_top"
}
