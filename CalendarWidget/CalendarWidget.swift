import WidgetKit
import SwiftUI

struct CalendarEntry: TimelineEntry {
    let date: Date
}

struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(CalendarEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        let timeline = Timeline(entries: [CalendarEntry(date: now)], policy: .after(startOfTomorrow))
        completion(timeline)
    }
}

struct CalendarWidgetEntryView: View {
    var entry: CalendarEntry

    var body: some View {
        CalendarView(date: entry.date)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .containerBackground(for: .widget) {
                Color(white: 0.11)
            }
    }
}

@main
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calendario")
        .description("Muestra el mes actual con el día de hoy destacado.")
        .supportedFamilies([.systemLarge])
    }
}

#if DEBUG
struct CalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        CalendarWidgetEntryView(entry: CalendarEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
