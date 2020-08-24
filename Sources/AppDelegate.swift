import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  private var apiMan: APIMan!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    window?.tintColor = .systemRed

    let mesh = MeshController()
    let nc = window?.rootViewController as? UINavigationController
    let vc = (nc?.topViewController ?? window?.rootViewController) as? ViewController
    vc?.uiHandler = mesh

    let wssURL = URL(string: "ws://0.0.0.0:80/ws_rpc?lat=53.904153&lon=27.556925")!
    let local = WebSocketConn(wss: wssURL)
    let _ = BtMan()

    apiMan = APIMan(meshController: mesh, localNetwork: local)
    mesh.api = apiMan
    local.api = apiMan

    return true
  }

}

let kThisDeviceName = UIDevice.current.name
