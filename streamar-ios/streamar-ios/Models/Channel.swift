// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let channel = try Channel(json)

import Foundation

// MARK: - Channel
struct Channel: Codable {
  let channelID, title: String
  let manifestURL: String
  
  enum CodingKeys: String, CodingKey {
    case channelID = "channelId"
    case title
    case manifestURL = "manifestUrl"
  }
}

// MARK: Channel convenience initializers and mutators

extension Channel {
  init(data: Data) throws {
    self = try newJSONDecoder().decode(Channel.self, from: data)
  }
  
  init(_ json: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = json.data(using: encoding) else {
      throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
    }
    try self.init(data: data)
  }
  
  init(fromURL url: URL) throws {
    try self.init(data: try Data(contentsOf: url))
  }
  
  func with(
    channelID: String? = nil,
    title: String? = nil,
    manifestURL: String? = nil
  ) -> Channel {
    return Channel(
      channelID: channelID ?? self.channelID,
      title: title ?? self.title,
      manifestURL: manifestURL ?? self.manifestURL
    )
  }
  
  func jsonData() throws -> Data {
    return try newJSONEncoder().encode(self)
  }
  
  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    return String(data: try self.jsonData(), encoding: encoding)
  }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
  let decoder = JSONDecoder()
  if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
    decoder.dateDecodingStrategy = .iso8601
  }
  return decoder
}

func newJSONEncoder() -> JSONEncoder {
  let encoder = JSONEncoder()
  if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
    encoder.dateEncodingStrategy = .iso8601
  }
  return encoder
}
