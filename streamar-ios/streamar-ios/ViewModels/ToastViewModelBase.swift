//
//  ToastViewModelBase.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/15.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum ToastLevel {
  case info
  case error
}

struct ToastConfig {
  let duration: TimeInterval
  let title: String?
  let text: String
  let level: ToastLevel
}

class ToastViewModelBase: ViewModelBase {
  private let toastRelay = PublishRelay<ToastConfig>()
  
  override init() {
    super.init()
  }
  
  var toast: Observable<ToastConfig> {
    return toastRelay.asObservable()
  }
  
  func showToast(text: String, title: String? = nil, duration: TimeInterval = .infinity, level: ToastLevel = .info) {
    toastRelay.accept(ToastConfig(duration: duration, title: title, text: text, level: level))
  }
}
