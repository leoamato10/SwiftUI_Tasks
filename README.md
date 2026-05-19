# Calendario Widget

Widget de iPhone construido con SwiftUI + WidgetKit que muestra el mes actual en tamaño grande (4×4), con los nombres de los días en español, el día de hoy resaltado en un círculo rojo y los fines de semana atenuados.

## Estructura

- `Tasks_SwiftUI/` — app contenedora (necesaria para distribuir el widget). Muestra el mismo calendario para previsualización.
  - `App.swift` — punto de entrada SwiftUI (`@main`).
  - `View/ContentView.swift` — pantalla de la app.
  - `View/CalendarView.swift` — vista de calendario compartida con el widget.
- `CalendarWidget/` — *Widget Extension*.
  - `CalendarWidget.swift` — `TimelineProvider` + `Widget` (`.systemLarge`).
  - `Info.plist` — declara `NSExtensionPointIdentifier = com.apple.widgetkit-extension`.

## Requisitos

- Xcode 15+
- iOS 17+ (usa `containerBackground(for:)`)

## Cómo usarlo

1. Abre `Tasks_SwiftUI.xcodeproj` en Xcode.
2. Ejecuta el esquema `Tasks_SwiftUI` en un simulador o dispositivo.
3. En la pantalla de inicio, mantén pulsado → **+** → busca **Calendario** y añade el widget tamaño grande (4×4).
