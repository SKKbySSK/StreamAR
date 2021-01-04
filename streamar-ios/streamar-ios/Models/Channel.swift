
import Foundation
import RxDataSources

struct Channel: Codable, IdentifiableType, Equatable {
  typealias Identity = String
  
  var id: String?
  let title: String
  let manifestUrl: String
  let location: String
  let anchorId: String
  let user: String
  let width: Double
  let height: Double
  
  var identity: String {
    return id ?? ""
  }
}
