//
//  BindablePage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Toast

class BindablePage: UIViewController {
  let disposeBag = DisposeBag()
  
  func subscribeToast(viewModel: ToastViewModelBase) {
    viewModel.toast.subscribe({ [weak self] ev in
      guard let config = ev.element, let this = self else { return }
      
      switch config.level {
      case .info:
        this.view.makeToast(config.text, duration: config.duration, position: .bottom, title: config.title, image: nil, style: ToastStyle(), completion: nil)
      case .error:
        var style = ToastStyle()
        style.backgroundColor = UIColor.systemRed
        this.view.makeToast(config.text, duration: config.duration, position: .bottom, title: config.title, image: nil, style: style, completion: nil)
      }
    }).disposed(by: disposeBag)
  }
}
