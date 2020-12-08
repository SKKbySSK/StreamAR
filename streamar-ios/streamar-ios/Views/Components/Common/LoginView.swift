//
//  LoginView.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import LGButton

enum LoginMode {
  case register
  case login
}

class LoginView: UIView, UITextFieldDelegate {
  private let disposeBag = DisposeBag()
  private let authRelay = PublishRelay<AuthenticationRequest>()
  private let tapRegisterRelay = PublishRelay<Void>()
  private var loading: Observable<Bool>! = nil {
    didSet {
      loading.subscribe({ [unowned self] ev in
        let loading = ev.element ?? false
        self.button?.isLoading = loading
        self.emailField?.isEnabled = !loading
        self.passwordField?.isEnabled = !loading
      }).disposed(by: disposeBag)
    }
  }
  
  var mode: LoginMode = .login {
    didSet {
      updateView()
    }
  }
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var button: LGButton?
  @IBOutlet weak var registerButton: UIButton!
  
  var authentication: Observable<AuthenticationRequest> {
    return authRelay.asObservable()
  }
  
  var onTapRegister: Observable<Void> {
    return tapRegisterRelay.asObservable()
  }
  
  static func create(mode: LoginMode, loading: Observable<Bool>) -> LoginView {
    let view: LoginView = ViewHelper.createView()
    view.mode = mode
    view.loading = loading
    
    return view
  }
  
  @IBAction func onButtonPressed(_ sender: Any) {
    acceptAuth()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    emailField.delegate = self
    passwordField.delegate = self
    
    registerButton.rx.tap.subscribe({ [weak self] e in
      self?.tapRegisterRelay.accept(Void())
    }).disposed(by: disposeBag)
    
    updateView()
  }
  
  private func updateView() {
    switch mode {
    case .login:
      registerButton?.isHidden = false
      button?.titleString = "ログイン"
    case .register:
      registerButton?.isHidden = true
      button?.titleString = "登録"
    }
  }
  
  private func acceptAuth() {
    let req = AuthenticationRequest(email: emailField.text ?? "", password: passwordField.text ?? "")
    authRelay.accept(req)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailField {
      passwordField.becomeFirstResponder()
    } else {
      acceptAuth()
      passwordField.resignFirstResponder()
    }
    
    return true
  }
}
