//
//  BroadMessage.swift
//  burevestnik
//
//  Created by Marat Saytakov on 12.08.2020.
//

import Foundation

struct BroadMessage: Equatable {

  let ti: Date
  let msg: String

  init(_ msg: String, _ ti: Date = Date()) {
    self.ti = ti
    self.msg = msg
  }

}
