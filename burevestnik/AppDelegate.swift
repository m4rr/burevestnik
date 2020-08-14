//
//  AppDelegate.swift
//  burevestnik
//
//  Created by Marat Saytakov on 12.08.2020.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  private var apiMan: APIMan!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    window?.tintColor = .systemRed

    let uiReloader = (window?.rootViewController as? ViewController)?.reloadUI
    let mesh = MeshController(reloadHandler: uiReloader)

    let wssURL = URL(string: "")!
    let local = WebSocketConn(wss: wssURL)

    apiMan = APIMan(meshController: mesh, localNetwork: local)

    mesh.api = apiMan
    local.api = apiMan

    return true
  }

}

