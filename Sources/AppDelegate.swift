import UIKit

let uuidTakeLength = 5

var kThisDeviceName: String {
  _kThisDeviceName + uuidTake
}

/// keep the name unless the app is alive
private let _kThisDeviceName = UIDevice.current.name
private let uuidKey = "myuuid"
private var uuidTake = UserDefaults.standard.string(forKey: uuidKey) ?? ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  private var meshCon: MeshControllerJS!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let defaults = UserDefaults.standard

    if nil == defaults.string(forKey: uuidKey) {
      let uuid = UUID().uuidString
      let uuidTake = "-" + String(uuid.dropFirst(uuid.count + 1 - uuidTakeLength))

      defaults.setValue(uuidTake, forKey: uuidKey)
    }

    window?.tintColor = .systemRed

    let nc = window?.rootViewController as? UINavigationController
    let vc = (nc?.topViewController ?? window?.rootViewController) as? Ui

    meshCon = MeshControllerJS(frontendAPI: FrontendAPI(ui: vc))

    return true
  }

}
