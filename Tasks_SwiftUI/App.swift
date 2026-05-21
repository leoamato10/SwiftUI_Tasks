import SwiftUI
import UIKit

@main
struct TasksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if url.scheme == "calshow" {
                        UIApplication.shared.open(url)
                    }
                }
        }
    }
}
