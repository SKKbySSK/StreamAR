//
//  RootPageBuilder.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import RxSwift

class RootPageBuilder {
  static let disposeBag = DisposeBag()
  static let auth = AuthViewModel()
  static var displayingLoginPage = false
  
  static func build() -> RootNavigator {
    let home = HomePageBuilder.build(auth: auth)
    let root = RootNavigator.create(viewController: home)
    root.navigationBar.prefersLargeTitles = true
    
    auth.authClient.status.subscribe({ ev in
      guard let status = ev.element else { return }
      guard status != .success else { return }
      self.presentLoginPage(home: home)
    }).disposed(by: disposeBag)
    
    return root
  }
  
  private static func presentLoginPage(home: UIViewController) {
    displayingLoginPage = true
    let login = LoginPageBuilder.buildModal(auth: auth)
    
    auth.authClient.status.subscribe({ ev in
      guard let status = ev.element else { return }
      guard status == .success else { return }
      login.dismiss(animated: true, completion: nil)
    }).disposed(by: disposeBag)
    
    home.present(login, animated: true, completion: nil)
  }
}
