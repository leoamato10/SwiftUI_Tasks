import SwiftUI

enum CalendarStyle {
    case adaptive
    case minimal
}

private let spanishLocale = Locale(identifier: "es_ES")

private let spanishCalendar: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = spanishLocale
    cal.firstWeekday = 2 // Lunes
    return cal
}()

struct CalendarView: View {
    let date: Date
    var style: CalendarStyle = .adaptive

    private var monthTitle: String {
        date.formatted(.dateTime.month(.wide).locale(spanishLocale)).uppercased()
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

    private var titleColor: Color {
        style == .minimal ? Color.red.opacity(0.65) : .red
    }

    private var weekdayHeaderColor: Color {
        style == .minimal ? Color.white.opacity(0.45) : .primary
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
                    .foregroundStyle(titleColor)
                    .frame(height: titleHeight, alignment: .bottomLeading)

                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { idx in
                        Text(weekdaySymbols[idx])
                            .font(.system(size: dayFontSize, weight: .semibold, design: .rounded))
                            .foregroundStyle(weekdayHeaderColor)
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
                                circleSize: circleSize,
                                style: style
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
    let style: CalendarStyle

    private var isToday: Bool {
        guard let date = date else { return false }
        return spanishCalendar.isDate(date, inSameDayAs: today)
    }

    private var dayString: String {
        guard let date = date else { return "" }
        return String(spanishCalendar.component(.day, from: date))
    }

    var body: some View {
        ZStack {
            if isToday {
                switch style {
                case .adaptive:
                    Circle()
                        .fill(Color.red)
                        .frame(width: circleSize, height: circleSize)
                case .minimal:
                    Circle()
                        .stroke(Color.red, lineWidth: max(1.5, circleSize * 0.05))
                        .frame(width: circleSize, height: circleSize)
                }
            }
            Text(dayString)
                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                .foregroundStyle(textColor)
        }
    }

    private var textColor: Color {
        if date == nil { return .clear }
        switch style {
        case .adaptive:
            if isToday { return .white }
            return isWeekendColumn ? .secondary : .primary
        case .minimal:
            if isToday { return .red }
            return isWeekendColumn ? Color.white.opacity(0.3) : Color.white.opacity(0.55)
        }
    }
}

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CalendarView(date: Date(), style: .adaptive)
                .padding(18)
                .background(Color(.systemBackground))
                .previewLayout(.fixed(width: 340, height: 340))
                .previewDisplayName("Adaptive")

            CalendarView(date: Date(), style: .minimal)
                .padding(18)
                .background(Color.black)
                .previewLayout(.fixed(width: 340, height: 340))
                .previewDisplayName("Minimal (OLED)")
        }
    }
}
#endif
