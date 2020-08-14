//
//  MeshController.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

class MeshController {

  var reloadHandler: () -> Void

  var storage = [BroadMessage]()

  var api: API 

  init(reloadHandler: @escaping () -> Void) {

    self.reloadHandler = reloadHandler

    api = SimulationAPI()
  }

}
