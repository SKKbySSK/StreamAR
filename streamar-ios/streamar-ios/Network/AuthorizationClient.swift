//
//  AuthorizationClient.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import FirebaseAuth

enum AuthorizationStatus {
  case authorizing
  case notAuthorized
  case authorized
}

protocol AuthorizationClient {
  var status: AuthorizationStatus { get }
  var user: UserAccount? { get }
  var callback: ((AuthorizationStatus, Error?) -> Void)? { get set }
  
  func initialize()
  func register(email: String, password: String)
  func signIn(email: String, password: String)
  func signOut()
}

class FirebaseAuthClient: AuthorizationClient {
  private(set) var status: AuthorizationStatus = .notAuthorized
  private(set) var user: UserAccount?
  var callback: ((AuthorizationStatus, Error?) -> Void)?
  
  func initialize() {
    status = .authorizing
    
    let auth = Auth.auth()
    
    if let user = auth.currentUser {
      status = .authorized
      self.user = FirebaseUserAccount(user: user)
    } else {
      status = .notAuthorized
      self.user = nil
    }
    
    callback?(status, nil)
    
    auth.addStateDidChangeListener({ [weak self] auth, user in
      guard let this = self else { return }

      if let user = user {
        this.status = .authorized
        this.user = FirebaseUserAccount(user: user)
      } else {
        this.status = .notAuthorized
        this.user = nil
      }
      
      this.callback?(this.status, nil)
    })
  }
  
  func signIn(email: String, password: String) {
    status = .authorizing
    callback?(status, nil)

    Auth.auth().signIn(withEmail: email, password: password, completion: signInCallback(result:error:))
  }
  
  func signOut() {
    do {
      try Auth.auth().signOut()
      status = .notAuthorized
      callback?(status, nil)
    } catch {
      callback?(status, error)
    }
  }
  
  func register(email: String, password: String) {
    status = .authorizing
    callback?(status, nil)

    Auth.auth().createUser(withEmail: email, password: password, completion: signInCallback(result:error:))
  }
  
  private func signInCallback(result: AuthDataResult?, error: Error?) {
    guard let result = result else {
      status = .notAuthorized
      user = nil
      callback?(status, error)
      return
    }
    
    user = FirebaseUserAccount(user: result.user)
    status = .notAuthorized
    callback?(status, error)
  }
}

class DummyAuthClient: AuthorizationClient {
  var user: UserAccount?
  var status: AuthorizationStatus
  var callback: ((AuthorizationStatus, Error?) -> Void)?
  
  init(status: AuthorizationStatus) {
    self.status = status
  }
  
  func initialize() {
  }
  
  func register(email: String, password: String) {
  }
  
  func signIn(email: String, password: String) {
  }
  
  func signOut() {
  }
}
