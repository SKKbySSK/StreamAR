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
    
    self.client.callback = { status, error in
      self.status = status
      
      guard let error = error else { return }
      print(error.localizedDescription)
    }
    self.client.initialize()
  }
  
  convenience init() {
    self.init(client: FirebaseAuthClient())
  }
  
  func signIn(email: String, password: String) {
    client.signIn(email: email, password: password)
  }
  
  func register(email: String, password: String) {
    client.register(email: email, password: password)
  }
  
  func signOut() {
    client.signOut()
  }
  
  private var client: AuthorizationClient
  @Published var status: AuthorizationStatus
}
