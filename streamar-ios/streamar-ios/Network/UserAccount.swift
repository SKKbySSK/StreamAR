//
// Created by Kaisei Sunaga on 2020/07/11.
// Copyright (c) 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

protocol UserAccount {
  var id: String { get }
}

class FirebaseUserAccount: UserAccount {
  private(set) var id: String

  init(user: User) {
    self.id = user.uid
  }
}