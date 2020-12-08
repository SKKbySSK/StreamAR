//
//  BroadcastPageBuilder.swift
//  streamar-ios
//
//  Created by Kaisei Sunaga on 2020/11/12.
//  Copyright © 2020 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit

class BroadcastPageBuilder {
  static func build() -> UIViewController {
    let nav = BroadcastPage()
    nav.modalPresentationStyle = .fullScreen
    
    return nav
  }
}
