import SwiftUI

struct CardDeckView: View {
  @State private var showingAddDeckView = false
  @State private var editActive = false
  @Binding var selectedCards: [Card]
  @Binding var showContentView: Bool

  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(fetchRequest: Deck.fetch()) var decks: FetchedResults<Deck>

  var body: some View {
    NavigationView {
      List {
        ForEach(0..<decks.count, id: \.self) { index in
          if !editActive {
            Button(action: {
              selectedCards = Array(decks[index].cards)
              showContentView = true
            }, label: {
              HStack {
                Text(decks[index].name)
                Spacer()
                Text("\(decks[index].cards.count) Sets")
              }
            })
          } else {
            NavigationLink(
              destination: EditCardsView(deck: decks[index]),
              label: {
                HStack {
                  Text(decks[index].name)
                  Spacer()
                  Text("\(decks[index].cards.count) Sets")
                }
              }) //: NavigationLink
              .environment(\.managedObjectContext, self.viewContext)
          }
        } //: ForEach
        .onDelete(perform: removeDeck)
      } //: List
      .navigationTitle("Card Decks")
      .navigationBarItems(
        leading:
          Button(editActive ? "Done": "Edit") {
            editActive.toggle()
          },
        trailing:
          Button("Add New Deck") {
            showingAddDeckView = true
          }
      )
    } //: NavigationView
    CreateDeckAlert(isShowingAlert: $showingAddDeckView)
      .frame(width: 0, height: 0)
      .environment(\.managedObjectContext, self.viewContext)
  } //: Body

  func removeDeck(at offsets: IndexSet) {
    let decks = Array(decks)
    if let index = offsets.first {
      let deck = decks[index]
      self.viewContext.delete(deck)
      try? self.viewContext.save()
    }
  }
}

struct CardsDeckView_Previews: PreviewProvider {
  static var previews: some View {
    let cards = [Card(context: PersistenceController.preview.container.viewContext)]
    CardDeckView(selectedCards: .constant(cards), showContentView: .constant(false))
      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
      .previewLayout(.fixed(width: 644, height: 421))
  }
}
