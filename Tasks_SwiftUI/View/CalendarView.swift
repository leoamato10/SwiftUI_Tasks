import SwiftUI

struct CalendarView: View {
    let date: Date

    private var spanishCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "es_ES")
        cal.firstWeekday = 2 // Lunes
        return cal
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date).uppercased()
    }

    private let weekdaySymbols = ["L", "M", "M", "J", "V", "S", "D"]

    private var weeks: [[Date?]] {
        let cal = spanishCalendar
        let comps = cal.dateComponents([.year, .month], from: date)
        guard let firstOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        let weekday = cal.component(.weekday, from: firstOfMonth)
        let leadingEmpty = (weekday - cal.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for offset in 0..<range.count {
            days.append(cal.date(byAdding: .day, value: offset, to: firstOfMonth))
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return stride(from: 0, to: days.count, by: 7).map {
            Array(days[$0..<$0 + 7])
        }
    }

    var body: some View {
        GeometryReader { geo in
            let columns = 7
            let titleHeight = geo.size.height * 0.16
            let weekdayHeight = geo.size.height * 0.11
            let rowsAvailable = geo.size.height - titleHeight - weekdayHeight
            let rowHeight = rowsAvailable / CGFloat(max(weeks.count, 1))
            let cellWidth = geo.size.width / CGFloat(columns)
            let dayFontSize = min(rowHeight, cellWidth) * 0.55
            let circleSize = min(rowHeight, cellWidth) * 0.92

            VStack(alignment: .leading, spacing: 0) {
                Text(monthTitle)
                    .font(.system(size: titleHeight * 0.62, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .frame(height: titleHeight, alignment: .bottomLeading)

                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { idx in
                        Text(weekdaySymbols[idx])
                            .font(.system(size: dayFontSize, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(width: cellWidth, height: weekdayHeight)
                    }
                }

                ForEach(weeks.indices, id: \.self) { weekIdx in
                    HStack(spacing: 0) {
                        ForEach(0..<columns, id: \.self) { dayIdx in
                            DayCell(
                                date: weeks[weekIdx][dayIdx],
                                today: date,
                                isWeekendColumn: dayIdx >= 5,
                                fontSize: dayFontSize,
                                circleSize: circleSize
                            )
                            .frame(width: cellWidth, height: rowHeight)
                        }
                    }
                }
            }
        }
    }
}

private struct DayCell: View {
    let date: Date?
    let today: Date
    let isWeekendColumn: Bool
    let fontSize: CGFloat
    let circleSize: CGFloat

    private var isToday: Bool {
        guard let date = date else { return false }
        return Calendar.current.isDate(date, inSameDayAs: today)
    }

    private var dayString: String {
        guard let date = date else { return "" }
        return String(Calendar.current.component(.day, from: date))
    }

    var body: some View {
        ZStack {
            if isToday {
                Circle()
                    .fill(Color.red)
                    .frame(width: circleSize, height: circleSize)
            }
            Text(dayString)
                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                .foregroundColor(textColor)
        }
    }

    private var textColor: Color {
        if isToday { return .white }
        if date == nil { return .clear }
        return isWeekendColumn ? .secondary : .primary
    }
}

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(date: Date())
            .padding(18)
            .background(Color(.systemBackground))
            .previewLayout(.fixed(width: 340, height: 340))
    }
}
#endif
