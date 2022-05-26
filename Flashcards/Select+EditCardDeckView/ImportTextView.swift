import SwiftUI

struct ImportTextView: View {
  @ObservedObject var deck: Deck

  @State private var text = ""
  @State private var promptAndAnswers: [String] = []
  @State private var shapeText = false
  @State private var registerDeck = false

  @State private var prompt: [String] = []
  @State private var answer: [String] = []

  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    VStack {
      if shapeText {
        VStack(spacing: 10) {
          Button("Register Deck") {
            registerDeck = true
          }
          List {
            ForEach(0..<prompt.count) { index in
              HStack() {
                Text("prompt : " + prompt[index])
                  .frame(width: 300, alignment: .leading)
                Text("answer : " + answer[index])
                  .frame(width: 300, alignment: .leading)
              }
            }
          }
        }
        .padding()
      } else {
        VStack {
          Text("Currently \(deck.cards.count) Sets in this deck")
          TextEditor(text: $text)
            .modifier(TextInputExample())
            .keyboardType(.alphabet)
            .padding(.horizontal)
            .font(.subheadline)
            .frame(minWidth: 10, maxWidth: .infinity, minHeight: 10, maxHeight: 300, alignment: .topLeading)
            .border(Color.primary)
            .clipped()
        }
        .padding()
      }
    }
    .navigationTitle("Import Text")
    .navigationBarItems(
      trailing:
        Button("Create Sets from text") {
          UIApplication.shared.endEditing()
          if !text.isEmpty {
            getPromptAndAnswer()
          }
        }
        .disabled(shapeText)
    )
    .alert(isPresented: $registerDeck) {
      Alert(title: Text("Add this to \(deck.name)?"),
            primaryButton: .default(Text("Add"), action: {
        saveToCoreData()
        registerDeck = false
        presentationMode.wrappedValue.dismiss()
      }),
            secondaryButton: .cancel(Text("Cancel"), action: {
        registerDeck = false
      })
      )
    } //: End of Alert
  } //: End of VStack

  func getPromptAndAnswer() {
    promptAndAnswers = text.components(separatedBy: "\n")
    for elem in promptAndAnswers {
      let singlePromptAndAnswer = elem.components(separatedBy: ":")
      if singlePromptAndAnswer.count >= 2 {
        prompt.append(singlePromptAndAnswer[0])
        answer.append(singlePromptAndAnswer[1])
      }
    }
    shapeText = true
  }

  func saveToCoreData() {

    for i in 0..<prompt.count {
      let card = Card(uuid: UUID(), context: self.viewContext)
      card.prompt = prompt[i]
      card.answer = answer[i]
      deck.cards.insert(card)
    }
    
    try? viewContext.save()
  }
}

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

struct TextInputExample: ViewModifier {
  
  func body(content: Content) -> some View {
    VStack(alignment: .leading) {
      Text("Prompt:Answer")
        .foregroundColor(.gray)
      content
    }
    .padding(.top, 10)
  }
}

struct CreateDecksView_Previews: PreviewProvider {
  static var previews: some View {
    let deck = Deck(uuid: UUID(), context: PersistenceController.preview.container.viewContext)
    ZStack {
      Color.black
        .edgesIgnoringSafeArea(.all)
      ImportTextView(deck: deck)
        .environment(\.colorScheme, .dark)
    }
    .previewLayout(.fixed(width: 644, height: 421))
  }
}
