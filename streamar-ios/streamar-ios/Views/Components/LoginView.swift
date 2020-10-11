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

class LoginView: UIView {
  private let disposeBag = DisposeBag()
  private let authRelay = PublishRelay<AuthenticationRequest>()
  private var loading: Observable<Bool>! = nil {
    didSet {
      loading.subscribe({ [unowned self] ev in
        self.button?.isLoading = ev.element ?? false
      }).disposed(by: disposeBag)
    }
  }
  
  private var mode: LoginMode = .login {
    didSet {
      updateView()
    }
  }
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var button: LGButton?
  
  var authentication: Observable<AuthenticationRequest> {
    return authRelay.asObservable()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func create(mode: LoginMode, loading: Observable<Bool>) -> LoginView {
    let view: LoginView = ViewHelper.createView()
    view.mode = mode
    view.loading = loading
    
    return view
  }
  
  @IBAction func onButtonPressed(_ sender: Any) {
    let req = AuthenticationRequest(email: emailField.text ?? "", password: passwordField.text ?? "")
    authRelay.accept(req)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    updateView()
  }
  
  private func updateView() {
    switch mode {
    case .login:
      button?.titleString = "ログイン"
    case .register:
      button?.titleString = "登録"
    }
  }
}
