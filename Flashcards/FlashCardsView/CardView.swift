import SwiftUI

struct CardView: View {
  @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
  @Environment(\.accessibilityEnabled) var accessibilityEnabled
  
  @State private var isShowingAnswer = false
  @State private var offset = CGSize.zero
  @State private var feedback = UINotificationFeedbackGenerator()
  
  @Binding var orientation: UIDeviceOrientation
  let card: Card
  var removal: ((Bool) -> Void)? = nil

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 25, style: .continuous)
        .fill(
          differentiateWithoutColor
            ? Color.white
            : Color.white
            .opacity(1 - Double(abs(offset.width / 50)))
        )
        .background(
          differentiateWithoutColor
            ? nil
            : RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(offset.width > 0 ? Color.green : Color.red)
        )
        .shadow(radius: 10)
      
      VStack {
        if accessibilityEnabled {
          Text(isShowingAnswer ? card.answer : card.prompt)
            .font(.largeTitle)
            .foregroundColor(.black)
        } else {
          Text(card.prompt)
            .font(.largeTitle)
            .foregroundColor(.black)
          
          if isShowingAnswer {
            Text(card.answer)
              .font(.title)
              .foregroundColor(.gray)
          }
        }
      }
      .padding(20)
      .multilineTextAlignment(.center)
    }
    .frame(width: flexibleFrame.width, height: flexibleFrame.height)
    .rotationEffect(.degrees(Double(offset.width / 5)))
    .offset(x: offset.width * 5, y: 0)
    .accessibility(addTraits: .isButton)
    .gesture(
      DragGesture()
        .onChanged { offset in
          self.offset = offset.translation
          self.feedback.prepare()
        }
        
        .onEnded { _ in
          if abs(self.offset.width) > 100 {
            var answerCorrect = false
            if self.offset.width > 0 {
              answerCorrect = true
              self.feedback.notificationOccurred(.success)
            } else {
              answerCorrect = false
              self.feedback.notificationOccurred(.error)
            }
            
            self.removal?(answerCorrect)
          } else {
            self.offset = .zero
          }
        }
    )
    .animation(.spring())
    .onTapGesture {
      self.isShowingAnswer.toggle()
    }
  }

  var flexibleFrame: (width: CGFloat, height: CGFloat) {
    if !orientation.isLandscape {
      return (width: 300, height: 350)
    } else {
      return (width: 450, height: 250)
    }
  }
}
