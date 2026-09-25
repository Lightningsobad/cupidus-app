import SwiftUI
import WidgetKit

// AC-37/BR-15: every string here is a contract identifier, never display copy.
// Dart builds the finished sentence and writes it to the shared group; this
// extension only draws what it finds.
enum CupidWidgetContract {
    static let appGroupId = "group.com.snapsofts.cupid"
    static let kind = "CupidPhaseWidget"
    static let keyPhaseId = "phase_id"
    static let keyPrimaryLine = "primary_line"
    static let keySecondaryLine = "secondary_line"
    static let keyEyebrowLine = "eyebrow_line"
    static let keyCardId = "card_id"
    static let phaseIdWaiting = "waiting"
    static let phaseIdUpcoming = "upcoming"
    static let phaseIdDateDay = "date_day"
    static let phaseIdQuiet = "quiet"
    static let deepLinkScheme = "cupidapp"
    static let deepLinkCardHost = "card"
    static let deepLinkHomeHost = "home"
    static let empty = ""
    static let pathSeparator = "/"
}

// D-12: the brand dark palette, as component values rather than as a named
// asset, so this extension needs no asset catalogue of its own. Copied from
// `lib/design_system/tokens/cupid_color_tokens.dart`, dark theme.
enum CupidWidgetPalette {
    // colorSurface #241B42
    static let surface = Color(red: 0.141, green: 0.106, blue: 0.259)
    // colorText #F7EEFB
    static let text = Color(red: 0.969, green: 0.933, blue: 0.984)
    // colorTextMuted #B4A6CE
    static let textMuted = Color(red: 0.706, green: 0.651, blue: 0.808)
    // colorAccentPink #FF7FB6
    static let accentPink = Color(red: 1.0, green: 0.498, blue: 0.714)
    // colorAccentPurple #B78CF5
    static let accentPurple = Color(red: 0.718, green: 0.549, blue: 0.961)
    // colorMint #79E2CD
    static let mint = Color(red: 0.475, green: 0.886, blue: 0.804)
    // colorAccentPurpleDark #8E5FD6
    static let accentPurpleDark = Color(red: 0.557, green: 0.373, blue: 0.839)

    // D-10 (architecture/contract-summary.md 3a): four dot token roles, one per
    // phase_id of the closed set. No fifth role and no system colour - an
    // unknown or missing phase_id draws the neutral waiting role.
    static let dotWaiting = textMuted
    static let dotUpcoming = mint
    static let dotToday = accentPink
    static let dotQuiet = accentPurpleDark

    static func dot(for phaseId: String) -> Color {
        switch phaseId {
        case CupidWidgetContract.phaseIdWaiting:
            return dotWaiting
        case CupidWidgetContract.phaseIdUpcoming:
            return dotUpcoming
        case CupidWidgetContract.phaseIdDateDay:
            return dotToday
        case CupidWidgetContract.phaseIdQuiet:
            return dotQuiet
        default:
            return dotWaiting
        }
    }
}

// D-11: the design draws the days number at display size while the rest of the
// line stays body size. This splits the payload string at its first run of
// digits and hands back all three pieces, so the widget re-sizes the number it
// was given without dropping, reordering or rewriting a single character. No
// digits in the line means the whole line comes back as `lead`.
struct CupidPhaseSplit {
    let lead: String
    let number: String
    let trail: String

    static func of(_ line: String) -> CupidPhaseSplit {
        guard let start = line.firstIndex(where: { $0.isNumber }) else {
            return CupidPhaseSplit(
                lead: line,
                number: CupidWidgetContract.empty,
                trail: CupidWidgetContract.empty
            )
        }
        var stop = start
        while stop < line.endIndex, line[stop].isNumber {
            stop = line.index(stop, offsetBy: 1)
        }
        return CupidPhaseSplit(
            lead: String(line[line.startIndex..<start]),
            number: String(line[start..<stop]),
            trail: String(line[stop...])
        )
    }
}

struct CupidPhaseEntry: TimelineEntry {
    let date: Date
    let phaseId: String
    let primaryLine: String
    let secondaryLine: String
    let eyebrowLine: String
    let cardId: String

    var isDateDay: Bool { phaseId == CupidWidgetContract.phaseIdDateDay }

    var dotColor: Color { CupidWidgetPalette.dot(for: phaseId) }

    static func blank(at date: Date) -> CupidPhaseEntry {
        CupidPhaseEntry(
            date: date,
            phaseId: CupidWidgetContract.empty,
            primaryLine: CupidWidgetContract.empty,
            secondaryLine: CupidWidgetContract.empty,
            eyebrowLine: CupidWidgetContract.empty,
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
            phaseId: store.string(forKey: CupidWidgetContract.keyPhaseId)
                ?? CupidWidgetContract.empty,
            primaryLine: store.string(forKey: CupidWidgetContract.keyPrimaryLine)
                ?? CupidWidgetContract.empty,
            secondaryLine: store.string(
                forKey: CupidWidgetContract.keySecondaryLine
            ) ?? CupidWidgetContract.empty,
            eyebrowLine: store.string(
                forKey: CupidWidgetContract.keyEyebrowLine
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

// D-12: the date-day phase gets the pink/purple brand gradient the design
// gives it; every other phase gets the brand surface. Neither is a system
// colour, so the widget reads as part of this app on any device theme.
private struct CupidPhaseBackground: View {
    let entry: CupidPhaseEntry

    var body: some View {
        if entry.isDateDay {
            LinearGradient(
                colors: [
                    CupidWidgetPalette.accentPink,
                    CupidWidgetPalette.accentPurple
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            CupidWidgetPalette.surface
        }
    }
}

private struct CupidWidgetContainer: ViewModifier {
    let entry: CupidPhaseEntry

    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(for: .widget) {
                CupidPhaseBackground(entry: entry)
            }
        } else {
            content.background(CupidPhaseBackground(entry: entry))
        }
    }
}

struct CupidPhaseWidgetView: View {
    let entry: CupidPhaseEntry

    private var split: CupidPhaseSplit {
        CupidPhaseSplit.of(entry.primaryLine)
    }

    private var numberColor: Color {
        entry.isDateDay ? CupidWidgetPalette.text : CupidWidgetPalette.accentPink
    }

    private var secondaryColor: Color {
        entry.isDateDay ? CupidWidgetPalette.text : CupidWidgetPalette.textMuted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // D-10: the eyebrow row. The dot is the phase token, looked up from
            // `phase_id`; the line itself is payload, never a literal.
            HStack(spacing: 5) {
                Circle()
                    .fill(entry.dotColor)
                    .frame(width: 7, height: 7)
                Text(entry.eyebrowLine)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundColor(entry.dotColor)
                    .lineLimit(1)
            }
            (
                Text(split.lead)
                    + Text(split.number)
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(numberColor)
                    + Text(split.trail)
            )
            .font(.headline)
            .foregroundColor(CupidWidgetPalette.text)
            .lineLimit(3)
            Text(entry.secondaryLine)
                .font(.caption)
                .foregroundColor(secondaryColor)
                .lineLimit(2)
                .opacity(entry.isDateDay ? 0.85 : 1.0)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
        .widgetURL(entry.deepLink)
        .modifier(CupidWidgetContainer(entry: entry))
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
