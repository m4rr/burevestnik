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

  var discoveryInfo: [String: String] {
    let res = [
      ti.timeIntervalSinceReferenceDate.description: msg,
    ]
    assert(res.description.count <= 400)
    return res
  }

  init(_ msg: String, _ ti: Date = Date()) {
    self.ti = ti
    self.msg = msg
  }

  static func from(dic: [String: String]) -> [BroadMessage] {
    dic.map { ti, msg in
      let date = TimeInterval(ti).flatMap(Date.init(timeIntervalSinceReferenceDate:)) ?? Date()

      return BroadMessage(msg, date)
    }
  }

}
