//
//  UserInfoClient.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2021/01/04.
//  Copyright © 2021 Kaisei Sunaga. All rights reserved.
//

import Foundation

import RxSwift
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

class UserInfoClient {
  static let shared = UserInfoClient()
  
  private let db = Firestore.firestore()
  private let storage = Storage.storage()
  private let disposeBag = DisposeBag()
  private var cachedUsers: [UserInfo] = []
  
  private init() {}
  
  func getUserInfo(id: String, useCache: Bool = true) -> Observable<UserInfo> {
    for user in cachedUsers {
      if id == user.id {
        return Observable.just(user)
      }
    }
    
    return Observable.create({ observer in
      self.db.collection("/users/v1/info").document(id).getDocument(completion: { snapshot, error in
        guard let snapshot = snapshot else {
          observer.onCompleted()
          return
        }
        
        guard let info = UserInfo(snapshot: snapshot) else {
          observer.onCompleted()
          return
        }
        
        self.cachedUsers.append(info)
        observer.onNext(info)
        observer.onCompleted()
      })
      
      return Disposables.create()
    })
  }
  
  func setUserInfo(id: String, document: UserInfoDocument) -> Observable<Void> {
    return Observable.create({ observer in
      try! self.db.collection("/users/v1/info").document(id).setData(from: document, encoder: Firestore.Encoder()) { error in
        observer.onCompleted()
      }
      return Disposables.create()
    })
  }
}
