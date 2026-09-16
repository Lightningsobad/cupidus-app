import SwiftUI
import WidgetKit

// AC-37/BR-15: every string here is a contract identifier, never display copy.
// Dart builds the finished sentence and writes it to the shared group; this
// extension only draws what it finds.
enum CupidWidgetContract {
    static let appGroupId = "group.com.snapsofts.cupid"
    static let kind = "CupidPhaseWidget"
    static let keyPrimaryLine = "primary_line"
    static let keySecondaryLine = "secondary_line"
    static let keyCardId = "card_id"
    static let deepLinkScheme = "cupidapp"
    static let deepLinkCardHost = "card"
    static let deepLinkHomeHost = "home"
    static let empty = ""
    static let pathSeparator = "/"
}

struct CupidPhaseEntry: TimelineEntry {
    let date: Date
    let primaryLine: String
    let secondaryLine: String
    let cardId: String

    static func blank(at date: Date) -> CupidPhaseEntry {
        CupidPhaseEntry(
            date: date,
            primaryLine: CupidWidgetContract.empty,
            secondaryLine: CupidWidgetContract.empty,
            cardId: CupidWidgetContract.empty
        )
    }

    static func current(at date: Date) -> CupidPhaseEntry {
        guard
            let store = UserDefaults(suiteName: CupidWidgetContract.appGroupId)
        else {
            return blank(at: date)
        }
        return CupidPhaseEntry(
            date: date,
            primaryLine: store.string(forKey: CupidWidgetContract.keyPrimaryLine)
                ?? CupidWidgetContract.empty,
            secondaryLine: store.string(
                forKey: CupidWidgetContract.keySecondaryLine
            ) ?? CupidWidgetContract.empty,
            cardId: store.string(forKey: CupidWidgetContract.keyCardId)
                ?? CupidWidgetContract.empty
        )
    }

    var deepLink: URL? {
        var components = URLComponents()
        components.scheme = CupidWidgetContract.deepLinkScheme
        if cardId.isEmpty {
            components.host = CupidWidgetContract.deepLinkHomeHost
        } else {
            components.host = CupidWidgetContract.deepLinkCardHost
            components.path = CupidWidgetContract.pathSeparator + cardId
        }
        return components.url
    }
}

struct CupidPhaseProvider: TimelineProvider {
    func placeholder(in context: Context) -> CupidPhaseEntry {
        CupidPhaseEntry.blank(at: Date())
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (CupidPhaseEntry) -> Void
    ) {
        completion(CupidPhaseEntry.current(at: Date()))
    }

    // WIDGET-STALE: `.never` keeps the system from reloading on its own. Dart
    // pushes on mount, on resume and on a card status change; nothing else may
    // wake this extension.
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<CupidPhaseEntry>) -> Void
    ) {
        completion(
            Timeline(
                entries: [CupidPhaseEntry.current(at: Date())],
                policy: .never
            )
        )
    }
}

private struct CupidWidgetContainer: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(for: .widget) { Color.clear }
        } else {
            content
        }
    }
}

struct CupidPhaseWidgetView: View {
    let entry: CupidPhaseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.primaryLine)
                .font(.headline)
                .lineLimit(3)
            Text(entry.secondaryLine)
                .font(.caption)
                .lineLimit(2)
                .opacity(0.7)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
        .widgetURL(entry.deepLink)
        .modifier(CupidWidgetContainer())
    }
}

@main
struct CupidPhaseWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: CupidWidgetContract.kind,
            provider: CupidPhaseProvider()
        ) { entry in
            CupidPhaseWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
