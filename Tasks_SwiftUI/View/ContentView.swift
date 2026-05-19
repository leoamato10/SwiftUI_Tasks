import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                CalendarView(date: Date())
                    .aspectRatio(1, contentMode: .fit)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .fill(Color(white: 0.11))
                    )
                    .padding(.horizontal, 24)

                Text("Añade el widget «Calendario» a tu pantalla de inicio para verlo en grande (4×4).")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.horizontal, 32)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
