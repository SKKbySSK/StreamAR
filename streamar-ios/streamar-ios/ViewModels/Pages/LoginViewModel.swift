//
//  LoginViewModel.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: ViewModelBase {
  private let processingRelay = BehaviorRelay<Bool>(value: false)
  private let acceptedRelay = BehaviorRelay<Bool>(value: false)
  private let client: FirebaseAuthClient
  
  init(client: FirebaseAuthClient) {
    self.client = client
    super.init()
    
    client.status.subscribe({ [weak self] e in
      guard let status = e.element else { return }
      switch(status) {
      case .success:
        self?.processingRelay.accept(false)
        self?.acceptedRelay.accept(true)
      case .none:
        self?.processingRelay.accept(false)
      case .processing:
        self?.processingRelay.accept(true)
      }
    }).disposed(by: disposeBag)
  }
  
  var accepted: Observable<Bool> {
    return acceptedRelay.asObservable().distinctUntilChanged()
  }
  
  var processing: Observable<Bool> {
    return processingRelay.asObservable()
  }
  
  func login(request: AuthenticationRequest) {
    if processingRelay.value {
      return
    }
    
    client.signIn(email: request.email, password: request.password)
  }
  
  func register(request: AuthenticationRequest) {
    if processingRelay.value {
      return
    }
    
    client.register(email: request.email, password: request.password)
  }
}
