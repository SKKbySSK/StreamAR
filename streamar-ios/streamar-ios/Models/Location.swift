//
//  Location.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/15.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxDataSources
import FirebaseFirestore

struct LocationDocument: Codable {
  let anchorIds: [String]
  let latitude: Double
  let longitude: Double
  let zip: String
  let name: String
  let thumbnailUrl: String
}

struct Location: Identifiable, IdentifiableType, Equatable {
  typealias Identity = String
  
  init?(snapshot: DocumentSnapshot) {
    guard let data = try? snapshot.data(as: LocationDocument.self) else {
      return nil
    }
    
    self.init(id: snapshot.documentID, document: data)
  }
  
  init(id: String, document: LocationDocument) {
    self.id = id
    anchorIds = document.anchorIds
    latitude = document.latitude
    longitude = document.longitude
    zip = document.zip
    name = document.name
    thumbnailUrl = document.thumbnailUrl
  }
  
  var document: LocationDocument {
    return LocationDocument(anchorIds: anchorIds, latitude: latitude, longitude: longitude, zip: zip, name: name, thumbnailUrl: thumbnailUrl)
  }
  
  let id: String
  let anchorIds: [String]
  let latitude: Double
  let longitude: Double
  let zip: String
  let name: String
  let thumbnailUrl: String
  
  var identity: Identity {
    return id
  }
}
