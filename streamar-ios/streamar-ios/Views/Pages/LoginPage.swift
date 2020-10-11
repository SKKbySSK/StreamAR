//
//  LoginPage.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit

class LoginPage: UIViewController {
  @IBOutlet weak var loginViewContainer: UIView!
  
  static func create(mode: LoginMode) {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loginViewContainer.addFittedChild(LoginView.create(mode: <#T##LoginMode#>, loading: <#T##Observable<Bool>#>))
  }
}
