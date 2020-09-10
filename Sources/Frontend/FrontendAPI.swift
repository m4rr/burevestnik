import Foundation
import JavaScriptCore

class FrontendAPI: NSObject, FrontendAPIProtocol, FrontendAPIExports {

  weak var ui: Ui?

  init(ui: Ui!) {
    assert(ui != nil)

    self.ui = ui
    super.init()
    ui?.uiProvider = self
  }

  //  private var conflictingShortNames: [String] = []

  private var data: [BroadMessage] = [] {
    didSet {
      DispatchQueue.main.async {
        self.ui?.reloadUI()
      }
    }
  }

  func userDataUpdateHandler(_ json: Any) {
//    parse_json(json)
    _userDataUpdateHandler.call(withArguments: [json])
  }

  private var _userDataUpdateHandler: JSValue!
  func registerUserDataUpdateHandler(_ f: JSValue) {
    _userDataUpdateHandler = f
  }

  func handleUpdate(_ json: JSValue!) {

    if let jsonObject = json?.toObject(),
       let jsonData = try? JSONSerialization
        .data(withJSONObject: jsonObject, options: []) ,
       let meshState = try? JSONDecoder()
        .decode(HandleUpdate.self, from: jsonData) {

      data = meshState
        .AllPeers
        .map(BroadMessage.from)
        .sorted { m1, m2 in
          m1.ti < m2.ti
        }
    }

    //    let cs = NSCountedSet(array: msgs.map { $0.simpleFrom })
    //    conflictingShortNames = cs
    //      .filter({ cs.count(for: $0) > 1 }) as? [String] ?? []

  }

}

// MARK: - UiProvider

extension FrontendAPI: UiDataProvider {

  func broadcastMessage(_ text: String) {
    userDataUpdateHandler(["Message": text])
  }

  var dataCount: Int {
    data.count
  }

  func dataAt(_ indexPath: IndexPath) -> BroadMessage {
    data[indexPath.row]
  }

  var numberOfPeers: Int {
    0
  }

  //  func isConflicting(_ name: String) -> Bool {
  //    conflictingShortNames.contains(name)
  //  }

}
