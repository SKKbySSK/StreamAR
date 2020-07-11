//
//  Authorization.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation

class Authorization: ObservableObject {
  init(client: AuthorizationClient) {
    self.client = client
    
    status = client.status
    
    client.initialize(callback: { status, error  in
      self.status = status
    })
  }
  
  convenience init() {
    self.init(client: FirebaseAuthClient())
  }
  
  func signIn(email: String, password: String) {
    client.signIn(email: email, password: password, callback: { status, error in
      self.status = status
    })
  }
  
  func signOut() {
    client.signOut(callback: { status, error in
      self.status = status
    })
  }
  
  private let client: AuthorizationClient
  @Published var status: AuthorizationStatus
}
