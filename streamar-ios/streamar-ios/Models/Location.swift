//
//  Location.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/09/15.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation

struct LocationDocument: Codable {
  let anchorId: String
  let latitude: Double
  let longitude: Double
  let zip: String
  let name: String
}

struct Location: Identifiable, Equatable {
  init(id: String, document: LocationDocument) {
    self.id = id
    anchorId = document.anchorId
    latitude = document.latitude
    longitude = document.longitude
    zip = document.zip
    name = document.name
  }
  
  var document: LocationDocument {
    return LocationDocument(anchorId: anchorId, latitude: latitude, longitude: longitude, zip: zip, name: name)
  }
  
  let id: String
  let anchorId: String
  let latitude: Double
  let longitude: Double
  let zip: String
  let name: String
}
