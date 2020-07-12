//
//  MainViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation

class LoginViewModel: ObservableObject {
  private let auth: Authorization
  
  @Published var email: String = ""
  @Published var password: String = ""
  
  init(auth: Authorization) {
    self.auth = auth
  }
  
  func signIn() {
    auth.signIn(email: email, password: password)
  }
  
  func register() {
    auth.register(email: email, password: password)
  }
}
