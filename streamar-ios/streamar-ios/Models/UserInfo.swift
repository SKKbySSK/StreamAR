//
//  UserInfo.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2021/01/04.
//  Copyright © 2021 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxDataSources
import FirebaseFirestore

struct UserInfo: Identifiable, IdentifiableType, Equatable {
  typealias Identity = String
  
  init(id: String, document: UserInfoDocument) {
    self.id = id
    self.name = document.name
    self.thumbnail = document.thumbnail
    self.permission = document.permission
  }
  
  init?(snapshot: DocumentSnapshot) {
    guard let data = try? snapshot.data(as: UserInfoDocument.self) else {
      return nil
    }
    
    self.init(id: snapshot.documentID, document: data)
  }
  
  let id: String
  let name: String
  let thumbnail: String?
  let permission: String
  
  var identity: String {
    return id
  }
}

class UserInfoDocument: Codable {
  init(name: String, thumbnail: String?, permission: String) {
    self.name = name
    self.thumbnail = thumbnail
    self.permission = permission
  }
  
  let name: String
  let thumbnail: String?
  let permission: String
}

extension UserInfo {
  var isAdmin: Bool {
    return permission == "admin"
  }
  
  var isEditor: Bool {
    return permission == "editor"
  }
  
  var isViewer: Bool {
    return permission == "viewer"
  }
}
