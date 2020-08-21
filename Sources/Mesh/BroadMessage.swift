import Foundation

struct BroadMessage: Equatable {

  let ti: Date
  let msg: String

  init(_ msg: String, _ ti: Date = Date()) {
    self.ti = ti
    self.msg = msg
  }

}
