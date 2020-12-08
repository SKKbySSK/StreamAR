//
//  TabbedPages.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/10/11.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit

class TabPage {
  let viewController: UIViewController
  
  init(viewController: UIViewController) {
    self.viewController = viewController
  }
}

class TabbedPages: UIViewController {
  static func create(pages: [TabPage]) {
    
  }
}
