//
//  AuthorizationClient.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/07/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa

enum AuthenticationStatus {
  case success
  case processing
  case none
}

class FirebaseAuthClient {
  private let statusRelay = BehaviorRelay(value: AuthenticationStatus.none)
  private let userRelay = BehaviorRelay<UserAccount?>(value: nil)
  
  var status: Observable<AuthenticationStatus> {
    return statusRelay.asObservable()
  }
  
  var user: Observable<UserAccount?> {
    return userRelay.asObservable()
  }
  
  init() {
    statusRelay.accept(.processing)
    
    let auth = Auth.auth()
    
    if let user = auth.currentUser {
      statusRelay.accept(.success)
      userRelay.accept(FirebaseUserAccount(user: user))
    } else {
      statusRelay.accept(.none)
    }
    
    auth.addStateDidChangeListener({ [weak self] auth, user in
      guard let this = self else { return }

      if let user = user {
        this.statusRelay.accept(.success)
        this.userRelay.accept(FirebaseUserAccount(user: user))
      } else {
        this.statusRelay.accept(.none)
      }
    })
  }
  
  func signIn(email: String, password: String) {
    statusRelay.accept(.processing)
    userRelay.accept(nil)
    Auth.auth().signIn(withEmail: email, password: password, completion: signInCallback(result:error:))
  }
  
  func signOut() {
    do {
      try Auth.auth().signOut()
      statusRelay.accept(.none)
      userRelay.accept(nil)
    } catch let error {
      print(error)
    }
  }
  
  func register(email: String, password: String) {
    Auth.auth().createUser(withEmail: email, password: password, completion: signInCallback(result:error:))
  }
  
  private func signInCallback(result: AuthDataResult?, error: Error?) {
    guard let result = result else {
      statusRelay.accept(.none)
      userRelay.accept(nil)
      
      if let error = error {
        print(error)
      }
      return
    }
    
    statusRelay.accept(.success)
    userRelay.accept(FirebaseUserAccount(user: result.user))
  }
}
