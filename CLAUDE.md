# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

iOS app + WidgetKit extension written in SwiftUI. The app (`Tasks_SwiftUI`) is a thin container; the actual product is the `CalendarWidget` Home Screen widget (`.systemLarge`, 4×4) showing the current month in Spanish with today circled in red and weekend columns dimmed.

- Xcode 15+, iOS 17+ (uses `containerBackground(for: .widget)`), Swift 5.
- Bundle IDs: `com.heptagon.Tasks-SwiftUI` (app) and `com.heptagon.Tasks-SwiftUI.CalendarWidget` (extension).
- Despite the repo name "SwiftUI_Tasks" and the older git history, there is no task-management code — the repo was repurposed (commit `94ce86c`) into a calendar widget. README and all UI strings are in Spanish; keep user-facing copy in Spanish.

## Build / Run

There is no test target and no package manager — build via Xcode or `xcodebuild`:

```sh
# Open in Xcode
open Tasks_SwiftUI.xcodeproj

# Build the app (which embeds the widget extension)
xcodebuild -project Tasks_SwiftUI.xcodeproj -scheme Tasks_SwiftUI -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15' build
```

To actually see the widget: run the app on simulator/device, then long-press home screen → **+** → search **Calendario** → add the large size.

## Architecture

Two targets share one Swift file:

- `Tasks_SwiftUI/View/CalendarView.swift` — the single source of truth for calendar rendering. Compiled into **both** the app target and the widget extension target. Any layout change here affects both. It builds its month grid manually (not via `LazyVGrid`) using a `GeometryReader` so cell sizes scale to whatever container hosts it (widget vs. in-app preview).
- `Tasks_SwiftUI/View/ContentView.swift` — in-app preview wrapper that just embeds `CalendarView` for users who open the app.
- `CalendarWidget/CalendarWidget.swift` — `TimelineProvider` + `Widget` declaration. The timeline emits a single entry for "now" with `policy: .after(startOfTomorrow)`, so WidgetKit refreshes the widget once per day at midnight. There is no shared App Group / no data passed between app and widget — the widget computes everything from `Date()`.

Locale is hard-coded to `es_ES` with `firstWeekday = 2` (Monday). Weekday symbols are a hard-coded `["L", "M", "M", "J", "V", "S", "D"]` array, not derived from the locale.

## Conventions worth knowing

- "Today" detection uses `Calendar.current.isDate(_:inSameDayAs:)` against the entry's `date`, not against `Date()` — so previews with a custom date highlight that date correctly.
- Weekend dimming is column-based (`dayIdx >= 5`), not derived from the actual weekday of each cell — works because the grid is always Mon-first.
- Sizing constants in `CalendarView` (`titleHeight = 0.16 * h`, `weekdayHeight = 0.11 * h`, font/circle ratios) are tuned for the `.systemLarge` widget aspect ratio; changing one usually requires re-tuning the others.
