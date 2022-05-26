import SwiftUI
import CoreHaptics

struct FlashCardsView: View {
  @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
  @Environment(\.accessibilityEnabled) var accessibilityEnabled
  
  @Binding var cards: [Card]
  @Binding var showContentView: Bool
  @State private var cardsForRestart: [Card] = []
  @State private var numberOfCards = 0
  @State private var isActive = true
  
  @State private var correctAnswerCount: Int = 0
  @State private var orientation = UIDevice.current.orientation
  
  @Environment(\.managedObjectContext) private var viewContext
  
  let backgroundImage = "background\(Int.random(in: 1...10))"
  
  var body: some View {
    ZStack {
      Image(decorative: backgroundImage)
        .resizable()
        .scaledToFill()
        .edgesIgnoringSafeArea(.all)
      
      VStack(alignment: .center) {
        if !orientation.isLandscape {
          PortraitSetup(showContentView: $showContentView, showCardRemainings: showCardRemainings)
        } else {
          LandScapeSetup(showContentView: $showContentView, showCardRemainings: showCardRemainings)
        }

        ZStack {
          ForEach(0..<cards.count, id: \.self) { index in
            CardView(orientation: $orientation, card: self.cards[index]) { answerCorrect in
              if answerCorrect {
                correctAnswerCount += 1
              }
              withAnimation {
                self.removeCard(at: index)
              }
            }
            .stacked(at: index, in: self.cards.count)
            .allowsHitTesting(index == self.cards.count - 1)
            .accessibility(hidden: index < self.cards.count - 1)
          }
        }
        .allowsHitTesting(cards.count > 0)
        
        if cards.isEmpty {
          Button("Restart?", action: {
            cards = cardsForRestart
            resetCards()
          })
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .clipShape(Capsule())
        }
        Spacer()
      } //: VStack
      .frame(width: flexibleFrame.width, height: flexibleFrame.height)
      if differentiateWithoutColor || accessibilityEnabled {
        AccessibilityView() {
          self.removeCard(at: self.cards.count - 1)
        }
      } //: differntiateWithoutColor
    } //: ZStack
    .onAppear(perform: resetCards)
    .onRotate { newOrientation in
      if !newOrientation.isFlat {
        orientation = newOrientation
      }
    }
  }

  var flexibleFrame: (width: CGFloat, height: CGFloat) {
    if !orientation.isLandscape {
      return (width: 400.0, height: 600.0)
    } else {
      return (width: 600.0, height: 350.0)
    }
  }

  var showCardRemainings: String {
    if cards.count != 0 {
      return "\(cards.count) / \(numberOfCards)"
    } else {
      return "Correct \(correctAnswerCount) out of \(numberOfCards)"
    }
  }

  func resetCards() {
    correctAnswerCount = 0
    numberOfCards = cards.count
    cardsForRestart = cards
    isActive = true
  }
  
  func removeCard(at index: Int) {
    guard index >= 0 else { return }
    
    cards.remove(at: index)
    if cards.isEmpty {
      isActive = false
    }
  }
}

extension View {
  func stacked(at position: Int, in total: Int) -> some View {
    let offset = CGFloat(total - position)
    return self.offset(CGSize(width: 0, height: offset * 10))
  }
}



struct PortraitSetup: View {

  @Binding var showContentView: Bool
  let showCardRemainings: String

  var body: some View {
    Group {
      HStack {
        Button(action: {
          self.showContentView = false
        }) {
          Image(systemName: "pencil.circle")
            .padding()
            .background(Color.black.opacity(0.7))
            .clipShape(Circle())
        }
        .foregroundColor(.white)
        .font(.largeTitle)
        Spacer()
      }
      .padding(.leading, 20)
      
      Text(showCardRemainings)
        .font(.largeTitle)
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(
          Capsule()
            .fill(Color.black)
            .opacity(0.75)
        )
    }
  }
}

struct LandScapeSetup: View {

  @Binding var showContentView: Bool
  let showCardRemainings: String

  var body: some View {
    HStack {
      Button(action: {
        self.showContentView = false
      }) {
        Image(systemName: "pencil.circle")
          .padding()
          .background(Color.black.opacity(0.7))
          .clipShape(Circle())
      }
      .foregroundColor(.white)
      .font(.largeTitle)
      Spacer()

      Text(showCardRemainings)
        .font(.largeTitle)
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(
          Capsule()
            .fill(Color.black)
            .opacity(0.75)
        )
        .offset(x: -30.0, y: 0.0)
      Spacer()
    }
    .padding(.top, 20)
  }
}

struct AccessibilityView: View {
  var removeCard: () -> Void

  var body: some View {
    VStack {
      Spacer()
      
      HStack {
        Button(action: {
          withAnimation {
            removeCard()
          }
        }) {
          Image(systemName: "xmark.circle")
            .padding()
            .background(Color.black.opacity(0.7))
            .clipShape(Circle())
        }
        .accessibility(label: Text("Wrong"))
        .accessibility(hint: Text("Mark your answer as being incorrect."))
        Spacer()
        
        Button(action: {
          withAnimation {
            removeCard()
          }
        }) {
          Image(systemName: "checkmark.circle")
            .padding()
            .background(Color.black.opacity(0.7))
            .clipShape(Circle())
        }
        .accessibility(label: Text("Correct"))
        .accessibility(hint: Text("Mark your answer as being correct."))
      }
      .foregroundColor(.white)
      .font(.largeTitle)
      .padding()
    }
  }
}
