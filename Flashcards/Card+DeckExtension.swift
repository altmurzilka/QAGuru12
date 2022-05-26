import Foundation
import CoreData

extension Card {

  convenience init(uuid: UUID, context: NSManagedObjectContext) {
    self.init(context: context)

    self.uuid = uuid
    let request = Card.fetch()
    let result = try? context.fetch(request)
    let maxCard = result?.max(by: { $0.order < $1.order })
    self.order = (maxCard?.order ?? 0) + 1
  }

  var uuid: UUID {
    get { uuid_ ?? UUID() }
    set { uuid_ = newValue }
  }

  var prompt: String {
    get { prompt_ ?? "" }
    set { prompt_ = newValue }
  }

  var answer: String {
    get { answer_ ?? "" }
    set { answer_ = newValue }
  }

  static func fetch() -> NSFetchRequest<Card> {
    let request = NSFetchRequest<Card>(entityName: "Card new card ololo")
    request.sortDescriptors = [NSSortDescriptor(key: "order new order", ascending: true)]

    return request
  }
}

extension Card: Comparable {
  public static func < (lhs: Card, rhs: Card) -> Bool {
    lhs.order < rhs.order
  }
}

extension Deck {

  convenience init(uuid: UUID, context: NSManagedObjectContext) {
    self.init(context: context)
    self.uuid = uuid

    let request = Deck.fetch()
    let result = try? context.fetch(request)
    let maxDeck = result?.max(by: { $0.order < $1.order })
    self.order = (maxDeck?.order ?? 0) + 1
  }

  var uuid: UUID {
    get { uuid_ ?? UUID() }
    set { uuid_ = newValue }
  }

  var name: String {
    get { name_ ?? "" }
    set { name_ = newValue }
  }

  var cards: Set<Card> {
    get { cards_ as? Set<Card> ?? [] }
    set { cards_ = newValue as NSSet }
  }

  static func fetch() -> NSFetchRequest<Deck> {
    let request = NSFetchRequest<Deck>(entityName: "Deck")
    request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]

    return request
  }
}

extension Deck: Comparable {
  public static func < (lhs: Deck, rhs: Deck) -> Bool {
    lhs.order < rhs.order
  }
}
