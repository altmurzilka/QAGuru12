import SwiftUI
import Lottie


struct SplashScreen: View {
    @State var show = false
    var body: some View {
        ZStack {
            Color("bg").ignoresSafeArea()
            AnimatedView(show: $show)
        }
    }
}


// animated View

struct AnimatedView: UIViewRepresentable {
    @Binding var show: Bool
    
    func makeUIView(context: Context) -> AnimationView {
        
        let view = AnimationView(name: "splash", bundle: Bundle.main)
        view.play{ (status) in
            if status {
                withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.8)){
                    show.toggle()
                }
            }
        }
        return view
    }
    
    
    func updateUIView(_ uiView: AnimationView, context: Context) {
        
    }
}
