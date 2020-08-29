import UIKit

// keep the name unless the app is alive
let kThisDeviceName = UIDevice.current.name

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  private var apiMan: APIMan!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    window?.tintColor = .systemRed

    let mesh = MeshController()

//    let wssURL = URL(string: "ws://burevestnik.means.live:8887/ws_rpc?lat=53.904153&lon=27.556925")!
//    let local = WebSocketConn(wss: wssURL)
    let local = BtMan()

    let nc = window?.rootViewController as? UINavigationController
    let vc = (nc?.topViewController ?? window?.rootViewController) as? ViewController
    vc?.uiHandler = mesh

    apiMan = APIMan(meshController: mesh, localNetwork: local)
    mesh.api = apiMan
    local.api = apiMan // starts multipeer session when assigned

    return true
  }

}
