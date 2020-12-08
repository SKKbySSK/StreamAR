//
//  RootNavigator.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit

class RootNavigator: UINavigationController {
  private let viewModel = AuthViewModel()
  
  static func create(viewController: UIViewController) -> RootNavigator {
    return RootNavigator(rootViewController: viewController)
  }
}
