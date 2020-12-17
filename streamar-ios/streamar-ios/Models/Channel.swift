
import Foundation

struct Channel: Codable {
  var id: String?
  let title: String
  let manifestUrl: String
  let location: String
  let anchorId: String
}
