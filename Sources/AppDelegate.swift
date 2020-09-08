import UIKit

/// keep the name unless the app is alive
let kThisDeviceName = UIDevice.current.name

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  private lazy var meshCon = MeshControllerJS()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    window?.tintColor = .systemRed

    let nc = window?.rootViewController as? UINavigationController
    let vc = (nc?.topViewController ?? window?.rootViewController) as? ViewController

    vc?.uiHandler = meshCon
    
    return true
  }

}
