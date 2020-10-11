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
  private let processingRelay = PublishRelay<Bool>()
  
  var processing: Observable<Bool> {
    return processingRelay.asObservable()
  }
}
