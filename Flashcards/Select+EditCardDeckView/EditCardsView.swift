import SwiftUI

struct EditCardsView: View {
  @Environment(\.presentationMode) var presentationMode
  @State private var newPrompt = ""
  @State private var newAnswer = ""
  @ObservedObject var deck: Deck
  @State private var showingCreateDeckView = false
  @Environment(\.managedObjectContext) var viewContext
  
  var body: some View {
    VStack {
      List {
        Section(header: Text("Add new card")) {
          HStack {
            TextField("Prompt", text: $newPrompt)
            Text(":")
            TextField("Answer", text: $newAnswer)
          }
          Button("Add card", action: addCard)
        }
        Section() {
          NavigationLink("Import Text", destination: ImportTextView(deck: deck))
        }
        Section(header: Text("Added")) {
          ForEach(deck.cards.sorted()) { card in
            VStack(alignment: .leading) {
              Text(card.prompt)
                .font(.headline)
              Text(card.answer)
                .foregroundColor(.secondary)
            }
          }
          .onDelete(perform: removeCards)
        } //: Section
      } //: List
    }
    .navigationBarTitle(deck.name)
    .navigationBarItems(trailing: Button("Save", action: saveAndDismiss))
    .listStyle(GroupedListStyle())
  }

  func saveAndDismiss() {
    presentationMode.wrappedValue.dismiss()
  }
  
  func addCard() {
    let card = Card(uuid: UUID(), context: self.viewContext)
    card.prompt = newPrompt
    card.answer = newAnswer
    deck.cards.insert(card)
    try? self.viewContext.save()

    newPrompt = ""
    newAnswer = ""
  }

  func removeCards(at offsets: IndexSet) {
    let cards = Array(deck.cards)
    if let index = offsets.first {
      let card = cards[index]
      self.viewContext.delete(card)
      try? self.viewContext.save()
    }
  }
}

struct EditCardsView_Previews: PreviewProvider {
  static var previews: some View {
    EditCardsView(deck: Deck(context: PersistenceController.preview.container.viewContext))
      .previewLayout(.fixed(width: 644, height: 421))
  }
}
