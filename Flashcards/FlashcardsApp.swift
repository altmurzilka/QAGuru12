import SwiftUI

@main
struct FlashcardsApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      MainView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
