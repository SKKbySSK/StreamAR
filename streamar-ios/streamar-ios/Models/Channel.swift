
import Foundation
import RxDataSources
import FirebaseFirestore

struct Channel: Equatable, IdentifiableType, Codable {
  static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Channel? {
    return try? snapshot.data(as: Channel.self)
  }
  
  var id: String!
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

extension Channel {
  var absoluteManifestUrl: URL {
    if manifestUrl.starts(with: "http") {
      return URL(string: manifestUrl)!
    }
    
    let url = URL(string: manifestUrl, relativeTo: URL(string: ChannelClient.multiplexServerEndpoint))!
    return url
  }
}
