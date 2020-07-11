//
//  AuthorizationClient.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation

enum AuthorizationStatus {
  case authorizing
  case notAuthorized
  case authorized
}

protocol AuthorizationClient {
  var status: AuthorizationStatus { get }
  
  func initialize(callback: (AuthorizationStatus, Error?) -> Void)
  func signIn(email: String, password: String, callback: (AuthorizationStatus, Error?) -> Void)
  func signOut(callback: (AuthorizationStatus, Error?) -> Void)
}

class FirebaseAuthClient: AuthorizationClient {
  private(set) var status: AuthorizationStatus = .notAuthorized
  
  func initialize(callback: (AuthorizationStatus, Error?) -> Void) {
    status = .notAuthorized
  }
  
  func signIn(email: String, password: String, callback: (AuthorizationStatus, Error?) -> Void) {
    status = .authorizing
    callback(self.status, nil)
  }
  
  func signOut(callback: (AuthorizationStatus, Error?) -> Void) {
  }
}

class DummyAuthClient: AuthorizationClient {
  var status: AuthorizationStatus
  
  init(status: AuthorizationStatus) {
    self.status = status
  }
  
  func initialize(callback: (AuthorizationStatus, Error?) -> Void) {
    callback(status, nil)
  }
  
  func setStatus(status: AuthorizationStatus) -> DummyAuthClient {
    self.status = status
    return self
  }
  
  func signIn(email: String, password: String, callback: (AuthorizationStatus, Error?) -> Void) {
    callback(status, nil)
  }
  
  func signOut(callback: (AuthorizationStatus, Error?) -> Void) {
    callback(status, nil)
  }
}
