//
//  LoginPageBuilder.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class LoginPageBuilder {
  static func buildModal(auth: AuthViewModel) -> UIViewController {
    let viewModel = LoginViewModel(client: auth.authClient)
    let vc = LoginPage.create(viewModel: viewModel)
    vc.isModalInPresentation = true
    
    return UINavigationController(rootViewController: vc)
  }
}
