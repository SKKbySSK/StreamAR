//
//  LoginPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import KeyboardGuide

class LoginPage: BindablePage {
  private var loginView: LoginView! = nil
  private var viewModel: LoginViewModel! = nil
  
  static func create(viewModel: LoginViewModel) -> LoginPage {
    return create(mode: .login, viewModel: viewModel)
  }
  
  private static func create(mode: LoginMode, viewModel: LoginViewModel) -> LoginPage {
    let vc: LoginPage = ViewHelper.createViewController()
    vc.loginView = LoginView.create(mode: mode, loading: viewModel.processing)
    vc.viewModel = viewModel
    
    return vc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    switch loginView.mode {
    case .login:
      navigationItem.title = "ログイン"
    case .register:
      navigationItem.title = "会員登録"
    }
    
    navigationItem.largeTitleDisplayMode = .always
    navigationController?.navigationBar.prefersLargeTitles = true
    
    view.addFittedChild(loginView, keyboard: true)
    
    loginView.authentication.subscribe({ [unowned self] e in
      guard let auth = e.element else { return }
      switch(self.loginView.mode) {
      case .login:
        self.viewModel.login(request: auth)
      case .register:
        self.viewModel.register(request: auth)
      }
    }).disposed(by: disposeBag)
    
    loginView.onTapRegister.subscribe({ [unowned self] _ in
      let vc = LoginPage.create(mode: .register, viewModel: viewModel)
      self.navigationController?.pushViewController(vc, animated: true)
    }).disposed(by: disposeBag)
  }
}
