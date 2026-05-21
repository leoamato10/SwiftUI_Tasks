import WidgetKit
import SwiftUI
import AppIntents

enum DisplayMode: String, AppEnum {
    case automatic
    case minimal

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Estilo"
    static let caseDisplayRepresentations: [DisplayMode: DisplayRepresentation] = [
        .automatic: DisplayRepresentation(title: "Automático", subtitle: "Se adapta a claro / oscuro"),
        .minimal: DisplayRepresentation(title: "Minimal (OLED)", subtitle: "Fondo negro, contornos tenues")
    ]

    var calendarStyle: CalendarStyle {
        switch self {
        case .automatic: return .adaptive
        case .minimal: return .minimal
        }
    }
}

struct CalendarConfigIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Calendario"
    static let description = IntentDescription("Elige el estilo del widget de calendario.")

    @Parameter(title: "Estilo", default: .automatic)
    var mode: DisplayMode
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let mode: DisplayMode
}

struct CalendarProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), mode: .automatic)
    }

    func snapshot(for configuration: CalendarConfigIntent, in context: Context) async -> CalendarEntry {
        CalendarEntry(date: Date(), mode: configuration.mode)
    }

    func timeline(for configuration: CalendarConfigIntent, in context: Context) async -> Timeline<CalendarEntry> {
        let now = Date()
        let calendar = Calendar.current
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        return Timeline(entries: [CalendarEntry(date: now, mode: configuration.mode)], policy: .after(startOfTomorrow))
    }
}

private let esLocale = Locale(identifier: "es_ES")

private func weekdayShort(_ date: Date) -> String {
    date.formatted(.dateTime.weekday(.abbreviated).locale(esLocale))
}

private func weekdayWide(_ date: Date) -> String {
    date.formatted(.dateTime.weekday(.wide).locale(esLocale)).capitalized
}

private func dayNumber(_ date: Date) -> String {
    String(Calendar.current.component(.day, from: date))
}

private func monthShort(_ date: Date) -> String {
    date.formatted(.dateTime.month(.abbreviated).locale(esLocale))
}

private func monthWide(_ date: Date) -> String {
    date.formatted(.dateTime.month(.wide).locale(esLocale)).uppercased()
}

struct CircularLockView: View {
    let date: Date
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -2) {
                Text(weekdayShort(date).uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .widgetAccentable()
                Text(dayNumber(date))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
            }
        }
    }
}

struct RectangularLockView: View {
    let date: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(monthWide(date))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .widgetAccentable()
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(dayNumber(date))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(weekdayWide(date))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InlineLockView: View {
    let date: Date
    var body: some View {
        Text("\(weekdayShort(date).capitalized) \(dayNumber(date)) \(monthShort(date))")
    }
}

struct SmallCalendarView: View {
    let date: Date
    let style: CalendarStyle

    private var monthColor: Color {
        style == .minimal ? Color.red.opacity(0.65) : .red
    }
    private var weekdayColor: Color {
        style == .minimal ? Color.white.opacity(0.55) : .secondary
    }
    private var dayColor: Color {
        style == .minimal ? .white : .primary
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(monthWide(date))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(monthColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(dayNumber(date))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(dayColor)
                .minimumScaleFactor(0.5)
            Text(weekdayWide(date))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(weekdayColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CalendarWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: CalendarEntry

    private static let calendarAppURL = URL(string: "calshow://")!

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                CircularLockView(date: entry.date)
                    .containerBackground(for: .widget) { Color.clear }
            case .accessoryRectangular:
                RectangularLockView(date: entry.date)
                    .containerBackground(for: .widget) { Color.clear }
            case .accessoryInline:
                InlineLockView(date: entry.date)
                    .containerBackground(for: .widget) { Color.clear }
            case .systemSmall:
                SmallCalendarView(date: entry.date, style: entry.mode.calendarStyle)
                    .containerBackground(for: .widget) {
                        switch entry.mode {
                        case .automatic:
                            Color(.systemBackground)
                        case .minimal:
                            Color.black
                        }
                    }
            default:
                CalendarView(date: entry.date, style: entry.mode.calendarStyle)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .containerBackground(for: .widget) {
                        switch entry.mode {
                        case .automatic:
                            Color(.systemBackground)
                        case .minimal:
                            Color.black
                        }
                    }
            }
        }
        .widgetURL(Self.calendarAppURL)
    }
}

@main
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: CalendarConfigIntent.self, provider: CalendarProvider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calendario")
        .description("Muestra el mes actual con el día de hoy destacado.")
        .supportedFamilies([
            .systemLarge,
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

#if DEBUG
struct CalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CalendarWidgetEntryView(entry: CalendarEntry(date: Date(), mode: .automatic))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Automático")

            CalendarWidgetEntryView(entry: CalendarEntry(date: Date(), mode: .minimal))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Minimal")

            CalendarWidgetEntryView(entry: CalendarEntry(date: Date(), mode: .automatic))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Lock · Circular")

            CalendarWidgetEntryView(entry: CalendarEntry(date: Date(), mode: .automatic))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Lock · Rectangular")

            CalendarWidgetEntryView(entry: CalendarEntry(date: Date(), mode: .automatic))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Lock · Inline")
        }
    }
}
#endif
