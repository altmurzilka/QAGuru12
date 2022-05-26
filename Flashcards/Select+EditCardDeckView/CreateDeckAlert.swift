import SwiftUI

struct CreateDeckAlert: UIViewControllerRepresentable {
  
  @Environment(\.managedObjectContext) private var viewContext
  @State private var decKName: String = ""
  @Binding var isShowingAlert: Bool
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<CreateDeckAlert>) -> some UIViewController {
    return UIViewController()
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<CreateDeckAlert>) {
    
    guard context.coordinator.alert == nil else {
      return
    }
    
    if !isShowingAlert {
      return
    }
    
    let alert = UIAlertController(title: "Create new deck", message: nil, preferredStyle: .alert)
    context.coordinator.alert = alert
    
    alert.addTextField { textField in
      textField.placeholder = "Name this deck"
      textField.text = decKName
      textField.delegate = context.coordinator
    }
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
      alert.dismiss(animated: true) {
        isShowingAlert = false
      }
    })
    
    alert.addAction(UIAlertAction(title: "Create", style: .default) { _ in
      if let textField = alert.textFields?.first, let text = textField.text {
        self.decKName = text
      }
      alert.dismiss(animated: true) {
        save()
        isShowingAlert = false
      }
    })
    
    DispatchQueue.main.async {
      uiViewController.present(alert, animated: true, completion: {
        isShowingAlert = false
        context.coordinator.alert = nil
      })
    }
  }
  
  func makeCoordinator() -> CreateDeckAlert.Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UITextFieldDelegate {
    
    var alert: UIAlertController?
    var view: CreateDeckAlert
    
    init(_ view: CreateDeckAlert) {
      self.view = view
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      if let text = textField.text as NSString? {
        self.view.decKName = text.replacingCharacters(in: range, with: string)
      } else {
        self.view.decKName = ""
      }
      return true
    }
  }

  func save() {
    let coreDataDeck = Deck(uuid: UUID(), context: self.viewContext)
    coreDataDeck.name = decKName
    coreDataDeck.cards = []
    try? viewContext.save()
  }
}
