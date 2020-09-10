import Foundation
import JavaScriptCore

@objc protocol FrontendAPIExports: JSExport {

  // MARK: - Funcs

  /// to update ui
  func handleUpdate(_ json: JSValue!)

  // MARK: - Callbacks (recieves a function that cannot be expressed with Swift)

  func registerUserDataUpdateHandler(_ f: JSValue) // f: (json) -> Void

}

protocol FrontendAPIProtocol {

  var ui: Ui? { get } // weak

  /// to send a message
  func userDataUpdateHandler(_ json: Any)

}
