import SwiftUI
import Lottie

struct MainView: View {
    @State private var showContentView = false
    @State private var cards: [Card] = []
    
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        if showContentView {
            FlashCardsView(cards: $cards, showContentView: $showContentView)
                .environment(\.managedObjectContext, viewContext)
            
        } else {
            VStack(spacing: 10) {
                SplashScreen()
                CardDeckView(selectedCards: $cards, showContentView: $showContentView)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
