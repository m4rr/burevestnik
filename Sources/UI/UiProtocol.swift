import Foundation

protocol Ui: class {

  func reloadUI()

  var uiProvider: UiDataProvider? { get set } // weak

}

protocol UiDataProvider: class {

  func broadcastMessage(_ text: String)

  var dataCount: Int { get }
  func dataAt(_ indexPath: IndexPath) -> BroadMessage

  var numberOfPeers: Int { get }

  //  func isConflicting(_ name: String) -> Bool

}
