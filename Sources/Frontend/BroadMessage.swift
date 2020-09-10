import Foundation

typealias NetworkMessage = String
typealias NetworkID = String
typealias NetworkTime = Int

@available(iOS 13.0, *)
private let relativeDateFormatter = RelativeDateTimeFormatter()

struct DataMessage: Codable {
  let Message: NetworkMessage
}

struct HandleUpdate: Codable {

  var ThisPeer: TsData?,
      AllPeers: [NetworkID: TsData]

  struct TsData: Codable {

    let TS: NetworkTime
    let Data: DataMessage

  }
}

struct BroadMessage: Equatable {

  let ti: NetworkTime
  let msg: NetworkMessage
  let from: NetworkID

  var simpleFrom: String {
    deviceNameRemovingUUID(from)
  }

  var simpleDate: String {
    let messageDate = Date(timeIntervalSinceReferenceDate: TimeInterval(ti) / 1000)

    if #available(iOS 13.0, *) {
      relativeDateFormatter.dateTimeStyle = .named

      return relativeDateFormatter.localizedString(for: messageDate, relativeTo: Date())
    }

    // fallback formatter
    return DateFormatter.localizedString(from: messageDate, dateStyle: .medium, timeStyle: .medium)
  }

  static func from(_ tsdatas: (key: NetworkID, val: HandleUpdate.TsData)) -> Self {
    return BroadMessage(ti: tsdatas.val.TS,
                        msg: tsdatas.val.Data.Message,
                        from: tsdatas.key)
  }

  private func deviceNameRemovingUUID(_ name: String) -> String {
    String(name.dropLast(uuidTakeLength))
  }

}
